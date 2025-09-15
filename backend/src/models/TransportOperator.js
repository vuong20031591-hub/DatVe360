const mongoose = require('mongoose');

const TransportOperatorSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true,
    maxlength: 100
  },
  code: {
    type: String,
    required: true,
    unique: true,
    uppercase: true,
    trim: true,
    maxlength: 10
  },
  transportTypes: [{
    type: String,
    enum: ['flight', 'train', 'bus', 'ferry'],
    required: true
  }],
  contactInfo: {
    phone: String,
    email: String,
    website: String,
    address: String
  },
  isActive: {
    type: Boolean,
    default: true,
    index: true
  },
  metadata: {
    type: Map,
    of: mongoose.Schema.Types.Mixed,
    default: {}
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes
TransportOperatorSchema.index({ code: 1 });
TransportOperatorSchema.index({ transportTypes: 1 });
TransportOperatorSchema.index({ isActive: 1, transportTypes: 1 });

// Virtual for display name
TransportOperatorSchema.virtual('displayName').get(function() {
  return `${this.name} (${this.code})`;
});

// Static methods
TransportOperatorSchema.statics.findByTransportType = function(transportType) {
  return this.find({
    transportTypes: transportType,
    isActive: true
  }).sort({ name: 1 });
};

TransportOperatorSchema.statics.findByCode = function(code) {
  return this.findOne({
    code: code.toUpperCase(),
    isActive: true
  });
};

module.exports = mongoose.model('TransportOperator', TransportOperatorSchema);
