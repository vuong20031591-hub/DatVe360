const express = require('express');
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
    const classInfo = schedule.seatConfiguration.classes[selectedClass];
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
        const existingLock = await redis.get(seatLockKey);
        if (existingLock) {
          throw new ConflictError('Bạn đang có ghế được giữ chỗ, vui lòng hoàn tất đặt vé');
        }
        
        await redis.set(seatLockKey, selectedSeats, lockExpiry);
      }
    }

    try {
      // Calculate total price
      const totalPrice = classInfo.price * passengers.length;

      // Create booking
      const booking = new Booking({
        userId: req.user._id,
        scheduleId,
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

      await booking.save();

      // Update seat availability
      schedule.seatConfiguration.classes[selectedClass].availableSeats -= passengers.length;
      schedule.seatConfiguration.availableSeats -= passengers.length;
      await schedule.save();

      // Create payment record
      const payment = new Payment({
        bookingId: booking._id,
        userId: req.user._id,
        amount: totalPrice,
        currency: 'VND',
        method: paymentMethod,
        transactionId: `TXN_${Date.now()}_${uuidv4().slice(0, 8).toUpperCase()}`
      });

      await payment.save();
      booking.paymentId = payment._id;
      await booking.save();

      logger.bookingLogger.info('Booking created', {
        bookingId: booking._id,
        userId: req.user._id,
        pnr: booking.pnr,
        scheduleId,
        totalPrice
      });

      res.status(201).json({
        success: true,
        message: 'Tạo đặt vé thành công',
        data: {
          booking: await booking.populate(['userId', 'scheduleId']),
          payment,
          expiresIn: '30 phút'
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
      .populate('scheduleId', 'departureTime arrivalTime route vehicleNumber')
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
    const booking = await Booking.findById(req.params.id);

    if (!booking) {
      throw new NotFoundError('Không tìm thấy đặt vé');
    }

    // Check ownership
    if (req.user.role !== 'admin' && booking.userId.toString() !== req.user._id.toString()) {
      throw new NotFoundError('Không tìm thấy đặt vé');
    }

    if (booking.status !== 'pending') {
      throw new ConflictError('Đặt vé đã được xử lý');
    }

    // Check if payment is completed
    if (booking.paymentId) {
      const payment = await Payment.findById(booking.paymentId);
      if (!payment || payment.status !== 'completed') {
        throw new ConflictError('Thanh toán chưa hoàn tất');
      }
    }

    // Confirm booking
    await booking.confirm();

    // Generate tickets
    const tickets = await booking.generateTickets();

    // Release seat lock if exists
    const seatLockKey = `seat_lock_${booking.scheduleId}_${req.user._id}`;
    if (redis.isConnected) {
      await redis.del(seatLockKey);
    }

    logger.bookingLogger.info('Booking confirmed', {
      bookingId: booking._id,
      userId: req.user._id,
      pnr: booking.pnr,
      ticketsGenerated: tickets.length
    });

    res.json({
      success: true,
      message: 'Xác nhận đặt vé thành công',
      data: {
        booking: await booking.populate(['scheduleId', 'paymentId']),
        tickets
      }
    });
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
    const booking = await Booking.findById(req.params.id);

    if (!booking) {
      throw new NotFoundError('Không tìm thấy đặt vé');
    }

    // Check ownership
    if (req.user.role !== 'admin' && booking.userId.toString() !== req.user._id.toString()) {
      throw new NotFoundError('Không tìm thấy đặt vé');
    }

    if (booking.status === 'cancelled') {
      throw new ConflictError('Đặt vé đã bị hủy');
    }

    if (booking.status === 'completed') {
      throw new ConflictError('Không thể hủy vé đã hoàn tất');
    }

    // Cancel booking
    await booking.cancel(reason);

    // Restore seat availability
    const schedule = await Schedule.findById(booking.scheduleId);
    if (schedule) {
      schedule.seatConfiguration.classes[booking.selectedClass].availableSeats += booking.passengers.length;
      schedule.seatConfiguration.availableSeats += booking.passengers.length;
      await schedule.save();
    }

    // Cancel related tickets
    await Ticket.updateMany(
      { bookingId: booking._id },
      { 
        status: 'cancelled',
        cancelledAt: new Date()
      }
    );

    // Handle refund if payment was completed
    if (booking.paymentId) {
      const payment = await Payment.findById(booking.paymentId);
      if (payment && payment.status === 'completed') {
        // In production, initiate refund process
        logger.bookingLogger.info('Refund required', {
          bookingId: booking._id,
          paymentId: payment._id,
          amount: payment.amount
        });
      }
    }

    // Release seat lock
    const seatLockKey = `seat_lock_${booking.scheduleId}_${req.user._id}`;
    if (redis.isConnected) {
      await redis.del(seatLockKey);
    }

    logger.bookingLogger.info('Booking cancelled', {
      bookingId: booking._id,
      userId: req.user._id,
      pnr: booking.pnr,
      reason
    });

    res.json({
      success: true,
      message: 'Hủy đặt vé thành công',
      data: { booking }
    });
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
