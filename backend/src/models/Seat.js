const mongoose = require('mongoose');

const seatSchema = new mongoose.Schema({
  tripId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Trip',
    required: [true, 'Trip ID là bắt buộc'],
    index: true
  },
  seatNumber: {
    type: String,
    required: [true, 'Số ghế là bắt buộc'],
    trim: true
  },
  row: {
    type: Number,
    required: [true, 'Hàng ghế là bắt buộc'],
    min: 1
  },
  column: {
    type: String,
    required: [true, 'Cột ghế là bắt buộc'],
    match: /^[A-Z]$/
  },
  classType: {
    type: String,
    required: [true, 'Loại hạng ghế là bắt buộc'],
    enum: ['economy', 'premium_economy', 'business', 'first']
  },
  seatType: {
    type: String,
    required: [true, 'Loại ghế là bắt buộc'],
    enum: {
      values: ['standard', 'premium', 'exit', 'window', 'aisle', 'middle'],
      message: 'Loại ghế không hợp lệ'
    }
  },
  status: {
    type: String,
    required: true,
    enum: {
      values: ['available', 'booked', 'selected', 'held', 'blocked', 'maintenance'],
      message: 'Trạng thái ghế không hợp lệ'
    },
    default: 'available',
    index: true
  },
  price: {
    type: Number,
    required: true,
    min: 0,
    default: 0
  },
  priceAddon: {
    type: Number,
    default: 0,
    min: 0
  },
  currency: {
    type: String,
    required: true,
    default: 'VND'
  },
  features: [{
    type: String,
    enum: ['extra_legroom', 'window_view', 'aisle_access', 'power_outlet', 'wifi', 'meal_included']
  }],
  restrictions: [{
    type: String,
    enum: ['no_infant', 'exit_row', 'limited_recline', 'no_wheelchair']
  }],
  position: {
    x: Number, // X coordinate in seat map
    y: Number  // Y coordinate in seat map
  },
  bookedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Booking',
    default: null,
    sparse: true
  },
  heldBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null,
    sparse: true
  },
  heldUntil: {
    type: Date,
    default: null,
    sparse: true
  },
  blockedReason: String,
  isAccessible: {
    type: Boolean,
    default: false
  },
  deck: {
    type: String,
    enum: ['main', 'upper', 'lower'],
    default: 'main'
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

// Compound indexes
seatSchema.index({ tripId: 1, seatNumber: 1 }, { unique: true });
seatSchema.index({ tripId: 1, status: 1 });
seatSchema.index({ tripId: 1, classType: 1, status: 1 });
seatSchema.index({ bookedBy: 1 }, { sparse: true });
seatSchema.index({ heldBy: 1, heldUntil: 1 }, { sparse: true });

// Virtual for total price (base price + addon)
seatSchema.virtual('totalPrice').get(function() {
  return this.price + (this.priceAddon || 0);
});

// Virtual for is available
seatSchema.virtual('isAvailable').get(function() {
  return this.status === 'available';
});

// Virtual for is booked
seatSchema.virtual('isBooked').get(function() {
  return this.status === 'booked' && this.bookedBy;
});

// Virtual for is held (temporarily reserved)
seatSchema.virtual('isHeld').get(function() {
  if (this.status !== 'held' || !this.heldBy || !this.heldUntil) return false;
  return new Date() < this.heldUntil;
});

// Virtual for is expired hold
seatSchema.virtual('isExpiredHold').get(function() {
  if (this.status !== 'held' || !this.heldUntil) return false;
  return new Date() >= this.heldUntil;
});

// Virtual for seat identifier (row + column)
seatSchema.virtual('identifier').get(function() {
  return `${this.row}${this.column}`;
});

// Pre-save middleware to auto-release expired holds
seatSchema.pre('save', function(next) {
  if (this.isExpiredHold) {
    this.status = 'available';
    this.heldBy = null;
    this.heldUntil = null;
  }
  next();
});

// Static method to get seat map for a trip
seatSchema.statics.getSeatMap = function(tripId, classType = null) {
  const query = { tripId };
  if (classType) query.classType = classType;
  
  return this.find(query)
    .sort({ deck: 1, row: 1, column: 1 })
    .select('-metadata -__v');
};

// Static method to get available seats
seatSchema.statics.getAvailableSeats = function(tripId, classType = null) {
  const query = { 
    tripId, 
    status: 'available'
  };
  if (classType) query.classType = classType;
  
  return this.find(query)
    .sort({ row: 1, column: 1 })
    .select('seatNumber row column classType seatType price priceAddon features');
};

// Static method to find seats by numbers
seatSchema.statics.findSeatsByNumbers = function(tripId, seatNumbers) {
  return this.find({
    tripId,
    seatNumber: { $in: seatNumbers }
  });
};

// Instance method to hold seat
seatSchema.methods.holdSeat = function(userId, minutes = 15) {
  if (this.status !== 'available') {
    throw new Error('Ghế không khả dụng để giữ chỗ');
  }
  
  this.status = 'held';
  this.heldBy = userId;
  this.heldUntil = new Date(Date.now() + minutes * 60 * 1000);
};

// Instance method to book seat
seatSchema.methods.bookSeat = function(bookingId) {
  if (!['available', 'held'].includes(this.status)) {
    throw new Error('Ghế không khả dụng để đặt');
  }
  
  this.status = 'booked';
  this.bookedBy = bookingId;
  this.heldBy = null;
  this.heldUntil = null;
};

// Instance method to release seat
seatSchema.methods.releaseSeat = function() {
  this.status = 'available';
  this.bookedBy = null;
  this.heldBy = null;
  this.heldUntil = null;
};

// Instance method to block seat
seatSchema.methods.blockSeat = function(reason) {
  this.status = 'blocked';
  this.blockedReason = reason;
  this.bookedBy = null;
  this.heldBy = null;
  this.heldUntil = null;
};

// Instance method to check if seat can be selected by passenger type
seatSchema.methods.canBeSelectedBy = function(passengerType, hasInfant = false) {
  // Exit row restrictions
  if (this.seatType === 'exit' && (passengerType !== 'adult' || hasInfant)) {
    return false;
  }
  
  // Infant restrictions
  if (hasInfant && this.restrictions.includes('no_infant')) {
    return false;
  }
  
  // Wheelchair accessibility
  if (this.restrictions.includes('no_wheelchair') && this.isAccessible) {
    return false;
  }
  
  return this.isAvailable;
};

// Static method to generate seat map for a trip
seatSchema.statics.generateSeatMap = async function(tripId, configuration) {
  const seats = [];
  const { rows, columns, classConfigs } = configuration;
  
  for (let row = 1; row <= rows; row++) {
    for (let colIndex = 0; colIndex < columns.length; colIndex++) {
      const column = columns[colIndex];
      
      // Determine class type based on row
      let classType = 'economy';
      let seatType = 'standard';
      let price = 0;
      
      for (const config of classConfigs) {
        if (row >= config.startRow && row <= config.endRow) {
          classType = config.classType;
          price = config.basePrice;
          break;
        }
      }
      
      // Determine seat type based on position
      if (column === 'A' || column === 'F') {
        seatType = 'window';
      } else if (column === 'C' || column === 'D') {
        seatType = 'aisle';
      } else {
        seatType = 'middle';
      }
      
      // Premium seats (typically first few rows of each class)
      if (row <= 3 || (classType !== 'economy' && row <= 5)) {
        seatType = 'premium';
        price += 50000; // Add premium surcharge
      }
      
      seats.push({
        tripId,
        seatNumber: `${row}${column}`,
        row,
        column,
        classType,
        seatType,
        status: 'available',
        price,
        currency: 'VND',
        position: {
          x: colIndex,
          y: row - 1
        }
      });
    }
  }
  
  return await this.insertMany(seats);
};

module.exports = mongoose.model('Seat', seatSchema);
