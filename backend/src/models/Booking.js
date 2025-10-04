const mongoose = require('mongoose');

const PassengerSchema = new mongoose.Schema({
  type: {
    type: String,
    enum: ['adult', 'child', 'infant'],
    required: true
  },
  firstName: {
    type: String,
    required: true,
    trim: true
  },
  lastName: {
    type: String,
    required: true,
    trim: true
  },
  dateOfBirth: Date,
  gender: {
    type: String,
    enum: ['male', 'female']
  },
  documentType: {
    type: String,
    enum: ['passport', 'id_card', 'driver_license'],
    required: true
  },
  documentNumber: {
    type: String,
    required: true,
    trim: true
  },
  nationality: String,
  seatNumber: String,
  metadata: {
    type: mongoose.Schema.Types.Mixed,
    default: {}
  }
}, { _id: true });

const ContactInfoSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    lowercase: true,
    trim: true
  },
  phone: {
    type: String,
    required: true,
    trim: true
  },
  firstName: String,
  lastName: String
}, { _id: false });

const BookingSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  scheduleId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Schedule',
    required: true,
    index: true
  },
  pnr: {
    type: String,
    required: true,
    unique: true,
    uppercase: true,
    index: true
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'cancelled', 'completed', 'expired'],
    default: 'pending',
    index: true
  },
  passengers: [PassengerSchema],
  selectedClass: {
    type: String,
    required: true
  },
  selectedSeats: [String],
  totalPrice: {
    type: Number,
    required: true,
    min: 0
  },
  currency: {
    type: String,
    default: 'VND',
    enum: ['VND', 'USD']
  },
  contactInfo: ContactInfoSchema,
  paymentMethod: {
    type: String,
    enum: ['vnpay', 'momo', 'stripe', 'bank_transfer'],
    required: true
  },
  paymentId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Payment'
  },
  confirmedAt: Date,
  cancelledAt: Date,
  cancelReason: String,
  expiresAt: {
    type: Date,
    default: function() {
      return new Date(Date.now() + 30 * 60 * 1000); // 30 minutes
    },
    index: { expireAfterSeconds: 0 }
  },
  metadata: {
    type: mongoose.Schema.Types.Mixed,
    default: {}
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes (pnr and expiresAt already have indexes defined in schema)
BookingSchema.index({ userId: 1, createdAt: -1 });
// BookingSchema.index({ pnr: 1 }); // Removed - already unique
BookingSchema.index({ status: 1, createdAt: -1 });
BookingSchema.index({ scheduleId: 1, status: 1 });
// BookingSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 }); // Removed - already defined in schema

// Virtuals
BookingSchema.virtual('isPending').get(function() {
  return this.status === 'pending';
});

BookingSchema.virtual('isConfirmed').get(function() {
  return this.status === 'confirmed';
});

BookingSchema.virtual('isCancelled').get(function() {
  return this.status === 'cancelled';
});

BookingSchema.virtual('passengerCount').get(function() {
  return this.passengers.length;
});

BookingSchema.virtual('adultCount').get(function() {
  return this.passengers.filter(p => p.type === 'adult').length;
});

BookingSchema.virtual('childCount').get(function() {
  return this.passengers.filter(p => p.type === 'child').length;
});

BookingSchema.virtual('infantCount').get(function() {
  return this.passengers.filter(p => p.type === 'infant').length;
});

BookingSchema.virtual('isExpired').get(function() {
  return this.status === 'pending' && new Date() > this.expiresAt;
});

// Methods
BookingSchema.methods.confirm = function() {
  this.status = 'confirmed';
  this.confirmedAt = new Date();
  this.expiresAt = undefined;
  return this.save();
};

BookingSchema.methods.cancel = function(reason) {
  this.status = 'cancelled';
  this.cancelledAt = new Date();
  this.cancelReason = reason;
  this.expiresAt = undefined;
  return this.save();
};

BookingSchema.methods.complete = function() {
  this.status = 'completed';
  return this.save();
};

BookingSchema.methods.extendExpiry = function(minutes = 30) {
  if (this.status === 'pending') {
    this.expiresAt = new Date(Date.now() + minutes * 60 * 1000);
    return this.save();
  }
  return Promise.resolve(this);
};

BookingSchema.methods.addPassenger = function(passenger) {
  this.passengers.push(passenger);
  return this.save();
};

BookingSchema.methods.removePassenger = function(passengerId) {
  this.passengers = this.passengers.filter(p => p._id.toString() !== passengerId.toString());
  return this.save();
};

BookingSchema.methods.updateSeat = function(passengerId, seatNumber) {
  const passenger = this.passengers.id(passengerId);
  if (passenger) {
    passenger.seatNumber = seatNumber;
    return this.save();
  }
  return Promise.reject(new Error('Passenger not found'));
};

BookingSchema.methods.generateTickets = async function() {
  const Ticket = require('./Ticket');
  const tickets = [];
  
  for (const passenger of this.passengers) {
    const ticketData = {
      bookingId: this._id,
      userId: this.userId,
      passengerId: passenger._id,
      pnr: this.pnr,
      ticketNumber: generateTicketNumber(),
      qrData: await generateQRData(this, passenger),
      status: 'issued'
    };
    
    const ticket = await Ticket.create(ticketData);
    tickets.push(ticket);
  }
  
  return tickets;
};

// Static methods
BookingSchema.statics.findByPNR = function(pnr) {
  return this.findOne({ pnr: pnr.toUpperCase() })
    .populate('userId', 'displayName email phoneNumber')
    .populate('scheduleId');
};

BookingSchema.statics.findByUser = function(userId, options = {}) {
  const query = this.find({ userId })
    .populate('scheduleId')
    .sort({ createdAt: -1 });
    
  if (options.status) {
    query.where({ status: options.status });
  }
  
  if (options.limit) {
    query.limit(options.limit);
  }
  
  return query;
};

BookingSchema.statics.findExpired = function() {
  return this.find({
    status: 'pending',
    expiresAt: { $lt: new Date() }
  });
};

BookingSchema.statics.findBySchedule = function(scheduleId) {
  return this.find({ 
    scheduleId, 
    status: { $in: ['confirmed', 'completed'] }
  }).populate('userId', 'displayName email');
};

// Pre-save middleware
BookingSchema.pre('save', function(next) {
  if (this.isNew && !this.pnr) {
    this.pnr = generatePNR();
  }
  next();
});

// Helper functions
function generatePNR() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let pnr = '';
  for (let i = 0; i < 6; i++) {
    pnr += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return pnr;
}

function generateTicketNumber() {
  const timestamp = Date.now().toString().slice(-8);
  const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
  return `DV${timestamp}${random}`;
}

async function generateQRData(booking, passenger) {
  const qrData = {
    bookingId: booking._id,
    pnr: booking.pnr,
    passengerName: `${passenger.firstName} ${passenger.lastName}`,
    passengerId: passenger._id,
    seatNumber: passenger.seatNumber,
    issuedAt: Date.now()
  };
  
  return JSON.stringify(qrData);
}

module.exports = mongoose.model('Booking', BookingSchema);
