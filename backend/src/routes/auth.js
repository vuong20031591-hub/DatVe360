const express = require('express');
const { body, validationResult } = require('express-validator');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const User = require('../models/User');
const AuthMiddleware = require('../middleware/auth');
const { asyncHandler, ValidationError, UnauthorizedError, NotFoundError } = require('../middleware/errorHandler');
const logger = require('../utils/logger');
// const redis = require('../config/redis'); // Commented out for now

const router = express.Router();

// Validation rules
const registerValidation = [
  body('email')
    .isEmail()
    .withMessage('Email không hợp lệ')
    .normalizeEmail(),
  body('password')
    .isLength({ min: 6 })
    .withMessage('Mật khẩu phải có ít nhất 6 ký tự'),
  body('displayName')
    .trim()
    .isLength({ min: 2 })
    .withMessage('Tên hiển thị phải có ít nhất 2 ký tự'),
  body('phoneNumber')
    .optional()
    .isMobilePhone('vi-VN')
    .withMessage('Số điện thoại không hợp lệ')
];

const loginValidation = [
  body('email')
    .isEmail()
    .withMessage('Email không hợp lệ')
    .normalizeEmail(),
  body('password')
    .notEmpty()
    .withMessage('Mật khẩu không được để trống')
];

const checkValidation = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ValidationError(errors.array().map(err => err.msg).join(', '));
  }
  next();
};

// @route   POST /api/v1/auth/register
// @desc    Register new user
// @access  Public
router.post('/register', 
  registerValidation,
  checkValidation,
  AuthMiddleware.logAuthEvent('REGISTER'),
  asyncHandler(async (req, res) => {
    const { email, password, displayName, phoneNumber } = req.body;

    // Check if user exists
    const existingUser = await User.findByEmail(email);
    if (existingUser) {
      throw new ValidationError('Email đã được sử dụng');
    }

    // Check phone number if provided
    if (phoneNumber) {
      const existingPhone = await User.findByPhoneNumber(phoneNumber);
      if (existingPhone) {
        throw new ValidationError('Số điện thoại đã được sử dụng');
      }
    }

    // Create user
    const user = new User({
      email,
      password,
      displayName,
      phoneNumber,
      role: 'user'
    });

    await user.save();

    // Generate verification token
    await user.generateVerification();

    // Generate tokens
    const { accessToken, refreshToken } = AuthMiddleware.generateTokens(user._id);
    await user.addRefreshToken(refreshToken);

    logger.info('User registered', {
      userId: user._id,
      email: user.email
    });

    res.status(201).json({
      success: true,
      message: 'Đăng ký thành công',
      data: {
        user: {
          id: user._id,
          email: user.email,
          displayName: user.displayName,
          role: user.role,
          isVerified: user.isVerified
        },
        tokens: {
          accessToken,
          refreshToken,
          expiresIn: process.env.JWT_EXPIRES_IN || '7d'
        }
      }
    });
  })
);

// @route   POST /api/v1/auth/login
// @desc    Login user
// @access  Public
router.post('/login',
  loginValidation,
  checkValidation,
  AuthMiddleware.logAuthEvent('LOGIN'),
  asyncHandler(async (req, res) => {
    const { email, password, rememberMe } = req.body;

    // Find user with password
    const user = await User.findOne({ email: email.toLowerCase() }).select('+password');
    
    if (!user || !user.isActive) {
      throw new UnauthorizedError('Email hoặc mật khẩu không chính xác');
    }

    // Check password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      throw new UnauthorizedError('Email hoặc mật khẩu không chính xác');
    }

    // Update last login
    await user.updateLastLogin();

    // Generate tokens
    const { accessToken, refreshToken } = AuthMiddleware.generateTokens(user._id);
    await user.addRefreshToken(refreshToken);

    // Set token expiry based on remember me
    const tokenExpiry = rememberMe ? '30d' : '7d';

    logger.info('User logged in', {
      userId: user._id,
      email: user.email,
      rememberMe
    });

    res.json({
      success: true,
      message: 'Đăng nhập thành công',
      data: {
        user: {
          id: user._id,
          email: user.email,
          displayName: user.displayName,
          role: user.role,
          isVerified: user.isVerified,
          photoURL: user.photoURL,
          preferences: user.preferences
        },
        tokens: {
          accessToken,
          refreshToken,
          expiresIn: tokenExpiry
        }
      }
    });
  })
);

// @route   POST /api/v1/auth/refresh
// @desc    Refresh access token
// @access  Public
router.post('/refresh',
  body('refreshToken').notEmpty().withMessage('Refresh token không được để trống'),
  checkValidation,
  asyncHandler(async (req, res) => {
    const { refreshToken } = req.body;

    // Verify refresh token
    const { userId } = await AuthMiddleware.verifyRefreshToken(refreshToken);

    // Find user
    const user = await User.findById(userId);
    if (!user || !user.isActive) {
      throw new UnauthorizedError('User không tồn tại hoặc đã bị vô hiệu hóa');
    }

    // Generate new tokens
    const { accessToken, refreshToken: newRefreshToken } = AuthMiddleware.generateTokens(userId);

    // Remove old refresh token and add new one
    await user.removeRefreshToken(refreshToken);
    await user.addRefreshToken(newRefreshToken);

    logger.info('Token refreshed', { userId });

    res.json({
      success: true,
      message: 'Token đã được làm mới',
      data: {
        tokens: {
          accessToken,
          refreshToken: newRefreshToken,
          expiresIn: process.env.JWT_EXPIRES_IN || '7d'
        }
      }
    });
  })
);

// @route   POST /api/v1/auth/logout
// @desc    Logout user
// @access  Private
router.post('/logout',
  AuthMiddleware.authenticate,
  AuthMiddleware.logAuthEvent('LOGOUT'),
  asyncHandler(async (req, res) => {
    const { refreshToken } = req.body;

    if (refreshToken) {
      await req.user.removeRefreshToken(refreshToken);
    }

    // Add token to blacklist (if using Redis) - Commented out for now
    // if (redis.isConnected) {
    //   const tokenExpiry = Math.floor(Date.now() / 1000) + (7 * 24 * 60 * 60); // 7 days
    //   await redis.set(`blacklist_${req.token}`, '1', tokenExpiry);
    // }

    logger.info('User logged out', {
      userId: req.user._id,
      email: req.user.email
    });

    res.json({
      success: true,
      message: 'Đăng xuất thành công'
    });
  })
);

// @route   POST /api/v1/auth/logout-all
// @desc    Logout from all devices
// @access  Private
router.post('/logout-all',
  AuthMiddleware.authenticate,
  AuthMiddleware.logAuthEvent('LOGOUT_ALL'),
  asyncHandler(async (req, res) => {
    await req.user.clearRefreshTokens();

    logger.info('User logged out from all devices', {
      userId: req.user._id,
      email: req.user.email
    });

    res.json({
      success: true,
      message: 'Đã đăng xuất khỏi tất cả thiết bị'
    });
  })
);

// @route   GET /api/v1/auth/me
// @desc    Get current user
// @access  Private
router.get('/me',
  AuthMiddleware.authenticate,
  asyncHandler(async (req, res) => {
    res.json({
      success: true,
      data: {
        user: {
          id: req.user._id,
          email: req.user.email,
          displayName: req.user.displayName,
          phoneNumber: req.user.phoneNumber,
          role: req.user.role,
          isVerified: req.user.isVerified,
          photoURL: req.user.photoURL,
          preferences: req.user.preferences,
          profile: req.user.profile,
          createdAt: req.user.createdAt,
          lastLoginAt: req.user.lastLoginAt
        }
      }
    });
  })
);

// @route   PUT /api/v1/auth/profile
// @desc    Update user profile
// @access  Private
router.put('/profile',
  AuthMiddleware.authenticate,
  [
    body('displayName').optional().trim().isLength({ min: 2 }),
    body('phoneNumber').optional().isMobilePhone('vi-VN'),
    body('profile.firstName').optional().trim().isLength({ min: 1 }),
    body('profile.lastName').optional().trim().isLength({ min: 1 }),
    body('profile.dateOfBirth').optional().isISO8601(),
    body('profile.gender').optional().isIn(['male', 'female', 'other'])
  ],
  checkValidation,
  asyncHandler(async (req, res) => {
    const allowedUpdates = [
      'displayName', 'phoneNumber', 'photoURL', 'preferences', 'profile'
    ];

    const updates = {};
    allowedUpdates.forEach(field => {
      if (req.body[field] !== undefined) {
        updates[field] = req.body[field];
      }
    });

    // Check phone number uniqueness if updating
    if (updates.phoneNumber && updates.phoneNumber !== req.user.phoneNumber) {
      const existingPhone = await User.findByPhoneNumber(updates.phoneNumber);
      if (existingPhone) {
        throw new ValidationError('Số điện thoại đã được sử dụng');
      }
    }

    Object.assign(req.user, updates);
    await req.user.save();

    logger.info('Profile updated', {
      userId: req.user._id,
      updates: Object.keys(updates)
    });

    res.json({
      success: true,
      message: 'Cập nhật thông tin thành công',
      data: {
        user: req.user
      }
    });
  })
);

// @route   POST /api/v1/auth/change-password
// @desc    Change password
// @access  Private
router.post('/change-password',
  AuthMiddleware.authenticate,
  [
    body('currentPassword').notEmpty().withMessage('Mật khẩu hiện tại không được để trống'),
    body('newPassword').isLength({ min: 6 }).withMessage('Mật khẩu mới phải có ít nhất 6 ký tự')
  ],
  checkValidation,
  asyncHandler(async (req, res) => {
    const { currentPassword, newPassword } = req.body;

    // Get user with password
    const user = await User.findById(req.user._id).select('+password');
    
    // Verify current password
    const isMatch = await user.comparePassword(currentPassword);
    if (!isMatch) {
      throw new UnauthorizedError('Mật khẩu hiện tại không chính xác');
    }

    // Update password
    user.password = newPassword;
    await user.save();

    // Clear all refresh tokens for security
    await user.clearRefreshTokens();

    logger.info('Password changed', {
      userId: user._id,
      email: user.email
    });

    res.json({
      success: true,
      message: 'Đổi mật khẩu thành công. Vui lòng đăng nhập lại.'
    });
  })
);

// @route   POST /api/v1/auth/forgot-password
// @desc    Forgot password
// @access  Public
router.post('/forgot-password',
  body('email').isEmail().withMessage('Email không hợp lệ').normalizeEmail(),
  checkValidation,
  asyncHandler(async (req, res) => {
    const { email } = req.body;

    const user = await User.findByEmail(email);
    if (!user) {
      throw new NotFoundError('Không tìm thấy tài khoản với email này');
    }

    // Generate reset token
    await user.generatePasswordReset();

    // In production, send email here
    logger.info('Password reset requested', {
      userId: user._id,
      email: user.email,
      resetToken: user.resetPasswordToken
    });

    res.json({
      success: true,
      message: 'Link đặt lại mật khẩu đã được gửi đến email của bạn',
      ...(process.env.NODE_ENV === 'development' && {
        resetToken: user.resetPasswordToken
      })
    });
  })
);

// @route   POST /api/v1/auth/reset-password
// @desc    Reset password
// @access  Public
router.post('/reset-password',
  [
    body('token').notEmpty().withMessage('Token không được để trống'),
    body('password').isLength({ min: 6 }).withMessage('Mật khẩu mới phải có ít nhất 6 ký tự')
  ],
  checkValidation,
  asyncHandler(async (req, res) => {
    const { token, password } = req.body;

    const user = await User.findOne({
      resetPasswordToken: token,
      resetPasswordExpires: { $gt: Date.now() }
    });

    if (!user) {
      throw new UnauthorizedError('Token không hợp lệ hoặc đã hết hạn');
    }

    // Reset password
    user.password = password;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpires = undefined;
    await user.save();

    // Clear all refresh tokens
    await user.clearRefreshTokens();

    logger.info('Password reset completed', {
      userId: user._id,
      email: user.email
    });

    res.json({
      success: true,
      message: 'Đặt lại mật khẩu thành công. Vui lòng đăng nhập.'
    });
  })
);

module.exports = router;
