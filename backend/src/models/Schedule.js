const mongoose = require('mongoose');

const SeatConfigurationSchema = new mongoose.Schema({
  totalSeats: {
    type: Number,
    required: true,
    min: 1
  },
  availableSeats: {
    type: Number,
    required: true,
    min: 0
  },
  layout: String, // "3-3", "2-4-2", etc.
  classes: {
    type: Map,
    of: {
      totalSeats: { type: Number, required: true, min: 0 },
      availableSeats: { type: Number, required: true, min: 0 },
      price: { type: Number, required: true, min: 0 },
      currency: { type: String, default: 'VND' },
      amenities: [String]
    }
  }
}, { _id: false });

const VehicleSchema = new mongoose.Schema({
  type: {
    type: String,
    enum: ['aircraft', 'bus', 'train', 'ferry'],
    required: true
  },
  model: String,
  registrationNumber: String,
  facilities: [String], // WiFi, AC, meals, entertainment, etc.
  accessibility: {
    wheelchairAccessible: { type: Boolean, default: false },
    assistanceAvailable: { type: Boolean, default: false }
  }
}, { _id: false });

const ScheduleSchema = new mongoose.Schema({
  routeId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Route',
    required: true,
    index: true
  },
  operatorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'TransportOperator',
    required: true,
    index: true
  },
  vehicleNumber: {
    type: String,
    required: true,
    trim: true,
    index: true
  },
  departureTime: {
    type: Date,
    required: true,
    index: true
  },
  arrivalTime: {
    type: Date,
    required: true,
    index: true
  },
  status: {
    type: String,
    enum: ['scheduled', 'delayed', 'cancelled', 'departed', 'arrived', 'maintenance'],
    default: 'scheduled',
    index: true
  },
  delayMinutes: {
    type: Number,
    default: 0,
    min: 0
  },
  seatConfiguration: SeatConfigurationSchema,
  vehicle: VehicleSchema,
  gate: String,
  terminal: String,
  checkInStart: Date,
  checkInEnd: Date,
  boardingStart: Date,
  boardingEnd: Date,
  isActive: {
    type: Boolean,
    default: true,
    index: true
  },
  frequency: {
    type: String,
    enum: ['daily', 'weekly', 'monthly', 'one-time'],
    default: 'one-time'
  },
  recurringDays: [Number], // 0-6 for Sunday-Saturday
  validFrom: Date,
  validTo: Date,
  specialPricing: {
    isPromotional: { type: Boolean, default: false },
    discount: { type: Number, min: 0, max: 100 },
    validUntil: Date
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

// Indexes
ScheduleSchema.index({ routeId: 1, departureTime: 1 });
ScheduleSchema.index({ operatorId: 1, departureTime: 1 });
ScheduleSchema.index({ status: 1, departureTime: 1 });
ScheduleSchema.index({ vehicleNumber: 1, departureTime: 1 });
ScheduleSchema.index({ departureTime: 1, arrivalTime: 1 });
ScheduleSchema.index({ isActive: 1, status: 1, departureTime: 1 });

// Virtuals
ScheduleSchema.virtual('duration').get(function() {
  return this.arrivalTime.getTime() - this.departureTime.getTime();
});

ScheduleSchema.virtual('durationFormatted').get(function() {
  const minutes = Math.floor(this.duration / (1000 * 60));
  const hours = Math.floor(minutes / 60);
  const remainingMinutes = minutes % 60;
  return `${hours}h ${remainingMinutes}m`;
});

ScheduleSchema.virtual('actualDepartureTime').get(function() {
  if (this.delayMinutes > 0) {
    return new Date(this.departureTime.getTime() + (this.delayMinutes * 60 * 1000));
  }
  return this.departureTime;
});

ScheduleSchema.virtual('actualArrivalTime').get(function() {
  if (this.delayMinutes > 0) {
    return new Date(this.arrivalTime.getTime() + (this.delayMinutes * 60 * 1000));
  }
  return this.arrivalTime;
});

ScheduleSchema.virtual('isDelayed').get(function() {
  return this.delayMinutes > 0;
});

ScheduleSchema.virtual('canBook').get(function() {
  return this.isActive && 
         this.status === 'scheduled' && 
         this.departureTime > new Date() &&
         this.seatConfiguration.availableSeats > 0;
});

ScheduleSchema.virtual('occupancyRate').get(function() {
  if (this.seatConfiguration.totalSeats === 0) return 0;
  const occupied = this.seatConfiguration.totalSeats - this.seatConfiguration.availableSeats;
  return Math.round((occupied / this.seatConfiguration.totalSeats) * 100);
});

ScheduleSchema.virtual('basePrice').get(function() {
  let minPrice = Infinity;
  this.seatConfiguration.classes.forEach((classInfo) => {
    if (classInfo.price < minPrice) {
      minPrice = classInfo.price;
    }
  });
  return minPrice === Infinity ? 0 : minPrice;
});

// Methods
ScheduleSchema.methods.updateDelay = function(minutes) {
  this.delayMinutes = Math.max(0, minutes);
  if (this.delayMinutes > 0 && this.status === 'scheduled') {
    this.status = 'delayed';
  } else if (this.delayMinutes === 0 && this.status === 'delayed') {
    this.status = 'scheduled';
  }
  return this.save();
};

ScheduleSchema.methods.updateStatus = function(newStatus) {
  const validTransitions = {
    'scheduled': ['delayed', 'cancelled', 'departed', 'maintenance'],
    'delayed': ['scheduled', 'cancelled', 'departed', 'maintenance'],
    'cancelled': ['scheduled'], // Can reactivate
    'departed': ['arrived', 'cancelled'],
    'arrived': [],
    'maintenance': ['scheduled', 'cancelled']
  };

  if (validTransitions[this.status] && validTransitions[this.status].includes(newStatus)) {
    this.status = newStatus;
    return this.save();
  }
  
  throw new Error(`Invalid status transition from ${this.status} to ${newStatus}`);
};

ScheduleSchema.methods.bookSeats = function(className, quantity) {
  const classConfig = this.seatConfiguration.classes.get(className);
  if (!classConfig) {
    throw new Error('Class not found');
  }
  
  if (classConfig.availableSeats < quantity) {
    throw new Error('Not enough seats available');
  }
  
  classConfig.availableSeats -= quantity;
  this.seatConfiguration.availableSeats -= quantity;
  
  return this.save();
};

ScheduleSchema.methods.releaseSeats = function(className, quantity) {
  const classConfig = this.seatConfiguration.classes.get(className);
  if (!classConfig) {
    throw new Error('Class not found');
  }
  
  const maxRelease = classConfig.totalSeats - classConfig.availableSeats;
  const actualRelease = Math.min(quantity, maxRelease);
  
  classConfig.availableSeats += actualRelease;
  this.seatConfiguration.availableSeats += actualRelease;
  
  return this.save();
};

ScheduleSchema.methods.getAvailableClasses = function() {
  const available = [];
  this.seatConfiguration.classes.forEach((classInfo, className) => {
    if (classInfo.availableSeats > 0) {
      available.push({
        name: className,
        availableSeats: classInfo.availableSeats,
        price: classInfo.price,
        amenities: classInfo.amenities
      });
    }
  });
  return available;
};

ScheduleSchema.methods.canCheckIn = function() {
  const now = new Date();
  return this.checkInStart && this.checkInEnd &&
         now >= this.checkInStart && now <= this.checkInEnd;
};

ScheduleSchema.methods.canBoard = function() {
  const now = new Date();
  return this.boardingStart && this.boardingEnd &&
         now >= this.boardingStart && now <= this.boardingEnd;
};

// Static methods
ScheduleSchema.statics.findAvailable = function(routeId, departureDate, options = {}) {
  const {
    minSeats = 1,
    className,
    status = ['scheduled', 'delayed']
  } = options;

  const startDate = new Date(departureDate);
  startDate.setHours(0, 0, 0, 0);
  const endDate = new Date(departureDate);
  endDate.setHours(23, 59, 59, 999);

  let filter = {
    routeId,
    departureTime: { $gte: startDate, $lte: endDate },
    isActive: true,
    status: { $in: status },
    'seatConfiguration.availableSeats': { $gte: minSeats }
  };

  if (className) {
    filter[`seatConfiguration.classes.${className}.availableSeats`] = { $gte: minSeats };
  }

  return this.find(filter)
    .populate('routeId operatorId')
    .sort({ departureTime: 1 });
};

ScheduleSchema.statics.findByRoute = function(routeId, options = {}) {
  const { 
    fromDate = new Date(),
    toDate,
    limit = 50,
    activeOnly = true
  } = options;

  let filter = { routeId };
  
  if (activeOnly) {
    filter.isActive = true;
    filter.status = { $in: ['scheduled', 'delayed'] };
  }

  filter.departureTime = { $gte: fromDate };
  if (toDate) {
    filter.departureTime.$lte = toDate;
  }

  return this.find(filter)
    .populate('routeId operatorId')
    .sort({ departureTime: 1 })
    .limit(limit);
};

ScheduleSchema.statics.findByOperator = function(operatorId, options = {}) {
  const {
    fromDate = new Date(),
    toDate,
    status,
    limit = 50
  } = options;

  let filter = { operatorId, isActive: true };

  filter.departureTime = { $gte: fromDate };
  if (toDate) {
    filter.departureTime.$lte = toDate;
  }

  if (status) {
    filter.status = Array.isArray(status) ? { $in: status } : status;
  }

  return this.find(filter)
    .populate('routeId operatorId')
    .sort({ departureTime: 1 })
    .limit(limit);
};

ScheduleSchema.statics.findDelayed = function() {
  return this.find({
    status: 'delayed',
    isActive: true,
    departureTime: { $gte: new Date() }
  })
  .populate('routeId operatorId')
  .sort({ departureTime: 1 });
};

ScheduleSchema.statics.search = function(searchParams) {
  const {
    fromDestination,
    toDestination,
    departureDate,
    returnDate,
    passengers = 1,
    className,
    maxPrice,
    operatorId,
    sortBy = 'departureTime'
  } = searchParams;

  // This will be implemented with Route model integration
  // For now, return basic query
  let pipeline = [
    {
      $lookup: {
        from: 'routes',
        localField: 'routeId',
        foreignField: '_id',
        as: 'route'
      }
    },
    {
      $unwind: '$route'
    },
    {
      $match: {
        isActive: true,
        status: { $in: ['scheduled', 'delayed'] },
        'seatConfiguration.availableSeats': { $gte: passengers }
      }
    }
  ];

  // Add date filter
  if (departureDate) {
    const startDate = new Date(departureDate);
    startDate.setHours(0, 0, 0, 0);
    const endDate = new Date(departureDate);
    endDate.setHours(23, 59, 59, 999);

    pipeline.push({
      $match: {
        departureTime: { $gte: startDate, $lte: endDate }
      }
    });
  }

  // Add route destination filters
  if (fromDestination) {
    pipeline.push({
      $match: {
        'route.fromDestination': mongoose.Types.ObjectId(fromDestination)
      }
    });
  }

  if (toDestination) {
    pipeline.push({
      $match: {
        'route.toDestination': mongoose.Types.ObjectId(toDestination)
      }
    });
  }

  // Add operator filter
  if (operatorId) {
    pipeline.push({
      $match: {
        operatorId: mongoose.Types.ObjectId(operatorId)
      }
    });
  }

  // Add sorting
  const sortOptions = {
    'departureTime': { departureTime: 1 },
    'price': { 'seatConfiguration.classes.economy.price': 1 },
    'duration': { $subtract: ['$arrivalTime', '$departureTime'] }
  };

  pipeline.push({
    $sort: sortOptions[sortBy] || { departureTime: 1 }
  });

  return this.aggregate(pipeline);
};

module.exports = mongoose.model('Schedule', ScheduleSchema);
