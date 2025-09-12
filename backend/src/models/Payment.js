const mongoose = require('mongoose');

const PaymentSchema = new mongoose.Schema({
  bookingId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Booking',
    required: true,
    index: true
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  amount: {
    type: Number,
    required: true,
    min: 0
  },
  currency: {
    type: String,
    default: 'VND',
    enum: ['VND', 'USD']
  },
  method: {
    type: String,
    required: true,
    enum: ['vnpay', 'momo', 'stripe', 'bank_transfer']
  },
  status: {
    type: String,
    default: 'pending',
    enum: ['pending', 'processing', 'completed', 'failed', 'cancelled', 'refunded'],
    index: true
  },
  transactionId: {
    type: String,
    unique: true,
    sparse: true
  },
  gatewayTransactionId: {
    type: String,
    sparse: true
  },
  gatewayResponse: {
    type: mongoose.Schema.Types.Mixed
  },
  refundAmount: {
    type: Number,
    default: 0,
    min: 0
  },
  refundReason: String,
  metadata: {
    type: mongoose.Schema.Types.Mixed,
    default: {}
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes
PaymentSchema.index({ userId: 1, createdAt: -1 });
PaymentSchema.index({ bookingId: 1 });
PaymentSchema.index({ status: 1, createdAt: -1 });
PaymentSchema.index({ transactionId: 1 });

// Virtuals
PaymentSchema.virtual('isCompleted').get(function() {
  return this.status === 'completed';
});

PaymentSchema.virtual('canRefund').get(function() {
  return this.status === 'completed' && this.refundAmount < this.amount;
});

// Methods
PaymentSchema.methods.markAsCompleted = function(gatewayData) {
  this.status = 'completed';
  this.gatewayTransactionId = gatewayData.transactionId;
  this.gatewayResponse = gatewayData;
  return this.save();
};

PaymentSchema.methods.markAsFailed = function(error) {
  this.status = 'failed';
  this.gatewayResponse = { error };
  return this.save();
};

// Static methods
PaymentSchema.statics.findByBooking = function(bookingId) {
  return this.findOne({ bookingId }).populate('booking user');
};

PaymentSchema.statics.findByTransactionId = function(transactionId) {
  return this.findOne({ transactionId });
};

module.exports = mongoose.model('Payment', PaymentSchema);

const paymentSchema = new mongoose.Schema({
  bookingId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Booking',
    required: [true, 'Booking ID là bắt buộc'],
    index: true
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User ID là bắt buộc'],
    index: true
  },
  transactionId: {
    type: String,
    required: [true, 'Transaction ID là bắt buộc'],
    unique: true,
    index: true
  },
  paymentMethod: {
    type: String,
    required: [true, 'Phương thức thanh toán là bắt buộc'],
    enum: {
      values: ['vnpay', 'momo', 'stripe', 'bank_transfer', 'cash'],
      message: 'Phương thức thanh toán không hợp lệ'
    },
    index: true
  },
  gatewayTransactionId: {
    type: String,
    sparse: true,
    index: true
  },
  gatewayOrderId: {
    type: String,
    sparse: true
  },
  amount: {
    type: Number,
    required: [true, 'Số tiền là bắt buộc'],
    min: [0, 'Số tiền không thể âm']
  },
  currency: {
    type: String,
    required: true,
    default: 'VND'
  },
  status: {
    type: String,
    required: true,
    enum: {
      values: ['pending', 'processing', 'completed', 'failed', 'cancelled', 'refunded', 'partially_refunded'],
      message: 'Trạng thái thanh toán không hợp lệ'
    },
    default: 'pending',
    index: true
  },
  paymentUrl: String, // URL để redirect đến gateway
  returnUrl: String,  // URL để redirect về sau khi thanh toán
  description: String,
  bankCode: String,   // Mã ngân hàng (cho VNPay)
  cardType: String,   // Loại thẻ (ATM, CREDIT, etc.)
  
  // Gateway response data
  gatewayResponse: {
    type: Map,
    of: mongoose.Schema.Types.Mixed,
    default: new Map()
  },
  
  // Webhook data
  webhookData: {
    type: Map,
    of: mongoose.Schema.Types.Mixed,
    default: new Map()
  },
  
  // Payment timestamps
  initiatedAt: {
    type: Date,
    default: Date.now
  },
  processedAt: Date,
  completedAt: Date,
  failedAt: Date,
  expiredAt: Date,
  
  // Refund information
  refundAmount: {
    type: Number,
    default: 0,
    min: 0
  },
  refundStatus: {
    type: String,
    enum: ['none', 'requested', 'processing', 'completed', 'failed'],
    default: 'none'
  },
  refundTransactionId: String,
  refundReason: String,
  refundRequestedAt: Date,
  refundCompletedAt: Date,
  
  // Error information
  errorCode: String,
  errorMessage: String,
  
  // Additional metadata
  userAgent: String,
  ipAddress: String,
  deviceInfo: String,
  
  metadata: {
    type: Map,
    of: mongoose.Schema.Types.Mixed,
    default: new Map()
  }
}, {
  timestamps: true,
  toJSON: { 
    virtuals: true,
    transform: function(doc, ret) {
      // Don't expose sensitive gateway data in JSON
      delete ret.gatewayResponse;
      delete ret.webhookData;
      return ret;
    }
  },
  toObject: { virtuals: true }
});

// Indexes
paymentSchema.index({ bookingId: 1 });
paymentSchema.index({ userId: 1, createdAt: -1 });
paymentSchema.index({ transactionId: 1 });
paymentSchema.index({ gatewayTransactionId: 1 }, { sparse: true });
paymentSchema.index({ paymentMethod: 1, status: 1 });
paymentSchema.index({ status: 1, createdAt: -1 });
paymentSchema.index({ expiredAt: 1 }, { sparse: true });

// Virtual for is successful
paymentSchema.virtual('isSuccessful').get(function() {
  return this.status === 'completed';
});

// Virtual for is pending
paymentSchema.virtual('isPending').get(function() {
  return ['pending', 'processing'].includes(this.status);
});

// Virtual for is failed
paymentSchema.virtual('isFailed').get(function() {
  return ['failed', 'cancelled'].includes(this.status);
});

// Virtual for is expired
paymentSchema.virtual('isExpired').get(function() {
  return this.expiredAt && new Date() > this.expiredAt;
});

// Virtual for can refund
paymentSchema.virtual('canRefund').get(function() {
  return this.status === 'completed' && this.refundStatus === 'none';
});

// Virtual for refund available amount
paymentSchema.virtual('refundAvailableAmount').get(function() {
  return Math.max(0, this.amount - this.refundAmount);
});

// Generate unique transaction ID
paymentSchema.methods.generateTransactionId = function() {
  const timestamp = Date.now().toString(36);
  const random = Math.random().toString(36).substring(2, 8);
  return `PAY${timestamp}${random}`.toUpperCase();
};

// Pre-save middleware to generate transaction ID
paymentSchema.pre('save', async function(next) {
  if (!this.transactionId) {
    let transactionId;
    let exists = true;
    
    while (exists) {
      transactionId = this.generateTransactionId();
      exists = await this.constructor.findOne({ transactionId });
    }
    
    this.transactionId = transactionId;
  }
  
  next();
});

// Pre-save middleware to set status timestamps
paymentSchema.pre('save', function(next) {
  const now = new Date();
  
  if (this.isModified('status')) {
    switch (this.status) {
      case 'processing':
        if (!this.processedAt) this.processedAt = now;
        break;
      case 'completed':
        if (!this.completedAt) this.completedAt = now;
        break;
      case 'failed':
      case 'cancelled':
        if (!this.failedAt) this.failedAt = now;
        break;
    }
  }
  
  next();
});

// Static method to find payments by user
paymentSchema.statics.findByUser = function(userId, options = {}) {
  const { page = 1, limit = 10, status, paymentMethod, sortBy = 'createdAt', sortOrder = 'desc' } = options;
  
  const query = { userId };
  if (status) query.status = status;
  if (paymentMethod) query.paymentMethod = paymentMethod;
  
  return this.find(query)
    .populate('bookingId', 'pnr totalPrice status tripId')
    .sort({ [sortBy]: sortOrder === 'desc' ? -1 : 1 })
    .skip((page - 1) * limit)
    .limit(limit);
};

// Static method to find payment by transaction ID
paymentSchema.statics.findByTransactionId = function(transactionId) {
  return this.findOne({ transactionId })
    .populate('bookingId')
    .populate('userId', 'fullName email phone');
};

// Static method to find payment by gateway transaction ID
paymentSchema.statics.findByGatewayTransactionId = function(gatewayTransactionId) {
  return this.findOne({ gatewayTransactionId })
    .populate('bookingId')
    .populate('userId', 'fullName email phone');
};

// Instance method to mark as completed
paymentSchema.methods.markAsCompleted = async function(gatewayData = {}) {
  this.status = 'completed';
  this.completedAt = new Date();
  this.gatewayResponse.set('completionData', gatewayData);
  
  await this.save();
};

// Instance method to mark as failed
paymentSchema.methods.markAsFailed = async function(errorCode, errorMessage, gatewayData = {}) {
  this.status = 'failed';
  this.failedAt = new Date();
  this.errorCode = errorCode;
  this.errorMessage = errorMessage;
  this.gatewayResponse.set('errorData', gatewayData);
  
  await this.save();
};

// Instance method to request refund
paymentSchema.methods.requestRefund = async function(amount, reason) {
  if (!this.canRefund) {
    throw new Error('Không thể hoàn tiền cho giao dịch này');
  }
  
  if (amount > this.refundAvailableAmount) {
    throw new Error('Số tiền hoàn vượt quá số tiền có thể hoàn');
  }
  
  this.refundAmount = amount;
  this.refundStatus = 'requested';
  this.refundReason = reason;
  this.refundRequestedAt = new Date();
  
  await this.save();
};

// Instance method to complete refund
paymentSchema.methods.completeRefund = async function(refundTransactionId) {
  if (this.refundStatus !== 'processing') {
    throw new Error('Không thể hoàn thành hoàn tiền cho giao dịch này');
  }
  
  this.refundStatus = 'completed';
  this.refundTransactionId = refundTransactionId;
  this.refundCompletedAt = new Date();
  
  // Update main status if fully refunded
  if (this.refundAmount >= this.amount) {
    this.status = 'refunded';
  } else {
    this.status = 'partially_refunded';
  }
  
  await this.save();
};

// Instance method to set expiration
paymentSchema.methods.setExpiration = function(minutes = 30) {
  this.expiredAt = new Date(Date.now() + minutes * 60 * 1000);
};

// Static method to cleanup expired payments
paymentSchema.statics.cleanupExpiredPayments = async function() {
  const now = new Date();
  
  const result = await this.updateMany(
    { 
      status: { $in: ['pending', 'processing'] },
      expiredAt: { $lt: now }
    },
    { 
      status: 'failed',
      failedAt: now,
      errorCode: 'EXPIRED',
      errorMessage: 'Giao dịch đã hết hạn'
    }
  );
  
  return result.modifiedCount;
};

// Static method to get payment statistics
paymentSchema.statics.getPaymentStats = function(dateFrom, dateTo, groupBy = 'day') {
  const groupId = groupBy === 'day' 
    ? { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } }
    : { $dateToString: { format: '%Y-%m', date: '$createdAt' } };
    
  return this.aggregate([
    {
      $match: {
        createdAt: { $gte: dateFrom, $lte: dateTo }
      }
    },
    {
      $group: {
        _id: groupId,
        totalAmount: { $sum: '$amount' },
        totalCount: { $sum: 1 },
        successfulCount: {
          $sum: { $cond: [{ $eq: ['$status', 'completed'] }, 1, 0] }
        },
        failedCount: {
          $sum: { $cond: [{ $in: ['$status', ['failed', 'cancelled']] }, 1, 0] }
        },
        avgAmount: { $avg: '$amount' }
      }
    },
    { $sort: { _id: 1 } }
  ]);
};

module.exports = mongoose.model('Payment', paymentSchema);
