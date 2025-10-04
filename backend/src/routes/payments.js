const express = require('express');
const mongoose = require('mongoose');
const router = express.Router();
const VNPayService = require('../services/vnpayService');
const Booking = require('../models/Booking');
const Payment = require('../models/Payment');
const AuthMiddleware = require('../middleware/auth');
const asyncHandler = require('../utils/asyncHandler');
const logger = require('../utils/logger');

const vnpayService = new VNPayService();

// @route   GET /api/v1/payments/vnpay/test
// @desc    Test VNPay payment URL generation
// @access  Public
router.get('/vnpay/test', async (req, res) => {
  try {
    const paymentUrl = vnpayService.createPaymentUrl({
      orderId: 'TEST' + Date.now(),
      amount: 1430000,
      orderInfo: 'Thanh toan ve may bay',
      ipAddr: req.ip || '127.0.0.1'
      // Không có bankCode để user có thể chọn
    });

    res.json({
      success: true,
      paymentUrl: paymentUrl,
      message: 'VNPay URL generated successfully'
    });
  } catch (error) {
    console.error('VNPay test error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   POST /api/v1/payments/vnpay/create
// @desc    Tạo URL thanh toán VNPay
// @access  Private
router.post('/vnpay/create',
  AuthMiddleware.authenticate,
  asyncHandler(async (req, res) => {
    const { bookingId, paymentMethod = 'vnpay', bankCode } = req.body;

    // Validate ObjectId format
    if (!mongoose.Types.ObjectId.isValid(bookingId)) {
      // For testing purposes, create a mock booking
      if (bookingId.startsWith('test_booking_')) {
        const mockBooking = {
          _id: new mongoose.Types.ObjectId(),
          userId: req.user._id,
          totalAmount: 100000, // 100k VND for testing
          status: 'pending',
          scheduleId: {
            from: { name: 'Test From' },
            to: { name: 'Test To' },
            departureTime: new Date()
          }
        };

        // Create VNPay payment URL for test booking
        const paymentUrl = vnpayService.createPaymentUrl({
          orderId: bookingId,
          amount: mockBooking.totalAmount,
          orderInfo: `Thanh toan ve test`,
          returnUrl: `${process.env.FRONTEND_URL || 'http://localhost:3000'}/payment/return`,
          ipAddr: req.ip || '127.0.0.1',
          bankCode: bankCode
        });

        return res.status(200).json({
          success: true,
          message: 'Tạo URL thanh toán VNPay thành công (Test Mode)',
          data: {
            paymentUrl,
            paymentId: `PAY_${Date.now()}`,
            transactionId: bookingId,
            amount: mockBooking.totalAmount,
            expiresAt: new Date(Date.now() + 15 * 60 * 1000).toISOString() // 15 minutes
          }
        });
      }

      return res.status(400).json({
        success: false,
        message: 'BookingId không hợp lệ'
      });
    }

    // Tìm booking
    const booking = await Booking.findById(bookingId).populate('scheduleId');
    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy booking'
      });
    }

    // Kiểm tra booking thuộc về user
    if (booking.userId.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Không có quyền truy cập booking này'
      });
    }

    // Kiểm tra trạng thái booking
    if (booking.status !== 'pending') {
      return res.status(400).json({
        success: false,
        message: 'Booking đã được xử lý hoặc đã hủy'
      });
    }

    try {
      // Kiểm tra totalPrice (field name trong Booking model)
      if (!booking.totalPrice || booking.totalPrice <= 0) {
        return res.status(400).json({
          success: false,
          message: 'Booking không có thông tin số tiền hợp lệ'
        });
      }

      // Tạo payment record
      const payment = new Payment({
        bookingId: booking._id,
        userId: req.user._id,
        amount: booking.totalPrice,
        paymentMethod: 'vnpay',
        status: 'pending',
        transactionId: `PAY_${booking._id}_${Date.now()}`,
        metadata: {
          bankCode: bankCode || '',
          userAgent: req.get('User-Agent'),
          ipAddress: req.ip
        }
      });

      await payment.save();

      // Extract route info safely
      const fromLocation = booking.scheduleId?.from?.name ||
                          booking.scheduleId?.route?.from?.name ||
                          booking.scheduleId?.route?.from || 'N/A';
      const toLocation = booking.scheduleId?.to?.name ||
                        booking.scheduleId?.route?.to?.name ||
                        booking.scheduleId?.route?.to || 'N/A';

      // Tạo URL thanh toán VNPay
      const paymentUrl = vnpayService.createPaymentUrl({
        orderId: payment.transactionId,
        amount: Math.round(booking.totalPrice), // Ensure integer for VNPay
        orderInfo: `Thanh toan ve may bay`,
        ipAddr: req.ip || '127.0.0.1',
        bankCode: bankCode || ''
      });

      // Cập nhật payment với URL
      payment.paymentUrl = paymentUrl;
      await payment.save();

      logger.info('VNPay payment URL created', {
        userId: req.user._id,
        bookingId: booking._id,
        paymentId: payment._id,
        amount: booking.totalPrice
      });

      res.json({
        success: true,
        data: {
          paymentUrl,
          paymentId: payment._id,
          transactionId: payment.transactionId,
          amount: booking.totalPrice,
          expiresAt: new Date(Date.now() + 15 * 60 * 1000) // 15 phút
        }
      });

    } catch (error) {
      logger.error('Error creating VNPay payment URL', {
        error: error.message,
        stack: error.stack,
        bookingId,
        userId: req.user._id,
        bookingData: {
          totalPrice: booking?.totalPrice,
          status: booking?.status,
          scheduleId: booking?.scheduleId?._id
        }
      });

      res.status(500).json({
        success: false,
        message: 'Lỗi tạo URL thanh toán',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  })
);

// @route   GET /api/v1/payments/vnpay/return
// @desc    Xử lý return URL từ VNPay
// @access  Public
router.get('/vnpay/return', asyncHandler(async (req, res) => {
  try {
    logger.info('VNPay return URL called', { query: req.query });

    // Handle test case (TEST prefix)
    if (req.query.vnp_TxnRef && req.query.vnp_TxnRef.startsWith('TEST')) {
      const responseCode = req.query.vnp_ResponseCode || '24'; // Default to cancelled
      const testResult = responseCode === '00' ? 'success' : 'failed';

      // Return HTML page for WebView to detect
      res.setHeader('Content-Security-Policy', "script-src 'unsafe-inline'");
      return res.send(`
        <!DOCTYPE html>
        <html>
        <head>
          <title>VNPay Payment Result</title>
          <meta charset="utf-8">
        </head>
        <body>
          <h1>Payment ${testResult === 'success' ? 'Successful' : 'Failed'}</h1>
          <p>Order ID: ${req.query.vnp_TxnRef}</p>
          <p>Response Code: ${responseCode}</p>
          <p>Amount: ${req.query.vnp_Amount}</p>
          <script>
            // Pass data to WebView
            window.paymentResult = {
              success: ${responseCode === '00'},
              responseCode: '${responseCode}',
              orderId: '${req.query.vnp_TxnRef}',
              amount: '${req.query.vnp_Amount}',
              bankCode: '${req.query.vnp_BankCode || ''}',
              testMode: true,
              status: '${testResult}'
            };
          </script>
        </body>
        </html>
      `);
    }

    // Xác thực dữ liệu từ VNPay sử dụng thư viện
    const verifyResult = vnpayService.verifyReturnUrl(req.query);

    if (!verifyResult.isVerified) {
      logger.warn('Invalid VNPay return signature', {
        query: req.query,
        verifyResult
      });

      return res.json({
        success: false,
        message: 'Invalid signature',
        error: 'invalid_signature'
      });
    }

    // Tìm payment
    const payment = await Payment.findOne({
      transactionId: verifyResult.orderId
    }).populate('bookingId');

    if (!payment) {
      logger.warn('Payment not found for VNPay return', {
        orderId: verifyResult.orderId
      });

      return res.redirect(`${process.env.BASE_URL}/payment/failed?error=payment_not_found`);
    }

    // Kiểm tra số tiền
    if (payment.amount !== verifyResult.amount) {
      logger.warn('Amount mismatch in VNPay return', {
        paymentAmount: payment.amount,
        vnpayAmount: verifyResult.amount,
        orderId: verifyResult.orderId
      });
      
      return res.redirect(`${process.env.BASE_URL}/payment/failed?error=amount_mismatch`);
    }

    // Xử lý kết quả thanh toán
    if (verifyResult.responseCode === '00') {
      // Thanh toán thành công
      payment.status = 'completed';
      payment.vnpayTransactionNo = verifyResult.transactionNo;
      payment.bankCode = verifyResult.bankCode;
      payment.payDate = verifyResult.payDate;
      payment.completedAt = new Date();
      
      // Cập nhật booking status
      if (payment.bookingId) {
        payment.bookingId.status = 'confirmed';
        payment.bookingId.paymentStatus = 'paid';
        await payment.bookingId.save();
      }

      await payment.save();

      logger.info('VNPay payment completed successfully', {
        paymentId: payment._id,
        bookingId: payment.bookingId?._id,
        transactionNo: verifyResult.transactionNo,
        amount: verifyResult.amount
      });

      // Return HTML page for WebView to detect
      res.setHeader('Content-Security-Policy', "script-src 'unsafe-inline'");
      return res.send(`
        <!DOCTYPE html>
        <html>
        <head>
          <title>Payment Successful</title>
          <meta charset="utf-8">
        </head>
        <body>
          <h1>Payment Successful!</h1>
          <p>Booking ID: ${payment.bookingId._id}</p>
          <p>Transaction No: ${verifyResult.transactionNo}</p>
          <p>Amount: ${verifyResult.amount}</p>
          <script>
            // Pass data to WebView
            window.paymentResult = {
              success: true,
              responseCode: '${verifyResult.responseCode}',
              orderId: '${verifyResult.orderId}',
              amount: '${verifyResult.amount}',
              bankCode: '${verifyResult.bankCode || ''}',
              transactionNo: '${verifyResult.transactionNo}',
              bookingId: '${payment.bookingId._id}'
            };
          </script>
        </body>
        </html>
      `);
      
    } else {
      // Thanh toán thất bại
      payment.status = 'failed';
      payment.failureReason = `VNPay error: ${verifyResult.responseCode}`;
      payment.vnpayTransactionNo = verifyResult.transactionNo;
      payment.failedAt = new Date();
      
      await payment.save();

      logger.info('VNPay payment failed', {
        paymentId: payment._id,
        bookingId: payment.bookingId?._id,
        responseCode: verifyResult.responseCode,
        transactionNo: verifyResult.transactionNo
      });

      // Return HTML page for WebView to detect
      res.setHeader('Content-Security-Policy', "script-src 'unsafe-inline'");
      return res.send(`
        <!DOCTYPE html>
        <html>
        <head>
          <title>Payment Failed</title>
          <meta charset="utf-8">
        </head>
        <body>
          <h1>Payment Failed</h1>
          <p>Error Code: ${verifyResult.responseCode}</p>
          <p>Transaction No: ${verifyResult.transactionNo}</p>
          <script>
            // Pass data to WebView
            window.paymentResult = {
              success: false,
              responseCode: '${verifyResult.responseCode}',
              orderId: '${verifyResult.orderId}',
              amount: '${verifyResult.amount}',
              bankCode: '${verifyResult.bankCode || ''}',
              transactionNo: '${verifyResult.transactionNo}',
              message: 'Payment failed'
            };
          </script>
        </body>
        </html>
      `);
    }

  } catch (error) {
    logger.error('Error processing VNPay return', {
      error: error.message,
      query: req.query
    });

    // Return HTML page for WebView to detect
    res.setHeader('Content-Security-Policy', "script-src 'unsafe-inline'");
    return res.send(`
      <!DOCTYPE html>
      <html>
      <head>
        <title>Payment Error</title>
        <meta charset="utf-8">
      </head>
      <body>
        <h1>Payment Processing Error</h1>
        <p>An error occurred while processing your payment.</p>
        <script>
          // Pass data to WebView
          window.paymentResult = {
            success: false,
            responseCode: '99',
            message: 'Processing error',
            error: 'processing_error'
          };
        </script>
      </body>
      </html>
    `);
  }
}));

// @route   GET /api/v1/payments/vnpay/ipn (Test endpoint)
// @desc    Test IPN từ VNPay
// @access  Public
router.get('/vnpay/ipn', asyncHandler(async (req, res) => {
  try {
    // Handle test case for IPN
    if (req.query.vnp_TxnRef && req.query.vnp_TxnRef.startsWith('TEST')) {
      const responseCode = req.query.vnp_ResponseCode || '00';

      return res.json({
        RspCode: '00',
        Message: 'Confirm Success',
        data: {
          orderId: req.query.vnp_TxnRef,
          responseCode: responseCode,
          amount: req.query.vnp_Amount,
          testMode: true
        }
      });
    }

    // Xác thực dữ liệu từ VNPay sử dụng thư viện
    const verifyResult = vnpayService.verifyIpnCall(req.query);

    if (!verifyResult.isVerified) {
      return res.json({
        RspCode: '97',
        Message: 'Invalid signature'
      });
    }

    return res.json({
      RspCode: '00',
      Message: 'Confirm Success'
    });
  } catch (error) {
    logger.error('Error processing VNPay IPN (GET)', {
      error: error.message,
      query: req.query
    });

    return res.json({
      RspCode: '99',
      Message: 'Unknown error'
    });
  }
}));

// @route   POST /api/v1/payments/vnpay/ipn
// @desc    Xử lý IPN từ VNPay
// @access  Public
router.post('/vnpay/ipn', asyncHandler(async (req, res) => {
  try {
    // Xác thực dữ liệu từ VNPay
    const verifyResult = vnpayService.verifyIpnCall(req.query);
    
    if (!verifyResult.isValid) {
      logger.warn('Invalid VNPay IPN signature', {
        query: req.query
      });
      
      return res.json(vnpayService.createIpnResponse(
        VNPayService.RESPONSE_CODES.INVALID_SIGNATURE,
        'Invalid signature'
      ));
    }

    // Tìm payment
    const payment = await Payment.findOne({
      transactionId: verifyResult.orderId
    }).populate('bookingId');

    if (!payment) {
      logger.warn('Payment not found for VNPay IPN', {
        orderId: verifyResult.orderId
      });
      
      return res.json(vnpayService.createIpnResponse(
        VNPayService.RESPONSE_CODES.ORDER_NOT_FOUND,
        'Order not found'
      ));
    }

    // Kiểm tra số tiền
    if (payment.amount !== verifyResult.amount) {
      logger.warn('Amount mismatch in VNPay IPN', {
        paymentAmount: payment.amount,
        vnpayAmount: verifyResult.amount,
        orderId: verifyResult.orderId
      });
      
      return res.json(vnpayService.createIpnResponse(
        VNPayService.RESPONSE_CODES.INVALID_AMOUNT,
        'Invalid amount'
      ));
    }

    // Kiểm tra trạng thái payment
    if (payment.status !== 'pending') {
      logger.warn('Payment already processed for VNPay IPN', {
        paymentId: payment._id,
        currentStatus: payment.status,
        orderId: verifyResult.orderId
      });
      
      return res.json(vnpayService.createIpnResponse(
        VNPayService.RESPONSE_CODES.ORDER_ALREADY_CONFIRMED,
        'Order already confirmed'
      ));
    }

    // Xử lý kết quả thanh toán
    if (verifyResult.responseCode === '00' && verifyResult.transactionStatus === '00') {
      // Thanh toán thành công
      payment.status = 'completed';
      payment.vnpayTransactionNo = verifyResult.transactionNo;
      payment.bankCode = verifyResult.bankCode;
      payment.payDate = verifyResult.payDate;
      payment.completedAt = new Date();
      
      // Cập nhật booking status
      if (payment.bookingId) {
        payment.bookingId.status = 'confirmed';
        payment.bookingId.paymentStatus = 'paid';
        await payment.bookingId.save();
      }

      await payment.save();

      logger.info('VNPay IPN payment completed successfully', {
        paymentId: payment._id,
        bookingId: payment.bookingId?._id,
        transactionNo: verifyResult.transactionNo,
        amount: verifyResult.amount
      });

    } else {
      // Thanh toán thất bại
      payment.status = 'failed';
      payment.failureReason = `VNPay error: ${verifyResult.responseCode}`;
      payment.vnpayTransactionNo = verifyResult.transactionNo;
      payment.failedAt = new Date();
      
      await payment.save();

      logger.info('VNPay IPN payment failed', {
        paymentId: payment._id,
        bookingId: payment.bookingId?._id,
        responseCode: verifyResult.responseCode,
        transactionNo: verifyResult.transactionNo
      });
    }

    // Trả về success cho VNPay
    return res.json(vnpayService.createIpnResponse(
      VNPayService.RESPONSE_CODES.SUCCESS,
      'Confirm Success'
    ));

  } catch (error) {
    logger.error('Error processing VNPay IPN', {
      error: error.message,
      query: req.query
    });

    return res.json(vnpayService.createIpnResponse(
      VNPayService.RESPONSE_CODES.UNKNOWN_ERROR,
      'Unknown error'
    ));
  }
}));

// @route   GET /api/v1/payments/banks
// @desc    Lấy danh sách ngân hàng VNPay
// @access  Public
router.get('/banks', asyncHandler(async (req, res) => {
  try {
    const banks = await vnpayService.getBankList();
    
    res.json({
      success: true,
      data: banks
    });
  } catch (error) {
    logger.error('Error getting bank list', {
      error: error.message
    });

    res.status(500).json({
      success: false,
      message: 'Lỗi lấy danh sách ngân hàng'
    });
  }
}));

module.exports = router;
