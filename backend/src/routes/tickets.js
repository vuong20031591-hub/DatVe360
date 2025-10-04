const express = require('express');
const router = express.Router();
const Booking = require('../models/Booking');
const AuthMiddleware = require('../middleware/auth');
const asyncHandler = require('../utils/asyncHandler');
const logger = require('../utils/logger');

// @route   POST /api/v1/tickets/:bookingId/email
// @desc    Send ticket via email
// @access  Private
router.post('/:bookingId/email',
  AuthMiddleware.authenticate,
  asyncHandler(async (req, res) => {
    const { bookingId } = req.params;
    const { email } = req.body;

    // Validate booking exists
    const booking = await Booking.findById(bookingId)
      .populate('scheduleId')
      .populate('userId', 'email firstName lastName');

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy vé'
      });
    }

    // Check ownership
    if (req.user.role !== 'admin' && booking.userId._id.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Không có quyền truy cập vé này'
      });
    }

    // Check if booking is confirmed
    if (booking.status !== 'confirmed') {
      return res.status(400).json({
        success: false,
        message: 'Vé chưa được xác nhận'
      });
    }

    // TODO: Implement actual email sending with nodemailer
    // For now, just log and return success
    logger.info(`Sending ticket email to ${email} for booking ${bookingId}`);

    res.json({
      success: true,
      message: 'Email đã được gửi thành công'
    });
  })
);

// @route   GET /api/v1/tickets/history/:userId
// @desc    Get ticket history for user
// @access  Private
router.get('/history/:userId',
  AuthMiddleware.authenticate,
  asyncHandler(async (req, res) => {
    const { userId } = req.params;

    // Check ownership
    if (req.user.role !== 'admin' && req.user._id.toString() !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Không có quyền truy cập'
      });
    }

    // Get all confirmed bookings for user
    const bookings = await Booking.find({
      userId: userId,
      status: { $in: ['confirmed', 'completed'] }
    })
      .populate('scheduleId')
      .sort({ createdAt: -1 })
      .limit(50);

    res.json({
      success: true,
      data: {
        tickets: bookings
      }
    });
  })
);

// @route   POST /api/v1/tickets/validate
// @desc    Validate ticket QR code
// @access  Public
router.post('/validate',
  asyncHandler(async (req, res) => {
    const { qrData } = req.body;

    if (!qrData) {
      return res.status(400).json({
        success: false,
        data: {
          valid: false,
          error: 'QR data không được để trống'
        }
      });
    }

    try {
      // Parse QR data (format: bookingId:pnr)
      const [bookingId, pnr] = qrData.split(':');

      const booking = await Booking.findById(bookingId)
        .populate('scheduleId')
        .populate('userId', 'firstName lastName email');

      if (!booking) {
        return res.json({
          success: true,
          data: {
            valid: false,
            error: 'Vé không tồn tại'
          }
        });
      }

      // Verify PNR matches
      if (booking.pnr !== pnr) {
        return res.json({
          success: true,
          data: {
            valid: false,
            error: 'Mã vé không hợp lệ'
          }
        });
      }

      // Check if booking is confirmed
      if (booking.status !== 'confirmed' && booking.status !== 'completed') {
        return res.json({
          success: true,
          data: {
            valid: false,
            error: `Vé ở trạng thái: ${booking.status}`
          }
        });
      }

      // Check if ticket is expired
      const now = new Date();
      const departureTime = new Date(booking.scheduleId.departureTime);
      if (now > departureTime) {
        return res.json({
          success: true,
          data: {
            valid: false,
            error: 'Vé đã hết hạn'
          }
        });
      }

      // Ticket is valid
      res.json({
        success: true,
        data: {
          valid: true,
          booking: {
            pnr: booking.pnr,
            status: booking.status,
            passengers: booking.passengers,
            schedule: booking.scheduleId,
            seats: booking.seats
          }
        }
      });
    } catch (error) {
      logger.error('Ticket validation error:', error);
      res.json({
        success: true,
        data: {
          valid: false,
          error: 'Lỗi xác thực vé'
        }
      });
    }
  })
);

// @route   POST /api/v1/tickets/:bookingId/checkin
// @desc    Check-in passenger
// @access  Private
router.post('/:bookingId/checkin',
  AuthMiddleware.authenticate,
  asyncHandler(async (req, res) => {
    const { bookingId } = req.params;
    const { passengerId } = req.body;

    const booking = await Booking.findById(bookingId);

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy vé'
      });
    }

    // Check ownership
    if (req.user.role !== 'admin' && booking.userId.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Không có quyền truy cập'
      });
    }

    // Check if booking is confirmed
    if (booking.status !== 'confirmed') {
      return res.status(400).json({
        success: false,
        message: 'Vé chưa được xác nhận'
      });
    }

    // Find passenger
    const passenger = booking.passengers.id(passengerId);
    if (!passenger) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy hành khách'
      });
    }

    // Check if already checked in
    if (passenger.checkedIn) {
      return res.status(400).json({
        success: false,
        message: 'Hành khách đã check-in'
      });
    }

    // Perform check-in
    passenger.checkedIn = true;
    passenger.checkedInAt = new Date();
    await booking.save();

    res.json({
      success: true,
      message: 'Check-in thành công',
      data: {
        passenger: passenger
      }
    });
  })
);

module.exports = router;

