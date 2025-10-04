const QRCode = require('qrcode');
const crypto = require('crypto');

class QRGenerator {
  // Generate QR code for ticket
  static async generateTicketQR(ticketData) {
    try {
      const {
        pnr,
        ticketNumber,
        passengerName,
        seatNumber,
        departureTime,
        gate
      } = ticketData;

      // Create QR data object
      const qrData = {
        pnr,
        ticketNumber,
        passengerName,
        seatNumber,
        departureTime: departureTime.toISOString(),
        gate,
        timestamp: new Date().toISOString()
      };

      // Generate checksum for security
      const checksum = crypto
        .createHash('sha256')
        .update(JSON.stringify(qrData))
        .digest('hex')
        .substring(0, 16);

      qrData.checksum = checksum;

      // Generate QR code
      const qrString = JSON.stringify(qrData);
      const qrCodeDataURL = await QRCode.toDataURL(qrString, {
        width: 300,
        margin: 2,
        color: {
          dark: '#000000',
          light: '#FFFFFF'
        }
      });

      return {
        qrData,
        qrCode: qrCodeDataURL,
        qrString
      };
    } catch (error) {
      throw new Error(`Lỗi tạo mã QR: ${error.message}`);
    }
  }

  // Generate QR code for boarding pass
  static async generateBoardingPassQR(bookingData) {
    try {
      const {
        pnr,
        passengers,
        tripInfo,
        seatNumbers
      } = bookingData;

      const qrData = {
        pnr,
        passengers: passengers.map(p => ({
          name: `${p.firstName} ${p.lastName}`,
          documentId: p.documentId,
          seat: seatNumbers[passengers.indexOf(p)]
        })),
        flight: tripInfo.flightNumber || tripInfo.trainNumber || tripInfo.busNumber,
        from: tripInfo.fromCode,
        to: tripInfo.toCode,
        departAt: tripInfo.departAt.toISOString(),
        gate: tripInfo.gate,
        timestamp: new Date().toISOString()
      };

      // Generate checksum
      const checksum = crypto
        .createHash('sha256')
        .update(JSON.stringify(qrData))
        .digest('hex')
        .substring(0, 16);

      qrData.checksum = checksum;

      const qrString = JSON.stringify(qrData);
      const qrCodeDataURL = await QRCode.toDataURL(qrString, {
        width: 400,
        margin: 2,
        color: {
          dark: '#000000',
          light: '#FFFFFF'
        }
      });

      return {
        qrData,
        qrCode: qrCodeDataURL,
        qrString
      };
    } catch (error) {
      throw new Error(`Lỗi tạo mã QR boarding pass: ${error.message}`);
    }
  }

  // Verify QR code data
  static verifyQRData(qrString) {
    try {
      const qrData = JSON.parse(qrString);
      const { checksum, ...dataWithoutChecksum } = qrData;

      // Recalculate checksum
      const calculatedChecksum = crypto
        .createHash('sha256')
        .update(JSON.stringify(dataWithoutChecksum))
        .digest('hex')
        .substring(0, 16);

      return {
        valid: checksum === calculatedChecksum,
        data: qrData
      };
    } catch (error) {
      return {
        valid: false,
        error: 'Mã QR không đúng định dạng'
      };
    }
  }

  // Generate QR for payment
  static async generatePaymentQR(paymentData) {
    try {
      const {
        transactionId,
        amount,
        currency,
        description,
        expireAt
      } = paymentData;

      const qrData = {
        type: 'payment',
        transactionId,
        amount,
        currency,
        description,
        expireAt: expireAt.toISOString(),
        timestamp: new Date().toISOString()
      };

      const qrString = JSON.stringify(qrData);
      const qrCodeDataURL = await QRCode.toDataURL(qrString, {
        width: 300,
        margin: 2,
        color: {
          dark: '#000000',
          light: '#FFFFFF'
        }
      });

      return {
        qrData,
        qrCode: qrCodeDataURL,
        qrString
      };
    } catch (error) {
      throw new Error(`Lỗi tạo mã QR thanh toán: ${error.message}`);
    }
  }

  // Generate simple text QR
  static async generateTextQR(text, options = {}) {
    try {
      const defaultOptions = {
        width: 300,
        margin: 2,
        color: {
          dark: '#000000',
          light: '#FFFFFF'
        },
        ...options
      };

      const qrCodeDataURL = await QRCode.toDataURL(text, defaultOptions);
      
      return {
        qrCode: qrCodeDataURL,
        text
      };
    } catch (error) {
      throw new Error(`Lỗi tạo mã QR text: ${error.message}`);
    }
  }

  // Generate WiFi QR code
  static async generateWiFiQR(wifiData) {
    try {
      const { ssid, password, security = 'WPA', hidden = false } = wifiData;
      
      const wifiString = `WIFI:T:${security};S:${ssid};P:${password};H:${hidden ? 'true' : 'false'};;`;
      
      const qrCodeDataURL = await QRCode.toDataURL(wifiString, {
        width: 300,
        margin: 2,
        color: {
          dark: '#000000',
          light: '#FFFFFF'
        }
      });

      return {
        qrCode: qrCodeDataURL,
        wifiString
      };
    } catch (error) {
      throw new Error(`Lỗi tạo mã QR WiFi: ${error.message}`);
    }
  }

  // Generate URL QR code
  static async generateUrlQR(url, options = {}) {
    try {
      const defaultOptions = {
        width: 300,
        margin: 2,
        color: {
          dark: '#000000',
          light: '#FFFFFF'
        },
        ...options
      };

      const qrCodeDataURL = await QRCode.toDataURL(url, defaultOptions);
      
      return {
        qrCode: qrCodeDataURL,
        url
      };
    } catch (error) {
      throw new Error(`Lỗi tạo mã QR URL: ${error.message}`);
    }
  }

  // Generate contact QR code (vCard)
  static async generateContactQR(contactData) {
    try {
      const {
        firstName,
        lastName,
        phone,
        email,
        organization,
        title,
        url
      } = contactData;

      const vCard = `BEGIN:VCARD
VERSION:3.0
FN:${firstName} ${lastName}
N:${lastName};${firstName};;;
ORG:${organization || ''}
TITLE:${title || ''}
TEL:${phone || ''}
EMAIL:${email || ''}
URL:${url || ''}
END:VCARD`;

      const qrCodeDataURL = await QRCode.toDataURL(vCard, {
        width: 300,
        margin: 2,
        color: {
          dark: '#000000',
          light: '#FFFFFF'
        }
      });

      return {
        qrCode: qrCodeDataURL,
        vCard
      };
    } catch (error) {
      throw new Error(`Lỗi tạo mã QR contact: ${error.message}`);
    }
  }
}

module.exports = QRGenerator;
