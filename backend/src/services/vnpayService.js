const { VNPay } = require('vnpay');

class VNPayService {
  constructor() {
    this.vnpay = new VNPay({
      tmnCode: process.env.VNP_TMN_CODE || 'I3PE73LI',
      secureSecret: process.env.VNP_HASH_SECRET || 'C9RNH2NR4QMEB7907BB6VVHYGGU2336R',
      vnpayHost: 'https://sandbox.vnpayment.vn',
      testMode: true,
      hashAlgorithm: 'SHA512',
      enableLog: true
    });
    
    this.vnp_ReturnUrl = process.env.VNP_RETURN_URL || 'http://localhost:5000/api/v1/payments/vnpay/return';
    this.vnp_IpnUrl = process.env.VNP_IPN_URL || 'http://localhost:5000/api/v1/payments/vnpay/ipn';
  }

  /**
   * Tạo URL thanh toán VNPay
   * @param {Object} params - Thông tin thanh toán
   * @param {string} params.orderId - Mã đơn hàng (booking ID)
   * @param {number} params.amount - Số tiền (VND)
   * @param {string} params.orderInfo - Thông tin đơn hàng
   * @param {string} params.ipAddr - IP address của user
   * @param {string} [params.bankCode] - Mã ngân hàng (optional)
   * @returns {string} URL thanh toán
   */
  createPaymentUrl(params) {
    try {
      const { orderId, amount, orderInfo, ipAddr, bankCode } = params;
      
      // Sử dụng thư viện vnpay để tạo payment URL
      const paymentUrl = this.vnpay.buildPaymentUrl({
        vnp_Amount: amount,
        vnp_IpAddr: ipAddr,
        vnp_TxnRef: orderId,
        vnp_OrderInfo: orderInfo,
        vnp_ReturnUrl: this.vnp_ReturnUrl,
        vnp_BankCode: bankCode || undefined
      });
      
      console.log('=== VNPay Payment URL (Using Library) ===');
      console.log('Order ID:', orderId);
      console.log('Amount:', amount);
      console.log('Order Info:', orderInfo);
      console.log('Payment URL:', paymentUrl);
      console.log('=========================================');
      
      return paymentUrl;
    } catch (error) {
      console.error('Error creating VNPay payment URL:', error);
      throw error;
    }
  }

  /**
   * Xác thực IPN từ VNPay
   * @param {Object} vnpayData - Dữ liệu từ VNPay
   * @returns {Object} Kết quả xác thực
   */
  verifyIpnCall(vnpayData) {
    try {
      const result = this.vnpay.verifyIpnCall(vnpayData);
      
      console.log('=== VNPay IPN Verification ===');
      console.log('Is Verified:', result.isVerified);
      console.log('Is Success:', result.isSuccess);
      console.log('Message:', result.message);
      console.log('==============================');
      
      return result;
    } catch (error) {
      console.error('Error verifying VNPay IPN:', error);
      throw error;
    }
  }

  /**
   * Xác thực return URL từ VNPay
   * @param {Object} vnpayData - Dữ liệu từ VNPay
   * @returns {Object} Kết quả xác thực
   */
  verifyReturnUrl(vnpayData) {
    try {
      const result = this.vnpay.verifyReturnUrl(vnpayData);
      
      console.log('=== VNPay Return URL Verification ===');
      console.log('Is Verified:', result.isVerified);
      console.log('Is Success:', result.isSuccess);
      console.log('Message:', result.message);
      console.log('Transaction Ref:', result.vnp_TxnRef);
      console.log('Amount:', result.vnp_Amount);
      console.log('=====================================');
      
      return result;
    } catch (error) {
      console.error('Error verifying VNPay return URL:', error);
      throw error;
    }
  }

  /**
   * Lấy danh sách ngân hàng
   * @returns {Promise<Array>} Danh sách ngân hàng
   */
  async getBankList() {
    try {
      const bankList = await this.vnpay.getBankList();
      
      console.log('=== VNPay Bank List ===');
      console.log('Total banks:', bankList.length);
      console.log('=======================');
      
      return bankList;
    } catch (error) {
      console.error('Error getting VNPay bank list:', error);
      throw error;
    }
  }

  /**
   * Truy vấn kết quả thanh toán
   * @param {Object} params - Thông tin truy vấn
   * @param {string} params.orderId - Mã đơn hàng
   * @param {string} params.transDate - Ngày giao dịch (yyyyMMddHHmmss)
   * @returns {Promise<Object>} Kết quả truy vấn
   */
  async queryTransaction(params) {
    try {
      const { orderId, transDate } = params;
      
      const result = await this.vnpay.queryDr({
        vnp_TxnRef: orderId,
        vnp_TransactionDate: transDate,
        vnp_CreateBy: 'DatVe360',
        vnp_IpAddr: '127.0.0.1'
      });
      
      console.log('=== VNPay Query Transaction ===');
      console.log('Order ID:', orderId);
      console.log('Transaction Date:', transDate);
      console.log('Result:', result);
      console.log('===============================');
      
      return result;
    } catch (error) {
      console.error('Error querying VNPay transaction:', error);
      throw error;
    }
  }

  /**
   * Hoàn tiền giao dịch
   * @param {Object} params - Thông tin hoàn tiền
   * @param {string} params.orderId - Mã đơn hàng
   * @param {number} params.amount - Số tiền hoàn
   * @param {string} params.transDate - Ngày giao dịch (yyyyMMddHHmmss)
   * @param {string} params.reason - Lý do hoàn tiền
   * @returns {Promise<Object>} Kết quả hoàn tiền
   */
  async refundTransaction(params) {
    try {
      const { orderId, amount, transDate, reason } = params;
      
      const result = await this.vnpay.refund({
        vnp_TxnRef: orderId,
        vnp_Amount: amount,
        vnp_TransactionDate: transDate,
        vnp_CreateBy: 'DatVe360',
        vnp_IpAddr: '127.0.0.1',
        vnp_OrderInfo: reason || 'Hoàn tiền đơn hàng'
      });
      
      console.log('=== VNPay Refund Transaction ===');
      console.log('Order ID:', orderId);
      console.log('Amount:', amount);
      console.log('Reason:', reason);
      console.log('Result:', result);
      console.log('================================');
      
      return result;
    } catch (error) {
      console.error('Error refunding VNPay transaction:', error);
      throw error;
    }
  }
}

module.exports = VNPayService;
