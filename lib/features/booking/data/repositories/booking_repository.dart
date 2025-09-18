import '../../../../core/network/dio_client.dart';
import '../models/booking.dart';

class BookingRepository {
  // ignore: unused_field
  final DioClient _dioClient;

  BookingRepository(this._dioClient);

  // Create a new booking
  Future<Booking> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final response = await _dioClient.post('/bookings', data: bookingData);

      if (response.data['success'] == true && response.data['data'] != null) {
        final bookingJson = response.data['data']['booking'];
        if (bookingJson != null) {
          try {
            return Booking.fromJson(bookingJson);
          } catch (parseError) {
            print('Booking.fromJson error: $parseError');
            print('Booking JSON: $bookingJson');
            throw Exception('Failed to parse booking data: $parseError');
          }
        } else {
          print('Response data: ${response.data}');
          throw Exception('Booking data is null in response');
        }
      } else {
        print(
          'API Error - Success: ${response.data['success']}, Message: ${response.data['message']}',
        );
        throw Exception(response.data['message'] ?? 'Tạo booking thất bại');
      }
    } catch (e) {
      // Log the full error for debugging
      print('BookingRepository.createBooking error: $e');
      if (e.toString().contains('Failed to create booking:') ||
          e.toString().contains('Failed to parse booking data:') ||
          e.toString().contains('Booking data is null')) {
        rethrow;
      }
      throw Exception('Failed to create booking: $e');
    }
  }

  // Get booking by ID
  Future<Booking?> getBookingById(String bookingId) async {
    try {
      final response = await _dioClient.get('/bookings/$bookingId');

      if (response.data['success'] == true && response.data['data'] != null) {
        return Booking.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get booking: $e');
    }
  }

  // Search bookings by booking ID and email
  Future<List<Booking>> searchBookings(String bookingId, String email) async {
    try {
      final response = await _dioClient.get(
        '/bookings/search',
        queryParameters: {'booking_id': bookingId, 'email': email},
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> bookingsData =
            response.data['data']['bookings'] ?? [];
        return bookingsData.map((json) => Booking.fromJson(json)).toList();
      }
      return [];
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
      final response = await _dioClient.get('/bookings');

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> bookingsData =
            response.data['data']['bookings'] ?? [];
        return bookingsData.map((json) => Booking.fromJson(json)).toList();
      }
      return [];
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

  // Create VNPay payment using new library-based service
  Future<Map<String, dynamic>> createVNPayPayment({
    required String bookingId,
    String? bankCode,
  }) async {
    try {
      final paymentData = <String, dynamic>{
        'bookingId': bookingId,
        'paymentMethod': 'vnpay',
      };

      if (bankCode != null && bankCode.isNotEmpty) {
        paymentData['bankCode'] = bankCode;
      }

      final response = await _dioClient.post(
        '/payments/vnpay/create',
        data: paymentData,
      );

      if (response.data['success'] == true) {
        return response.data;
      } else {
        throw Exception(
          response.data['message'] ?? 'Tạo thanh toán VNPay thất bại',
        );
      }
    } catch (e) {
      throw Exception('Failed to create VNPay payment: $e');
    }
  }

  // Get VNPay bank list
  Future<List<Map<String, dynamic>>> getVNPayBankList() async {
    try {
      final response = await _dioClient.get('/payments/banks');

      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      } else {
        throw Exception(
          response.data['message'] ?? 'Lấy danh sách ngân hàng thất bại',
        );
      }
    } catch (e) {
      throw Exception('Failed to get bank list: $e');
    }
  }
}
