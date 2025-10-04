import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/payments_admin_service.dart';

// Service provider
final paymentsAdminServiceProvider = Provider<PaymentsAdminService>((ref) {
  return PaymentsAdminService();
});

// State class
class PaymentsAdminState {
  final List<dynamic> payments;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? stats;
  final int currentPage;
  final int totalPages;

  const PaymentsAdminState({
    this.payments = const [],
    this.isLoading = false,
    this.error,
    this.stats,
    this.currentPage = 1,
    this.totalPages = 1,
  });

  PaymentsAdminState copyWith({
    List<dynamic>? payments,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? stats,
    int? currentPage,
    int? totalPages,
    bool clearError = false,
  }) {
    return PaymentsAdminState(
      payments: payments ?? this.payments,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      stats: stats ?? this.stats,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

// Notifier
class PaymentsAdminNotifier extends Notifier<PaymentsAdminState> {
  late final PaymentsAdminService _service;

  @override
  PaymentsAdminState build() {
    _service = ref.read(paymentsAdminServiceProvider);
    Future.microtask(() => loadStats());
    return const PaymentsAdminState();
  }

  Future<void> loadPayments({
    String? status,
    String? paymentMethod,
    String? transactionId,
    int page = 1,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _service.getPayments(
        status: status,
        paymentMethod: paymentMethod,
        transactionId: transactionId,
        page: page,
      );

      state = state.copyWith(
        payments: result['data'] ?? [],
        isLoading: false,
        currentPage: result['pagination']?['page'] ?? 1,
        totalPages: result['pagination']?['pages'] ?? 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadStats() async {
    try {
      final stats = await _service.getPaymentStats();
      state = state.copyWith(stats: stats['data']);
    } catch (e) {
      // Ignore
    }
  }

  Future<bool> refundPayment(String paymentId, {
    double? refundAmount,
    String? refundReason,
  }) async {
    try {
      await _service.refundPayment(
        paymentId,
        refundAmount: refundAmount,
        refundReason: refundReason,
      );
      await loadPayments();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

// Provider
final paymentsAdminProvider = NotifierProvider<PaymentsAdminNotifier, PaymentsAdminState>(
  PaymentsAdminNotifier.new,
);
