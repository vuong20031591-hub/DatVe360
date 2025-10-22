const express = require('express');
const mongoose = require('mongoose');
const { body, validationResult, param, query } = require('express-validator');
const Booking = require('../models/Booking');
const Schedule = require('../models/Schedule');
const Payment = require('../models/Payment');
const Ticket = require('../models/Ticket');
const AuthMiddleware = require('../middleware/auth');
const { asyncHandler, ValidationError, NotFoundError, ConflictError } = require('../middleware/errorHandler');
const logger = require('../config/logger');
const redis = require('../config/redis');
const { v4: uuidv4 } = require('uuid');
const socketEmitter = require('../utils/socketEmitter');

const router = express.Router();

// Validation rules
const createBookingValidation = [
  body('scheduleId').isMongoId().withMessage('Schedule ID không hợp lệ'),
  body('passengers').isArray({ min: 1 }).withMessage('Phải có ít nhất 1 hành khách'),
  body('passengers.*.type').isIn(['adult', 'child', 'infant']).withMessage('Loại hành khách không hợp lệ'),
  body('passengers.*.firstName').trim().notEmpty().withMessage('Tên không được để trống'),
  body('passengers.*.lastName').trim().notEmpty().withMessage('Họ không được để trống'),
  body('passengers.*.documentType').isIn(['passport', 'id_card', 'driver_license']),
  body('passengers.*.documentNumber').trim().notEmpty().withMessage('Số giấy tờ không được để trống'),
  body('selectedClass').trim().notEmpty().withMessage('Hạng ghế không được để trống'),
  body('contactInfo.email').isEmail().withMessage('Email liên hệ không hợp lệ'),
  body('contactInfo.phone').isMobilePhone('vi-VN').withMessage('Số điện thoại liên hệ không hợp lệ'),
  body('paymentMethod').isIn(['vnpay', 'momo', 'stripe', 'bank_transfer'])
];

const checkValidation = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ValidationError(errors.array().map(err => err.msg).join(', '));
  }
  next();
};

/**
 * @swagger
 * /bookings:
 *   post:
 *     summary: Create a new booking
 *     tags: [Bookings]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - scheduleId
 *               - passengers
 *               - selectedClass
 *               - contactInfo
 *               - paymentMethod
 *             properties:
 *               scheduleId:
 *                 type: string
 *                 example: 507f1f77bcf86cd799439011
 *               passengers:
 *                 type: array
 *                 items:
 *                   type: object
 *                   properties:
 *                     type:
 *                       type: string
 *                       enum: [adult, child, infant]
 *                     firstName:
 *                       type: string
 *                     lastName:
 *                       type: string
 *                     documentType:
 *                       type: string
 *                       enum: [passport, id_card, driver_license]
 *                     documentNumber:
 *                       type: string
 *               selectedClass:
 *                 type: string
 *                 example: economy
 *               selectedSeats:
 *                 type: array
 *                 items:
 *                   type: string
 *               contactInfo:
 *                 type: object
 *                 properties:
 *                   email:
 *                     type: string
 *                     format: email
 *                   phone:
 *                     type: string
 *               paymentMethod:
 *                 type: string
 *                 enum: [vnpay, momo, stripe, bank_transfer]
 *     responses:
 *       201:
 *         description: Booking created successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 message:
 *                   type: string
 *                 data:
 *                   type: object
 *                   properties:
 *                     booking:
 *                       $ref: '#/components/schemas/Booking'
 *                     payment:
 *                       type: object
 *                     expiresIn:
 *                       type: string
 *       400:
 *         $ref: '#/components/responses/ValidationError'
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *       404:
 *         $ref: '#/components/responses/NotFoundError'
 */
// @route   POST /api/v1/bookings
// @desc    Create new booking
// @access  Private
router.post('/',
  AuthMiddleware.authenticate,
  createBookingValidation,
  checkValidation,
  asyncHandler(async (req, res) => {
    const {
      scheduleId,
      passengers,
      selectedClass,
      selectedSeats,
      contactInfo,
      paymentMethod
    } = req.body;

    // Check if schedule exists and has availability
    const schedule = await Schedule.findById(scheduleId);
    if (!schedule) {
      throw new NotFoundError('Không tìm thấy lịch trình');
    }

    if (!schedule.isActive) {
      throw new ConflictError('Lịch trình đã bị vô hiệu hóa');
    }

    // Check seat availability
    const classInfo = schedule.seatConfiguration.classes.get(selectedClass);
    if (!classInfo) {
      throw new ValidationError('Hạng ghế không tồn tại');
    }

    if (classInfo.availableSeats < passengers.length) {
      throw new ConflictError('Không đủ ghế trống');
    }

    // Check if departure time is in the future
    if (new Date(schedule.departureTime) <= new Date()) {
      throw new ConflictError('Không thể đặt vé cho chuyến đã khởi hành');
    }

    // Lock seats temporarily if specific seats are selected
    let seatLockKey = null;
    if (selectedSeats && selectedSeats.length > 0) {
      seatLockKey = `seat_lock_${scheduleId}_${req.user._id}`;
      const lockExpiry = 15 * 60; // 15 minutes

      if (redis.isConnected) {
        // Check if user already has a lock
        const existingLock = await redis.get(seatLockKey);
        if (existingLock) {
          // Verify lock is still valid and matches requested seats
          const lockedSeats = existingLock; // Already parsed by redis.get()
          const requestedSeatsSet = new Set(selectedSeats);
          const lockedSeatsSet = new Set(lockedSeats);

          // Check if requested seats match locked seats
          const seatsMatch = selectedSeats.length === lockedSeats.length &&
            selectedSeats.every(seat => lockedSeatsSet.has(seat));

          if (!seatsMatch) {
            throw new ConflictError('Ghế đã thay đổi, vui lòng chọn lại');
          }

          // Lock is valid, extend it
          await redis.set(seatLockKey, selectedSeats, lockExpiry);
        } else {
          // Create new lock
          await redis.set(seatLockKey, selectedSeats, lockExpiry);
        }

        // Verify seats are not locked by other users
        for (const seat of selectedSeats) {
          const otherUserLockPattern = `seat_lock_${scheduleId}_*`;
          const keys = await redis.keys(otherUserLockPattern);

          for (const key of keys) {
            if (key !== seatLockKey) {
              const otherLock = await redis.get(key);
              if (otherLock) {
                const otherSeats = otherLock; // Already parsed by redis.get()
                if (otherSeats.includes(seat)) {
                  throw new ConflictError(`Ghế ${seat} đã được giữ bởi người khác`);
                }
              }
            }
          }
        }
      }
    }

    try {
      // Calculate total price
      const totalPrice = classInfo.price * passengers.length;

      // Generate PNR
      const generatePNR = () => {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        let pnr = '';
        for (let i = 0; i < 6; i++) {
          pnr += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return pnr;
      };

      // Use MongoDB Transaction to prevent race condition
      const session = await mongoose.startSession();
      session.startTransaction();

      let booking, payment;

      try {
        // Atomic update: decrement seats and check availability in one operation
        const updatedSchedule = await Schedule.findOneAndUpdate(
          {
            _id: scheduleId,
            [`seatConfiguration.classes.${selectedClass}.availableSeats`]: { $gte: passengers.length },
            'seatConfiguration.availableSeats': { $gte: passengers.length }
          },
          {
            $inc: {
              [`seatConfiguration.classes.${selectedClass}.availableSeats`]: -passengers.length,
              'seatConfiguration.availableSeats': -passengers.length
            }
          },
          {
            new: true,
            session,
            runValidators: true
          }
        );

        // If update failed, seats were taken by another request
        if (!updatedSchedule) {
          throw new ConflictError('Ghế đã được đặt bởi người khác, vui lòng thử lại');
        }

        // Create booking
        booking = new Booking({
          userId: req.user._id,
          scheduleId,
          pnr: generatePNR(),
          passengers: passengers.map(p => ({
            ...p,
            seatNumber: selectedSeats ? selectedSeats.shift() : null
          })),
          selectedClass,
          selectedSeats: selectedSeats || [],
          totalPrice,
          currency: 'VND',
          contactInfo,
          paymentMethod,
          expiresAt: new Date(Date.now() + 30 * 60 * 1000) // 30 minutes
        });

        await booking.save({ session });

        // Create payment record
        payment = new Payment({
          bookingId: booking._id,
          userId: req.user._id,
          amount: totalPrice,
          currency: 'VND',
          paymentMethod: paymentMethod,
          transactionId: `TXN_${Date.now()}_${uuidv4().slice(0, 8).toUpperCase()}`
        });

        await payment.save({ session });
        booking.paymentId = payment._id;
        await booking.save({ session });

        // Commit transaction
        await session.commitTransaction();

      } catch (error) {
        // Rollback transaction on error
        await session.abortTransaction();
        throw error;
      } finally {
        session.endSession();
      }

      logger.bookingLogger.info('Booking created with transaction', {
        bookingId: booking._id,
        userId: req.user._id,
        pnr: booking.pnr,
        scheduleId,
        totalPrice,
        method: 'atomic_update'
      });

      // Get updated schedule for socket emit
      const updatedSchedule = await Schedule.findById(scheduleId);
      const updatedClassInfo = updatedSchedule.seatConfiguration.classes.get(selectedClass);

      // Emit socket event for new booking
      socketEmitter.notifyNewBooking(booking);

      // Emit seat update to schedule room with actual updated values
      socketEmitter.emitSeatUpdate(scheduleId, {
        selectedClass,
        availableSeats: updatedClassInfo.availableSeats,
        totalAvailable: updatedSchedule.seatConfiguration.availableSeats,
      });

      res.status(201).json({
        success: true,
        message: 'Tạo đặt vé thành công',
        data: {
          booking: await booking.populate(['userId', 'scheduleId']),
          payment,
          expiresIn: '30 phút',
          remainingSeats: {
            [selectedClass]: updatedClassInfo.availableSeats,
            total: updatedSchedule.seatConfiguration.availableSeats
          }
        }
      });

    } catch (error) {
      // Release seat lock if error occurs
      if (seatLockKey && redis.isConnected) {
        await redis.del(seatLockKey);
      }
      throw error;
    }
  })
);

// @route   GET /api/v1/bookings
// @desc    Get user's bookings
// @access  Private
router.get('/',
  AuthMiddleware.authenticate,
  [
    query('status').optional().isIn(['pending', 'confirmed', 'cancelled', 'completed']),
    query('limit').optional().isInt({ min: 1, max: 100 }),
    query('page').optional().isInt({ min: 1 })
  ],
  checkValidation,
  asyncHandler(async (req, res) => {
    const { status, limit = 20, page = 1 } = req.query;
    const skip = (page - 1) * limit;

    const filter = { userId: req.user._id };
    if (status) {
      filter.status = status;
    }

    const bookings = await Booking.find(filter)
      .populate({
        path: 'scheduleId',
        select: 'departureTime arrivalTime from to vehicleNumber transportType',
        populate: [
          { path: 'from', select: 'name city code' },
          { path: 'to', select: 'name city code' }
        ],
        options: { virtuals: false }
      })
      .populate('paymentId', 'status amount method')
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .skip(skip);

    const total = await Booking.countDocuments(filter);

    res.json({
      success: true,
      data: {
        bookings,
        pagination: {
          current: parseInt(page),
          pages: Math.ceil(total / limit),
          total
        }
      }
    });
  })
);

// @route   GET /api/v1/bookings/:id
// @desc    Get booking by ID
// @access  Private
router.get('/:id',
  AuthMiddleware.authenticate,
  param('id').isMongoId().withMessage('Booking ID không hợp lệ'),
  checkValidation,
  asyncHandler(async (req, res) => {
    const booking = await Booking.findById(req.params.id)
      .populate('userId', 'displayName email phoneNumber')
      .populate('scheduleId')
      .populate('paymentId');

    if (!booking) {
      throw new NotFoundError('Không tìm thấy đặt vé');
    }

    // Check ownership (non-admin users can only see their own bookings)
    if (req.user.role !== 'admin' && booking.userId._id.toString() !== req.user._id.toString()) {
      throw new NotFoundError('Không tìm thấy đặt vé');
    }

    res.json({
      success: true,
      data: { booking }
    });
  })
);

// @route   GET /api/v1/bookings/pnr/:pnr
// @desc    Get booking by PNR
// @access  Private
router.get('/pnr/:pnr',
  AuthMiddleware.authenticate,
  param('pnr').isLength({ min: 6, max: 6 }).withMessage('PNR phải có 6 ký tự'),
  checkValidation,
  asyncHandler(async (req, res) => {
    const booking = await Booking.findByPNR(req.params.pnr);

    if (!booking) {
      throw new NotFoundError('Không tìm thấy đặt vé với PNR này');
    }

    // Check ownership
    if (req.user.role !== 'admin' && booking.userId._id.toString() !== req.user._id.toString()) {
      throw new NotFoundError('Không tìm thấy đặt vé với PNR này');
    }

    res.json({
      success: true,
      data: { booking }
    });
  })
);

// @route   POST /api/v1/bookings/:id/confirm
// @desc    Confirm booking (after payment)
// @access  Private
router.post('/:id/confirm',
  AuthMiddleware.authenticate,
  param('id').isMongoId().withMessage('Booking ID không hợp lệ'),
  checkValidation,
  asyncHandler(async (req, res) => {
    const session = await mongoose.startSession();
    session.startTransaction();

    try {
      // Atomic update: Only confirm if status is pending
      const booking = await Booking.findOneAndUpdate(
        {
          _id: req.params.id,
          status: 'pending'
        },
        {
          $set: {
            status: 'confirmed',
            confirmedAt: new Date()
          }
        },
        {
          new: true,
          session,
          runValidators: true
        }
      ).populate('paymentId');

      if (!booking) {
        // Either not found or already confirmed
        const existingBooking = await Booking.findById(req.params.id);
        if (!existingBooking) {
          throw new NotFoundError('Không tìm thấy đặt vé');
        }
        if (existingBooking.status === 'confirmed') {
          throw new ConflictError('Đặt vé đã được xác nhận');
        }
        throw new ConflictError('Đặt vé đã được xử lý');
      }

      // Check ownership
      if (req.user.role !== 'admin' && booking.userId.toString() !== req.user._id.toString()) {
        throw new NotFoundError('Không tìm thấy đặt vé');
      }

      // Check if payment is completed
      if (booking.paymentId) {
        if (booking.paymentId.status !== 'completed') {
          throw new ConflictError('Thanh toán chưa hoàn tất');
        }
      }

      // Check if tickets already exist (idempotency)
      const existingTickets = await Ticket.find({ bookingId: booking._id }).session(session);

      let tickets;
      if (existingTickets.length > 0) {
        // Tickets already generated
        tickets = existingTickets;
        logger.bookingLogger.info('Tickets already exist (idempotent)', {
          bookingId: booking._id,
          ticketCount: tickets.length
        });
      } else {
        // Generate new tickets
        tickets = await booking.generateTickets(session);
      }

      // Commit transaction
      await session.commitTransaction();

      // Release seat lock if exists (outside transaction)
      const seatLockKey = `seat_lock_${booking.scheduleId}_${req.user._id}`;
      if (redis.isConnected) {
        await redis.del(seatLockKey);
      }

      logger.bookingLogger.info('Booking confirmed with transaction', {
        bookingId: booking._id,
        userId: req.user._id,
        pnr: booking.pnr,
        ticketsGenerated: tickets.length,
        method: 'atomic_update'
      });

      res.json({
        success: true,
        message: 'Xác nhận đặt vé thành công',
        data: {
          booking: await booking.populate(['scheduleId', 'paymentId']),
          tickets
        }
      });

    } catch (error) {
      await session.abortTransaction();
      throw error;
    } finally {
      session.endSession();
    }
  })
);

// @route   POST /api/v1/bookings/:id/cancel
// @desc    Cancel booking
// @access  Private
router.post('/:id/cancel',
  AuthMiddleware.authenticate,
  [
    param('id').isMongoId().withMessage('Booking ID không hợp lệ'),
    body('reason').optional().trim().isLength({ max: 500 })
  ],
  checkValidation,
  asyncHandler(async (req, res) => {
    const { reason } = req.body;

    // Use transaction to prevent race condition
    const session = await mongoose.startSession();
    session.startTransaction();

    try {
      // Atomic update: Only cancel if status is pending or confirmed
      const booking = await Booking.findOneAndUpdate(
        {
          _id: req.params.id,
          status: { $in: ['pending', 'confirmed'] }
        },
        {
          $set: {
            status: 'cancelled',
            cancelledAt: new Date(),
            cancelReason: reason,
            expiresAt: null
          }
        },
        {
          new: true,
          session,
          runValidators: true
        }
      );

      if (!booking) {
        // Either not found or already cancelled/completed
        const existingBooking = await Booking.findById(req.params.id);
        if (!existingBooking) {
          throw new NotFoundError('Không tìm thấy đặt vé');
        }
        if (existingBooking.status === 'cancelled') {
          throw new ConflictError('Đặt vé đã bị hủy');
        }
        if (existingBooking.status === 'completed') {
          throw new ConflictError('Không thể hủy vé đã hoàn tất');
        }
        throw new ConflictError('Không thể hủy đặt vé');
      }

      // Check ownership
      if (req.user.role !== 'admin' && booking.userId.toString() !== req.user._id.toString()) {
        throw new NotFoundError('Không tìm thấy đặt vé');
      }

      // Atomic restore seat availability
      const updatedSchedule = await Schedule.findOneAndUpdate(
        { _id: booking.scheduleId },
        {
          $inc: {
            [`seatConfiguration.classes.${booking.selectedClass}.availableSeats`]: booking.passengers.length,
            'seatConfiguration.availableSeats': booking.passengers.length
          }
        },
        { new: true, session }
      );

      if (!updatedSchedule) {
        throw new NotFoundError('Không tìm thấy lịch trình');
      }

      // Cancel related tickets
      await Ticket.updateMany(
        { bookingId: booking._id },
        {
          status: 'cancelled',
          cancelledAt: new Date()
        },
        { session }
      );

      // Handle refund if payment was completed
      if (booking.paymentId) {
        const payment = await Payment.findById(booking.paymentId).session(session);
        if (payment && payment.status === 'completed') {
          // Mark payment for refund
          payment.status = 'refunding';
          payment.metadata = payment.metadata || {};
          payment.metadata.refundInitiatedAt = new Date();
          await payment.save({ session });

          logger.bookingLogger.info('Refund initiated', {
            bookingId: booking._id,
            paymentId: payment._id,
            amount: payment.amount
          });
        }
      }

      // Commit transaction
      await session.commitTransaction();

      // Release seat lock (outside transaction)
      const seatLockKey = `seat_lock_${booking.scheduleId}_${req.user._id}`;
      if (redis.isConnected) {
        await redis.del(seatLockKey);
      }

      logger.bookingLogger.info('Booking cancelled with transaction', {
        bookingId: booking._id,
        userId: req.user._id,
        pnr: booking.pnr,
        reason,
        method: 'atomic_update'
      });

      res.json({
        success: true,
        message: 'Hủy đặt vé thành công',
        data: { booking }
      });

    } catch (error) {
      await session.abortTransaction();
      throw error;
    } finally {
      session.endSession();
    }
  })
);

// @route   PUT /api/v1/bookings/:id/passengers/:passengerId
// @desc    Update passenger information
// @access  Private
router.put('/:id/passengers/:passengerId',
  AuthMiddleware.authenticate,
  [
    param('id').isMongoId().withMessage('Booking ID không hợp lệ'),
    param('passengerId').isMongoId().withMessage('Passenger ID không hợp lệ'),
    body('firstName').optional().trim().notEmpty(),
    body('lastName').optional().trim().notEmpty(),
    body('dateOfBirth').optional().isISO8601(),
    body('documentNumber').optional().trim().notEmpty()
  ],
  checkValidation,
  asyncHandler(async (req, res) => {
    const booking = await Booking.findById(req.params.id);

    if (!booking) {
      throw new NotFoundError('Không tìm thấy đặt vé');
    }

    // Check ownership
    if (req.user.role !== 'admin' && booking.userId.toString() !== req.user._id.toString()) {
      throw new NotFoundError('Không tìm thấy đặt vé');
    }

    if (booking.status !== 'pending') {
      throw new ConflictError('Chỉ có thể sửa thông tin hành khách khi đặt vé ở trạng thái chờ');
    }

    // Find and update passenger
    const passenger = booking.passengers.id(req.params.passengerId);
    if (!passenger) {
      throw new NotFoundError('Không tìm thấy hành khách');
    }

    const allowedUpdates = ['firstName', 'lastName', 'dateOfBirth', 'gender', 'documentNumber'];
    allowedUpdates.forEach(field => {
      if (req.body[field] !== undefined) {
        passenger[field] = req.body[field];
      }
    });

    await booking.save();

    logger.bookingLogger.info('Passenger information updated', {
      bookingId: booking._id,
      passengerId: req.params.passengerId,
      updates: Object.keys(req.body)
    });

    res.json({
      success: true,
      message: 'Cập nhật thông tin hành khách thành công',
      data: { booking }
    });
  })
);

// @route   GET /api/v1/bookings/:id/tickets
// @desc    Get tickets for booking
// @access  Private
router.get('/:id/tickets',
  AuthMiddleware.authenticate,
  param('id').isMongoId().withMessage('Booking ID không hợp lệ'),
  checkValidation,
  asyncHandler(async (req, res) => {
    const booking = await Booking.findById(req.params.id);

    if (!booking) {
      throw new NotFoundError('Không tìm thấy đặt vé');
    }

    // Check ownership
    if (req.user.role !== 'admin' && booking.userId.toString() !== req.user._id.toString()) {
      throw new NotFoundError('Không tìm thấy đặt vé');
    }

    const tickets = await Ticket.find({ bookingId: booking._id })
      .populate('bookingId', 'pnr scheduleId passengers');

    res.json({
      success: true,
      data: { tickets }
    });
  })
);

// @route   POST /api/v1/bookings/:id/extend
// @desc    Extend booking expiry
// @access  Private
router.post('/:id/extend',
  AuthMiddleware.authenticate,
  [
    param('id').isMongoId().withMessage('Booking ID không hợp lệ'),
    body('minutes').optional().isInt({ min: 5, max: 60 })
  ],
  checkValidation,
  asyncHandler(async (req, res) => {
    const { minutes = 15 } = req.body;
    const booking = await Booking.findById(req.params.id);

    if (!booking) {
      throw new NotFoundError('Không tìm thấy đặt vé');
    }

    // Check ownership
    if (req.user.role !== 'admin' && booking.userId.toString() !== req.user._id.toString()) {
      throw new NotFoundError('Không tìm thấy đặt vé');
    }

    if (booking.status !== 'pending') {
      throw new ConflictError('Chỉ có thể gia hạn đặt vé ở trạng thái chờ');
    }

    await booking.extendExpiry(minutes);

    logger.bookingLogger.info('Booking expiry extended', {
      bookingId: booking._id,
      userId: req.user._id,
      minutes,
      newExpiryTime: booking.expiresAt
    });

    res.json({
      success: true,
      message: `Đã gia hạn đặt vé thêm ${minutes} phút`,
      data: {
        booking,
        expiresAt: booking.expiresAt
      }
    });
  })
);

module.exports = router;
