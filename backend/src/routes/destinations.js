const express = require('express');
const Destination = require('../models/Destination');
const Route = require('../models/Route');
const { asyncHandler } = require('../middleware/errorHandler');

const router = express.Router();

// @route   GET /api/v1/destinations/popular
// @desc    Get popular destinations
// @access  Public
router.get('/popular', asyncHandler(async (req, res) => {
  const destinations = await Destination.find({ 
    active: true,
    popular: true 
  }).limit(10);

  res.json({
    success: true,
    data: destinations
  });
}));

// @route   GET /api/v1/destinations/nearby
// @desc    Get nearby destinations using geospatial query
// @access  Public
router.get('/nearby', asyncHandler(async (req, res) => {
  const { latitude, longitude, maxDistance = 50000 } = req.query;

  if (!latitude || !longitude) {
    return res.status(400).json({
      success: false,
      message: 'Vui lòng cung cấp latitude và longitude'
    });
  }

  const destinations = await Destination.find({
    active: true,
    coordinates: {
      $near: {
        $geometry: {
          type: 'Point',
          coordinates: [parseFloat(longitude), parseFloat(latitude)]
        },
        $maxDistance: parseInt(maxDistance)
      }
    }
  }).limit(20);

  res.json({
    success: true,
    data: destinations,
    params: {
      latitude: parseFloat(latitude),
      longitude: parseFloat(longitude),
      maxDistance: parseInt(maxDistance)
    }
  });
}));

// @route   GET /api/v1/destinations/from
// @desc    Get all destinations that have outgoing routes (có route đi)
// @access  Public
router.get('/from', asyncHandler(async (req, res) => {
  const { transportType } = req.query;

  // Build query
  const routeQuery = {};
  if (transportType) {
    routeQuery.transportType = transportType;
  }

  // Get all unique fromDestination IDs
  const routes = await Route.find(routeQuery).distinct('fromDestination');

  // Get destinations
  const destinations = await Destination.find({
    _id: { $in: routes },
    active: true
  }).sort({ city: 1, name: 1 });

  res.json({
    success: true,
    data: destinations,
    count: destinations.length
  });
}));

// @route   GET /api/v1/destinations/to
// @desc    Get destinations that have routes from a specific origin
// @access  Public
router.get('/to', asyncHandler(async (req, res) => {
  const { from, transportType } = req.query;

  if (!from) {
    return res.status(400).json({
      success: false,
      message: 'Vui lòng cung cấp mã điểm đi (from)'
    });
  }

  // Find origin destination
  const fromDestination = await Destination.findOne({
    code: from.toUpperCase(),
    active: true
  });

  if (!fromDestination) {
    return res.status(404).json({
      success: false,
      message: `Không tìm thấy điểm đi: ${from}`
    });
  }

  // Build route query
  const routeQuery = {
    fromDestination: fromDestination._id
  };
  if (transportType) {
    routeQuery.transportType = transportType;
  }

  // Get all routes from this origin
  const routes = await Route.find(routeQuery).distinct('toDestination');

  // Get destinations
  const destinations = await Destination.find({
    _id: { $in: routes },
    active: true
  }).sort({ city: 1, name: 1 });

  res.json({
    success: true,
    data: destinations,
    count: destinations.length,
    from: {
      code: fromDestination.code,
      name: fromDestination.name
    }
  });
}));

// @route   GET /api/v1/destinations/search
// @desc    Search destinations
// @access  Public
router.get('/search', asyncHandler(async (req, res) => {
  const { q } = req.query;

  if (!q) {
    return res.json({
      success: true,
      data: []
    });
  }

  const destinations = await Destination.find({
    active: true,
    $or: [
      { name: new RegExp(q, 'i') },
      { code: new RegExp(q, 'i') },
      { city: new RegExp(q, 'i') }
    ]
  }).limit(20);

  res.json({
    success: true,
    data: destinations
  });
}));

// @route   GET /api/v1/destinations
// @desc    Get all destinations
// @access  Public
router.get('/', asyncHandler(async (req, res) => {
  const destinations = await Destination.find({ active: true });

  res.json({
    success: true,
    data: destinations
  });
}));

// @route   GET /api/v1/destinations/:id
// @desc    Get destination by ID
// @access  Public
router.get('/:id', asyncHandler(async (req, res) => {
  const destination = await Destination.findById(req.params.id);

  if (!destination) {
    return res.status(404).json({
      success: false,
      message: 'Không tìm thấy điểm đến'
    });
  }

  res.json({
    success: true,
    data: destination
  });
}));

// @route   POST /api/v1/destinations
// @desc    Create new destination
// @access  Private (Admin only)
router.post('/', asyncHandler(async (req, res) => {
  const destination = new Destination(req.body);
  await destination.save();

  res.status(201).json({
    success: true,
    message: 'Đã tạo điểm đến mới',
    data: destination
  });
}));

// @route   PUT /api/v1/destinations/:id
// @desc    Update destination
// @access  Private (Admin only)
router.put('/:id', asyncHandler(async (req, res) => {
  const destination = await Destination.findByIdAndUpdate(
    req.params.id,
    req.body,
    { new: true, runValidators: true }
  );

  if (!destination) {
    return res.status(404).json({
      success: false,
      message: 'Không tìm thấy điểm đến'
    });
  }

  res.json({
    success: true,
    message: 'Đã cập nhật điểm đến',
    data: destination
  });
}));

// @route   DELETE /api/v1/destinations/:id
// @desc    Delete destination
// @access  Private (Admin only)
router.delete('/:id', asyncHandler(async (req, res) => {
  const destination = await Destination.findByIdAndDelete(req.params.id);

  if (!destination) {
    return res.status(404).json({
      success: false,
      message: 'Không tìm thấy điểm đến'
    });
  }

  res.json({
    success: true,
    message: 'Đã xóa điểm đến'
  });
}));

module.exports = router;
