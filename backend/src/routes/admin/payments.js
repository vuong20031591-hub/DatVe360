const express = require('express');
const router = express.Router();
const Payment = require('../../models/Payment');
const Booking = require('../../models/Booking');
const AuthMiddleware = require('../../middleware/auth');
const asyncHandler = require('../../utils/asyncHandler');

// Apply authentication and authorization middleware
router.use(AuthMiddleware.authenticate);
router.use(AuthMiddleware.authorize('admin', 'operator'));

// @route   GET /api/v1/admin/payments
// @desc    Get all payments with filters
// @access  Private (Admin, Operator)
router.get('/', asyncHandler(async (req, res) => {
  const { 
    status, 
    paymentMethod,
    transactionId,
    fromDate,
    toDate,
    page = 1, 
    limit = 20,
    sortBy = 'createdAt',
    sortOrder = 'desc'
  } = req.query;

  // Build filter
  const filter = {};
  
  if (status) {
    filter.status = status;
  }
  
  if (paymentMethod) {
    filter.paymentMethod = paymentMethod;
  }
  
  if (transactionId) {
    filter.transactionId = { $regex: transactionId, $options: 'i' };
  }
  
  if (fromDate || toDate) {
    filter.createdAt = {};
    if (fromDate) filter.createdAt.$gte = new Date(fromDate);
    if (toDate) filter.createdAt.$lte = new Date(toDate);
  }

  // Execute query
  const skip = (page - 1) * limit;
  const sort = { [sortBy]: sortOrder === 'desc' ? -1 : 1 };

  const [payments, total] = await Promise.all([
    Payment.find(filter)
      .populate('userId', 'displayName email phoneNumber')
      .populate({
        path: 'bookingId',
        select: 'pnr totalPrice status scheduleId',
        populate: {
          path: 'scheduleId',
          select: 'departureTime arrivalTime'
        }
      })
      .sort(sort)
      .skip(skip)
      .limit(parseInt(limit)),
    Payment.countDocuments(filter)
  ]);

  res.json({
    success: true,
    data: payments,
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      total,
      pages: Math.ceil(total / limit)
    }
  });
}));

// @route   GET /api/v1/admin/payments/stats/overview
// @desc    Get payment statistics
// @access  Private (Admin, Operator)
router.get('/stats/overview', asyncHandler(async (req, res) => {
  const [
    total,
    pending,
    completed,
    failed,
    refunded,
    totalAmount,
    completedAmount
  ] = await Promise.all([
    Payment.countDocuments(),
    Payment.countDocuments({ status: 'pending' }),
    Payment.countDocuments({ status: 'completed' }),
    Payment.countDocuments({ status: 'failed' }),
    Payment.countDocuments({ status: 'refunded' }),
    Payment.aggregate([
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ]).then(result => result[0]?.total || 0),
    Payment.aggregate([
      { $match: { status: 'completed' } },
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ]).then(result => result[0]?.total || 0)
  ]);

  // Payment method breakdown
  const methodBreakdown = await Payment.aggregate([
    { $match: { status: 'completed' } },
    {
      $group: {
        _id: '$paymentMethod',
        count: { $sum: 1 },
        amount: { $sum: '$amount' }
      }
    }
  ]);

  res.json({
    success: true,
    data: {
      total,
      pending,
      completed,
      failed,
      refunded,
      totalAmount,
      completedAmount,
      methodBreakdown
    }
  });
}));

// @route   GET /api/v1/admin/payments/stats/revenue
// @desc    Get revenue statistics by date range
// @access  Private (Admin, Operator)
router.get('/stats/revenue', asyncHandler(async (req, res) => {
  const { fromDate, toDate, groupBy = 'day' } = req.query;

  const matchStage = {
    status: 'completed'
  };

  if (fromDate || toDate) {
    matchStage.completedAt = {};
    if (fromDate) matchStage.completedAt.$gte = new Date(fromDate);
    if (toDate) matchStage.completedAt.$lte = new Date(toDate);
  }

  const groupId = groupBy === 'day' 
    ? { $dateToString: { format: '%Y-%m-%d', date: '$completedAt' } }
    : { $dateToString: { format: '%Y-%m', date: '$completedAt' } };

  const revenue = await Payment.aggregate([
    { $match: matchStage },
    {
      $group: {
        _id: groupId,
        totalAmount: { $sum: '$amount' },
        totalCount: { $sum: 1 },
        avgAmount: { $avg: '$amount' }
      }
    },
    { $sort: { _id: 1 } }
  ]);

  res.json({
    success: true,
    data: revenue
  });
}));

// @route   GET /api/v1/admin/payments/:id
// @desc    Get payment details by ID
// @access  Private (Admin, Operator)
router.get('/:id', asyncHandler(async (req, res) => {
  const payment = await Payment.findById(req.params.id)
    .populate('userId', 'displayName email phoneNumber')
    .populate({
      path: 'bookingId',
      populate: {
        path: 'scheduleId'
      }
    });

  if (!payment) {
    return res.status(404).json({
      success: false,
      message: 'Không tìm thấy giao dịch'
    });
  }

  res.json({
    success: true,
    data: payment
  });
}));

// @route   PUT /api/v1/admin/payments/:id/refund
// @desc    Process refund for a payment
// @access  Private (Admin only)
router.put('/:id/refund', AuthMiddleware.authorize('admin'), asyncHandler(async (req, res) => {
  const { refundAmount, refundReason } = req.body;
  
  const payment = await Payment.findById(req.params.id);
  
  if (!payment) {
    return res.status(404).json({
      success: false,
      message: 'Không tìm thấy giao dịch'
    });
  }

  if (payment.status !== 'completed') {
    return res.status(400).json({
      success: false,
      message: 'Chỉ có thể hoàn tiền cho giao dịch đã hoàn thành'
    });
  }

  const amountToRefund = refundAmount || payment.amount;

  if (amountToRefund > payment.amount) {
    return res.status(400).json({
      success: false,
      message: 'Số tiền hoàn không được lớn hơn số tiền gốc'
    });
  }

  // Request refund
  await payment.requestRefund(amountToRefund, refundReason);

  // Update booking status if full refund
  if (amountToRefund >= payment.amount && payment.bookingId) {
    const booking = await Booking.findById(payment.bookingId);
    if (booking) {
      booking.status = 'cancelled';
      booking.cancelReason = refundReason || 'Hoàn tiền';
      booking.cancelledAt = new Date();
      await booking.save();
    }
  }

  res.json({
    success: true,
    message: 'Yêu cầu hoàn tiền đã được ghi nhận',
    data: payment
  });
}));

// @route   PUT /api/v1/admin/payments/:id/complete-refund
// @desc    Complete a refund request
// @access  Private (Admin only)
router.put('/:id/complete-refund', AuthMiddleware.authorize('admin'), asyncHandler(async (req, res) => {
  const { refundTransactionId } = req.body;
  
  const payment = await Payment.findById(req.params.id);
  
  if (!payment) {
    return res.status(404).json({
      success: false,
      message: 'Không tìm thấy giao dịch'
    });
  }

  if (payment.refundStatus !== 'processing') {
    return res.status(400).json({
      success: false,
      message: 'Giao dịch không trong trạng thái xử lý hoàn tiền'
    });
  }

  await payment.completeRefund(refundTransactionId || `REFUND_${Date.now()}`);

  res.json({
    success: true,
    message: 'Hoàn tiền thành công',
    data: payment
  });
}));

module.exports = router;

