import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/reports_admin_service.dart';

// Service provider
final reportsAdminServiceProvider = Provider<ReportsAdminService>((ref) {
  return ReportsAdminService();
});

// State class
class ReportsAdminState {
  final Map<String, dynamic>? dashboardStats;
  final List<dynamic>? bookingStats;
  final List<dynamic>? revenueStats;
  final List<dynamic>? popularRoutes;
  final bool isLoading;
  final String? error;

  const ReportsAdminState({
    this.dashboardStats,
    this.bookingStats,
    this.revenueStats,
    this.popularRoutes,
    this.isLoading = false,
    this.error,
  });

  ReportsAdminState copyWith({
    Map<String, dynamic>? dashboardStats,
    List<dynamic>? bookingStats,
    List<dynamic>? revenueStats,
    List<dynamic>? popularRoutes,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ReportsAdminState(
      dashboardStats: dashboardStats ?? this.dashboardStats,
      bookingStats: bookingStats ?? this.bookingStats,
      revenueStats: revenueStats ?? this.revenueStats,
      popularRoutes: popularRoutes ?? this.popularRoutes,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Notifier
class ReportsAdminNotifier extends Notifier<ReportsAdminState> {
  late final ReportsAdminService _service;

  @override
  ReportsAdminState build() {
    _service = ref.read(reportsAdminServiceProvider);
    return const ReportsAdminState();
  }

  Future<void> loadDashboardStats() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _service.getDashboardStats();
      state = state.copyWith(
        dashboardStats: result['data'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadBookingStats({
    DateTime? fromDate,
    DateTime? toDate,
    String groupBy = 'day',
  }) async {
    try {
      final result = await _service.getBookingStats(
        fromDate: fromDate,
        toDate: toDate,
        groupBy: groupBy,
      );
      state = state.copyWith(bookingStats: result['data']);
    } catch (e) {
      // Ignore
    }
  }

  Future<void> loadRevenueStats({
    DateTime? fromDate,
    DateTime? toDate,
    String groupBy = 'day',
  }) async {
    try {
      final result = await _service.getRevenueStats(
        fromDate: fromDate,
        toDate: toDate,
        groupBy: groupBy,
      );
      
      if (result['data'] != null) {
        final byDate = result['data']['byDate'] ?? [];
        state = state.copyWith(revenueStats: byDate);
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> loadPopularRoutes({int limit = 10}) async {
    try {
      final result = await _service.getPopularRoutes(limit: limit);
      state = state.copyWith(popularRoutes: result['data']);
    } catch (e) {
      // Ignore
    }
  }

  void setPeriod(String period) {
    // Calculate date range based on period
    final now = DateTime.now();
    DateTime? fromDate;
    DateTime? toDate = now;
    String groupBy = 'day';

    switch (period) {
      case 'today':
        fromDate = DateTime(now.year, now.month, now.day);
        groupBy = 'day';
        break;
      case 'week':
        fromDate = now.subtract(const Duration(days: 7));
        groupBy = 'day';
        break;
      case 'month':
        fromDate = DateTime(now.year, now.month, 1);
        groupBy = 'day';
        break;
      case 'year':
        fromDate = DateTime(now.year, 1, 1);
        groupBy = 'month';
        break;
    }

    // Load data for the selected period
    loadRevenueStats(fromDate: fromDate, toDate: toDate, groupBy: groupBy);
    loadBookingStats(fromDate: fromDate, toDate: toDate, groupBy: groupBy);
  }

  Future<Map<String, dynamic>?> exportReport({
    required String type,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final result = await _service.exportReport(
        type: type,
        fromDate: fromDate,
        toDate: toDate,
      );
      return result;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}

// Provider
final reportsAdminProvider = NotifierProvider<ReportsAdminNotifier, ReportsAdminState>(
  ReportsAdminNotifier.new,
);
