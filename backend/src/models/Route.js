const mongoose = require('mongoose');

const RouteSchema = new mongoose.Schema({
  fromDestination: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Destination',
    required: true,
    index: true
  },
  toDestination: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Destination',
    required: true,
    index: true
  },
  transportType: {
    type: String,
    enum: ['flight', 'train', 'bus', 'ferry'],
    required: true,
    index: true
  },
  distance: {
    type: Number,
    required: true,
    min: 0
  },
  estimatedDuration: {
    type: Number, // in minutes
    required: true,
    min: 0
  },
  isActive: {
    type: Boolean,
    default: true,
    index: true
  },
  operatingDays: {
    type: [Number], // 0-6 for Sunday-Saturday
    default: [0, 1, 2, 3, 4, 5, 6] // All days by default
  },
  seasonalPricing: {
    type: Map,
    of: {
      startDate: Date,
      endDate: Date,
      multiplier: { type: Number, min: 0.1, max: 10 }
    }
  },
  restrictions: {
    minBookingTime: { type: Number, default: 60 }, // minutes before departure
    maxBookingTime: { type: Number, default: 30 * 24 * 60 }, // 30 days in minutes
    cancellationPolicy: {
      refundable: { type: Boolean, default: true },
      cancellationFee: { type: Number, default: 0 },
      timeLimit: { type: Number, default: 24 } // hours
    }
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes for performance
RouteSchema.index({ fromDestination: 1, toDestination: 1, transportType: 1 });
RouteSchema.index({ isActive: 1, transportType: 1 });

// Virtual for route code
RouteSchema.virtual('routeCode').get(function() {
  return `${this.fromDestination}-${this.toDestination}`;
});

// Static method to find routes between destinations
RouteSchema.statics.findRoutes = function(fromCode, toCode, transportType = null) {
  const Destination = mongoose.model('Destination');
  
  return this.aggregate([
    {
      $lookup: {
        from: 'destinations',
        localField: 'fromDestination',
        foreignField: '_id',
        as: 'fromDest'
      }
    },
    {
      $lookup: {
        from: 'destinations',
        localField: 'toDestination',
        foreignField: '_id',
        as: 'toDest'
      }
    },
    {
      $unwind: '$fromDest'
    },
    {
      $unwind: '$toDest'
    },
    {
      $match: {
        'fromDest.code': fromCode,
        'toDest.code': toCode,
        isActive: true,
        ...(transportType && { transportType })
      }
    }
  ]);
};

module.exports = mongoose.model('Route', RouteSchema);
