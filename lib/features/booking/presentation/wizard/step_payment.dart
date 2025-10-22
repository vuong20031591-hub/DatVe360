import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/vnpay_webview.dart';
import '../providers/booking_provider.dart';
import '../../data/models/booking.dart';
import '../../data/models/booking_exception.dart';

class StepPayment extends ConsumerStatefulWidget {
  const StepPayment({
    super.key,
    required this.bookingData,
    required this.onDataChanged,
    required this.onPaymentComplete,
    required this.onPrevious,
  });

  final Map<String, dynamic> bookingData;
  final Function(Map<String, dynamic>) onDataChanged;
  final Function(String bookingId) onPaymentComplete;
  final VoidCallback onPrevious;

  @override
  ConsumerState<StepPayment> createState() => _StepPaymentState();
}

class _StepPaymentState extends ConsumerState<StepPayment> {
  String? _selectedPaymentMethod;
  bool _isProcessing = false;
  bool _agreeToTerms = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'vnpay',
      'name': 'VNPay',
      'description': 'Thanh toán qua VNPay',
      'icon': Icons.payment,
      'color': Colors.blue,
      'fee': 0,
    },
    {
      'id': 'momo',
      'name': 'MoMo',
      'description': 'Ví điện tử MoMo',
      'icon': Icons.account_balance_wallet,
      'color': Colors.pink,
      'fee': 0,
    },
    {
      'id': 'banking',
      'name': 'Internet Banking',
      'description': 'Chuyển khoản ngân hàng',
      'icon': Icons.account_balance,
      'color': Colors.green,
      'fee': 0,
    },
    {
      'id': 'visa',
      'name': 'Thẻ Visa/MasterCard',
      'description': 'Thanh toán bằng thẻ quốc tế',
      'icon': Icons.credit_card,
      'color': Colors.orange,
      'fee': 15000,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Tóm tắt thanh toán',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Calculate real pricing
                  ..._buildPricingRows(theme),

                  if (_selectedPaymentMethod != null)
                    _buildSummaryRow(
                      theme,
                      'Phí thanh toán',
                      _getPaymentFee() > 0
                          ? '${_formatPrice(_getPaymentFee())}đ'
                          : 'Miễn phí',
                    ),

                  const Divider(height: 24),

                  Row(
                    children: [
                      Text(
                        'Tổng thanh toán',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_formatPrice(_getTotalAmount())}đ',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightSuccess,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Payment methods
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.payment, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Chọn phương thức thanh toán',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  ..._paymentMethods.map(
                    (method) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildPaymentMethodTile(theme, method),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Terms and conditions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.gavel, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Điều khoản và điều kiện',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  CheckboxListTile(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                    title: RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium,
                        children: [
                          const TextSpan(text: 'Tôi đồng ý với '),
                          TextSpan(
                            text: 'Điều khoản sử dụng',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' và '),
                          TextSpan(
                            text: 'Chính sách bảo mật',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' của DatVe360'),
                        ],
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lưu ý quan trọng:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• Vé điện tử sẽ được gửi qua email sau khi thanh toán thành công\n'
                          '• Vui lòng kiểm tra thông tin hành khách trước khi thanh toán\n'
                          '• Chính sách hủy/đổi vé theo quy định của hãng hàng không',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  onPressed: widget.onPrevious,
                  text: 'Quay lại',
                  type: AppButtonType.outline,
                  icon: Icons.arrow_back,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: AppButton(
                  onPressed: _canProceedPayment() ? _processPayment : null,
                  text: _isProcessing ? 'Đang xử lý...' : 'Thanh toán ngay',
                  icon: _isProcessing ? null : Icons.lock,
                  isLoading: _isProcessing,
                  size: AppButtonSize.large,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(ThemeData theme, String label, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          const Spacer(),
          Text(
            amount,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(ThemeData theme, Map<String, dynamic> method) {
    final isSelected = _selectedPaymentMethod == method['id'];

    return Card(
      elevation: isSelected ? 2 : 0,
      color: isSelected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: method['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(method['icon'], color: method['color']),
        ),
        title: Text(
          method['name'],
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(method['description']),
            if (method['fee'] > 0)
              Text(
                'Phí: ${_formatPrice(method['fee'])}đ',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                ),
              ),
          ],
        ),
        trailing: Radio<String>(
          value: method['id'],
          groupValue: _selectedPaymentMethod,
          onChanged: (value) {
            setState(() {
              _selectedPaymentMethod = value;
            });
            widget.onDataChanged({'paymentMethod': value});
          },
        ),
        onTap: () {
          setState(() {
            _selectedPaymentMethod = method['id'];
          });
          widget.onDataChanged({'paymentMethod': method['id']});
        },
      ),
    );
  }

  bool _canProceedPayment() {
    return _selectedPaymentMethod != null && _agreeToTerms && !_isProcessing;
  }

  int _getPaymentFee() {
    if (_selectedPaymentMethod == null) return 0;
    final method = _paymentMethods.firstWhere(
      (m) => m['id'] == _selectedPaymentMethod,
      orElse: () => {'fee': 0},
    );
    return method['fee'] ?? 0;
  }

  int _getTotalAmount() {
    final trip = widget.bookingData['trip'] as Map<String, dynamic>?;
    final selectedClass = widget.bookingData['selectedClass'] as String?;
    final selectedSeatData = widget.bookingData['selectedSeatData'] is List
        ? List<dynamic>.from(widget.bookingData['selectedSeatData'])
        : <dynamic>[];

    if (trip == null) return _getPaymentFee();

    final basePricePerSeat = _getBasePrice(trip, selectedClass);
    final numberOfSeats = selectedSeatData.length;
    final totalBasePrice = basePricePerSeat * numberOfSeats;
    final seatPrice = _getSeatPrice(selectedSeatData);
    final taxPrice = (totalBasePrice * 0.1).round();

    return totalBasePrice + seatPrice + taxPrice + _getPaymentFee();
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _processPayment() async {
    if (_selectedPaymentMethod == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Create booking request
      final trip = widget.bookingData['trip'] as Map<String, dynamic>?;
      final passengers =
          widget.bookingData['passengers'] as List<dynamic>? ?? [];
      final selectedSeats =
          widget.bookingData['selectedSeats'] as List<dynamic>? ?? [];
      final selectedClass =
          widget.bookingData['selectedClass'] as String? ?? '';
      final contactInfo =
          widget.bookingData['contactInfo'] as Map<String, dynamic>? ?? {};

      if (trip == null || passengers.isEmpty) {
        throw Exception('Thông tin booking không đầy đủ');
      }

      final bookingRequest = BookingRequest(
        scheduleId: trip['_id'] ?? trip['id'] ?? '',
        passengers: passengers.map((p) => Passenger.fromJson(p)).toList(),
        selectedClass: selectedClass,
        selectedSeats: selectedSeats.cast<String>(),
        contactInfo: ContactInfo.fromJson(contactInfo),
        paymentMethod: _selectedPaymentMethod!,
      );

      final bookingNotifier = ref.read(bookingProvider.notifier);

      // Tạo booking trước
      final booking = await bookingNotifier.createBooking(
        scheduleId: bookingRequest.scheduleId,
        passengers: bookingRequest.passengers.map((p) => p.toJson()).toList(),
        selectedClass: bookingRequest.selectedClass,
        selectedSeats: bookingRequest.selectedSeats,
        contactInfo: bookingRequest.contactInfo.toJson(),
        paymentMethod: bookingRequest.paymentMethod,
      );

      if (booking != null) {
        try {
          // Xử lý thanh toán theo phương thức được chọn
          switch (_selectedPaymentMethod) {
            case 'vnpay':
              await _processVNPayPayment(booking.id);
              break;
            case 'momo':
              await _processMoMoPayment(booking.id);
              break;
            case 'visa':
            case 'mastercard':
              await _processStripePayment(booking.id);
              break;
            case 'zalopay':
              await _processZaloPayPayment(booking.id);
              break;
            default:
              // Fallback cho các phương thức khác
              final paymentResult = await bookingNotifier
                  .processPayment(booking.id, {
                    'payment_method': _selectedPaymentMethod,
                    'amount': _getTotalAmount(),
                  });

              if (paymentResult != null && paymentResult['success'] == true) {
                setState(() {
                  _isProcessing = false;
                });
                widget.onPaymentComplete(booking.id);
              } else {
                throw Exception('Thanh toán thất bại');
              }
          }
        } catch (e) {
          // Nếu thanh toán thất bại, xóa booking đã tạo
          try {
            await bookingNotifier.cancelBooking(booking.id, 'Payment failed');
          } catch (cancelError) {
            // Log error nhưng không làm gián đoạn flow
            debugPrint('Lỗi khi hủy booking: $cancelError');
          }
          rethrow; // Ném lại lỗi gốc
        }
      } else {
        throw Exception('Tạo booking thất bại');
      }
    } on BookingException catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        // Hiển thị dialog cho race condition
        if (e.isRaceCondition) {
          _showRaceConditionDialog(e);
        } else {
          // Hiển thị snackbar cho các lỗi khác
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.userMessage),
              backgroundColor: e.canRetry ? Colors.orange : Colors.red,
              action: e.canRetry
                  ? SnackBarAction(
                      label: e.actionMessage,
                      textColor: Colors.white,
                      onPressed: () {
                        // Retry booking
                        _processPayment();
                      },
                    )
                  : null,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Hiển thị dialog khi xảy ra race condition
  void _showRaceConditionDialog(BookingException exception) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Ghế đã hết'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exception.userMessage, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text(
              'Vui lòng:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Chọn ghế khác'),
            const Text('• Hoặc thử lại để kiểm tra ghế trống'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Quay lại step chọn ghế
              widget.onPrevious();
            },
            child: const Text('Chọn lại ghế'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Retry booking với ghế hiện tại
              _processPayment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
            ),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Future<void> _processVNPayPayment(String bookingId) async {
    try {
      final bookingNotifier = ref.read(bookingProvider.notifier);

      // Tạo VNPay payment URL
      final paymentResult = await bookingNotifier.createVNPayPayment(
        bookingId: bookingId,
        bankCode: _getSelectedBankCode(),
      );

      if (paymentResult != null && paymentResult['success'] == true) {
        final paymentUrl = paymentResult['data']['paymentUrl'] as String?;

        if (paymentUrl != null) {
          setState(() {
            _isProcessing = false;
          });

          // Chuyển đến trang thanh toán VNPay
          await _openVNPayPayment(paymentUrl, bookingId);
        } else {
          throw Exception('Không thể tạo URL thanh toán');
        }
      } else {
        throw Exception('Tạo thanh toán VNPay thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi VNPay: ${e.toString()}');
    }
  }

  Future<void> _openVNPayPayment(String paymentUrl, String bookingId) async {
    if (!mounted) return;

    try {
      // Import VNPayWebView
      final result = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (context) => VNPayWebView(
            paymentUrl: paymentUrl,
            onPaymentResult: (result) {
              Navigator.of(context).pop(result);
            },
            onCancel: () {
              Navigator.of(context).pop({
                'success': false,
                'message': 'Người dùng hủy thanh toán',
                'cancelled': true,
              });
            },
          ),
        ),
      );

      if (result != null) {
        await _handleVNPayResult(result, bookingId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi mở thanh toán: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleVNPayResult(
    Map<String, dynamic> result,
    String bookingId,
  ) async {
    if (!mounted) return;

    try {
      if (result['success'] == true) {
        // Payment successful - call the callback to handle navigation
        widget.onPaymentComplete(bookingId);
      } else if (result['cancelled'] == true) {
        // User cancelled payment
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thanh toán đã bị hủy'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        // Payment failed
        final message = result['message'] ?? 'Thanh toán thất bại';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xử lý kết quả thanh toán: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processMoMoPayment(String bookingId) async {
    try {
      final bookingNotifier = ref.read(bookingProvider.notifier);

      // Tạo MoMo payment
      final paymentResult = await bookingNotifier.createMoMoPayment(
        bookingId: bookingId,
      );

      if (paymentResult != null && paymentResult['success'] == true) {
        final paymentUrl = paymentResult['data']['paymentUrl'] as String?;
        final deeplink = paymentResult['data']['deeplink'] as String?;

        if (paymentUrl != null) {
          setState(() {
            _isProcessing = false;
          });

          // Chuyển đến trang thanh toán MoMo
          await _openMoMoPayment(paymentUrl, deeplink, bookingId);
        } else {
          throw Exception('Không thể tạo URL thanh toán MoMo');
        }
      } else {
        throw Exception('Tạo thanh toán MoMo thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi MoMo: ${e.toString()}');
    }
  }

  Future<void> _openMoMoPayment(
    String paymentUrl,
    String? deeplink,
    String bookingId,
  ) async {
    if (!mounted) return;

    try {
      // Hiển thị dialog với các tùy chọn thanh toán MoMo
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Thanh toán MoMo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Chọn cách thanh toán MoMo:'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop({
                    'success': true,
                    'method': 'app',
                    'message': 'Mở ứng dụng MoMo',
                  });
                },
                child: const Text('Mở ứng dụng MoMo'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop({
                    'success': true,
                    'method': 'web',
                    'message': 'Thanh toán qua web',
                  });
                },
                child: const Text('Thanh toán qua web'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'success': false,
                  'cancelled': true,
                  'message': 'Người dùng hủy thanh toán',
                });
              },
              child: const Text('Hủy'),
            ),
          ],
        ),
      );

      if (result != null) {
        await _handleMoMoResult(result, bookingId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi mở thanh toán MoMo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleMoMoResult(
    Map<String, dynamic> result,
    String bookingId,
  ) async {
    try {
      if (result['success'] == true && result['cancelled'] != true) {
        // Simulate successful payment for demo
        setState(() {
          _isProcessing = false;
        });
        widget.onPaymentComplete(bookingId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thanh toán MoMo thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (result['cancelled'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thanh toán đã bị hủy'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        final message = result['message'] ?? 'Thanh toán MoMo thất bại';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xử lý kết quả MoMo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processStripePayment(String bookingId) async {
    try {
      final bookingNotifier = ref.read(bookingProvider.notifier);

      // Tạo Stripe Payment Intent
      final paymentResult = await bookingNotifier.createStripePayment(
        bookingId: bookingId,
      );

      if (paymentResult != null && paymentResult['success'] == true) {
        final clientSecret = paymentResult['data']['clientSecret'] as String?;
        final publishableKey =
            paymentResult['data']['publishableKey'] as String?;

        if (clientSecret != null && publishableKey != null) {
          setState(() {
            _isProcessing = false;
          });

          // Chuyển đến trang thanh toán Stripe
          await _openStripePayment(clientSecret, publishableKey, bookingId);
        } else {
          throw Exception('Không thể tạo Payment Intent');
        }
      } else {
        throw Exception('Tạo Payment Intent thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi Stripe: ${e.toString()}');
    }
  }

  Future<void> _openStripePayment(
    String clientSecret,
    String publishableKey,
    String bookingId,
  ) async {
    if (!mounted) return;

    try {
      // Hiển thị dialog mô phỏng thanh toán Stripe
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Thanh toán thẻ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Nhập thông tin thẻ:'),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Số thẻ',
                  hintText: '4242 4242 4242 4242',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'MM/YY',
                        hintText: '12/25',
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'CVC',
                        hintText: '123',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'success': false,
                  'cancelled': true,
                  'message': 'Người dùng hủy thanh toán',
                });
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop({'success': true, 'message': 'Thanh toán thành công'});
              },
              child: const Text('Thanh toán'),
            ),
          ],
        ),
      );

      if (result != null) {
        await _handleStripeResult(result, bookingId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi mở thanh toán Stripe: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleStripeResult(
    Map<String, dynamic> result,
    String bookingId,
  ) async {
    try {
      if (result['success'] == true && result['cancelled'] != true) {
        setState(() {
          _isProcessing = false;
        });
        widget.onPaymentComplete(bookingId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thanh toán thẻ thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (result['cancelled'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thanh toán đã bị hủy'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        final message = result['message'] ?? 'Thanh toán thẻ thất bại';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xử lý kết quả Stripe: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processZaloPayPayment(String bookingId) async {
    try {
      // ZaloPay chưa được implement, hiển thị thông báo
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ZaloPay sẽ được hỗ trợ trong phiên bản tiếp theo'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      setState(() {
        _isProcessing = false;
      });
    } catch (e) {
      throw Exception('Lỗi ZaloPay: ${e.toString()}');
    }
  }

  String? _getSelectedBankCode() {
    // Map payment method to bank code for VNPay
    switch (_selectedPaymentMethod) {
      case 'vnpay':
        return null; // Let user choose payment method on VNPay page
      case 'banking':
        return 'VNBANK';
      case 'visa':
        return 'VISA';
      case 'mastercard':
        return 'MASTERCARD';
      default:
        return null;
    }
  }

  List<Widget> _buildPricingRows(ThemeData theme) {
    final trip = widget.bookingData['trip'] as Map<String, dynamic>?;
    final selectedClass = widget.bookingData['selectedClass'] as String?;
    final selectedSeatData = widget.bookingData['selectedSeatData'] is List
        ? List<dynamic>.from(widget.bookingData['selectedSeatData'])
        : <dynamic>[];

    if (trip == null) {
      return [_buildSummaryRow(theme, 'Giá vé', '0đ')];
    }

    final basePricePerSeat = _getBasePrice(trip, selectedClass);
    final numberOfSeats = selectedSeatData.length;
    final totalBasePrice = basePricePerSeat * numberOfSeats;
    final seatPrice = _getSeatPrice(selectedSeatData);
    final taxPrice = (totalBasePrice * 0.1).round();

    return [
      _buildSummaryRow(
        theme,
        'Giá vé ${selectedClass?.toUpperCase() ?? ''} (${numberOfSeats}x)',
        '${_formatPrice(totalBasePrice)}đ',
      ),
      if (seatPrice > 0)
        _buildSummaryRow(theme, 'Phí chọn ghế', '${_formatPrice(seatPrice)}đ'),
      _buildSummaryRow(theme, 'Thuế và phí', '${_formatPrice(taxPrice)}đ'),
    ];
  }

  int _getBasePrice(Map<String, dynamic> trip, String? selectedClass) {
    if (selectedClass == null) return trip['price']?.toInt() ?? 0;

    final classes = trip['classes'] as List?;
    if (classes == null) return trip['price']?.toInt() ?? 0;

    try {
      final classData = classes.firstWhere((c) => c['id'] == selectedClass);
      return (classData['price'] as num?)?.toInt() ??
          trip['price']?.toInt() ??
          0;
    } catch (e) {
      return trip['price']?.toInt() ?? 0;
    }
  }

  int _getSeatPrice(List<dynamic> selectedSeatData) {
    int total = 0;
    for (final seatData in selectedSeatData) {
      if (seatData != null && seatData.priceAddon != null) {
        total += (seatData.priceAddon as num).toInt();
      }
    }
    return total;
  }
}
