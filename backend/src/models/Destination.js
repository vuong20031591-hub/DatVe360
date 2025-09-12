const mongoose = require('mongoose');

const DestinationSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true,
    index: true
  },
  nameEn: {
    type: String,
    trim: true
  },
  code: {
    type: String,
    required: true,
    unique: true,
    uppercase: true,
    index: true
  },
  type: {
    type: String,
    enum: ['airport', 'bus_station', 'train_station', 'port'],
    required: true,
    index: true
  },
  city: {
    type: String,
    required: true,
    trim: true,
    index: true
  },
  country: {
    type: String,
    required: true,
    default: 'Vietnam',
    index: true
  },
  coordinates: {
    latitude: {
      type: Number,
      min: -90,
      max: 90
    },
    longitude: {
      type: Number,
      min: -180,
      max: 180
    }
  },
  timezone: {
    type: String,
    default: 'Asia/Ho_Chi_Minh'
  },
  active: {
    type: Boolean,
    default: true,
    index: true
  },
  popular: {
    type: Boolean,
    default: false,
    index: true
  },
  imageUrl: String,
  metadata: {
    description: String,
    facilities: [String],
    contactInfo: {
      phone: String,
      email: String,
      website: String,
      address: String
    },
    operatingHours: {
      open: String,
      close: String,
      timezone: String
    }
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes
DestinationSchema.index({ name: 'text', nameEn: 'text', city: 'text' });
DestinationSchema.index({ type: 1, active: 1 });
DestinationSchema.index({ city: 1, type: 1 });
DestinationSchema.index({ coordinates: '2dsphere' });
DestinationSchema.index({ popular: -1, name: 1 });

// Virtuals
DestinationSchema.virtual('fullName').get(function() {
  return `${this.name} (${this.code})`;
});

DestinationSchema.virtual('displayName').get(function() {
  return this.nameEn ? `${this.name} - ${this.nameEn}` : this.name;
});

DestinationSchema.virtual('location').get(function() {
  if (this.coordinates && this.coordinates.latitude && this.coordinates.longitude) {
    return {
      type: 'Point',
      coordinates: [this.coordinates.longitude, this.coordinates.latitude]
    };
  }
  return null;
});

// Methods
DestinationSchema.methods.getDistance = function(otherDestination) {
  if (!this.coordinates || !otherDestination.coordinates) {
    return null;
  }

  const R = 6371; // Earth's radius in kilometers
  const dLat = (otherDestination.coordinates.latitude - this.coordinates.latitude) * Math.PI / 180;
  const dLon = (otherDestination.coordinates.longitude - this.coordinates.longitude) * Math.PI / 180;
  
  const a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(this.coordinates.latitude * Math.PI / 180) * 
    Math.cos(otherDestination.coordinates.latitude * Math.PI / 180) * 
    Math.sin(dLon/2) * Math.sin(dLon/2);
  
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  const distance = R * c;
  
  return Math.round(distance * 100) / 100; // Round to 2 decimal places
};

DestinationSchema.methods.isNearby = function(latitude, longitude, radiusKm = 50) {
  if (!this.coordinates) return false;
  
  const distance = this.getDistance({
    coordinates: { latitude, longitude }
  });
  
  return distance && distance <= radiusKm;
};

// Static methods
DestinationSchema.statics.findByType = function(type, activeOnly = true) {
  const filter = { type };
  if (activeOnly) filter.active = true;
  
  return this.find(filter).sort({ popular: -1, name: 1 });
};

DestinationSchema.statics.findByCity = function(city, activeOnly = true) {
  const filter = { city: new RegExp(city, 'i') };
  if (activeOnly) filter.active = true;
  
  return this.find(filter).sort({ popular: -1, name: 1 });
};

DestinationSchema.statics.findByCode = function(code) {
  return this.findOne({ code: code.toUpperCase(), active: true });
};

DestinationSchema.statics.search = function(query, options = {}) {
  const {
    type,
    city,
    country = 'Vietnam',
    limit = 20,
    popularFirst = true
  } = options;

  let filter = {
    active: true,
    $or: [
      { name: new RegExp(query, 'i') },
      { nameEn: new RegExp(query, 'i') },
      { code: new RegExp(query, 'i') },
      { city: new RegExp(query, 'i') }
    ]
  };

  if (type) filter.type = type;
  if (city) filter.city = new RegExp(city, 'i');
  if (country) filter.country = country;

  const sortCriteria = popularFirst 
    ? { popular: -1, name: 1 }
    : { name: 1 };

  return this.find(filter)
    .sort(sortCriteria)
    .limit(limit);
};

DestinationSchema.statics.findNearby = function(latitude, longitude, radiusKm = 50, type = null) {
  const filter = {
    active: true,
    coordinates: {
      $near: {
        $geometry: {
          type: 'Point',
          coordinates: [longitude, latitude]
        },
        $maxDistance: radiusKm * 1000 // Convert to meters
      }
    }
  };

  if (type) filter.type = type;

  return this.find(filter);
};

DestinationSchema.statics.getPopular = function(type = null, limit = 10) {
  const filter = { active: true, popular: true };
  if (type) filter.type = type;

  return this.find(filter)
    .sort({ name: 1 })
    .limit(limit);
};

DestinationSchema.statics.getStatistics = async function() {
  return this.aggregate([
    { $match: { active: true } },
    {
      $group: {
        _id: '$type',
        count: { $sum: 1 },
        popularCount: {
          $sum: { $cond: ['$popular', 1, 0] }
        }
      }
    },
    {
      $project: {
        type: '$_id',
        count: 1,
        popularCount: 1,
        _id: 0
      }
    }
  ]);
};

module.exports = mongoose.model('Destination', DestinationSchema);
