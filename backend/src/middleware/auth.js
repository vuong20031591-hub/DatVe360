const jwt = require('jsonwebtoken');
const User = require('../models/User');
const logger = require('../config/logger');

class AuthMiddleware {
  // Verify JWT token
  static async authenticate(req, res, next) {
    try {
      const token = AuthMiddleware.extractToken(req);
      
      if (!token) {
        return res.status(401).json({
          success: false,
          message: 'Token không được cung cấp'
        });
      }

      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.userId).select('-password');
      
      if (!user || !user.isActive) {
        return res.status(401).json({
          success: false,
          message: 'Token không hợp lệ hoặc user đã bị vô hiệu hóa'
        });
      }

      req.user = user;
      req.token = token;
      next();
    } catch (error) {
      logger.authLogger.error('Authentication failed', { error: error.message });
      
      if (error.name === 'JsonWebTokenError') {
        return res.status(401).json({
          success: false,
          message: 'Token không hợp lệ'
        });
      }
      
      if (error.name === 'TokenExpiredError') {
        return res.status(401).json({
          success: false,
          message: 'Token đã hết hạn'
        });
      }

      return res.status(500).json({
        success: false,
        message: 'Lỗi xác thực'
      });
    }
  }

  // Optional authentication (doesn't fail if no token)
  static async optionalAuth(req, res, next) {
    try {
      const token = AuthMiddleware.extractToken(req);
      
      if (token) {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const user = await User.findById(decoded.userId).select('-password');
        
        if (user && user.isActive) {
          req.user = user;
          req.token = token;
        }
      }
      
      next();
    } catch (error) {
      // Continue without authentication
      next();
    }
  }

  // Role-based authorization
  static authorize(...roles) {
    return (req, res, next) => {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          message: 'Bạn cần đăng nhập để truy cập'
        });
      }

      if (!roles.includes(req.user.role)) {
        return res.status(403).json({
          success: false,
          message: 'Bạn không có quyền truy cập tài nguyên này'
        });
      }

      next();
    };
  }

  // Admin only
  static adminOnly(req, res, next) {
    return AuthMiddleware.authorize('admin')(req, res, next);
  }

  // Admin or Operator
  static operatorOrAdmin(req, res, next) {
    return AuthMiddleware.authorize('operator', 'admin')(req, res, next);
  }

  // Check if user owns resource
  static checkOwnership(resourcePath = 'userId') {
    return (req, res, next) => {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          message: 'Bạn cần đăng nhập'
        });
      }

      // Admin can access everything
      if (req.user.role === 'admin') {
        return next();
      }

      // Get resource owner ID from different sources
      let resourceOwnerId;
      
      if (req.resource && req.resource[resourcePath]) {
        resourceOwnerId = req.resource[resourcePath].toString();
      } else if (req.params.userId) {
        resourceOwnerId = req.params.userId;
      } else if (req.body[resourcePath]) {
        resourceOwnerId = req.body[resourcePath].toString();
      }

      if (!resourceOwnerId || resourceOwnerId !== req.user._id.toString()) {
        return res.status(403).json({
          success: false,
          message: 'Bạn không có quyền truy cập tài nguyên này'
        });
      }

      next();
    };
  }

  // Extract token from header
  static extractToken(req) {
    const authHeader = req.headers.authorization;
    
    if (authHeader && authHeader.startsWith('Bearer ')) {
      return authHeader.substring(7);
    }
    
    return null;
  }

  // Generate tokens
  static generateTokens(userId) {
    const accessToken = jwt.sign(
      { userId },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    const refreshToken = jwt.sign(
      { userId, type: 'refresh' },
      process.env.JWT_REFRESH_SECRET,
      { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d' }
    );

    return { accessToken, refreshToken };
  }

  // Verify refresh token
  static async verifyRefreshToken(token) {
    try {
      const decoded = jwt.verify(token, process.env.JWT_REFRESH_SECRET);
      
      if (decoded.type !== 'refresh') {
        throw new Error('Invalid token type');
      }

      const user = await User.findById(decoded.userId);
      
      if (!user || !user.isActive) {
        throw new Error('User not found or inactive');
      }

      // Check if refresh token exists in user's token list
      const tokenExists = user.refreshTokens.some(rt => 
        rt.token === token && rt.expiresAt > new Date()
      );

      if (!tokenExists) {
        throw new Error('Refresh token not found or expired');
      }

      return { userId: decoded.userId };
    } catch (error) {
      throw error;
    }
  }

  // Rate limiting per user
  static rateLimitByUser(maxRequests = 100, windowMs = 15 * 60 * 1000) {
    const requests = new Map();

    return (req, res, next) => {
      const userId = req.user ? req.user._id.toString() : req.ip;
      const now = Date.now();
      const windowStart = now - windowMs;

      // Clean old requests
      if (requests.has(userId)) {
        const userRequests = requests.get(userId).filter(time => time > windowStart);
        requests.set(userId, userRequests);
      }

      const userRequests = requests.get(userId) || [];

      if (userRequests.length >= maxRequests) {
        return res.status(429).json({
          success: false,
          message: 'Quá nhiều yêu cầu, vui lòng thử lại sau'
        });
      }

      userRequests.push(now);
      requests.set(userId, userRequests);
      next();
    };
  }

  // Log authentication events
  static logAuthEvent(event) {
    return (req, res, next) => {
      const originalSend = res.send;
      
      res.send = function(data) {
        const user = req.user || { email: 'anonymous' };
        const success = res.statusCode < 400;
        
        logger.authLogger.info(`${event} ${success ? 'successful' : 'failed'}`, {
          userId: user._id,
          email: user.email,
          ip: req.ip,
          userAgent: req.get('User-Agent'),
          statusCode: res.statusCode
        });

        originalSend.call(this, data);
      };
      
      next();
    };
  }
}

module.exports = AuthMiddleware;
