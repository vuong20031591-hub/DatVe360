const { body, param, query, validationResult } = require('express-validator');

// Handle validation errors
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  
  if (!errors.isEmpty()) {
    const formattedErrors = errors.array().map(error => ({
      field: error.path,
      message: error.msg,
      value: error.value
    }));

    return res.status(400).json({
      success: false,
      message: 'Dữ liệu không hợp lệ',
      errors: formattedErrors
    });
  }
  
  next();
};

// Common validation rules
const commonValidations = {
  email: body('email')
    .isEmail()
    .withMessage('Email không hợp lệ')
    .normalizeEmail(),
    
  phone: body('phone')
    .matches(/^[0-9]{10,11}$/)
    .withMessage('Số điện thoại không hợp lệ (10-11 chữ số)'),
    
  password: body('password')
    .isLength({ min: 6 })
    .withMessage('Mật khẩu phải có ít nhất 6 ký tự')
    .matches(/^(?=.*[a-zA-Z])(?=.*\d)/)
    .withMessage('Mật khẩu phải chứa ít nhất 1 chữ cái và 1 số'),
    
  fullName: body('fullName')
    .isLength({ min: 2, max: 100 })
    .withMessage('Họ tên phải từ 2-100 ký tự')
    .matches(/^[a-zA-ZÀ-ỹ\s]+$/)
    .withMessage('Họ tên chỉ được chứa chữ cái và khoảng trắng'),
    
  objectId: (field) => param(field)
    .isMongoId()
    .withMessage(`${field} không hợp lệ`),
    
  pnr: param('pnr')
    .isLength({ min: 6, max: 6 })
    .withMessage('PNR phải có đúng 6 ký tự')
    .isAlphanumeric()
    .withMessage('PNR chỉ được chứa chữ cái và số')
    .toUpperCase(),
    
  date: (field) => body(field)
    .isISO8601()
    .withMessage(`${field} phải có định dạng ngày hợp lệ (ISO 8601)`)
    .toDate(),
    
  pagination: [
    query('page')
      .optional()
      .isInt({ min: 1 })
      .withMessage('Trang phải là số nguyên dương')
      .toInt(),
    query('limit')
      .optional()
      .isInt({ min: 1, max: 100 })
      .withMessage('Giới hạn phải từ 1-100')
      .toInt()
  ]
};

// Auth validation rules
const authValidations = {
  register: [
    commonValidations.email,
    commonValidations.phone,
    commonValidations.password,
    commonValidations.fullName,
    body('confirmPassword')
      .custom((value, { req }) => {
        if (value !== req.body.password) {
          throw new Error('Xác nhận mật khẩu không khớp');
        }
        return true;
      }),
    handleValidationErrors
  ],
  
  login: [
    body('identifier')
      .notEmpty()
      .withMessage('Email hoặc số điện thoại là bắt buộc'),
    body('password')
      .notEmpty()
      .withMessage('Mật khẩu là bắt buộc'),
    handleValidationErrors
  ],
  
  refreshToken: [
    body('refreshToken')
      .notEmpty()
      .withMessage('Refresh token là bắt buộc'),
    handleValidationErrors
  ],
  
  forgotPassword: [
    body('identifier')
      .notEmpty()
      .withMessage('Email hoặc số điện thoại là bắt buộc'),
    handleValidationErrors
  ],
  
  resetPassword: [
    body('token')
      .notEmpty()
      .withMessage('Token reset là bắt buộc'),
    commonValidations.password,
    body('confirmPassword')
      .custom((value, { req }) => {
        if (value !== req.body.password) {
          throw new Error('Xác nhận mật khẩu không khớp');
        }
        return true;
      }),
    handleValidationErrors
  ],
  
  changePassword: [
    body('currentPassword')
      .notEmpty()
      .withMessage('Mật khẩu hiện tại là bắt buộc'),
    commonValidations.password.withMessage('Mật khẩu mới phải có ít nhất 6 ký tự và chứa chữ cái, số'),
    body('confirmPassword')
      .custom((value, { req }) => {
        if (value !== req.body.password) {
          throw new Error('Xác nhận mật khẩu không khớp');
        }
        return true;
      }),
    handleValidationErrors
  ]
};

// User validation rules
const userValidations = {
  updateProfile: [
    commonValidations.fullName.optional(),
    body('avatar')
      .optional()
      .isURL()
      .withMessage('Avatar phải là URL hợp lệ'),
    handleValidationErrors
  ]
};

// Search validation rules
const searchValidations = {
  searchTrips: [
    query('from')
      .notEmpty()
      .withMessage('Điểm đi là bắt buộc')
      .isLength({ max: 10 })
      .withMessage('Mã điểm đi không hợp lệ'),
    query('to')
      .notEmpty()
      .withMessage('Điểm đến là bắt buộc')
      .isLength({ max: 10 })
      .withMessage('Mã điểm đến không hợp lệ'),
    query('departDate')
      .notEmpty()
      .withMessage('Ngày khởi hành là bắt buộc')
      .isISO8601()
      .withMessage('Ngày khởi hành không hợp lệ')
      .custom((value) => {
        const departDate = new Date(value);
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        
        if (departDate < today) {
          throw new Error('Ngày khởi hành không thể trong quá khứ');
        }
        return true;
      }),
    query('mode')
      .optional()
      .isIn(['flight', 'train', 'bus', 'ferry'])
      .withMessage('Phương thức vận chuyển không hợp lệ'),
    query('passengers')
      .optional()
      .isInt({ min: 1, max: 9 })
      .withMessage('Số hành khách phải từ 1-9')
      .toInt(),
    ...commonValidations.pagination,
    handleValidationErrors
  ]
};

// Booking validation rules
const bookingValidations = {
  createBooking: [
    body('tripId')
      .isMongoId()
      .withMessage('Trip ID không hợp lệ'),
    body('selectedClass')
      .notEmpty()
      .withMessage('Hạng ghế là bắt buộc'),
    body('passengers')
      .isArray({ min: 1, max: 9 })
      .withMessage('Danh sách hành khách phải từ 1-9 người'),
    body('passengers.*.firstName')
      .notEmpty()
      .withMessage('Tên của hành khách là bắt buộc')
      .isLength({ max: 50 })
      .withMessage('Tên không được vượt quá 50 ký tự'),
    body('passengers.*.lastName')
      .notEmpty()
      .withMessage('Họ của hành khách là bắt buộc')
      .isLength({ max: 50 })
      .withMessage('Họ không được vượt quá 50 ký tự'),
    body('passengers.*.type')
      .isIn(['adult', 'child', 'infant'])
      .withMessage('Loại hành khách không hợp lệ'),
    body('passengers.*.documentType')
      .isIn(['passport', 'id_card', 'birth_certificate', 'driver_license'])
      .withMessage('Loại giấy tờ không hợp lệ'),
    body('passengers.*.documentId')
      .notEmpty()
      .withMessage('Số giấy tờ là bắt buộc')
      .isLength({ max: 50 })
      .withMessage('Số giấy tờ không được vượt quá 50 ký tự'),
    body('passengers.*.dateOfBirth')
      .isISO8601()
      .withMessage('Ngày sinh không hợp lệ')
      .toDate(),
    body('passengers.*.gender')
      .isIn(['male', 'female', 'other'])
      .withMessage('Giới tính không hợp lệ'),
    body('contactInfo.fullName')
      .notEmpty()
      .withMessage('Tên liên hệ là bắt buộc'),
    body('contactInfo.email')
      .isEmail()
      .withMessage('Email liên hệ không hợp lệ')
      .normalizeEmail(),
    body('contactInfo.phone')
      .matches(/^[0-9]{10,11}$/)
      .withMessage('Số điện thoại liên hệ không hợp lệ'),
    body('selectedSeats')
      .optional()
      .isArray()
      .withMessage('Danh sách ghế đã chọn phải là mảng'),
    handleValidationErrors
  ],
  
  updateBooking: [
    commonValidations.objectId('id'),
    body('status')
      .optional()
      .isIn(['pending', 'confirmed', 'cancelled', 'completed'])
      .withMessage('Trạng thái booking không hợp lệ'),
    handleValidationErrors
  ],
  
  cancelBooking: [
    commonValidations.objectId('id'),
    body('reason')
      .optional()
      .isLength({ max: 200 })
      .withMessage('Lý do hủy không được vượt quá 200 ký tự'),
    handleValidationErrors
  ]
};

// Payment validation rules
const paymentValidations = {
  createPayment: [
    body('bookingId')
      .isMongoId()
      .withMessage('Booking ID không hợp lệ'),
    body('paymentMethod')
      .isIn(['vnpay', 'momo', 'stripe'])
      .withMessage('Phương thức thanh toán không hợp lệ'),
    body('returnUrl')
      .optional()
      .isURL()
      .withMessage('Return URL không hợp lệ'),
    handleValidationErrors
  ]
};

// Seat validation rules
const seatValidations = {
  selectSeats: [
    body('tripId')
      .isMongoId()
      .withMessage('Trip ID không hợp lệ'),
    body('seatNumbers')
      .isArray({ min: 1 })
      .withMessage('Danh sách ghế phải là mảng và có ít nhất 1 ghế'),
    body('seatNumbers.*')
      .matches(/^[0-9]{1,2}[A-Z]$/)
      .withMessage('Số ghế không hợp lệ (ví dụ: 12A)'),
    handleValidationErrors
  ]
};

module.exports = {
  handleValidationErrors,
  commonValidations,
  authValidations,
  userValidations,
  searchValidations,
  bookingValidations,
  paymentValidations,
  seatValidations
};
