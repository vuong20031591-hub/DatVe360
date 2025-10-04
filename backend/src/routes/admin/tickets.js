const express = require('express');
const router = express.Router();
const Ticket = require('../../models/Ticket');
const Booking = require('../../models/Booking');
const AuthMiddleware = require('../../middleware/auth');
const asyncHandler = require('../../utils/asyncHandler');

// Apply authentication middleware to all routes
router.use(AuthMiddleware.authenticate);

// @route   GET /api/v1/admin/tickets
// @desc    Get all tickets (admin)
// @access  Private (Admin, Operator)
router.get('/', AuthMiddleware.authorize('admin', 'operator'), asyncHandler(async (req, res) => {
  const { status, search, page = 1, limit = 20 } = req.query;

  const query = {};

  // Filter by status
  if (status) {
    query.status = status;
  }

  // Search by PNR or ticket number
  if (search) {
    query.$or = [
      { pnr: { $regex: search, $options: 'i' } },
      { ticketNumber: { $regex: search, $options: 'i' } }
    ];
  }

  const skip = (parseInt(page) - 1) * parseInt(limit);

  const [tickets, total] = await Promise.all([
    Ticket.find(query)
      .populate('userId', 'displayName email phoneNumber')
      .populate({
        path: 'bookingId',
        select: 'pnr scheduleId passengers totalPrice status',
        populate: {
          path: 'scheduleId',
          select: 'departureLocation arrivalLocation departAt arriveAt'
        }
      })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit)),
    Ticket.countDocuments(query)
  ]);

  res.json({
    success: true,
    data: tickets,
    pagination: {
      total,
      page: parseInt(page),
      limit: parseInt(limit),
      pages: Math.ceil(total / parseInt(limit))
    }
  });
}));

// @route   GET /api/v1/admin/tickets/search
// @desc    Search tickets
// @access  Private (Admin, Operator)
router.get('/search', AuthMiddleware.authorize('admin', 'operator'), asyncHandler(async (req, res) => {
  const { q } = req.query;

  if (!q || q.trim().length === 0) {
    return res.json({
      success: true,
      data: []
    });
  }

  const tickets = await Ticket.find({
    $or: [
      { pnr: { $regex: q, $options: 'i' } },
      { ticketNumber: { $regex: q, $options: 'i' } }
    ]
  })
    .populate('userId', 'displayName email phoneNumber')
    .populate({
      path: 'bookingId',
      select: 'pnr scheduleId passengers totalPrice status'
    })
    .limit(50)
    .sort({ createdAt: -1 });

  res.json({
    success: true,
    data: tickets
  });
}));

// @route   GET /api/v1/admin/tickets/stats/overview
// @desc    Get tickets statistics
// @access  Private (Admin, Operator)
router.get('/stats/overview', AuthMiddleware.authorize('admin', 'operator'), asyncHandler(async (req, res) => {
  const [total, issued, used, cancelled, expired] = await Promise.all([
    Ticket.countDocuments(),
    Ticket.countDocuments({ status: 'issued' }),
    Ticket.countDocuments({ status: 'used' }),
    Ticket.countDocuments({ status: 'cancelled' }),
    Ticket.countDocuments({ status: 'expired' })
  ]);

  res.json({
    success: true,
    data: {
      total,
      issued,
      used,
      cancelled,
      expired
    }
  });
}));

// @route   GET /api/v1/admin/tickets/:id
// @desc    Get ticket by ID
// @access  Private (Admin, Operator)
router.get('/:id', AuthMiddleware.authorize('admin', 'operator'), asyncHandler(async (req, res) => {
  const ticket = await Ticket.findById(req.params.id)
    .populate('userId', 'displayName email phoneNumber')
    .populate({
      path: 'bookingId',
      select: 'pnr scheduleId passengers totalPrice status contactInfo',
      populate: {
        path: 'scheduleId',
        select: 'departureLocation arrivalLocation departAt arriveAt transportType'
      }
    });

  if (!ticket) {
    return res.status(404).json({
      success: false,
      message: 'Ticket not found'
    });
  }

  res.json({
    success: true,
    data: ticket
  });
}));

// @route   POST /api/v1/admin/tickets/:id/cancel
// @desc    Cancel ticket
// @access  Private (Admin)
router.post('/:id/cancel', AuthMiddleware.authorize('admin'), asyncHandler(async (req, res) => {
  const { reason } = req.body;

  const ticket = await Ticket.findById(req.params.id);

  if (!ticket) {
    return res.status(404).json({
      success: false,
      message: 'Ticket not found'
    });
  }

  if (ticket.status === 'cancelled') {
    return res.status(400).json({
      success: false,
      message: 'Ticket already cancelled'
    });
  }

  if (ticket.status === 'used') {
    return res.status(400).json({
      success: false,
      message: 'Cannot cancel used ticket'
    });
  }

  ticket.status = 'cancelled';
  ticket.cancelledAt = new Date();
  if (reason) {
    ticket.metadata = { ...ticket.metadata, cancellationReason: reason };
  }

  await ticket.save();

  res.json({
    success: true,
    data: ticket,
    message: 'Ticket cancelled successfully'
  });
}));

// @route   POST /api/v1/admin/tickets/:id/mark-used
// @desc    Mark ticket as used
// @access  Private (Admin, Operator)
router.post('/:id/mark-used', AuthMiddleware.authorize('admin', 'operator'), asyncHandler(async (req, res) => {
  const { usedBy } = req.body;

  const ticket = await Ticket.findById(req.params.id);

  if (!ticket) {
    return res.status(404).json({
      success: false,
      message: 'Ticket not found'
    });
  }

  if (ticket.status === 'used') {
    return res.status(400).json({
      success: false,
      message: 'Ticket already used'
    });
  }

  if (ticket.status === 'cancelled') {
    return res.status(400).json({
      success: false,
      message: 'Cannot use cancelled ticket'
    });
  }

  ticket.status = 'used';
  ticket.usedAt = new Date();
  ticket.usedBy = usedBy || req.user.displayName;

  await ticket.save();

  res.json({
    success: true,
    data: ticket,
    message: 'Ticket marked as used'
  });
}));

// @route   POST /api/v1/admin/tickets/:id/reissue
// @desc    Reissue ticket (change from cancelled/expired to issued)
// @access  Private (Admin)
router.post('/:id/reissue', AuthMiddleware.authorize('admin'), asyncHandler(async (req, res) => {
  const ticket = await Ticket.findById(req.params.id);

  if (!ticket) {
    return res.status(404).json({
      success: false,
      message: 'Ticket not found'
    });
  }

  if (ticket.status === 'used') {
    return res.status(400).json({
      success: false,
      message: 'Cannot reissue used ticket'
    });
  }

  ticket.status = 'issued';
  ticket.cancelledAt = null;
  ticket.usedAt = null;
  ticket.usedBy = null;

  await ticket.save();

  res.json({
    success: true,
    data: ticket,
    message: 'Ticket reissued successfully'
  });
}));

// @route   DELETE /api/v1/admin/tickets/:id
// @desc    Delete ticket
// @access  Private (Admin only)
router.delete('/:id', AuthMiddleware.authorize('admin'), asyncHandler(async (req, res) => {
  const ticket = await Ticket.findById(req.params.id);

  if (!ticket) {
    return res.status(404).json({
      success: false,
      message: 'Ticket not found'
    });
  }

  await ticket.deleteOne();

  res.json({
    success: true,
    message: 'Ticket deleted successfully'
  });
}));

module.exports = router;

