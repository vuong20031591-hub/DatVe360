import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/booking.dart';

class BookingRepository {
  // ignore: unused_field
  final DioClient _dioClient;

  BookingRepository(this._dioClient);

  // Create a new booking
  Future<Booking> createBooking(Map<String, dynamic> bookingData) async {
    try {
      // TODO: Implement real API call
      // final response = await _dioClient.post('/bookings', data: bookingData);
      // return Booking.fromJson(response.data);

      // For now, create mock booking
      return _createMockBooking(bookingData);
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // Get booking by ID
  Future<Booking?> getBookingById(String bookingId) async {
    try {
      // TODO: Implement real API call
      // final response = await _dioClient.get('/bookings/$bookingId');
      // return Booking.fromJson(response.data);

      // For now, return mock booking
      return _getMockBookingById(bookingId);
    } catch (e) {
      throw Exception('Failed to get booking: $e');
    }
  }

  // Search bookings by booking ID and email
  Future<List<Booking>> searchBookings(String bookingId, String email) async {
    try {
      // TODO: Implement real API call
      // final response = await _dioClient.get('/bookings/search',
      //   queryParameters: {'booking_id': bookingId, 'email': email});
      // final List<dynamic> data = response.data['bookings'];
      // return data.map((json) => Booking.fromJson(json)).toList();

      // For now, return mock search results
      return _searchMockBookings(bookingId, email);
    } catch (e) {
      throw Exception('Failed to search bookings: $e');
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(String bookingId, String reason) async {
    try {
      // TODO: Implement real API call
      // final response = await _dioClient.post('/bookings/$bookingId/cancel',
      //   data: {'reason': reason});
      // return response.data['success'] ?? false;

      // For now, simulate cancellation
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // Update booking
  Future<Booking> updateBooking(
    String bookingId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // TODO: Implement real API call
      // final response = await _dioClient.put('/bookings/$bookingId', data: updates);
      // return Booking.fromJson(response.data);

      // For now, return updated mock booking
      final booking = await getBookingById(bookingId);
      if (booking == null) throw Exception('Booking not found');

      return booking.copyWith(status: updates['status'] ?? booking.status);
    } catch (e) {
      throw Exception('Failed to update booking: $e');
    }
  }

  // Get user bookings
  Future<List<Booking>> getUserBookings(String userId) async {
    try {
      // TODO: Implement real API call
      // final response = await _dioClient.get('/users/$userId/bookings');
      // final List<dynamic> data = response.data['bookings'];
      // return data.map((json) => Booking.fromJson(json)).toList();

      // For now, return mock user bookings
      return _getMockUserBookings(userId);
    } catch (e) {
      throw Exception('Failed to get user bookings: $e');
    }
  }

  // Process payment
  Future<Map<String, dynamic>> processPayment(
    String bookingId,
    Map<String, dynamic> paymentData,
  ) async {
    try {
      // TODO: Implement real payment processing
      // final response = await _dioClient.post('/bookings/$bookingId/payment', data: paymentData);
      // return response.data;

      // For now, simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      return {
        'success': true,
        'transaction_id': 'TXN_${DateTime.now().millisecondsSinceEpoch}',
        'payment_method': paymentData['payment_method'],
        'amount': paymentData['amount'],
        'status': 'completed',
        'processed_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to process payment: $e');
    }
  }

  // Mock data methods
  Booking _createMockBooking(Map<String, dynamic> bookingData) {
    final bookingId =
        'DV360${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    // Convert passengers from Map to Passenger objects
    final passengersList =
        (bookingData['passengers'] as List?)
            ?.map((p) => Passenger.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];

    return Booking(
      id: bookingId,
      pnr: 'ABC123',
      status: BookingStatus.confirmed,
      tripId: bookingData['trip']?['id'] ?? 'unknown',
      passengers: passengersList,
      selectedClass: bookingData['selectedClass'] ?? 'economy',
      selectedSeats: List<String>.from(bookingData['selectedSeats'] ?? []),
      totalPrice: (bookingData['totalPrice'] ?? 1430000).toDouble(),
      currency: bookingData['currency'] ?? 'VND',
      createdAt: DateTime.now(),
    );
  }

  Booking? _getMockBookingById(String bookingId) {
    // Simulate finding booking
    if (bookingId == 'DV360123') {
      return Booking(
        id: bookingId,
        pnr: 'ABC123',
        status: BookingStatus.confirmed,
        tripId: 'VN210_20241201_0600',
        passengers: [
          Passenger(
            id: 'p1',
            firstName: 'Văn A',
            lastName: 'Nguyễn',
            type: PassengerType.adult,
            documentType: 'passport',
            documentId: 'A1234567',
            dateOfBirth: DateTime(1990, 1, 1),
            gender: 'male',
            nationality: 'VN',
          ),
        ],
        selectedClass: 'economy',
        selectedSeats: ['12A'],
        totalPrice: 1430000,
        currency: 'VND',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      );
    }

    return null;
  }

  List<Booking> _searchMockBookings(String bookingId, String email) {
    final booking = _getMockBookingById(bookingId);
    if (booking != null) {
      // For mock data, just return the booking if found
      return [booking];
    }
    return [];
  }

  List<Booking> _getMockUserBookings(String userId) {
    return [
      Booking(
        id: 'DV360123',
        pnr: 'ABC123',
        status: BookingStatus.confirmed,
        tripId: 'VN210_20241201_0600',
        passengers: [
          Passenger(
            id: 'p1',
            firstName: 'Văn A',
            lastName: 'Nguyễn',
            type: PassengerType.adult,
            documentType: 'passport',
            documentId: 'A1234567',
            dateOfBirth: DateTime(1990, 1, 1),
            gender: 'male',
            nationality: 'VN',
          ),
        ],
        selectedClass: 'economy',
        selectedSeats: ['12A'],
        totalPrice: 1430000,
        currency: 'VND',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Booking(
        id: 'DV360124',
        pnr: 'DEF456',
        status: BookingStatus.pending,
        tripId: 'VJ150_20241205_0730',
        passengers: [
          Passenger(
            id: 'p2',
            firstName: 'Thị B',
            lastName: 'Trần',
            type: PassengerType.adult,
            documentType: 'passport',
            documentId: 'B7654321',
            dateOfBirth: DateTime(1985, 5, 15),
            gender: 'female',
            nationality: 'VN',
          ),
        ],
        selectedClass: 'economy',
        selectedSeats: ['15C'],
        totalPrice: 999000,
        currency: 'VND',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }
}
