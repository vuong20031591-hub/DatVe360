const express = require('express');
const router = express.Router();
const User = require('../../models/User');
const asyncHandler = require('../../utils/asyncHandler');
const AuthMiddleware = require('../../middleware/auth');

// Apply authentication and authorization middleware
router.use(AuthMiddleware.authenticate);
router.use(AuthMiddleware.authorize('admin', 'operator'));

// @route   GET /api/v1/admin/users
// @desc    Get all users
// @access  Private (Admin, Operator)
router.get('/', asyncHandler(async (req, res) => {
  const users = await User.find()
    .select('-password')
    .sort({ createdAt: -1 });

  res.json({
    success: true,
    data: users,
  });
}));

// @route   GET /api/v1/admin/users/search
// @desc    Search users
// @access  Private (Admin, Operator)
router.get('/search', asyncHandler(async (req, res) => {
  const { q } = req.query;

  if (!q) {
    return res.status(400).json({
      success: false,
      message: 'Query parameter is required',
    });
  }

  const users = await User.find({
    $or: [
      { email: { $regex: q, $options: 'i' } },
      { displayName: { $regex: q, $options: 'i' } },
      { phoneNumber: { $regex: q, $options: 'i' } },
    ],
  })
    .select('-password')
    .sort({ createdAt: -1 });

  res.json({
    success: true,
    data: users,
  });
}));

// @route   GET /api/v1/admin/users/:id
// @desc    Get user by ID
// @access  Private (Admin, Operator)
router.get('/:id', asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.id).select('-password');

  if (!user) {
    return res.status(404).json({
      success: false,
      message: 'User not found',
    });
  }

  res.json({
    success: true,
    data: user,
  });
}));

// @route   POST /api/v1/admin/users
// @desc    Create new user
// @access  Private (Admin)
router.post('/', AuthMiddleware.authorize('admin'), asyncHandler(async (req, res) => {
  const {
    email,
    password,
    displayName,
    phoneNumber,
    role,
    isVerified,
    isActive,
  } = req.body;

  // Check if user already exists
  const existingUser = await User.findOne({ email });
  if (existingUser) {
    return res.status(400).json({
      success: false,
      message: 'User with this email already exists',
    });
  }

  // Create user
  const user = await User.create({
    email,
    password,
    displayName,
    phoneNumber,
    role: role || 'user',
    isVerified: isVerified || false,
    isActive: isActive !== undefined ? isActive : true,
  });

  // Remove password from response
  user.password = undefined;

  res.status(201).json({
    success: true,
    data: user,
  });
}));

// @route   PUT /api/v1/admin/users/:id
// @desc    Update user
// @access  Private (Admin, Operator)
router.put('/:id', asyncHandler(async (req, res) => {
  const {
    displayName,
    phoneNumber,
    role,
    isVerified,
    isActive,
  } = req.body;

  const user = await User.findById(req.params.id);

  if (!user) {
    return res.status(404).json({
      success: false,
      message: 'User not found',
    });
  }

  // Update fields
  if (displayName !== undefined) user.displayName = displayName;
  if (phoneNumber !== undefined) user.phoneNumber = phoneNumber;
  if (role !== undefined && req.user.role === 'admin') user.role = role;
  if (isVerified !== undefined) user.isVerified = isVerified;
  if (isActive !== undefined) user.isActive = isActive;

  await user.save();

  // Remove password from response
  user.password = undefined;

  res.json({
    success: true,
    data: user,
  });
}));

// @route   POST /api/v1/admin/users/:id/suspend
// @desc    Suspend user temporarily
// @access  Private (Admin, Operator)
router.post('/:id/suspend', asyncHandler(async (req, res) => {
  const { durationInDays, reason } = req.body;

  if (!durationInDays || !reason) {
    return res.status(400).json({
      success: false,
      message: 'Duration and reason are required',
    });
  }

  const user = await User.findById(req.params.id);

  if (!user) {
    return res.status(404).json({
      success: false,
      message: 'User not found',
    });
  }

  // Calculate suspension end date
  const suspendedUntil = new Date();
  const days = parseInt(durationInDays);

  if (days === 1) {
    // Khóa 1 ngày: mở lại vào đúng giờ này ngày mai
    suspendedUntil.setDate(suspendedUntil.getDate() + 1);
  } else {
    // Khóa nhiều ngày: mở lại vào 6h sáng của ngày đó
    suspendedUntil.setDate(suspendedUntil.getDate() + days);
    suspendedUntil.setHours(6, 0, 0, 0); // 6:00:00 AM
  }

  user.suspendedUntil = suspendedUntil;
  user.suspensionReason = reason;
  user.isPermanentlySuspended = false;
  user.isActive = false;

  await user.save();

  // Remove password from response
  user.password = undefined;

  res.json({
    success: true,
    data: user,
  });
}));

// @route   POST /api/v1/admin/users/:id/suspend-permanent
// @desc    Suspend user permanently
// @access  Private (Admin)
router.post('/:id/suspend-permanent', AuthMiddleware.authorize('admin'), asyncHandler(async (req, res) => {
  const { reason } = req.body;

  if (!reason) {
    return res.status(400).json({
      success: false,
      message: 'Reason is required',
    });
  }

  const user = await User.findById(req.params.id);

  if (!user) {
    return res.status(404).json({
      success: false,
      message: 'User not found',
    });
  }

  user.isPermanentlySuspended = true;
  user.suspensionReason = reason;
  user.isActive = false;

  await user.save();

  // Remove password from response
  user.password = undefined;

  res.json({
    success: true,
    data: user,
  });
}));

// @route   POST /api/v1/admin/users/:id/unsuspend
// @desc    Unsuspend user
// @access  Private (Admin, Operator)
router.post('/:id/unsuspend', asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.id);

  if (!user) {
    return res.status(404).json({
      success: false,
      message: 'User not found',
    });
  }

  user.suspendedUntil = null;
  user.suspensionReason = null;
  user.isPermanentlySuspended = false;
  user.isActive = true;

  await user.save();

  // Remove password from response
  user.password = undefined;

  res.json({
    success: true,
    data: user,
  });
}));

// @route   DELETE /api/v1/admin/users/:id
// @desc    Delete user
// @access  Private (Admin)
router.delete('/:id', AuthMiddleware.authorize('admin'), asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.id);

  if (!user) {
    return res.status(404).json({
      success: false,
      message: 'User not found',
    });
  }

  // Prevent deleting yourself
  if (user._id.toString() === req.user._id.toString()) {
    return res.status(400).json({
      success: false,
      message: 'You cannot delete your own account',
    });
  }

  await user.deleteOne();

  res.json({
    success: true,
    message: 'User deleted successfully',
  });
}));

// @route   PUT /api/v1/admin/users/:id/role
// @desc    Change user role
// @access  Private (Admin)
router.put('/:id/role', AuthMiddleware.authorize('admin'), asyncHandler(async (req, res) => {
  const { role } = req.body;

  if (!role || !['user', 'operator', 'admin'].includes(role)) {
    return res.status(400).json({
      success: false,
      message: 'Invalid role',
    });
  }

  const user = await User.findById(req.params.id);

  if (!user) {
    return res.status(404).json({
      success: false,
      message: 'User not found',
    });
  }

  user.role = role;
  await user.save();

  // Remove password from response
  user.password = undefined;

  res.json({
    success: true,
    data: user,
  });
}));

// @route   POST /api/v1/admin/users/:id/verify
// @desc    Verify user email
// @access  Private (Admin, Operator)
router.post('/:id/verify', asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.id);

  if (!user) {
    return res.status(404).json({
      success: false,
      message: 'User not found',
    });
  }

  user.isVerified = true;
  await user.save();

  // Remove password from response
  user.password = undefined;

  res.json({
    success: true,
    data: user,
  });
}));

// @route   POST /api/v1/admin/users/:id/reset-password
// @desc    Reset user password
// @access  Private (Admin)
router.post('/:id/reset-password', AuthMiddleware.authorize('admin'), asyncHandler(async (req, res) => {
  const { newPassword } = req.body;

  if (!newPassword || newPassword.length < 6) {
    return res.status(400).json({
      success: false,
      message: 'Password must be at least 6 characters',
    });
  }

  const user = await User.findById(req.params.id);

  if (!user) {
    return res.status(404).json({
      success: false,
      message: 'User not found',
    });
  }

  user.password = newPassword;
  await user.save();

  res.json({
    success: true,
    message: 'Password reset successfully',
  });
}));

module.exports = router;

