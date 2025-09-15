import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/models/booking.dart';

// Booking repository provider
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(DioClient.instance);
});

// Booking state
class BookingState {
  final bool isLoading;
  final String? error;
  final Booking? currentBooking;
  final List<Booking> userBookings;

  const BookingState({
    this.isLoading = false,
    this.error,
    this.currentBooking,
    this.userBookings = const [],
  });

  BookingState copyWith({
    bool? isLoading,
    String? error,
    Booking? currentBooking,
    List<Booking>? userBookings,
  }) {
    return BookingState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentBooking: currentBooking ?? this.currentBooking,
      userBookings: userBookings ?? this.userBookings,
    );
  }
}

// Booking provider
class BookingNotifier extends Notifier<BookingState> {
  @override
  BookingState build() {
    return const BookingState();
  }

  BookingRepository get _repository => ref.read(bookingRepositoryProvider);

  /// Create a new booking
  Future<Booking?> createBooking({
    required String scheduleId,
    required List<Map<String, dynamic>> passengers,
    required String selectedClass,
    required List<String> selectedSeats,
    required Map<String, dynamic> contactInfo,
    required String paymentMethod,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final bookingData = {
        'scheduleId': scheduleId,
        'passengers': passengers,
        'selectedClass': selectedClass,
        'selectedSeats': selectedSeats,
        'contactInfo': contactInfo,
        'paymentMethod': paymentMethod,
      };

      final booking = await _repository.createBooking(bookingData);
      
      state = state.copyWith(
        isLoading: false,
        currentBooking: booking,
      );

      return booking;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Get booking by ID
  Future<Booking?> getBookingById(String bookingId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final booking = await _repository.getBookingById(bookingId);
      
      state = state.copyWith(
        isLoading: false,
        currentBooking: booking,
      );

      return booking;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Search bookings by booking ID and email
  Future<List<Booking>> searchBookings(String bookingId, String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final bookings = await _repository.searchBookings(bookingId, email);
      
      state = state.copyWith(
        isLoading: false,
        userBookings: bookings,
      );

      return bookings;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return [];
    }
  }

  /// Get user bookings
  Future<List<Booking>> getUserBookings(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final bookings = await _repository.getUserBookings(userId);
      
      state = state.copyWith(
        isLoading: false,
        userBookings: bookings,
      );

      return bookings;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return [];
    }
  }

  /// Cancel booking
  Future<bool> cancelBooking(String bookingId, String reason) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _repository.cancelBooking(bookingId, reason);
      
      if (success) {
        // Refresh user bookings
        // Note: This would need userId from auth state
        // await getUserBookings(userId);
      }

      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Process payment
  Future<Map<String, dynamic>?> processPayment(
    String bookingId,
    Map<String, dynamic> paymentData,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.processPayment(bookingId, paymentData);
      
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear current booking
  void clearCurrentBooking() {
    state = state.copyWith(currentBooking: null);
  }
}

// Booking provider instance
final bookingProvider = NotifierProvider<BookingNotifier, BookingState>(() {
  return BookingNotifier();
});
