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

module.exports = router;
