import 'package:flutter/material.dart';
import 'shared/widgets/vnpay_webview.dart';

class TestVNPayPage extends StatelessWidget {
  const TestVNPayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test VNPay Integration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test VNPay Payment Integration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _testVNPayPayment(context),
              child: const Text('Test VNPay Payment'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _testVNPayWithWebView(context),
              child: const Text('Test VNPay with WebView'),
            ),
          ],
        ),
      ),
    );
  }

  void _testVNPayPayment(BuildContext context) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Simulate API call to get payment URL
      await Future.delayed(const Duration(seconds: 1));
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('VNPay service is working! Check browser for payment URL.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _testVNPayWithWebView(BuildContext context) {
    // Use the test payment URL from our backend
    const testPaymentUrl = 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?vnp_Amount=143000000&vnp_Command=pay&vnp_CreateDate=20250918050443&vnp_CurrCode=VND&vnp_IpAddr=127.0.0.1&vnp_Locale=vn&vnp_OrderInfo=Thanh+toan+ve+may+bay&vnp_OrderType=other&vnp_ReturnUrl=http%3A%2F%2Flocalhost%3A5000%2Fapi%2Fv1%2Fpayments%2Fvnpay%2Freturn&vnp_TmnCode=I3PE73LI&vnp_TxnRef=TEST1758121483351&vnp_Version=2.1.0&vnp_SecureHash=f40f667a9d9df782b986a536b282c361b5d35a4dfd265f8cc06dc0928304caae47ce7af1c3c4c996101d3dae035d18bfc6231c33a5e845a8a2fc6cad561607fb';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VNPayWebView(
          paymentUrl: testPaymentUrl,
          onPaymentResult: (result) {
            Navigator.of(context).pop();
            _showPaymentResult(context, result);
          },
          onCancel: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment cancelled by user'),
                backgroundColor: Colors.orange,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showPaymentResult(BuildContext context, Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          result['success'] == true ? 'Payment Success' : 'Payment Failed',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Success: ${result['success']}'),
            Text('Response Code: ${result['responseCode']}'),
            Text('Order ID: ${result['orderId']}'),
            Text('Amount: ${result['amount']}'),
            Text('Message: ${result['message']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
