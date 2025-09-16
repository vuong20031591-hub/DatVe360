import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../providers/booking_provider.dart';
import '../../data/models/booking.dart';

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

    final basePrice = _getBasePrice(trip, selectedClass);
    final seatPrice = _getSeatPrice(selectedSeatData);
    final taxPrice = (basePrice * 0.1).round();

    return basePrice + seatPrice + taxPrice + _getPaymentFee();
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

      // Create booking via provider
      final bookingNotifier = ref.read(bookingProvider.notifier);
      final booking = await bookingNotifier.createBooking(
        scheduleId: bookingRequest.scheduleId,
        passengers: bookingRequest.passengers.map((p) => p.toJson()).toList(),
        selectedClass: bookingRequest.selectedClass,
        selectedSeats: bookingRequest.selectedSeats,
        contactInfo: bookingRequest.contactInfo.toJson(),
        paymentMethod: bookingRequest.paymentMethod,
      );

      if (booking != null) {
        // Process payment
        final paymentResult = await bookingNotifier.processPayment(booking.id, {
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
      } else {
        throw Exception('Tạo booking thất bại');
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

  List<Widget> _buildPricingRows(ThemeData theme) {
    final trip = widget.bookingData['trip'] as Map<String, dynamic>?;
    final selectedClass = widget.bookingData['selectedClass'] as String?;
    final selectedSeatData = widget.bookingData['selectedSeatData'] is List
        ? List<dynamic>.from(widget.bookingData['selectedSeatData'])
        : <dynamic>[];

    if (trip == null) {
      return [_buildSummaryRow(theme, 'Giá vé', '0đ')];
    }

    final basePrice = _getBasePrice(trip, selectedClass);
    final seatPrice = _getSeatPrice(selectedSeatData);
    final taxPrice = (basePrice * 0.1).round();

    return [
      _buildSummaryRow(
        theme,
        'Giá vé ${selectedClass?.toUpperCase() ?? ''}',
        '${_formatPrice(basePrice)}đ',
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
