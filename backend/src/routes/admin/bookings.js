const express = require('express');
const router = express.Router();
const Booking = require('../../models/Booking');
const Ticket = require('../../models/Ticket');
const AuthMiddleware = require('../../middleware/auth');
const asyncHandler = require('../../utils/asyncHandler');

// Apply authentication and authorization middleware
router.use(AuthMiddleware.authenticate);
router.use(AuthMiddleware.authorize('admin', 'operator'));

// GET /api/v1/admin/bookings - Lấy danh sách bookings
router.get('/', asyncHandler(async (req, res) => {
  const { 
    status, 
    pnr, 
    email, 
    phone,
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
  
  if (pnr) {
    filter.pnr = pnr.toUpperCase();
  }
  
  if (email) {
    filter['contactInfo.email'] = { $regex: email, $options: 'i' };
  }
  
  if (phone) {
    filter['contactInfo.phone'] = { $regex: phone };
  }
  
  if (fromDate || toDate) {
    filter.createdAt = {};
    if (fromDate) filter.createdAt.$gte = new Date(fromDate);
    if (toDate) filter.createdAt.$lte = new Date(toDate);
  }

  // Pagination
  const skip = (parseInt(page) - 1) * parseInt(limit);
  const sort = { [sortBy]: sortOrder === 'desc' ? -1 : 1 };

  // Query
  const [bookings, total] = await Promise.all([
    Booking.find(filter)
      .populate({
        path: 'userId',
        select: 'displayName email phoneNumber avatar'
      })
      .populate({
        path: 'scheduleId',
        populate: [
          {
            path: 'routeId',
            populate: ['fromDestination', 'toDestination']
          },
          {
            path: 'operatorId',
            select: 'name logo transportTypes'
          }
        ]
      })
      .sort(sort)
      .skip(skip)
      .limit(parseInt(limit))
      .lean(),
    Booking.countDocuments(filter)
  ]);

  res.json({
    success: true,
    data: bookings,
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      total,
      pages: Math.ceil(total / parseInt(limit))
    }
  });
}));

// GET /api/v1/admin/bookings/stats - Thống kê bookings
router.get('/stats', asyncHandler(async (req, res) => {
  const { fromDate, toDate } = req.query;
  
  const dateFilter = {};
  if (fromDate || toDate) {
    dateFilter.createdAt = {};
    if (fromDate) dateFilter.createdAt.$gte = new Date(fromDate);
    if (toDate) dateFilter.createdAt.$lte = new Date(toDate);
  }

  const [statusStats, revenueStats, totalBookings, totalTickets] = await Promise.all([
    // Thống kê theo status
    Booking.aggregate([
      { $match: dateFilter },
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 },
          totalRevenue: { $sum: '$totalPrice' }
        }
      }
    ]),
    
    // Tổng doanh thu
    Booking.aggregate([
      { $match: { ...dateFilter, status: { $in: ['confirmed', 'completed'] } } },
      {
        $group: {
          _id: null,
          totalRevenue: { $sum: '$totalPrice' },
          avgBookingValue: { $avg: '$totalPrice' }
        }
      }
    ]),
    
    // Tổng số bookings
    Booking.countDocuments(dateFilter),
    
    // Tổng số tickets
    Ticket.countDocuments(dateFilter.createdAt ? { createdAt: dateFilter.createdAt } : {})
  ]);

  res.json({
    success: true,
    data: {
      totalBookings,
      totalTickets,
      statusBreakdown: statusStats,
      revenue: revenueStats[0] || { totalRevenue: 0, avgBookingValue: 0 }
    }
  });
}));

// GET /api/v1/admin/bookings/:id - Lấy chi tiết booking
router.get('/:id', asyncHandler(async (req, res) => {
  const booking = await Booking.findById(req.params.id)
    .populate({
      path: 'userId',
      select: 'displayName email phoneNumber avatar'
    })
    .populate({
      path: 'scheduleId',
      populate: [
        {
          path: 'routeId',
          populate: ['fromDestination', 'toDestination']
        },
        {
          path: 'operatorId',
          select: 'name logo transportTypes contactInfo'
        }
      ]
    })
    .populate('paymentId');

  if (!booking) {
    return res.status(404).json({
      success: false,
      message: 'Không tìm thấy booking'
    });
  }

  // Lấy tickets của booking
  const tickets = await Ticket.find({ bookingId: booking._id });

  res.json({
    success: true,
    data: {
      ...booking.toObject(),
      tickets
    }
  });
}));

// PUT /api/v1/admin/bookings/:id/confirm - Xác nhận booking
router.put('/:id/confirm', asyncHandler(async (req, res) => {
  const booking = await Booking.findById(req.params.id);
  
  if (!booking) {
    return res.status(404).json({
      success: false,
      message: 'Không tìm thấy booking'
    });
  }

  if (booking.status !== 'pending') {
    return res.status(400).json({
      success: false,
      message: 'Chỉ có thể xác nhận booking đang pending'
    });
  }

  await booking.confirm();

  // Tạo tickets
  const tickets = await booking.generateTickets();

  res.json({
    success: true,
    message: 'Đã xác nhận booking',
    data: {
      booking,
      tickets
    }
  });
}));

// PUT /api/v1/admin/bookings/:id/cancel - Hủy booking
router.put('/:id/cancel', asyncHandler(async (req, res) => {
  const { reason } = req.body;
  
  const booking = await Booking.findById(req.params.id);
  
  if (!booking) {
    return res.status(404).json({
      success: false,
      message: 'Không tìm thấy booking'
    });
  }

  if (booking.status === 'cancelled') {
    return res.status(400).json({
      success: false,
      message: 'Booking đã bị hủy'
    });
  }

  await booking.cancel(reason || 'Hủy bởi admin');

  // Hủy tickets nếu có
  await Ticket.updateMany(
    { bookingId: booking._id },
    { status: 'cancelled', cancelledAt: new Date() }
  );

  res.json({
    success: true,
    message: 'Đã hủy booking',
    data: booking
  });
}));

// PUT /api/v1/admin/bookings/:id/complete - Hoàn thành booking
router.put('/:id/complete', asyncHandler(async (req, res) => {
  const booking = await Booking.findById(req.params.id);
  
  if (!booking) {
    return res.status(404).json({
      success: false,
      message: 'Không tìm thấy booking'
    });
  }

  if (booking.status !== 'confirmed') {
    return res.status(400).json({
      success: false,
      message: 'Chỉ có thể hoàn thành booking đã confirmed'
    });
  }

  await booking.complete();

  // Đánh dấu tickets đã sử dụng
  await Ticket.updateMany(
    { bookingId: booking._id, status: 'issued' },
    { status: 'used', usedAt: new Date(), usedBy: 'Admin' }
  );

  res.json({
    success: true,
    message: 'Đã hoàn thành booking',
    data: booking
  });
}));

// DELETE /api/v1/admin/bookings/:id - Xóa booking (soft delete)
router.delete('/:id', asyncHandler(async (req, res) => {
  const booking = await Booking.findById(req.params.id);
  
  if (!booking) {
    return res.status(404).json({
      success: false,
      message: 'Không tìm thấy booking'
    });
  }

  // Chỉ cho phép xóa booking pending hoặc cancelled
  if (!['pending', 'cancelled'].includes(booking.status)) {
    return res.status(400).json({
      success: false,
      message: 'Chỉ có thể xóa booking pending hoặc cancelled'
    });
  }

  await booking.deleteOne();
  await Ticket.deleteMany({ bookingId: booking._id });

  res.json({
    success: true,
    message: 'Đã xóa booking'
  });
}));

module.exports = router;

