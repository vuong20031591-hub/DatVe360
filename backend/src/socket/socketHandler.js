const logger = require('../utils/logger');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

/**
 * Socket.IO event handlers
 * Handles real-time communication for:
 * - Seat availability updates
 * - Booking status changes
 * - Payment notifications
 * - Admin notifications
 */

class SocketHandler {
  constructor(io) {
    this.io = io;
    this.connectedUsers = new Map(); // userId -> socketId
    this.setupMiddleware();
    this.setupEventHandlers();
  }

  /**
   * Setup Socket.IO middleware for authentication
   */
  setupMiddleware() {
    this.io.use(async (socket, next) => {
      try {
        const token = socket.handshake.auth.token || socket.handshake.headers.authorization?.replace('Bearer ', '');

        if (!token) {
          // Allow anonymous connections for public features
          socket.userId = null;
          socket.userRole = 'guest';
          return next();
        }

        // Verify JWT token
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const user = await User.findById(decoded.userId).select('-password');

        if (!user || !user.isActive) {
          return next(new Error('Authentication failed'));
        }

        socket.userId = user._id.toString();
        socket.userRole = user.role;
        socket.userEmail = user.email;

        logger.info('Socket authenticated', {
          socketId: socket.id,
          userId: socket.userId,
          role: socket.userRole,
        });

        next();
      } catch (error) {
        logger.error('Socket authentication error:', error);
        // Allow connection but mark as guest
        socket.userId = null;
        socket.userRole = 'guest';
        next();
      }
    });
  }

  /**
   * Setup event handlers
   */
  setupEventHandlers() {
    this.io.on('connection', (socket) => {
      logger.info('Client connected', {
        socketId: socket.id,
        userId: socket.userId,
        role: socket.userRole,
      });

      // Store user connection
      if (socket.userId) {
        this.connectedUsers.set(socket.userId, socket.id);
      }

      // Register event handlers
      this.handleSeatEvents(socket);
      this.handleBookingEvents(socket);
      this.handlePaymentEvents(socket);
      this.handleAdminEvents(socket);
      this.handleDisconnect(socket);
    });
  }

  /**
   * Handle seat-related events
   */
  handleSeatEvents(socket) {
    // Join schedule room to receive seat updates
    socket.on('join:schedule', (scheduleId) => {
      socket.join(`schedule:${scheduleId}`);
      logger.info('User joined schedule room', {
        socketId: socket.id,
        userId: socket.userId,
        scheduleId,
      });

      socket.emit('joined:schedule', {
        scheduleId,
        message: 'Successfully joined schedule room',
      });
    });

    // Leave schedule room
    socket.on('leave:schedule', (scheduleId) => {
      socket.leave(`schedule:${scheduleId}`);
      logger.info('User left schedule room', {
        socketId: socket.id,
        userId: socket.userId,
        scheduleId,
      });
    });

    // Hold seat (temporary reservation)
    socket.on('seat:hold', async (data) => {
      const { scheduleId, seatNumbers, holdDuration = 300000 } = data; // 5 minutes default

      try {
        // Emit to all users in the schedule room
        this.io.to(`schedule:${scheduleId}`).emit('seat:held', {
          scheduleId,
          seatNumbers,
          heldBy: socket.userId,
          expiresAt: Date.now() + holdDuration,
        });

        logger.info('Seats held', {
          scheduleId,
          seatNumbers,
          userId: socket.userId,
        });

        // Auto-release after duration
        setTimeout(() => {
          this.io.to(`schedule:${scheduleId}`).emit('seat:released', {
            scheduleId,
            seatNumbers,
          });
        }, holdDuration);
      } catch (error) {
        socket.emit('error', {
          event: 'seat:hold',
          message: error.message,
        });
      }
    });

    // Release seat hold
    socket.on('seat:release', (data) => {
      const { scheduleId, seatNumbers } = data;

      this.io.to(`schedule:${scheduleId}`).emit('seat:released', {
        scheduleId,
        seatNumbers,
      });

      logger.info('Seats released', {
        scheduleId,
        seatNumbers,
        userId: socket.userId,
      });
    });
  }

  /**
   * Handle booking-related events
   */
  handleBookingEvents(socket) {
    // Join booking room to receive updates
    socket.on('join:booking', (bookingId) => {
      socket.join(`booking:${bookingId}`);
      logger.info('User joined booking room', {
        socketId: socket.id,
        userId: socket.userId,
        bookingId,
      });
    });

    // Leave booking room
    socket.on('leave:booking', (bookingId) => {
      socket.leave(`booking:${bookingId}`);
    });

    // Request booking status
    socket.on('booking:status', async (bookingId) => {
      try {
        const Booking = require('../models/Booking');
        const booking = await Booking.findOne({ bookingId });

        if (!booking) {
          return socket.emit('error', {
            event: 'booking:status',
            message: 'Booking not found',
          });
        }

        // Check if user has access to this booking
        if (
          socket.userRole !== 'admin' &&
          socket.userRole !== 'operator' &&
          booking.userId?.toString() !== socket.userId
        ) {
          return socket.emit('error', {
            event: 'booking:status',
            message: 'Unauthorized',
          });
        }

        socket.emit('booking:update', {
          bookingId: booking.bookingId,
          status: booking.status,
          totalAmount: booking.totalAmount,
          paymentStatus: booking.paymentStatus,
        });
      } catch (error) {
        socket.emit('error', {
          event: 'booking:status',
          message: error.message,
        });
      }
    });
  }

  /**
   * Handle payment-related events
   */
  handlePaymentEvents(socket) {
    // Join payment room
    socket.on('join:payment', (paymentId) => {
      socket.join(`payment:${paymentId}`);
      logger.info('User joined payment room', {
        socketId: socket.id,
        userId: socket.userId,
        paymentId,
      });
    });

    // Leave payment room
    socket.on('leave:payment', (paymentId) => {
      socket.leave(`payment:${paymentId}`);
    });
  }

  /**
   * Handle admin-related events
   */
  handleAdminEvents(socket) {
    // Only admin/operator can join admin room
    if (socket.userRole === 'admin' || socket.userRole === 'operator') {
      socket.on('join:admin', () => {
        socket.join('admin');
        logger.info('Admin joined admin room', {
          socketId: socket.id,
          userId: socket.userId,
        });

        socket.emit('joined:admin', {
          message: 'Successfully joined admin room',
        });
      });

      socket.on('leave:admin', () => {
        socket.leave('admin');
      });
    }
  }

  /**
   * Handle disconnect
   */
  handleDisconnect(socket) {
    socket.on('disconnect', (reason) => {
      logger.info('Client disconnected', {
        socketId: socket.id,
        userId: socket.userId,
        reason,
      });

      // Remove from connected users
      if (socket.userId) {
        this.connectedUsers.delete(socket.userId);
      }
    });
  }

  /**
   * Emit booking status update to user
   */
  emitBookingUpdate(bookingId, data) {
    this.io.to(`booking:${bookingId}`).emit('booking:update', data);
    logger.info('Booking update emitted', { bookingId, data });
  }

  /**
   * Emit payment status update
   */
  emitPaymentUpdate(paymentId, data) {
    this.io.to(`payment:${paymentId}`).emit('payment:update', data);
    logger.info('Payment update emitted', { paymentId, data });
  }

  /**
   * Emit seat availability update
   */
  emitSeatUpdate(scheduleId, data) {
    this.io.to(`schedule:${scheduleId}`).emit('seat:update', data);
    logger.info('Seat update emitted', { scheduleId, data });
  }

  /**
   * Emit notification to specific user
   */
  emitToUser(userId, event, data) {
    const socketId = this.connectedUsers.get(userId);
    if (socketId) {
      this.io.to(socketId).emit(event, data);
      logger.info('Event emitted to user', { userId, event, data });
    }
  }

  /**
   * Emit notification to all admins
   */
  emitToAdmins(event, data) {
    this.io.to('admin').emit(event, data);
    logger.info('Event emitted to admins', { event, data });
  }
}

/**
 * Initialize Socket.IO handler
 */
module.exports = (io) => {
  const handler = new SocketHandler(io);
  
  // Attach handler to io for external access
  io.socketHandler = handler;
  
  logger.info('Socket.IO handler initialized');
  
  return handler;
};

