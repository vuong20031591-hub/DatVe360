const express = require('express');
const router = express.Router();
const TransportOperator = require('../../models/TransportOperator');
const AuthMiddleware = require('../../middleware/auth');
const asyncHandler = require('../../utils/asyncHandler');

// Apply authentication middleware
router.use(AuthMiddleware.authenticate);

// @route   GET /api/v1/admin/categories
// @desc    Get all transport operators grouped by type
// @access  Private (Admin, Operator)
router.get('/', AuthMiddleware.authorize('admin', 'operator'), asyncHandler(async (req, res) => {
  const operators = await TransportOperator.find({ isActive: true }).sort({ name: 1 });

  // Group by transport type
  const grouped = {
    flight: operators.filter(op => op.transportTypes.includes('flight')),
    train: operators.filter(op => op.transportTypes.includes('train')),
    bus: operators.filter(op => op.transportTypes.includes('bus'))
  };

  res.json({
    success: true,
    data: grouped
  });
}));

// @route   GET /api/v1/admin/categories/stats/overview
// @desc    Get categories statistics
// @access  Private (Admin, Operator)
router.get('/stats/overview', AuthMiddleware.authorize('admin', 'operator'), asyncHandler(async (req, res) => {
  const [total, airlines, trains, buses, active] = await Promise.all([
    TransportOperator.countDocuments(),
    TransportOperator.countDocuments({ transportTypes: 'flight' }),
    TransportOperator.countDocuments({ transportTypes: 'train' }),
    TransportOperator.countDocuments({ transportTypes: 'bus' }),
    TransportOperator.countDocuments({ isActive: true })
  ]);

  res.json({
    success: true,
    data: {
      total,
      airlines,
      trains,
      buses,
      active,
      inactive: total - active
    }
  });
}));

// @route   GET /api/v1/admin/categories/:type
// @desc    Get operators by transport type
// @access  Private (Admin, Operator)
router.get('/:type', AuthMiddleware.authorize('admin', 'operator'), asyncHandler(async (req, res) => {
  const { type } = req.params;

  if (!['flight', 'train', 'bus'].includes(type)) {
    return res.status(400).json({
      success: false,
      message: 'Invalid transport type'
    });
  }

  const operators = await TransportOperator.findByTransportType(type);

  res.json({
    success: true,
    data: operators
  });
}));

// @route   POST /api/v1/admin/categories
// @desc    Create new transport operator
// @access  Private (Admin)
router.post('/', AuthMiddleware.authorize('admin'), asyncHandler(async (req, res) => {
  const { name, code, transportTypes, contactInfo, metadata } = req.body;

  // Check if code already exists
  const existing = await TransportOperator.findOne({ code: code.toUpperCase() });
  if (existing) {
    return res.status(400).json({
      success: false,
      message: 'Mã nhà cung cấp đã tồn tại'
    });
  }

  const operator = await TransportOperator.create({
    name,
    code: code.toUpperCase(),
    transportTypes,
    contactInfo,
    metadata,
    isActive: true
  });

  res.status(201).json({
    success: true,
    message: 'Tạo nhà cung cấp thành công',
    data: operator
  });
}));

// @route   PUT /api/v1/admin/categories/:id
// @desc    Update transport operator
// @access  Private (Admin)
router.put('/:id', AuthMiddleware.authorize('admin'), asyncHandler(async (req, res) => {
  const { name, code, transportTypes, contactInfo, metadata, isActive } = req.body;

  const operator = await TransportOperator.findById(req.params.id);
  if (!operator) {
    return res.status(404).json({
      success: false,
      message: 'Không tìm thấy nhà cung cấp'
    });
  }

  // Check if new code conflicts with another operator
  if (code && code.toUpperCase() !== operator.code) {
    const existing = await TransportOperator.findOne({ 
      code: code.toUpperCase(),
      _id: { $ne: req.params.id }
    });
    if (existing) {
      return res.status(400).json({
        success: false,
        message: 'Mã nhà cung cấp đã tồn tại'
      });
    }
  }

  // Update fields
  if (name) operator.name = name;
  if (code) operator.code = code.toUpperCase();
  if (transportTypes) operator.transportTypes = transportTypes;
  if (contactInfo) operator.contactInfo = contactInfo;
  if (metadata) operator.metadata = metadata;
  if (typeof isActive !== 'undefined') operator.isActive = isActive;

  await operator.save();

  res.json({
    success: true,
    message: 'Cập nhật nhà cung cấp thành công',
    data: operator
  });
}));

// @route   DELETE /api/v1/admin/categories/:id
// @desc    Delete transport operator (soft delete)
// @access  Private (Admin)
router.delete('/:id', AuthMiddleware.authorize('admin'), asyncHandler(async (req, res) => {
  const operator = await TransportOperator.findById(req.params.id);
  
  if (!operator) {
    return res.status(404).json({
      success: false,
      message: 'Không tìm thấy nhà cung cấp'
    });
  }

  // Soft delete
  operator.isActive = false;
  await operator.save();

  res.json({
    success: true,
    message: 'Xóa nhà cung cấp thành công'
  });
}));

module.exports = router;

