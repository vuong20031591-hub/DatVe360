import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/app_button.dart';
import '../wizard/step_review.dart';
import '../wizard/step_passenger.dart';
import '../wizard/step_payment.dart';

class BookingPage extends ConsumerStatefulWidget {
  const BookingPage({
    super.key,
    this.trip,
    this.selectedSeats,
  });

  final Map<String, dynamic>? trip;
  final List<String>? selectedSeats;

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
            backgroundColor: theme.colorScheme.surfaceVariant,
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
              border: Border(
                bottom: BorderSide(color: theme.dividerColor),
              ),
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
                ),
              ],
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.dividerColor),
              ),
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
                    text: _currentStep == 2 ? 'Thanh toán' : 'Tiếp theo',
                    icon: _currentStep == 2 ? Icons.payment : Icons.arrow_forward,
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
                      : theme.colorScheme.surfaceVariant,
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
                  : theme.colorScheme.onSurface.withOpacity(0.6),
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

  void _processPayment() {
    // TODO: Process payment
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang xử lý thanh toán...'),
      ),
    );
  }

  void _handlePaymentComplete(String bookingId) {
    // TODO: Navigate to ticket page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đặt vé thành công! Mã đặt vé: $bookingId'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Navigate back to home or to ticket page
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
