const express = require('express');
const router = express.Router();
const Schedule = require('../../models/Schedule');
const Route = require('../../models/Route');
const TransportOperator = require('../../models/TransportOperator');
const AuthMiddleware = require('../../middleware/auth');
const asyncHandler = require('../../utils/asyncHandler');

// Apply authentication middleware
router.use(AuthMiddleware.authenticate);

// @route   GET /api/v1/admin/schedules
// @desc    Get all schedules with filters
// @access  Private (Admin, Operator)
router.get('/', AuthMiddleware.authorize('admin', 'operator'), asyncHandler(async (req, res) => {
  const { transportType, status, page = 1, limit = 50 } = req.query;

  const query = {};

  // Build query based on filters
  if (status) {
    query.status = status;
  }

  const skip = (parseInt(page) - 1) * parseInt(limit);

  // Get schedules with populated route and operator
  let schedulesQuery = Schedule.find(query)
    .populate({
      path: 'routeId',
      populate: [
        { path: 'fromDestination', select: 'name code city country' },
        { path: 'toDestination', select: 'name code city country' }
      ]
    })
    .populate('operatorId', 'name code transportTypes metadata')
    .sort({ departureTime: -1 })
    .skip(skip)
    .limit(parseInt(limit));

  const [schedules, total] = await Promise.all([
    schedulesQuery,
    Schedule.countDocuments(query)
  ]);

  // Filter by transport type if specified (after population)
  let filteredSchedules = schedules;
  if (transportType) {
    filteredSchedules = schedules.filter(schedule => 
      schedule.routeId && schedule.routeId.transportType === transportType
    );
  }

  res.json({
    success: true,
    data: filteredSchedules,
    pagination: {
      total: transportType ? filteredSchedules.length : total,
      page: parseInt(page),
      limit: parseInt(limit),
      pages: Math.ceil((transportType ? filteredSchedules.length : total) / parseInt(limit))
    }
  });
}));

// @route   GET /api/v1/admin/schedules/routes
// @desc    Get all routes for dropdown
// @access  Private (Admin, Operator)
router.get('/routes', AuthMiddleware.authorize('admin', 'operator'), asyncHandler(async (req, res) => {
  const { transportType } = req.query;

  const query = { isActive: true };
  if (transportType) {
    query.transportType = transportType;
  }

  const routes = await Route.find(query)
    .populate('fromDestination', 'name code city country')
    .populate('toDestination', 'name code city country')
    .sort({ 'fromDestination.name': 1 });

  res.json({
    success: true,
    data: routes
  });
}));

// @route   GET /api/v1/admin/schedules/stats/overview
// @desc    Get schedules statistics
// @access  Private (Admin, Operator)
router.get('/stats/overview', AuthMiddleware.authorize('admin', 'operator'), asyncHandler(async (_req, res) => {
  const [total, scheduled, active, cancelled] = await Promise.all([
    Schedule.countDocuments(),
    Schedule.countDocuments({ status: 'scheduled' }),
    Schedule.countDocuments({ isActive: true }),
    Schedule.countDocuments({ status: 'cancelled' })
  ]);

  res.json({
    success: true,
    data: {
      total,
      scheduled,
      active,
      cancelled,
      inactive: total - active
    }
  });
}));

// @route   GET /api/v1/admin/schedules/:id
// @desc    Get schedule by ID
// @access  Private (Admin, Operator)
router.get('/:id', AuthMiddleware.authorize('admin', 'operator'), asyncHandler(async (req, res) => {
  const schedule = await Schedule.findById(req.params.id)
    .populate({
      path: 'routeId',
      populate: [
        { path: 'fromDestination', select: 'name code city country' },
        { path: 'toDestination', select: 'name code city country' }
      ]
    })
    .populate('operatorId', 'name code transportTypes metadata');

  if (!schedule) {
    return res.status(404).json({
      success: false,
      message: 'Không tìm thấy lịch trình'
    });
  }

  res.json({
    success: true,
    data: schedule
  });
}));

// @route   POST /api/v1/admin/schedules
// @desc    Create new schedule
// @access  Private (Admin)
router.post('/', AuthMiddleware.authorize('admin'), asyncHandler(async (req, res) => {
  const {
    routeId,
    operatorId,
    vehicleNumber,
    departureTime,
    arrivalTime,
    seatConfiguration,
    vehicle,
    gate,
    terminal,
    frequency,
    recurringDays,
    validFrom,
    validTo,
    specialPricing,
    metadata
  } = req.body;

  // Validate route exists
  const route = await Route.findById(routeId);
  if (!route) {
    return res.status(404).json({
      success: false,
      message: 'Không tìm thấy tuyến đường'
    });
  }

  // Validate operator exists
  const operator = await TransportOperator.findById(operatorId);
  if (!operator) {
    return res.status(404).json({
      success: false,
      message: 'Không tìm thấy nhà cung cấp'
    });
  }

  // Validate operator supports this transport type
  if (!operator.transportTypes.includes(route.transportType)) {
    return res.status(400).json({
      success: false,
      message: `Nhà cung cấp không hỗ trợ loại phương tiện ${route.transportType}`
    });
  }

  // Create schedule
  const schedule = await Schedule.create({
    routeId,
    operatorId,
    vehicleNumber,
    departureTime,
    arrivalTime,
    seatConfiguration,
    vehicle,
    gate,
    terminal,
    frequency: frequency || 'one-time',
    recurringDays,
    validFrom,
    validTo,
    specialPricing,
    metadata,
    status: 'scheduled',
    isActive: true
  });

  // Populate before returning
  await schedule.populate([
    {
      path: 'routeId',
      populate: [
        { path: 'fromDestination', select: 'name code city country' },
        { path: 'toDestination', select: 'name code city country' }
      ]
    },
    { path: 'operatorId', select: 'name code transportTypes metadata' }
  ]);

  res.status(201).json({
    success: true,
    data: schedule,
    message: 'Tạo lịch trình thành công'
  });
}));

// @route   PUT /api/v1/admin/schedules/:id
// @desc    Update schedule
// @access  Private (Admin)
router.put('/:id', AuthMiddleware.authorize('admin'), asyncHandler(async (req, res) => {
  const schedule = await Schedule.findById(req.params.id);

  if (!schedule) {
    return res.status(404).json({
      success: false,
      message: 'Không tìm thấy lịch trình'
    });
  }

  const {
    vehicleNumber,
    departureTime,
    arrivalTime,
    seatConfiguration,
    vehicle,
    gate,
    terminal,
    status,
    isActive,
    frequency,
    recurringDays,
    validFrom,
    validTo,
    specialPricing,
    metadata
  } = req.body;

  // Update fields
  if (vehicleNumber !== undefined) schedule.vehicleNumber = vehicleNumber;
  if (departureTime !== undefined) schedule.departureTime = departureTime;
  if (arrivalTime !== undefined) schedule.arrivalTime = arrivalTime;
  if (seatConfiguration !== undefined) schedule.seatConfiguration = seatConfiguration;
  if (vehicle !== undefined) schedule.vehicle = vehicle;
  if (gate !== undefined) schedule.gate = gate;
  if (terminal !== undefined) schedule.terminal = terminal;
  if (status !== undefined) schedule.status = status;
  if (isActive !== undefined) schedule.isActive = isActive;
  if (frequency !== undefined) schedule.frequency = frequency;
  if (recurringDays !== undefined) schedule.recurringDays = recurringDays;
  if (validFrom !== undefined) schedule.validFrom = validFrom;
  if (validTo !== undefined) schedule.validTo = validTo;
  if (specialPricing !== undefined) schedule.specialPricing = specialPricing;
  if (metadata !== undefined) schedule.metadata = metadata;

  await schedule.save();

  // Populate before returning
  await schedule.populate([
    {
      path: 'routeId',
      populate: [
        { path: 'fromDestination', select: 'name code city country' },
        { path: 'toDestination', select: 'name code city country' }
      ]
    },
    { path: 'operatorId', select: 'name code transportTypes metadata' }
  ]);

  res.json({
    success: true,
    data: schedule,
    message: 'Cập nhật lịch trình thành công'
  });
}));

// @route   DELETE /api/v1/admin/schedules/:id
// @desc    Delete schedule
// @access  Private (Admin)
router.delete('/:id', AuthMiddleware.authorize('admin'), asyncHandler(async (req, res) => {
  const schedule = await Schedule.findById(req.params.id);

  if (!schedule) {
    return res.status(404).json({
      success: false,
      message: 'Không tìm thấy lịch trình'
    });
  }

  await schedule.deleteOne();

  res.json({
    success: true,
    message: 'Xóa lịch trình thành công'
  });
}));

module.exports = router;

