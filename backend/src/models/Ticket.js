const mongoose = require('mongoose');

const TicketSchema = new mongoose.Schema({
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
  passengerId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true
  },
  pnr: {
    type: String,
    required: true,
    uppercase: true,
    index: true
  },
  ticketNumber: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  qrData: {
    type: String,
    required: true
  },
  qrCodeUrl: String, // URL to generated QR code image
  pdfUrl: String, // URL to generated PDF ticket
  status: {
    type: String,
    enum: ['issued', 'used', 'expired', 'cancelled'],
    default: 'issued',
    index: true
  },
  validUntil: Date,
  usedAt: Date,
  usedBy: String, // Who checked the ticket
  cancelledAt: Date,
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
TicketSchema.index({ userId: 1, createdAt: -1 });
TicketSchema.index({ bookingId: 1 });
TicketSchema.index({ pnr: 1 });
TicketSchema.index({ ticketNumber: 1 });
TicketSchema.index({ status: 1 });

// Virtuals
TicketSchema.virtual('isValid').get(function() {
  if (this.status !== 'issued') return false;
  if (this.validUntil && new Date() > this.validUntil) return false;
  return true;
});

TicketSchema.virtual('isUsed').get(function() {
  return this.status === 'used';
});

TicketSchema.virtual('isExpired').get(function() {
  return this.status === 'expired' || (this.validUntil && new Date() > this.validUntil);
});

TicketSchema.virtual('isCancelled').get(function() {
  return this.status === 'cancelled';
});

TicketSchema.virtual('statusText').get(function() {
  switch (this.status) {
    case 'issued': return 'Có hiệu lực';
    case 'used': return 'Đã sử dụng';
    case 'expired': return 'Đã hết hạn';
    case 'cancelled': return 'Đã hủy';
    default: return 'Không xác định';
  }
});

TicketSchema.virtual('hasPdf').get(function() {
  return !!this.pdfUrl;
});

TicketSchema.virtual('hasQrCode').get(function() {
  return !!this.qrCodeUrl;
});

// Methods
TicketSchema.methods.markAsUsed = function(usedBy) {
  this.status = 'used';
  this.usedAt = new Date();
  this.usedBy = usedBy;
  return this.save();
};

TicketSchema.methods.markAsExpired = function() {
  this.status = 'expired';
  return this.save();
};

TicketSchema.methods.cancel = function() {
  this.status = 'cancelled';
  this.cancelledAt = new Date();
  return this.save();
};

TicketSchema.methods.generateQRCode = async function() {
  try {
    const QRCode = require('qrcode');
    const path = require('path');
    const fs = require('fs').promises;
    
    const fileName = `qr_${this.ticketNumber}.png`;
    const filePath = path.join(process.env.UPLOAD_DIR || 'uploads', 'qr-codes', fileName);
    
    // Ensure directory exists
    await fs.mkdir(path.dirname(filePath), { recursive: true });
    
    // Generate QR code
    await QRCode.toFile(filePath, this.qrData, {
      width: 300,
      margin: 2,
      color: {
        dark: '#000000',
        light: '#FFFFFF'
      }
    });
    
    this.qrCodeUrl = `/uploads/qr-codes/${fileName}`;
    return this.save();
  } catch (error) {
    throw new Error('Failed to generate QR code: ' + error.message);
  }
};

TicketSchema.methods.generatePDF = async function() {
  try {
    const PDFDocument = require('pdfkit');
    const path = require('path');
    const fs = require('fs').promises;
    
    const fileName = `ticket_${this.ticketNumber}.pdf`;
    const filePath = path.join(process.env.UPLOAD_DIR || 'uploads', 'tickets', fileName);
    
    // Ensure directory exists
    await fs.mkdir(path.dirname(filePath), { recursive: true });
    
    // Get related data
    const booking = await this.model('Booking').findById(this.bookingId)
      .populate('scheduleId userId');
    
    if (!booking) {
      throw new Error('Booking not found');
    }
    
    const passenger = booking.passengers.id(this.passengerId);
    if (!passenger) {
      throw new Error('Passenger not found');
    }
    
    // Create PDF
    const doc = new PDFDocument();
    const stream = fs.createWriteStream(filePath);
    doc.pipe(stream);
    
    // PDF Content
    doc.fontSize(20).text('DatVe360 - Vé Điện Tử', { align: 'center' });
    doc.moveDown();
    
    doc.fontSize(12)
       .text(`Mã đặt vé: ${this.pnr}`, 50, 120)
       .text(`Số vé: ${this.ticketNumber}`, 50, 140)
       .text(`Hành khách: ${passenger.firstName} ${passenger.lastName}`, 50, 160)
       .text(`Ghế: ${passenger.seatNumber || 'Chưa chọn'}`, 50, 180)
       .text(`Ngày phát hành: ${this.createdAt.toLocaleDateString('vi-VN')}`, 50, 200);
    
    // Add QR code if exists
    if (this.qrCodeUrl) {
      const qrPath = path.join(process.cwd(), this.qrCodeUrl);
      try {
        doc.image(qrPath, 400, 120, { width: 100 });
      } catch (err) {
        console.warn('Could not add QR code to PDF:', err.message);
      }
    }
    
    doc.end();
    
    await new Promise((resolve, reject) => {
      stream.on('finish', resolve);
      stream.on('error', reject);
    });
    
    this.pdfUrl = `/uploads/tickets/${fileName}`;
    return this.save();
  } catch (error) {
    throw new Error('Failed to generate PDF: ' + error.message);
  }
};

TicketSchema.methods.validateQRData = function(qrString) {
  try {
    const qrData = JSON.parse(qrString);
    return qrData.bookingId === this.bookingId.toString() &&
           qrData.pnr === this.pnr &&
           qrData.passengerId === this.passengerId.toString();
  } catch (error) {
    return false;
  }
};

// Static methods
TicketSchema.statics.findByPNR = function(pnr) {
  return this.find({ pnr: pnr.toUpperCase() })
    .populate('bookingId userId');
};

TicketSchema.statics.findByTicketNumber = function(ticketNumber) {
  return this.findOne({ ticketNumber })
    .populate('bookingId userId');
};

TicketSchema.statics.findByUser = function(userId, options = {}) {
  const query = this.find({ userId })
    .populate('bookingId')
    .sort({ createdAt: -1 });
    
  if (options.status) {
    query.where({ status: options.status });
  }
  
  if (options.limit) {
    query.limit(options.limit);
  }
  
  return query;
};

TicketSchema.statics.findValidTickets = function() {
  return this.find({
    status: 'issued',
    $or: [
      { validUntil: { $exists: false } },
      { validUntil: { $gt: new Date() } }
    ]
  });
};

TicketSchema.statics.findExpiredTickets = function() {
  return this.find({
    status: 'issued',
    validUntil: { $lt: new Date() }
  });
};

TicketSchema.statics.validateQRCode = function(qrString) {
  try {
    const qrData = JSON.parse(qrString);
    return this.findOne({
      bookingId: qrData.bookingId,
      pnr: qrData.pnr,
      passengerId: qrData.passengerId,
      status: 'issued'
    });
  } catch (error) {
    return null;
  }
};

// Pre-save middleware
TicketSchema.pre('save', function(next) {
  if (this.isNew && !this.ticketNumber) {
    this.ticketNumber = generateTicketNumber();
  }
  next();
});

// Helper function
function generateTicketNumber() {
  const timestamp = Date.now().toString().slice(-8);
  const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
  return `DV${timestamp}${random}`;
}

module.exports = mongoose.model('Ticket', TicketSchema);
