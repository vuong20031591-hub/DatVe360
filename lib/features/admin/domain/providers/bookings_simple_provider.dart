import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/models/booking_simple.dart';
import '../../data/services/bookings_simple_service.dart';

// Service provider
final bookingsSimpleServiceProvider = Provider<BookingsSimpleService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return BookingsSimpleService(dioClient);
});

// State class
class BookingsSimpleState {
  final List<BookingSimple> bookings;
  final BookingStatsSimple? stats;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? pagination;
  final String? selectedStatus;
  final String? searchQuery;

  BookingsSimpleState({
    this.bookings = const [],
    this.stats,
    this.isLoading = false,
    this.error,
    this.pagination,
    this.selectedStatus,
    this.searchQuery,
  });

  BookingsSimpleState copyWith({
    List<BookingSimple>? bookings,
    BookingStatsSimple? stats,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? pagination,
    String? selectedStatus,
    String? searchQuery,
  }) {
    return BookingsSimpleState(
      bookings: bookings ?? this.bookings,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pagination: pagination ?? this.pagination,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Notifier
class BookingsSimpleNotifier extends Notifier<BookingsSimpleState> {
  @override
  BookingsSimpleState build() {
    // Don't auto-load on initialization
    // Let the UI trigger the initial load after authentication
    return BookingsSimpleState();
  }

  Future<void> loadBookings({
    String? status,
    String? searchQuery,
    int page = 1,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(bookingsSimpleServiceProvider);
      final result = await service.getBookings(
        status: status,
        pnr: searchQuery,
        email: searchQuery,
        phone: searchQuery,
        page: page,
      );

      state = state.copyWith(
        bookings: result['bookings'] as List<BookingSimple>,
        pagination: result['pagination'] as Map<String, dynamic>,
        isLoading: false,
        selectedStatus: status,
        searchQuery: searchQuery,
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
      final service = ref.read(bookingsSimpleServiceProvider);
      final stats = await service.getStats();
      state = state.copyWith(stats: stats);
    } catch (e) {
      // Ignore stats error
    }
  }

  Future<void> confirmBooking(String id) async {
    try {
      final service = ref.read(bookingsSimpleServiceProvider);
      await service.confirmBooking(id);
      // Reload all bookings to see the updated status
      await loadBookings(searchQuery: state.searchQuery);
      await loadStats();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> cancelBooking(String id, String reason) async {
    try {
      final service = ref.read(bookingsSimpleServiceProvider);
      await service.cancelBooking(id, reason);
      // Reload all bookings to see the updated status
      await loadBookings(searchQuery: state.searchQuery);
      await loadStats();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> completeBooking(String id) async {
    try {
      final service = ref.read(bookingsSimpleServiceProvider);
      await service.completeBooking(id);
      // Reload all bookings to see the updated status
      await loadBookings(searchQuery: state.searchQuery);
      await loadStats();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteBooking(String id) async {
    try {
      final service = ref.read(bookingsSimpleServiceProvider);
      await service.deleteBooking(id);
      await loadBookings(
        status: state.selectedStatus,
        searchQuery: state.searchQuery,
      );
      await loadStats();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void setFilter(String? status) {
    loadBookings(status: status, searchQuery: state.searchQuery);
  }

  void setSearch(String? query) {
    loadBookings(status: state.selectedStatus, searchQuery: query);
  }

  void refresh() {
    loadBookings(
      status: state.selectedStatus,
      searchQuery: state.searchQuery,
    );
    loadStats();
  }
}

// Provider
final bookingsSimpleProvider =
    NotifierProvider<BookingsSimpleNotifier, BookingsSimpleState>(
  BookingsSimpleNotifier.new,
);

