const express = require('express');
const Trip = require('../models/Trip');
const { asyncHandler, NotFoundError } = require('../middleware/errorHandler');
const { searchValidations, commonValidations } = require('../middleware/validation');
const { optionalAuth } = require('../middleware/auth');
const { cache } = require('../config/redis');

const router = express.Router();

// @desc    Search trips
// @route   GET /api/v1/trips/search
// @access  Public
router.get('/search', searchValidations.searchTrips, asyncHandler(async (req, res) => {
  const {
    from,
    to,
    departDate,
    mode,
    passengers = 1,
    minPrice,
    maxPrice,
    carrierId,
    page = 1,
    limit = 20,
    sortBy = 'departAt',
    sortOrder = 'asc'
  } = req.query;

  // Create cache key
  const cacheKey = `trip_search:${JSON.stringify(req.query)}`;
  
  // Try to get from cache first
  const cachedResults = await cache.get(cacheKey);
  if (cachedResults) {
    return res.json({
      success: true,
      data: cachedResults,
      cached: true
    });
  }

  const searchParams = {
    from: from?.toUpperCase(),
    to: to?.toUpperCase(),
    departDate,
    mode,
    minPrice: minPrice ? parseFloat(minPrice) : undefined,
    maxPrice: maxPrice ? parseFloat(maxPrice) : undefined,
    carrierId,
    page: parseInt(page),
    limit: parseInt(limit),
    sortBy,
    sortOrder
  };

  const trips = await Trip.searchTrips(searchParams);
  
  // Get total count for pagination
  const totalQuery = {
    isActive: true,
    status: 'scheduled',
    allowBooking: true,
    ...(from && { fromCode: from.toUpperCase() }),
    ...(to && { toCode: to.toUpperCase() }),
    ...(mode && { mode }),
    ...(carrierId && { carrierId })
  };

  if (departDate) {
    const startOfDay = new Date(departDate);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(departDate);
    endOfDay.setHours(23, 59, 59, 999);
    totalQuery.departAt = { $gte: startOfDay, $lte: endOfDay };
  }

  const total = await Trip.countDocuments(totalQuery);

  const result = {
    trips,
    pagination: {
      currentPage: parseInt(page),
      totalPages: Math.ceil(total / parseInt(limit)),
      totalTrips: total,
      hasNext: page < Math.ceil(total / limit),
      hasPrev: page > 1
    },
    searchParams: {
      from: from?.toUpperCase(),
      to: to?.toUpperCase(),
      departDate,
      mode,
      passengers: parseInt(passengers)
    }
  };

  // Cache results for 10 minutes
  await cache.set(cacheKey, result, 600);

  res.json({
    success: true,
    data: result
  });
}));

// @desc    Get trip by ID
// @route   GET /api/v1/trips/:id
// @access  Public
router.get('/:id', commonValidations.objectId('id'), asyncHandler(async (req, res) => {
  const { id } = req.params;
  
  // Check cache first
  const cacheKey = `trip:${id}`;
  const cachedTrip = await cache.get(cacheKey);
  
  if (cachedTrip) {
    return res.json({
      success: true,
      data: { trip: cachedTrip },
      cached: true
    });
  }

  const trip = await Trip.findById(id);

  if (!trip) {
    throw new NotFoundError('Không tìm thấy chuyến đi');
  }

  if (!trip.isActive) {
    throw new NotFoundError('Chuyến đi không khả dụng');
  }

  // Cache trip for 5 minutes
  await cache.set(cacheKey, trip, 300);

  res.json({
    success: true,
    data: { trip }
  });
}));

// @desc    Get popular routes
// @route   GET /api/v1/trips/popular-routes
// @access  Public
router.get('/popular-routes', asyncHandler(async (req, res) => {
  const { limit = 10 } = req.query;
  
  const cacheKey = `popular_routes:${limit}`;
  const cachedRoutes = await cache.get(cacheKey);
  
  if (cachedRoutes) {
    return res.json({
      success: true,
      data: { routes: cachedRoutes },
      cached: true
    });
  }

  const routes = await Trip.getPopularRoutes(parseInt(limit));

  // Cache for 1 hour
  await cache.set(cacheKey, routes, 3600);

  res.json({
    success: true,
    data: { routes }
  });
}));

// @desc    Get trip schedules by route
// @route   GET /api/v1/trips/schedules/:fromCode/:toCode
// @access  Public
router.get('/schedules/:fromCode/:toCode', asyncHandler(async (req, res) => {
  const { fromCode, toCode } = req.params;
  const { 
    date,
    mode,
    limit = 50,
    sortBy = 'departAt',
    sortOrder = 'asc'
  } = req.query;

  const query = {
    fromCode: fromCode.toUpperCase(),
    toCode: toCode.toUpperCase(),
    isActive: true,
    status: 'scheduled',
    allowBooking: true
  };

  if (mode) query.mode = mode;
  
  if (date) {
    const startOfDay = new Date(date);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(date);
    endOfDay.setHours(23, 59, 59, 999);
    query.departAt = { $gte: startOfDay, $lte: endOfDay };
  }

  const trips = await Trip.find(query)
    .sort({ [sortBy]: sortOrder === 'desc' ? -1 : 1 })
    .limit(parseInt(limit))
    .select('carrierId carrierName carrierLogo mode departAt arriveAt duration classOptions basePrice currency');

  // Group by time slots
  const timeSlots = {
    morning: [],   // 6:00 - 11:59
    afternoon: [], // 12:00 - 17:59
    evening: [],   // 18:00 - 23:59
    night: []      // 0:00 - 5:59
  };

  trips.forEach(trip => {
    const hour = new Date(trip.departAt).getHours();
    
    if (hour >= 6 && hour < 12) {
      timeSlots.morning.push(trip);
    } else if (hour >= 12 && hour < 18) {
      timeSlots.afternoon.push(trip);
    } else if (hour >= 18 && hour < 24) {
      timeSlots.evening.push(trip);
    } else {
      timeSlots.night.push(trip);
    }
  });

  res.json({
    success: true,
    data: {
      route: {
        from: fromCode.toUpperCase(),
        to: toCode.toUpperCase(),
        date: date || null
      },
      totalTrips: trips.length,
      timeSlots,
      trips
    }
  });
}));

// @desc    Get available carriers for route
// @route   GET /api/v1/trips/carriers/:fromCode/:toCode
// @access  Public
router.get('/carriers/:fromCode/:toCode', asyncHandler(async (req, res) => {
  const { fromCode, toCode } = req.params;
  const { mode } = req.query;

  const query = {
    fromCode: fromCode.toUpperCase(),
    toCode: toCode.toUpperCase(),
    isActive: true,
    status: 'scheduled'
  };

  if (mode) query.mode = mode;

  const carriers = await Trip.aggregate([
    { $match: query },
    {
      $group: {
        _id: '$carrierId',
        name: { $first: '$carrierName' },
        logo: { $first: '$carrierLogo' },
        modes: { $addToSet: '$mode' },
        tripCount: { $sum: 1 },
        minPrice: { $min: '$basePrice' },
        avgPrice: { $avg: '$basePrice' }
      }
    },
    { $sort: { name: 1 } }
  ]);

  res.json({
    success: true,
    data: { carriers }
  });
}));

// @desc    Check seat availability
// @route   GET /api/v1/trips/:id/availability
// @access  Public
router.get('/:id/availability', commonValidations.objectId('id'), asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { classId, passengers = 1 } = req.query;

  const trip = await Trip.findById(id);

  if (!trip) {
    throw new NotFoundError('Không tìm thấy chuyến đi');
  }

  if (!trip.canBook) {
    return res.json({
      success: true,
      data: {
        available: false,
        reason: 'Chuyến đi không khả dụng để đặt'
      }
    });
  }

  let availability = {};

  if (classId) {
    // Check specific class
    const isAvailable = trip.checkSeatAvailability(classId, parseInt(passengers));
    const classOption = trip.classOptions.find(option => option.id === classId);
    
    availability = {
      available: isAvailable,
      class: classOption || null,
      requestedSeats: parseInt(passengers)
    };
  } else {
    // Check all classes
    availability = {
      classes: trip.classOptions.map(option => ({
        ...option.toObject(),
        available: option.availableSeats >= parseInt(passengers)
      })),
      totalAvailableSeats: trip.totalAvailableSeats,
      canBook: trip.canBook
    };
  }

  res.json({
    success: true,
    data: availability
  });
}));

module.exports = router;
