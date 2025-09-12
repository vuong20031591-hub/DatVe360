const express = require('express');
const { query, param, validationResult } = require('express-validator');
const Schedule = require('../models/Schedule');
// const Route = require('../models/Route'); // Commented out - model doesn't exist
const Destination = require('../models/Destination');
const AuthMiddleware = require('../middleware/auth');
const { asyncHandler, ValidationError, NotFoundError } = require('../middleware/errorHandler');
const logger = require('../utils/logger');
// const redis = require('../config/redis'); // Commented out for now

const router = express.Router();

const checkValidation = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ValidationError(errors.array().map(err => err.msg).join(', '));
  }
  next();
};

// @route   GET /api/v1/schedules/search
// @desc    Search schedules
// @access  Public
router.get('/search',
  [
    query('from').notEmpty().withMessage('Điểm khởi hành không được để trống'),
    query('to').notEmpty().withMessage('Điểm đến không được để trống'),
    query('departureDate').isISO8601().withMessage('Ngày khởi hành không hợp lệ'),
    query('returnDate').optional().isISO8601().withMessage('Ngày về không hợp lệ'),
    query('passengers').optional().isInt({ min: 1, max: 9 }).withMessage('Số hành khách không hợp lệ'),
    query('class').optional().isString(),
    query('maxPrice').optional().isFloat({ min: 0 }),
    query('sortBy').optional().isIn(['departureTime', 'price', 'duration']),
    query('transportType').optional().isIn(['flight', 'bus', 'train', 'ferry'])
  ],
  checkValidation,
  asyncHandler(async (req, res) => {
    const {
      from,
      to,
      departureDate,
      returnDate,
      passengers = 1,
      class: className,
      maxPrice,
      sortBy = 'departureTime',
      transportType,
      operatorId,
      limit = 50,
      page = 1
    } = req.query;

    // Create cache key - Commented out for now
    // const cacheKey = redis.getCacheKey('schedules_search',
    //   JSON.stringify({ from, to, departureDate, passengers, className, sortBy })
    // );

    // Check cache first - Commented out for now
    // if (redis.isConnected) {
    //   const cached = await redis.get(cacheKey);
    //   if (cached) {
    //     return res.json({
    //       success: true,
    //       data: cached,
    //       cached: true
    //     });
    //   }
    // }

    // Find destinations
    const [fromDestination, toDestination] = await Promise.all([
      Destination.findOne({
        $or: [
          { code: from.toUpperCase() },
          { name: new RegExp(from, 'i') }
        ],
        active: true
      }),
      Destination.findOne({
        $or: [
          { code: to.toUpperCase() },
          { name: new RegExp(to, 'i') }
        ],
        active: true
      })
    ]);

    if (!fromDestination) {
      throw new NotFoundError(`Không tìm thấy điểm khởi hành: ${from}`);
    }

    if (!toDestination) {
      throw new NotFoundError(`Không tìm thấy điểm đến: ${to}`);
    }

    // Build aggregation pipeline
    let pipeline = [
      {
        $lookup: {
          from: 'routes',
          localField: 'routeId',
          foreignField: '_id',
          as: 'route'
        }
      },
      {
        $unwind: '$route'
      },
      {
        $lookup: {
          from: 'destinations',
          localField: 'route.fromDestination',
          foreignField: '_id',
          as: 'fromDest'
        }
      },
      {
        $lookup: {
          from: 'destinations',
          localField: 'route.toDestination',
          foreignField: '_id',
          as: 'toDest'
        }
      },
      {
        $lookup: {
          from: 'transportoperators',
          localField: 'operatorId',
          foreignField: '_id',
          as: 'operator'
        }
      },
      {
        $unwind: '$fromDest'
      },
      {
        $unwind: '$toDest'
      },
      {
        $unwind: '$operator'
      },
      {
        $match: {
          isActive: true,
          status: { $in: ['scheduled', 'delayed'] },
          'route.fromDestination': fromDestination._id,
          'route.toDestination': toDestination._id,
          'seatConfiguration.availableSeats': { $gte: parseInt(passengers) },
          departureTime: { $gte: new Date() }
        }
      }
    ];

    // Add date filter
    if (departureDate) {
      const startDate = new Date(departureDate);
      startDate.setHours(0, 0, 0, 0);
      const endDate = new Date(departureDate);
      endDate.setHours(23, 59, 59, 999);

      pipeline.push({
        $match: {
          departureTime: { $gte: startDate, $lte: endDate }
        }
      });
    }

    // Add transport type filter
    if (transportType) {
      pipeline.push({
        $match: {
          'route.transportType': transportType
        }
      });
    }

    // Add operator filter
    if (operatorId) {
      pipeline.push({
        $match: {
          operatorId: mongoose.Types.ObjectId(operatorId)
        }
      });
    }

    // Add class and price filters
    if (className) {
      pipeline.push({
        $match: {
          [`seatConfiguration.classes.${className}.availableSeats`]: { $gte: parseInt(passengers) }
        }
      });
    }

    // Add price filter
    if (maxPrice) {
      pipeline.push({
        $addFields: {
          minPrice: {
            $min: {
              $map: {
                input: { $objectToArray: '$seatConfiguration.classes' },
                as: 'class',
                in: '$$class.v.price'
              }
            }
          }
        }
      },
      {
        $match: {
          minPrice: { $lte: parseFloat(maxPrice) }
        }
      });
    }

    // Add sorting
    const sortOptions = {
      departureTime: { departureTime: 1 },
      price: { minPrice: 1 },
      duration: { 
        $subtract: ['$arrivalTime', '$departureTime']
      }
    };

    pipeline.push({
      $sort: sortOptions[sortBy] === undefined ? { departureTime: 1 } : sortOptions[sortBy]
    });

    // Add pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);
    pipeline.push({ $skip: skip });
    pipeline.push({ $limit: parseInt(limit) });

    // Execute search
    const schedules = await Schedule.aggregate(pipeline);

    // Get total count for pagination
    const countPipeline = pipeline.slice(0, -2); // Remove skip and limit
    countPipeline.push({ $count: 'total' });
    const countResult = await Schedule.aggregate(countPipeline);
    const total = countResult[0]?.total || 0;

    // Process results
    const processedSchedules = schedules.map(schedule => ({
      id: schedule._id,
      vehicleNumber: schedule.vehicleNumber,
      departureTime: schedule.departureTime,
      arrivalTime: schedule.arrivalTime,
      duration: schedule.arrivalTime - schedule.departureTime,
      status: schedule.status,
      delayMinutes: schedule.delayMinutes,
      availableSeats: schedule.seatConfiguration.availableSeats,
      classes: schedule.seatConfiguration.classes,
      route: {
        id: schedule.route._id,
        from: schedule.fromDest,
        to: schedule.toDest,
        transportType: schedule.route.transportType,
        distance: schedule.route.distance
      },
      operator: {
        id: schedule.operator._id,
        name: schedule.operator.name,
        logo: schedule.operator.logo,
        type: schedule.operator.type
      },
      vehicle: schedule.vehicle,
      gate: schedule.gate,
      terminal: schedule.terminal,
      specialPricing: schedule.specialPricing
    }));

    const result = {
      schedules: processedSchedules,
      searchParams: {
        from: fromDestination,
        to: toDestination,
        departureDate,
        passengers: parseInt(passengers)
      },
      pagination: {
        current: parseInt(page),
        pages: Math.ceil(total / parseInt(limit)),
        total,
        limit: parseInt(limit)
      },
      filters: {
        transportType,
        className,
        maxPrice,
        sortBy
      }
    };

    // Cache results for 5 minutes - Commented out for now
    // if (redis.isConnected) {
    //   await redis.set(cacheKey, result, 300);
    // }

    // Log search
    logger.info('Schedule search performed', {
      from: fromDestination.code,
      to: toDestination.code,
      departureDate,
      passengers,
      resultsCount: processedSchedules.length,
      userId: req.user?._id
    });

    res.json({
      success: true,
      data: result
    });
  })
);

// @route   GET /api/v1/schedules/popular-routes
// @desc    Get popular routes
// @access  Public
router.get('/popular-routes',
  [
    query('limit').optional().isInt({ min: 1, max: 20 })
  ],
  checkValidation,
  asyncHandler(async (req, res) => {
    const { limit = 10 } = req.query;

    // const cacheKey = redis.getCacheKey('popular_routes', limit); // Commented out for now

    // Check cache - Commented out for now
    // if (redis.isConnected) {
    //   const cached = await redis.get(cacheKey);
    //   if (cached) {
    //     return res.json({
    //       success: true,
    //       data: cached,
    //       cached: true
    //     });
    //   }
    // }

    // Get popular routes based on booking frequency
    const popularRoutes = await Schedule.aggregate([
      {
        $match: {
          isActive: true,
          departureTime: { $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) } // Last 30 days
        }
      },
      {
        $lookup: {
          from: 'bookings',
          localField: '_id',
          foreignField: 'scheduleId',
          as: 'bookings'
        }
      },
      {
        $lookup: {
          from: 'routes',
          localField: 'routeId',
          foreignField: '_id',
          as: 'route'
        }
      },
      {
        $unwind: '$route'
      },
      {
        $lookup: {
          from: 'destinations',
          localField: 'route.fromDestination',
          foreignField: '_id',
          as: 'fromDest'
        }
      },
      {
        $lookup: {
          from: 'destinations',
          localField: 'route.toDestination',
          foreignField: '_id',
          as: 'toDest'
        }
      },
      {
        $unwind: '$fromDest'
      },
      {
        $unwind: '$toDest'
      },
      {
        $group: {
          _id: {
            routeId: '$routeId',
            from: '$fromDest',
            to: '$toDest',
            transportType: '$route.transportType'
          },
          bookingCount: { $sum: { $size: '$bookings' } },
          scheduleCount: { $sum: 1 },
          avgPrice: { 
            $avg: {
              $min: {
                $map: {
                  input: { $objectToArray: '$seatConfiguration.classes' },
                  as: 'class',
                  in: '$$class.v.price'
                }
              }
            }
          }
        }
      },
      {
        $sort: { bookingCount: -1 }
      },
      {
        $limit: parseInt(limit)
      },
      {
        $project: {
          route: {
            id: '$_id.routeId',
            from: '$_id.from',
            to: '$_id.to',
            transportType: '$_id.transportType'
          },
          bookingCount: 1,
          scheduleCount: 1,
          avgPrice: { $round: ['$avgPrice', 0] },
          _id: 0
        }
      }
    ]);

    // Cache for 1 hour - Commented out for now
    // if (redis.isConnected) {
    //   await redis.set(cacheKey, popularRoutes, 3600);
    // }

    res.json({
      success: true,
      data: popularRoutes
    });
  })
);

// @route   GET /api/v1/schedules/:id
// @desc    Get schedule by ID
// @access  Public
router.get('/:id',
  param('id').isMongoId().withMessage('Schedule ID không hợp lệ'),
  checkValidation,
  asyncHandler(async (req, res) => {
    const schedule = await Schedule.findById(req.params.id)
      .populate('routeId')
      .populate('operatorId')
      .populate({
        path: 'routeId',
        populate: {
          path: 'fromDestination toDestination',
          model: 'Destination'
        }
      });

    if (!schedule) {
      throw new NotFoundError('Không tìm thấy lịch trình');
    }

    res.json({
      success: true,
      data: { schedule }
    });
  })
);

// @route   GET /api/v1/schedules/:id/availability
// @desc    Get seat availability for schedule
// @access  Public
router.get('/:id/availability',
  param('id').isMongoId().withMessage('Schedule ID không hợp lệ'),
  checkValidation,
  asyncHandler(async (req, res) => {
    const schedule = await Schedule.findById(req.params.id);

    if (!schedule) {
      throw new NotFoundError('Không tìm thấy lịch trình');
    }

    const availability = {
      scheduleId: schedule._id,
      totalSeats: schedule.seatConfiguration.totalSeats,
      availableSeats: schedule.seatConfiguration.availableSeats,
      occupancyRate: schedule.occupancyRate,
      classes: schedule.getAvailableClasses(),
      lastUpdated: schedule.updatedAt
    };

    res.json({
      success: true,
      data: availability
    });
  })
);

// @route   GET /api/v1/schedules/route/:routeId
// @desc    Get schedules by route
// @access  Public
router.get('/route/:routeId',
  [
    param('routeId').isMongoId().withMessage('Route ID không hợp lệ'),
    query('fromDate').optional().isISO8601(),
    query('toDate').optional().isISO8601(),
    query('limit').optional().isInt({ min: 1, max: 100 })
  ],
  checkValidation,
  asyncHandler(async (req, res) => {
    const { routeId } = req.params;
    const { 
      fromDate = new Date().toISOString(),
      toDate,
      limit = 20 
    } = req.query;

    const options = {
      fromDate: new Date(fromDate),
      limit: parseInt(limit)
    };

    if (toDate) {
      options.toDate = new Date(toDate);
    }

    const schedules = await Schedule.findByRoute(routeId, options);

    res.json({
      success: true,
      data: {
        schedules,
        routeId,
        count: schedules.length
      }
    });
  })
);

// @route   GET /api/v1/schedules/operator/:operatorId
// @desc    Get schedules by operator
// @access  Private (Operator/Admin)
router.get('/operator/:operatorId',
  AuthMiddleware.authenticate,
  AuthMiddleware.operatorOrAdmin,
  [
    param('operatorId').isMongoId().withMessage('Operator ID không hợp lệ'),
    query('status').optional().isIn(['scheduled', 'delayed', 'cancelled', 'departed', 'arrived']),
    query('limit').optional().isInt({ min: 1, max: 100 })
  ],
  checkValidation,
  asyncHandler(async (req, res) => {
    const { operatorId } = req.params;
    const { status, limit = 50 } = req.query;

    const options = { limit: parseInt(limit) };
    if (status) {
      options.status = status;
    }

    const schedules = await Schedule.findByOperator(operatorId, options);

    res.json({
      success: true,
      data: {
        schedules,
        operatorId,
        count: schedules.length
      }
    });
  })
);

// @route   GET /api/v1/schedules/delayed
// @desc    Get delayed schedules
// @access  Public
router.get('/delayed',
  asyncHandler(async (req, res) => {
    const delayedSchedules = await Schedule.findDelayed();

    res.json({
      success: true,
      data: {
        schedules: delayedSchedules,
        count: delayedSchedules.length
      }
    });
  })
);

module.exports = router;
