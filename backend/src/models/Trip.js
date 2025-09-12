const mongoose = require('mongoose');

const classOptionSchema = new mongoose.Schema({
  id: {
    type: String,
    required: true
  },
  name: {
    type: String,
    required: true
  },
  description: String,
  price: {
    type: Number,
    required: true,
    min: 0
  },
  currency: {
    type: String,
    required: true,
    default: 'VND'
  },
  availableSeats: {
    type: Number,
    required: true,
    min: 0
  },
  totalSeats: {
    type: Number,
    required: true,
    min: 0
  },
  amenities: [String],
  refundable: {
    type: Boolean,
    default: true
  },
  changeable: {
    type: Boolean,
    default: true
  }
}, { _id: false });

const stopSchema = new mongoose.Schema({
  code: {
    type: String,
    required: true
  },
  name: {
    type: String,
    required: true
  },
  arriveAt: Date,
  departAt: Date,
  duration: {
    type: Number, // Duration in minutes
    default: 0
  }
}, { _id: false });

const tripSchema = new mongoose.Schema({
  carrierId: {
    type: String,
    required: [true, 'ID nhà cung cấp là bắt buộc'],
    index: true
  },
  carrierName: {
    type: String,
    required: [true, 'Tên nhà cung cấp là bắt buộc']
  },
  carrierLogo: {
    type: String,
    default: null
  },
  mode: {
    type: String,
    required: [true, 'Phương thức vận chuyển là bắt buộc'],
    enum: {
      values: ['flight', 'train', 'bus', 'ferry'],
      message: 'Phương thức vận chuyển không hợp lệ'
    },
    index: true
  },
  flightNumber: {
    type: String,
    sparse: true, // Only for flights
    index: true
  },
  trainNumber: {
    type: String,
    sparse: true, // Only for trains
    index: true
  },
  busNumber: {
    type: String,
    sparse: true, // Only for buses
    index: true
  },
  from: {
    type: String,
    required: [true, 'Điểm đi là bắt buộc'],
    index: true
  },
  fromCode: {
    type: String,
    required: [true, 'Mã điểm đi là bắt buộc'],
    index: true
  },
  to: {
    type: String,
    required: [true, 'Điểm đến là bắt buộc'],
    index: true
  },
  toCode: {
    type: String,
    required: [true, 'Mã điểm đến là bắt buộc'],
    index: true
  },
  departAt: {
    type: Date,
    required: [true, 'Thời gian khởi hành là bắt buộc'],
    index: true
  },
  arriveAt: {
    type: Date,
    required: [true, 'Thời gian đến là bắt buộc'],
    index: true
  },
  duration: {
    type: Number, // Duration in minutes
    required: true,
    min: 0
  },
  basePrice: {
    type: Number,
    required: [true, 'Giá cơ bản là bắt buộc'],
    min: 0
  },
  currency: {
    type: String,
    required: true,
    default: 'VND'
  },
  stops: [stopSchema],
  classOptions: [classOptionSchema],
  status: {
    type: String,
    enum: ['scheduled', 'boarding', 'departed', 'arrived', 'cancelled', 'delayed'],
    default: 'scheduled',
    index: true
  },
  gate: String,
  terminal: String,
  aircraft: String, // For flights
  trainType: String, // For trains
  busType: String, // For buses
  isActive: {
    type: Boolean,
    default: true,
    index: true
  },
  allowBooking: {
    type: Boolean,
    default: true
  },
  bookingDeadline: {
    type: Date,
    default: function() {
      // Default booking deadline is 1 hour before departure
      return new Date(this.departAt - 60 * 60 * 1000);
    }
  },
  cancellationDeadline: {
    type: Date,
    default: function() {
      // Default cancellation deadline is 2 hours before departure
      return new Date(this.departAt - 2 * 60 * 60 * 1000);
    }
  },
  metadata: {
    type: Map,
    of: mongoose.Schema.Types.Mixed,
    default: new Map()
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Compound indexes for efficient queries
tripSchema.index({ fromCode: 1, toCode: 1, departAt: 1 });
tripSchema.index({ mode: 1, departAt: 1 });
tripSchema.index({ carrierId: 1, departAt: 1 });
tripSchema.index({ status: 1, isActive: 1 });
tripSchema.index({ departAt: 1, status: 1 });

// Virtual for route (from-to combination)
tripSchema.virtual('route').get(function() {
  return `${this.fromCode}-${this.toCode}`;
});

// Virtual for available seats across all classes
tripSchema.virtual('totalAvailableSeats').get(function() {
  return this.classOptions.reduce((total, classOption) => total + classOption.availableSeats, 0);
});

// Virtual for total seats across all classes
tripSchema.virtual('totalSeats').get(function() {
  return this.classOptions.reduce((total, classOption) => total + classOption.totalSeats, 0);
});

// Virtual for lowest price
tripSchema.virtual('lowestPrice').get(function() {
  if (!this.classOptions || this.classOptions.length === 0) return this.basePrice;
  return Math.min(...this.classOptions.map(option => option.price));
});

// Virtual for booking availability
tripSchema.virtual('canBook').get(function() {
  const now = new Date();
  return this.isActive && 
         this.allowBooking && 
         this.status === 'scheduled' && 
         this.bookingDeadline > now &&
         this.totalAvailableSeats > 0;
});

// Pre-save middleware to calculate duration
tripSchema.pre('save', function(next) {
  if (this.isModified('departAt') || this.isModified('arriveAt')) {
    this.duration = Math.round((this.arriveAt - this.departAt) / (1000 * 60)); // Duration in minutes
  }
  next();
});

// Static method to search trips
tripSchema.statics.searchTrips = function(searchParams) {
  const {
    from,
    to,
    departDate,
    mode,
    minPrice,
    maxPrice,
    carrierId,
    page = 1,
    limit = 20,
    sortBy = 'departAt',
    sortOrder = 'asc'
  } = searchParams;

  const query = {
    isActive: true,
    status: 'scheduled',
    allowBooking: true
  };

  if (from) query.fromCode = from;
  if (to) query.toCode = to;
  if (mode) query.mode = mode;
  if (carrierId) query.carrierId = carrierId;

  // Date range for departure
  if (departDate) {
    const startOfDay = new Date(departDate);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(departDate);
    endOfDay.setHours(23, 59, 59, 999);
    
    query.departAt = {
      $gte: startOfDay,
      $lte: endOfDay
    };
  }

  // Price range
  if (minPrice || maxPrice) {
    const priceQuery = {};
    if (minPrice) priceQuery.$gte = minPrice;
    if (maxPrice) priceQuery.$lte = maxPrice;
    
    // Use aggregation to filter by price range across class options
    return this.aggregate([
      { $match: query },
      { $match: { 'classOptions.price': priceQuery } },
      { $sort: { [sortBy]: sortOrder === 'desc' ? -1 : 1 } },
      { $skip: (page - 1) * limit },
      { $limit: limit }
    ]);
  }

  return this.find(query)
    .sort({ [sortBy]: sortOrder === 'desc' ? -1 : 1 })
    .skip((page - 1) * limit)
    .limit(limit);
};

// Static method to get popular routes
tripSchema.statics.getPopularRoutes = function(limit = 10) {
  return this.aggregate([
    { $match: { isActive: true, status: 'scheduled' } },
    { 
      $group: {
        _id: { from: '$fromCode', to: '$toCode', fromName: '$from', toName: '$to' },
        count: { $sum: 1 },
        minPrice: { $min: '$basePrice' },
        avgPrice: { $avg: '$basePrice' }
      }
    },
    { $sort: { count: -1 } },
    { $limit: limit },
    {
      $project: {
        _id: 0,
        route: '$_id',
        tripCount: '$count',
        minPrice: '$minPrice',
        avgPrice: '$avgPrice'
      }
    }
  ]);
};

// Instance method to check seat availability
tripSchema.methods.checkSeatAvailability = function(classId, requestedSeats = 1) {
  const classOption = this.classOptions.find(option => option.id === classId);
  if (!classOption) return false;
  return classOption.availableSeats >= requestedSeats;
};

// Instance method to reserve seats
tripSchema.methods.reserveSeats = function(classId, seatCount) {
  const classOption = this.classOptions.find(option => option.id === classId);
  if (!classOption || classOption.availableSeats < seatCount) {
    throw new Error('Không đủ ghế trống');
  }
  classOption.availableSeats -= seatCount;
};

// Instance method to release seats
tripSchema.methods.releaseSeats = function(classId, seatCount) {
  const classOption = this.classOptions.find(option => option.id === classId);
  if (!classOption) return;
  classOption.availableSeats = Math.min(
    classOption.availableSeats + seatCount,
    classOption.totalSeats
  );
};

module.exports = mongoose.model('Trip', tripSchema);
