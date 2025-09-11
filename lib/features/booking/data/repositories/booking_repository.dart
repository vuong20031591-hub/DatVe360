import '../../../../core/network/dio_client.dart';
import '../models/booking.dart';

class BookingRepository {
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
  Future<Booking> updateBooking(String bookingId, Map<String, dynamic> updates) async {
    try {
      // TODO: Implement real API call
      // final response = await _dioClient.put('/bookings/$bookingId', data: updates);
      // return Booking.fromJson(response.data);
      
      // For now, return updated mock booking
      final booking = await getBookingById(bookingId);
      if (booking == null) throw Exception('Booking not found');
      
      return booking.copyWith(
        status: updates['status'] ?? booking.status,
        updatedAt: DateTime.now(),
      );
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
  Future<Map<String, dynamic>> processPayment(String bookingId, Map<String, dynamic> paymentData) async {
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
    final bookingId = 'DV360${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    
    return Booking(
      id: bookingId,
      pnr: 'ABC123',
      status: BookingStatus.confirmed,
      tripId: bookingData['trip']?['id'] ?? 'unknown',
      passengers: List<Map<String, dynamic>>.from(bookingData['passengers'] ?? []),
      contactInfo: Map<String, dynamic>.from(bookingData['contactInfo'] ?? {}),
      selectedSeats: List<String>.from(bookingData['selectedSeats'] ?? []),
      totalPrice: bookingData['totalPrice'] ?? 1430000,
      paymentMethod: bookingData['paymentMethod'] ?? 'vnpay',
      paymentStatus: PaymentStatus.completed,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
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
          {'firstName': 'Văn A', 'lastName': 'Nguyễn', 'type': 'adult'},
        ],
        contactInfo: {
          'name': 'Nguyễn Văn A',
          'email': 'test@example.com',
          'phone': '0123456789',
        },
        selectedSeats: ['12A'],
        totalPrice: 1430000,
        paymentMethod: 'vnpay',
        paymentStatus: PaymentStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      );
    }
    
    return null;
  }

  List<Booking> _searchMockBookings(String bookingId, String email) {
    final booking = _getMockBookingById(bookingId);
    if (booking != null && booking.contactInfo['email'] == email) {
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
          {'firstName': 'Văn A', 'lastName': 'Nguyễn', 'type': 'adult'},
        ],
        contactInfo: {
          'name': 'Nguyễn Văn A',
          'email': 'user@example.com',
          'phone': '0123456789',
        },
        selectedSeats: ['12A'],
        totalPrice: 1430000,
        paymentMethod: 'vnpay',
        paymentStatus: PaymentStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Booking(
        id: 'DV360124',
        pnr: 'DEF456',
        status: BookingStatus.pending,
        tripId: 'VJ150_20241205_0730',
        passengers: [
          {'firstName': 'Thị B', 'lastName': 'Trần', 'type': 'adult'},
        ],
        contactInfo: {
          'name': 'Trần Thị B',
          'email': 'user@example.com',
          'phone': '0123456789',
        },
        selectedSeats: ['15C'],
        totalPrice: 999000,
        paymentMethod: 'momo',
        paymentStatus: PaymentStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }
}
