const nodemailer = require('nodemailer');
const logger = require('../utils/logger');

class EmailService {
  constructor() {
    this.transporter = null;
    this.init();
  }

  init() {
    // Check if email is configured
    if (!process.env.EMAIL_HOST || !process.env.EMAIL_USER) {
      logger.warn('Email service not configured, emails will be logged only');
      return;
    }

    try {
      this.transporter = nodemailer.createTransport({
        host: process.env.EMAIL_HOST,
        port: parseInt(process.env.EMAIL_PORT) || 587,
        secure: process.env.EMAIL_SECURE === 'true', // true for 465, false for other ports
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_PASSWORD,
        },
      });

      // Verify connection
      this.transporter.verify((error, success) => {
        if (error) {
          logger.error('Email service verification failed:', error);
        } else {
          logger.info('Email service is ready');
        }
      });
    } catch (error) {
      logger.error('Email service initialization error:', error);
    }
  }

  async sendEmail({ to, subject, html, text }) {
    try {
      // If transporter not configured, just log
      if (!this.transporter) {
        logger.info('Email would be sent:', {
          to,
          subject,
          preview: text?.substring(0, 100) || html?.substring(0, 100),
        });
        return { success: true, messageId: 'mock-' + Date.now() };
      }

      const mailOptions = {
        from: `"${process.env.EMAIL_FROM_NAME || 'DatVe360'}" <${process.env.EMAIL_FROM || process.env.EMAIL_USER}>`,
        to,
        subject,
        text,
        html,
      };

      const info = await this.transporter.sendMail(mailOptions);
      logger.info('Email sent successfully:', {
        to,
        subject,
        messageId: info.messageId,
      });

      return { success: true, messageId: info.messageId };
    } catch (error) {
      logger.error('Failed to send email:', error);
      throw new Error(`Failed to send email: ${error.message}`);
    }
  }

  async sendPasswordResetEmail(email, resetToken, userName) {
    const resetUrl = `${process.env.FRONTEND_URL || 'http://localhost:3000'}/reset-password?token=${resetToken}`;
    
    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
          .button { display: inline-block; padding: 12px 30px; background: #667eea; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }
          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
          .warning { background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🔐 Đặt lại mật khẩu</h1>
          </div>
          <div class="content">
            <p>Xin chào <strong>${userName || email}</strong>,</p>
            <p>Chúng tôi nhận được yêu cầu đặt lại mật khẩu cho tài khoản DatVe360 của bạn.</p>
            <p>Nhấn vào nút bên dưới để đặt lại mật khẩu:</p>
            <div style="text-align: center;">
              <a href="${resetUrl}" class="button">Đặt lại mật khẩu</a>
            </div>
            <p>Hoặc copy link sau vào trình duyệt:</p>
            <p style="background: #fff; padding: 10px; border: 1px solid #ddd; word-break: break-all;">
              ${resetUrl}
            </p>
            <div class="warning">
              <strong>⚠️ Lưu ý:</strong>
              <ul>
                <li>Link này chỉ có hiệu lực trong <strong>1 giờ</strong></li>
                <li>Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này</li>
                <li>Không chia sẻ link này với bất kỳ ai</li>
              </ul>
            </div>
            <p>Trân trọng,<br><strong>Đội ngũ DatVe360</strong></p>
          </div>
          <div class="footer">
            <p>© ${new Date().getFullYear()} DatVe360. All rights reserved.</p>
            <p>Email này được gửi tự động, vui lòng không trả lời.</p>
          </div>
        </div>
      </body>
      </html>
    `;

    const text = `
Xin chào ${userName || email},

Chúng tôi nhận được yêu cầu đặt lại mật khẩu cho tài khoản DatVe360 của bạn.

Vui lòng truy cập link sau để đặt lại mật khẩu:
${resetUrl}

Link này chỉ có hiệu lực trong 1 giờ.

Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.

Trân trọng,
Đội ngũ DatVe360
    `;

    return await this.sendEmail({
      to: email,
      subject: '🔐 Đặt lại mật khẩu - DatVe360',
      html,
      text,
    });
  }

  async sendBookingConfirmationEmail(email, booking, tickets) {
    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
          .booking-info { background: white; padding: 20px; border-radius: 5px; margin: 20px 0; }
          .info-row { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #eee; }
          .label { font-weight: bold; color: #666; }
          .value { color: #333; }
          .total { background: #667eea; color: white; padding: 15px; border-radius: 5px; margin-top: 20px; text-align: center; font-size: 18px; }
          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>✅ Đặt vé thành công!</h1>
          </div>
          <div class="content">
            <p>Xin chào <strong>${booking.contactInfo?.name || email}</strong>,</p>
            <p>Cảm ơn bạn đã đặt vé tại DatVe360. Đơn đặt vé của bạn đã được xác nhận.</p>
            
            <div class="booking-info">
              <h3>📋 Thông tin đặt vé</h3>
              <div class="info-row">
                <span class="label">Mã đặt vé:</span>
                <span class="value">${booking.bookingId}</span>
              </div>
              <div class="info-row">
                <span class="label">Trạng thái:</span>
                <span class="value">${booking.status === 'confirmed' ? 'Đã xác nhận' : booking.status}</span>
              </div>
              <div class="info-row">
                <span class="label">Số lượng vé:</span>
                <span class="value">${tickets?.length || booking.passengers?.length || 0} vé</span>
              </div>
              <div class="total">
                <strong>Tổng tiền: ${booking.totalAmount?.toLocaleString('vi-VN')} VNĐ</strong>
              </div>
            </div>

            <p>Vé điện tử của bạn đã được đính kèm trong email này. Vui lòng xuất trình vé khi lên tàu/xe.</p>
            
            <p>Nếu có bất kỳ thắc mắc nào, vui lòng liên hệ với chúng tôi qua hotline: <strong>1900-xxxx</strong></p>
            
            <p>Chúc bạn có chuyến đi vui vẻ!<br><strong>Đội ngũ DatVe360</strong></p>
          </div>
          <div class="footer">
            <p>© ${new Date().getFullYear()} DatVe360. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `;

    const text = `
Xin chào ${booking.contactInfo?.name || email},

Cảm ơn bạn đã đặt vé tại DatVe360. Đơn đặt vé của bạn đã được xác nhận.

Mã đặt vé: ${booking.bookingId}
Trạng thái: ${booking.status === 'confirmed' ? 'Đã xác nhận' : booking.status}
Số lượng vé: ${tickets?.length || booking.passengers?.length || 0} vé
Tổng tiền: ${booking.totalAmount?.toLocaleString('vi-VN')} VNĐ

Vé điện tử của bạn đã được đính kèm trong email này.

Chúc bạn có chuyến đi vui vẻ!
Đội ngũ DatVe360
    `;

    return await this.sendEmail({
      to: email,
      subject: `✅ Xác nhận đặt vé #${booking.bookingId} - DatVe360`,
      html,
      text,
    });
  }

  async sendTicketEmail(email, booking, ticketPdfBuffer) {
    // This would attach the PDF ticket
    // For now, just send confirmation
    return await this.sendBookingConfirmationEmail(email, booking, []);
  }

  async sendWelcomeEmail(email, userName) {
    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🎉 Chào mừng đến với DatVe360!</h1>
          </div>
          <div class="content">
            <p>Xin chào <strong>${userName}</strong>,</p>
            <p>Cảm ơn bạn đã đăng ký tài khoản tại DatVe360!</p>
            <p>Bạn có thể bắt đầu đặt vé máy bay, tàu hỏa, xe khách và phà ngay bây giờ.</p>
            <p>Chúc bạn có những trải nghiệm tuyệt vời!</p>
            <p>Trân trọng,<br><strong>Đội ngũ DatVe360</strong></p>
          </div>
          <div class="footer">
            <p>© ${new Date().getFullYear()} DatVe360. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `;

    return await this.sendEmail({
      to: email,
      subject: '🎉 Chào mừng đến với DatVe360!',
      html,
      text: `Xin chào ${userName},\n\nCảm ơn bạn đã đăng ký tài khoản tại DatVe360!\n\nTrân trọng,\nĐội ngũ DatVe360`,
    });
  }
}

// Create singleton instance
const emailService = new EmailService();

module.exports = emailService;

