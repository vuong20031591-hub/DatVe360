import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VNPayWebView extends StatefulWidget {
  final String paymentUrl;
  final Function(Map<String, dynamic>) onPaymentResult;
  final VoidCallback? onCancel;

  const VNPayWebView({
    super.key,
    required this.paymentUrl,
    required this.onPaymentResult,
    this.onCancel,
  });

  @override
  State<VNPayWebView> createState() => _VNPayWebViewState();
}

class _VNPayWebViewState extends State<VNPayWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading progress if needed
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _error = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _handleUrlChange(url);
            _checkForPaymentResult(url);
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _error = 'Lỗi tải trang: ${error.description}';
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            _handleUrlChange(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handleUrlChange(String url) {
    print('VNPayWebView URL changed: $url'); // Debug log

    // Check if this is a return URL from VNPay
    if (url.contains('/api/v1/payments/vnpay/return') ||
        url.contains('/payments/vnpay/return') ||
        url.contains('payment/success') ||
        url.contains('payment/failed') ||
        url.contains('vnp_ResponseCode')) {
      print('VNPayWebView detected return URL: $url'); // Debug log

      final uri = Uri.parse(url);
      final params = uri.queryParameters;

      // Extract payment result
      final responseCode =
          params['vnp_ResponseCode'] ??
          params['responseCode'] ??
          (url.contains('success') ? '00' : '99');

      final result = {
        'success': responseCode == '00',
        'responseCode': responseCode,
        'orderId': params['vnp_TxnRef'] ?? params['orderId'],
        'amount': params['vnp_Amount'] ?? params['amount'],
        'bankCode': params['vnp_BankCode'] ?? params['bankCode'],
        'transactionNo': params['vnp_TransactionNo'] ?? params['transactionNo'],
        'message': responseCode == '00'
            ? 'Thanh toán thành công'
            : 'Thanh toán thất bại',
        'url': url,
      };

      print('VNPayWebView payment result: $result'); // Debug log
      widget.onPaymentResult(result);
    }
  }

  void _checkForPaymentResult(String url) async {
    // Check if this is a return URL that might have JavaScript data
    if (url.contains('/api/v1/payments/vnpay/return')) {
      try {
        // Wait a bit for JavaScript to load
        await Future.delayed(const Duration(milliseconds: 500));

        // Try to extract payment result from JavaScript
        final jsResult = await _controller.runJavaScriptReturningResult(
          'window.paymentResult ? JSON.stringify(window.paymentResult) : null',
        );

        if (jsResult != 'null') {
          print('VNPayWebView JavaScript result: $jsResult'); // Debug log

          try {
            // Parse the JSON result
            final resultString = jsResult.toString();
            if (resultString.isNotEmpty && resultString != 'null') {
              // Try to parse as JSON
              final Map<String, dynamic> result = {};

              // Extract key values from the JSON string
              if (resultString.contains('success')) {
                result['success'] =
                    resultString.contains('"success":true') ||
                    resultString.contains('success:true');
                result['responseCode'] = _extractJsonValue(
                  resultString,
                  'responseCode',
                );
                result['orderId'] = _extractJsonValue(resultString, 'orderId');
                result['amount'] = _extractJsonValue(resultString, 'amount');
                result['bankCode'] = _extractJsonValue(
                  resultString,
                  'bankCode',
                );
                result['transactionNo'] = _extractJsonValue(
                  resultString,
                  'transactionNo',
                );
                result['bookingId'] = _extractJsonValue(
                  resultString,
                  'bookingId',
                );
                result['message'] = result['success'] == true
                    ? 'Thanh toán thành công'
                    : 'Thanh toán thất bại';
              }

              print('VNPayWebView parsed JS result: $result'); // Debug log
              widget.onPaymentResult(result);
            }
          } catch (e) {
            print('VNPayWebView JS parse error: $e'); // Debug log
          }
        }
      } catch (e) {
        print('VNPayWebView JS execution error: $e'); // Debug log
      }
    }
  }

  String? _extractJsonValue(String jsonString, String key) {
    try {
      // Simple regex to extract value from JSON string
      final pattern = RegExp('"$key"\\s*:\\s*"([^"]*)"');
      final match = pattern.firstMatch(jsonString);
      return match?.group(1);
    } catch (e) {
      print('Error extracting $key: $e'); // Debug log
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán VNPay'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (widget.onCancel != null) {
              widget.onCancel!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          if (_error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _error = null;
                      });
                      _controller.loadRequest(Uri.parse(widget.paymentUrl));
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          else
            WebViewWidget(controller: _controller),

          if (_isLoading && _error == null)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Đang tải trang thanh toán...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
