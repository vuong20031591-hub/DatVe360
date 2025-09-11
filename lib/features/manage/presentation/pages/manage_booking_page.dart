import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../widgets/booking_card.dart';

class ManageBookingPage extends ConsumerStatefulWidget {
  const ManageBookingPage({super.key});

  @override
  ConsumerState<ManageBookingPage> createState() => _ManageBookingPageState();
}

class _ManageBookingPageState extends ConsumerState<ManageBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _bookingIdController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  List<Map<String, dynamic>> _bookings = [];
  bool _hasSearched = false;

  @override
  void dispose() {
    _bookingIdController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý đặt vé')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tra cứu đặt vé',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      AppTextField(
                        controller: _bookingIdController,
                        label: 'Mã đặt vé',
                        hint: 'Nhập mã đặt vé (6-10 ký tự)',
                        prefixIcon: Icons.confirmation_number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mã đặt vé';
                          }
                          if (value.length < AppConstants.minBookingIdLength ||
                              value.length > AppConstants.maxBookingIdLength) {
                            return 'Mã đặt vé phải có ${AppConstants.minBookingIdLength}-${AppConstants.maxBookingIdLength} ký tự';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      AppEmailField(
                        controller: _emailController,
                        label: 'Email đặt vé',
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          onPressed: _isLoading ? null : _searchBooking,
                          text: 'Tra cứu',
                          icon: Icons.search,
                          isLoading: _isLoading,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Search results
            if (_hasSearched) ...[
              Text(
                'Kết quả tra cứu',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              if (_bookings.isEmpty)
                _buildEmptyState(theme)
              else
                ..._bookings
                    .map(
                      (booking) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: BookingCard(
                          booking: booking,
                          onViewTicket: () => _viewTicket(booking['id']),
                          onCancel: booking['status'] == 'confirmed'
                              ? () => _cancelBooking(booking['id'])
                              : null,
                        ),
                      ),
                    )
                    .toList(),
            ],

            const SizedBox(height: 32),

            // Help section
            _buildHelpSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy đặt vé',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng kiểm tra lại mã đặt vé và email.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.help_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Cần hỗ trợ?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildHelpItem(
              theme,
              Icons.email,
              'Email hỗ trợ',
              'support@datve360.com',
            ),

            _buildHelpItem(theme, Icons.phone, 'Hotline', '1900 1234'),

            _buildHelpItem(theme, Icons.schedule, 'Thời gian hỗ trợ', '24/7'),

            const SizedBox(height: 16),

            Text(
              'Lưu ý: Mã đặt vé được gửi qua email sau khi thanh toán thành công. '
              'Vui lòng kiểm tra cả hộp thư spam.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(
    ThemeData theme,
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Text(
            '$title: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _searchBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _hasSearched = false;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Mock search result
    final bookingId = _bookingIdController.text.toUpperCase();
    final email = _emailController.text.toLowerCase();

    // Simulate finding booking
    if (bookingId == 'DV360123' && email == 'test@example.com') {
      _bookings = [_getMockBooking()];
    } else {
      _bookings = [];
    }

    setState(() {
      _isLoading = false;
      _hasSearched = true;
    });
  }

  void _viewTicket(String bookingId) {
    // TODO: Navigate to ticket page
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Xem vé: $bookingId')));
  }

  void _cancelBooking(String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đặt vé'),
        content: const Text(
          'Bạn có chắc chắn muốn hủy đặt vé này? '
          'Phí hủy có thể được áp dụng theo chính sách của hãng.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Cancel booking
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã hủy đặt vé: $bookingId')),
              );
            },
            child: const Text('Hủy vé'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getMockBooking() {
    return {
      'id': 'DV360123',
      'pnr': 'ABC123',
      'status': 'confirmed',
      'trip': {
        'carrier': 'Vietnam Airlines',
        'flightNumber': 'VN210',
        'from': 'Hà Nội',
        'to': 'TP.HCM',
        'departTime': '06:00',
        'arriveTime': '08:15',
        'departDate': DateTime.now().add(const Duration(days: 7)),
      },
      'passengers': [
        {'name': 'Nguyễn Văn A', 'type': 'adult'},
      ],
      'seats': ['12A'],
      'totalPrice': 1200000,
      'createdAt': DateTime.now().subtract(const Duration(days: 1)),
    };
  }
}
