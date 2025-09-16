import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/app_button.dart';
import '../providers/booking_provider.dart';
import '../wizard/step_review.dart';
import '../wizard/step_passenger.dart';
import '../wizard/step_payment.dart';

class BookingPage extends ConsumerStatefulWidget {
  const BookingPage({
    super.key,
    this.trip,
    this.selectedSeats,
    this.selectedSeatData,
    this.selectedClass,
  });

  final Map<String, dynamic>? trip;
  final List<String>? selectedSeats;
  final List<dynamic>? selectedSeatData;
  final String? selectedClass;

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  Map<String, dynamic> _bookingData = {};

  @override
  void initState() {
    super.initState();
    _initializeBookingData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _initializeBookingData() {
    _bookingData = {
      'trip': widget.trip,
      'selectedSeats': widget.selectedSeats ?? [],
      'selectedSeatData': widget.selectedSeatData ?? [],
      'selectedClass': widget.selectedClass,
      'passengers': <Map<String, dynamic>>[],
      'contactInfo': <String, dynamic>{},
      'paymentMethod': null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt vé'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Step indicator
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              children: [
                _buildStepIndicator(0, 'Xem lại', Icons.visibility),
                _buildStepConnector(),
                _buildStepIndicator(1, 'Hành khách', Icons.person),
                _buildStepConnector(),
                _buildStepIndicator(2, 'Thanh toán', Icons.payment),
              ],
            ),
          ),

          // Step content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                StepReview(
                  bookingData: _bookingData,
                  onDataChanged: (data) {
                    setState(() {
                      _bookingData.addAll(data);
                    });
                  },
                ),
                StepPassenger(
                  bookingData: _bookingData,
                  onDataChanged: (data) {
                    setState(() {
                      _bookingData.addAll(data);
                    });
                  },
                ),
                StepPayment(
                  bookingData: _bookingData,
                  onDataChanged: (data) {
                    setState(() {
                      _bookingData.addAll(data);
                    });
                  },
                  onPaymentComplete: _handlePaymentComplete,
                  onPrevious: _previousStep,
                ),
              ],
            ),
          ),

          // Navigation buttons (hidden on payment step)
          if (_currentStep < 2)
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: AppButton(
                        onPressed: _previousStep,
                        text: 'Quay lại',
                        type: AppButtonType.outline,
                        icon: Icons.arrow_back,
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      onPressed: _canProceed() ? _nextStep : null,
                      text: 'Tiếp theo',
                      icon: Icons.arrow_forward,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String title, IconData icon) {
    final theme = Theme.of(context);
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? theme.colorScheme.primary
                  : isActive
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: isCompleted
                  ? theme.colorScheme.onPrimary
                  : isActive
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector() {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 24),
        color: theme.dividerColor,
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return true; // Review step always allows proceeding
      case 1:
        return _bookingData['passengers'] != null &&
            (_bookingData['passengers'] as List).isNotEmpty &&
            _bookingData['contactInfo'] != null &&
            (_bookingData['contactInfo'] as Map).isNotEmpty;
      case 2:
        return _bookingData['paymentMethod'] != null;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _processPayment();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _processPayment() async {
    if (_bookingData['trip'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thông tin chuyến đi không hợp lệ')),
      );
      return;
    }

    // Show loading
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đang xử lý thanh toán...')));

    try {
      // Create booking
      final booking = await ref
          .read(bookingProvider.notifier)
          .createBooking(
            scheduleId: _bookingData['trip']['id'],
            passengers: _bookingData['passengers'] is List
                ? List<Map<String, dynamic>>.from(_bookingData['passengers'])
                : <Map<String, dynamic>>[],
            selectedClass: _bookingData['selectedClass'] ?? 'economy',
            selectedSeats: _bookingData['selectedSeats'] is List
                ? List<String>.from(_bookingData['selectedSeats'])
                : <String>[],
            contactInfo: _bookingData['contactInfo'] is Map
                ? Map<String, dynamic>.from(_bookingData['contactInfo'])
                : <String, dynamic>{},
            paymentMethod: _bookingData['paymentMethod'],
          );

      if (booking != null) {
        _handlePaymentComplete(booking.pnr);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tạo booking thất bại. Vui lòng thử lại.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _handlePaymentComplete(String bookingId) {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đặt vé thành công! Mã đặt vé: $bookingId'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );

    // Navigate to booking success page or ticket details
    _navigateToBookingSuccess(bookingId);
  }

  void _navigateToBookingSuccess(String bookingId) {
    // Show success dialog with options
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        title: const Text('Đặt vé thành công!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Mã đặt vé: $bookingId'),
            const SizedBox(height: 8),
            const Text(
              'Vé của bạn đã được tạo thành công. Bạn có thể xem chi tiết vé hoặc quay về trang chủ.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(
                context,
              ).popUntil((route) => route.isFirst); // Go to home
            },
            child: const Text('Về trang chủ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _navigateToTicketDetails(bookingId);
            },
            child: const Text('Xem vé'),
          ),
        ],
      ),
    );
  }

  void _navigateToTicketDetails(String bookingId) {
    // Navigate to manage bookings page to see the new booking
    Navigator.of(context).popUntil((route) => route.isFirst);

    // Navigate to manage bookings page
    context.go('/manage');

    // TODO: In future, navigate to specific ticket details page
    // context.go('/tickets/$bookingId');
  }
}
