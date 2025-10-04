const express = require('express');
const Destination = require('../models/Destination');
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
