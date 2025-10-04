const express = require('express');
const router = express.Router();
const Booking = require('../../models/Booking');
const Payment = require('../../models/Payment');
const User = require('../../models/User');
const Schedule = require('../../models/Schedule');
const Ticket = require('../../models/Ticket');
const AuthMiddleware = require('../../middleware/auth');
const asyncHandler = require('../../utils/asyncHandler');

// Apply authentication and authorization middleware
router.use(AuthMiddleware.authenticate);
router.use(AuthMiddleware.authorize('admin', 'operator'));

// @route   GET /api/v1/admin/reports/dashboard
// @desc    Get dashboard summary statistics
// @access  Private (Admin, Operator)
router.get('/dashboard', asyncHandler(async (req, res) => {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  const thisMonth = new Date(today.getFullYear(), today.getMonth(), 1);
  const lastMonth = new Date(today.getFullYear(), today.getMonth() - 1, 1);

  // Get all statistics in parallel
  const [
    totalUsers,
    totalBookings,
    totalRevenue,
    todayBookings,
    todayRevenue,
    monthBookings,
    monthRevenue,
    lastMonthRevenue,
    pendingBookings,
    activeSchedules
  ] = await Promise.all([
    User.countDocuments({ role: 'user' }),
    Booking.countDocuments(),
    Payment.aggregate([
      { $match: { status: 'completed' } },
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ]).then(result => result[0]?.total || 0),
    Booking.countDocuments({ createdAt: { $gte: today } }),
    Payment.aggregate([
      { $match: { status: 'completed', completedAt: { $gte: today } } },
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ]).then(result => result[0]?.total || 0),
    Booking.countDocuments({ createdAt: { $gte: thisMonth } }),
    Payment.aggregate([
      { $match: { status: 'completed', completedAt: { $gte: thisMonth } } },
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ]).then(result => result[0]?.total || 0),
    Payment.aggregate([
      { $match: { status: 'completed', completedAt: { $gte: lastMonth, $lt: thisMonth } } },
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ]).then(result => result[0]?.total || 0),
    Booking.countDocuments({ status: 'pending' }),
    Schedule.countDocuments({ isActive: true })
  ]);

  // Calculate growth rates
  const revenueGrowth = lastMonthRevenue > 0 
    ? ((monthRevenue - lastMonthRevenue) / lastMonthRevenue * 100).toFixed(2)
    : 0;

  res.json({
    success: true,
    data: {
      users: {
        total: totalUsers
      },
      bookings: {
        total: totalBookings,
        today: todayBookings,
        thisMonth: monthBookings,
        pending: pendingBookings
      },
      revenue: {
        total: totalRevenue,
        today: todayRevenue,
        thisMonth: monthRevenue,
        lastMonth: lastMonthRevenue,
        growth: parseFloat(revenueGrowth)
      },
      schedules: {
        active: activeSchedules
      }
    }
  });
}));

// @route   GET /api/v1/admin/reports/bookings
// @desc    Get booking statistics by date range
// @access  Private (Admin, Operator)
router.get('/bookings', asyncHandler(async (req, res) => {
  const { fromDate, toDate, groupBy = 'day' } = req.query;

  const matchStage = {};
  if (fromDate || toDate) {
    matchStage.createdAt = {};
    if (fromDate) matchStage.createdAt.$gte = new Date(fromDate);
    if (toDate) matchStage.createdAt.$lte = new Date(toDate);
  }

  const groupId = groupBy === 'day' 
    ? { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } }
    : { $dateToString: { format: '%Y-%m', date: '$createdAt' } };

  const bookingStats = await Booking.aggregate([
    { $match: matchStage },
    {
      $group: {
        _id: groupId,
        totalBookings: { $sum: 1 },
        totalRevenue: { $sum: '$totalPrice' },
        confirmedBookings: {
          $sum: { $cond: [{ $eq: ['$status', 'confirmed'] }, 1, 0] }
        },
        cancelledBookings: {
          $sum: { $cond: [{ $eq: ['$status', 'cancelled'] }, 1, 0] }
        },
        avgBookingValue: { $avg: '$totalPrice' }
      }
    },
    { $sort: { _id: 1 } }
  ]);

  res.json({
    success: true,
    data: bookingStats
  });
}));

// @route   GET /api/v1/admin/reports/revenue
// @desc    Get revenue statistics by date range and payment method
// @access  Private (Admin, Operator)
router.get('/revenue', asyncHandler(async (req, res) => {
  const { fromDate, toDate, groupBy = 'day' } = req.query;

  const matchStage = { status: 'completed' };
  if (fromDate || toDate) {
    matchStage.completedAt = {};
    if (fromDate) matchStage.completedAt.$gte = new Date(fromDate);
    if (toDate) matchStage.completedAt.$lte = new Date(toDate);
  }

  const groupId = groupBy === 'day' 
    ? { $dateToString: { format: '%Y-%m-%d', date: '$completedAt' } }
    : { $dateToString: { format: '%Y-%m', date: '$completedAt' } };

  const [revenueByDate, revenueByMethod] = await Promise.all([
    Payment.aggregate([
      { $match: matchStage },
      {
        $group: {
          _id: groupId,
          totalRevenue: { $sum: '$amount' },
          totalTransactions: { $sum: 1 },
          avgTransactionValue: { $avg: '$amount' }
        }
      },
      { $sort: { _id: 1 } }
    ]),
    Payment.aggregate([
      { $match: matchStage },
      {
        $group: {
          _id: '$paymentMethod',
          totalRevenue: { $sum: '$amount' },
          totalTransactions: { $sum: 1 }
        }
      }
    ])
  ]);

  res.json({
    success: true,
    data: {
      byDate: revenueByDate,
      byMethod: revenueByMethod
    }
  });
}));

// @route   GET /api/v1/admin/reports/popular-routes
// @desc    Get most popular routes
// @access  Private (Admin, Operator)
router.get('/popular-routes', asyncHandler(async (req, res) => {
  const { limit = 10 } = req.query;

  const popularRoutes = await Booking.aggregate([
    {
      $match: {
        status: { $in: ['confirmed', 'completed'] }
      }
    },
    {
      $lookup: {
        from: 'schedules',
        localField: 'scheduleId',
        foreignField: '_id',
        as: 'schedule'
      }
    },
    { $unwind: '$schedule' },
    {
      $lookup: {
        from: 'routes',
        localField: 'schedule.routeId',
        foreignField: '_id',
        as: 'route'
      }
    },
    { $unwind: '$route' },
    {
      $group: {
        _id: '$route._id',
        routeInfo: { $first: '$route' },
        totalBookings: { $sum: 1 },
        totalRevenue: { $sum: '$totalPrice' },
        totalPassengers: { $sum: { $size: '$passengers' } }
      }
    },
    { $sort: { totalBookings: -1 } },
    { $limit: parseInt(limit) }
  ]);

  res.json({
    success: true,
    data: popularRoutes
  });
}));

// @route   GET /api/v1/admin/reports/user-activity
// @desc    Get user activity statistics
// @access  Private (Admin, Operator)
router.get('/user-activity', asyncHandler(async (req, res) => {
  const { fromDate, toDate } = req.query;

  const matchStage = {};
  if (fromDate || toDate) {
    matchStage.createdAt = {};
    if (fromDate) matchStage.createdAt.$gte = new Date(fromDate);
    if (toDate) matchStage.createdAt.$lte = new Date(toDate);
  }

  const [newUsers, activeUsers, topUsers] = await Promise.all([
    User.countDocuments(matchStage),
    Booking.distinct('userId', matchStage).then(users => users.length),
    Booking.aggregate([
      { $match: matchStage },
      {
        $group: {
          _id: '$userId',
          totalBookings: { $sum: 1 },
          totalSpent: { $sum: '$totalPrice' }
        }
      },
      { $sort: { totalSpent: -1 } },
      { $limit: 10 },
      {
        $lookup: {
          from: 'users',
          localField: '_id',
          foreignField: '_id',
          as: 'user'
        }
      },
      { $unwind: '$user' }
    ])
  ]);

  res.json({
    success: true,
    data: {
      newUsers,
      activeUsers,
      topUsers
    }
  });
}));

// @route   GET /api/v1/admin/reports/export
// @desc    Export report data (CSV format)
// @access  Private (Admin only)
router.get('/export', AuthMiddleware.authorize('admin'), asyncHandler(async (req, res) => {
  const { type, fromDate, toDate } = req.query;

  let data = [];
  let filename = 'report';

  const dateFilter = {};
  if (fromDate || toDate) {
    dateFilter.createdAt = {};
    if (fromDate) dateFilter.createdAt.$gte = new Date(fromDate);
    if (toDate) dateFilter.createdAt.$lte = new Date(toDate);
  }

  switch (type) {
    case 'bookings':
      data = await Booking.find(dateFilter)
        .populate('userId', 'displayName email')
        .populate('scheduleId')
        .lean();
      filename = 'bookings_report';
      break;
    
    case 'payments':
      data = await Payment.find(dateFilter)
        .populate('userId', 'displayName email')
        .populate('bookingId', 'pnr')
        .lean();
      filename = 'payments_report';
      break;
    
    case 'users':
      data = await User.find(dateFilter).lean();
      filename = 'users_report';
      break;
    
    default:
      return res.status(400).json({
        success: false,
        message: 'Invalid report type'
      });
  }

  res.json({
    success: true,
    data,
    filename: `${filename}_${new Date().toISOString().split('T')[0]}.json`
  });
}));

module.exports = router;

