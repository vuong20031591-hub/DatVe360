const express = require('express');
const router = express.Router();
const Schedule = require('../../models/Schedule');
const Route = require('../../models/Route');
const TransportOperator = require('../../models/TransportOperator');
const AuthMiddleware = require('../../middleware/auth');
const asyncHandler = require('../../utils/asyncHandler');

// Apply authentication middleware
router.use(AuthMiddleware.authenticate);
router.use(AuthMiddleware.authorize('admin', 'operator'));

// GET /api/v1/admin/schedules-by-type/:type - Get schedules by transport type
router.get('/:type', asyncHandler(async (req, res) => {
  const { type } = req.params;
  const { page = 1, limit = 20, status, search } = req.query;

  // Validate and map type
  const typeMap = {
    'plane': 'flight',
    'train': 'train',
    'bus': 'bus'
  };

  if (!typeMap[type]) {
    return res.status(400).json({
      success: false,
      message: 'Invalid type. Must be plane, train, or bus'
    });
  }

  const transportType = typeMap[type];

  // Get routes of this transport type
  const routes = await Route.find({ transportType });
  const routeIds = routes.map(r => r._id);

  // Build filter
  let filter = { routeId: { $in: routeIds } };
  if (status) {
    filter.status = status;
  }

  // Count total
  const total = await Schedule.countDocuments(filter);

  // Get schedules
  const schedules = await Schedule.find(filter)
    .populate({
      path: 'routeId',
      populate: [
        { path: 'fromDestination', select: 'name code city country' },
        { path: 'toDestination', select: 'name code city country' }
      ]
    })
    .populate('operatorId', 'name code logo contactInfo')
    .sort({ departureTime: -1 })
    .limit(parseInt(limit))
    .skip((parseInt(page) - 1) * parseInt(limit));

  // Filter out null routes
  const validSchedules = schedules.filter(s => s.routeId != null);

  res.json({
    success: true,
    data: validSchedules,
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      total,
      pages: Math.ceil(total / parseInt(limit))
    }
  });
}));

// GET /api/v1/admin/schedules-by-type/:type/routes - Get routes for type
router.get('/:type/routes', asyncHandler(async (req, res) => {
  const { type } = req.params;

  const typeMap = {
    'plane': 'flight',
    'train': 'train',
    'bus': 'bus'
  };

  if (!typeMap[type]) {
    return res.status(400).json({
      success: false,
      message: 'Invalid type'
    });
  }

  const routes = await Route.find({ transportType: typeMap[type] })
    .populate('fromDestination', 'name code city')
    .populate('toDestination', 'name code city');

  res.json({
    success: true,
    data: routes
  });
}));

// GET /api/v1/admin/schedules-by-type/:type/operators - Get operators for type
router.get('/:type/operators', asyncHandler(async (req, res) => {
  const { type } = req.params;

  const typeMap = {
    'plane': 'flight',
    'train': 'train',
    'bus': 'bus'
  };

  if (!typeMap[type]) {
    return res.status(400).json({
      success: false,
      message: 'Invalid type'
    });
  }

  const operators = await TransportOperator.find({ transportType: typeMap[type] })
    .select('name code logo contactInfo');

  res.json({
    success: true,
    data: operators
  });
}));

// POST /api/v1/admin/schedules-by-type/:type - Create schedule
router.post('/:type', asyncHandler(async (req, res) => {
  const { type } = req.params;
  const {
    routeId,
    operatorId,
    vehicleNumber,
    departureTime,
    arrivalTime,
    seatConfiguration,
    vehicle,
    gate,
    terminal
  } = req.body;

  // Validate type
  const typeMap = {
    'plane': 'flight',
    'train': 'train',
    'bus': 'bus'
  };

  if (!typeMap[type]) {
    return res.status(400).json({
      success: false,
      message: 'Invalid type'
    });
  }

  // Verify route
  const route = await Route.findById(routeId);
  if (!route) {
    return res.status(404).json({
      success: false,
      message: 'Route not found'
    });
  }

  if (route.transportType !== typeMap[type]) {
    return res.status(400).json({
      success: false,
      message: `Route type mismatch. Expected ${type}`
    });
  }

  // Verify operator
  const operator = await TransportOperator.findById(operatorId);
  if (!operator) {
    return res.status(404).json({
      success: false,
      message: 'Operator not found'
    });
  }

  // Create schedule
  const schedule = new Schedule({
    routeId,
    operatorId,
    vehicleNumber,
    departureTime: new Date(departureTime),
    arrivalTime: new Date(arrivalTime),
    seatConfiguration,
    vehicle,
    gate,
    terminal,
    status: 'scheduled',
    isActive: true
  });

  await schedule.save();

  // Populate
  await schedule.populate([
    {
      path: 'routeId',
      populate: [
        { path: 'fromDestination', select: 'name code city country' },
        { path: 'toDestination', select: 'name code city country' }
      ]
    },
    { path: 'operatorId', select: 'name code logo' }
  ]);

  res.status(201).json({
    success: true,
    data: schedule,
    message: 'Schedule created successfully'
  });
}));

// PUT /api/v1/admin/schedules-by-type/:type/:id - Update schedule
router.put('/:type/:id', asyncHandler(async (req, res) => {
  const { type, id } = req.params;
  const updateData = req.body;

  const schedule = await Schedule.findById(id);
  if (!schedule) {
    return res.status(404).json({
      success: false,
      message: 'Schedule not found'
    });
  }

  // Update fields
  Object.keys(updateData).forEach(key => {
    if (updateData[key] !== undefined && key !== '_id') {
      schedule[key] = updateData[key];
    }
  });

  await schedule.save();

  // Populate
  await schedule.populate([
    {
      path: 'routeId',
      populate: [
        { path: 'fromDestination', select: 'name code city country' },
        { path: 'toDestination', select: 'name code city country' }
      ]
    },
    { path: 'operatorId', select: 'name code logo' }
  ]);

  res.json({
    success: true,
    data: schedule,
    message: 'Schedule updated successfully'
  });
}));

// DELETE /api/v1/admin/schedules-by-type/:type/:id - Delete schedule
router.delete('/:type/:id', asyncHandler(async (req, res) => {
  const { id } = req.params;

  const schedule = await Schedule.findByIdAndDelete(id);
  if (!schedule) {
    return res.status(404).json({
      success: false,
      message: 'Schedule not found'
    });
  }

  res.json({
    success: true,
    message: 'Schedule deleted successfully'
  });
}));

module.exports = router;

