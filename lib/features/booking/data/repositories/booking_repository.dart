import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/booking.dart';
import '../models/booking_exception.dart';

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
            throw BookingException(
              'Failed to parse booking data: $parseError',
              type: BookingErrorType.parseError,
            );
          }
        } else {
          print('Response data: ${response.data}');
          throw BookingException(
            'Booking data is null in response',
            type: BookingErrorType.invalidResponse,
          );
        }
      } else {
        print(
          'API Error - Success: ${response.data['success']}, Message: ${response.data['message']}',
        );
        throw BookingException(
          response.data['message'] ?? 'Tạo booking thất bại',
          type: BookingErrorType.apiError,
        );
      }
    } on DioException catch (e) {
      // Handle DioException specifically
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data['message'] ?? e.message;

        // Race condition: 409 Conflict
        if (statusCode == 409) {
          throw BookingException(
            message ?? 'Ghế đã được đặt bởi người khác, vui lòng thử lại',
            type: BookingErrorType.conflict,
            canRetry: true,
          );
        }

        // Validation error: 400 Bad Request
        if (statusCode == 400) {
          throw BookingException(
            message ?? 'Dữ liệu không hợp lệ',
            type: BookingErrorType.validation,
          );
        }

        // Not found: 404
        if (statusCode == 404) {
          throw BookingException(
            message ?? 'Không tìm thấy lịch trình',
            type: BookingErrorType.notFound,
          );
        }

        // Server error: 500+
        if (statusCode != null && statusCode >= 500) {
          throw BookingException(
            message ?? 'Lỗi máy chủ, vui lòng thử lại sau',
            type: BookingErrorType.serverError,
            canRetry: true,
          );
        }
      }

      // Network error
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw BookingException(
          'Kết nối timeout, vui lòng thử lại',
          type: BookingErrorType.timeout,
          canRetry: true,
        );
      }

      if (e.type == DioExceptionType.connectionError) {
        throw BookingException(
          'Không thể kết nối đến máy chủ',
          type: BookingErrorType.network,
          canRetry: true,
        );
      }

      // Unknown error
      throw BookingException(
        'Lỗi không xác định: ${e.message}',
        type: BookingErrorType.unknown,
      );
    } catch (e) {
      // Log the full error for debugging
      print('BookingRepository.createBooking error: $e');

      // Re-throw BookingException
      if (e is BookingException) {
        rethrow;
      }

      throw BookingException(
        'Failed to create booking: $e',
        type: BookingErrorType.unknown,
      );
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
      final response = await _dioClient.post(
        '/bookings/$bookingId/cancel',
        data: {'reason': reason},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Hủy đặt vé thất bại');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data['message'] ?? e.message;

        // Race condition: 409 Conflict - booking đã bị hủy
        if (statusCode == 409) {
          throw BookingException(
            message ?? 'Đặt vé đã bị hủy hoặc không thể hủy',
            type: BookingErrorType.conflict,
            canRetry: false,
          );
        }

        // Not found: 404
        if (statusCode == 404) {
          throw BookingException(
            message ?? 'Không tìm thấy booking',
            type: BookingErrorType.notFound,
          );
        }

        // Bad request: 400
        if (statusCode == 400) {
          throw BookingException(
            message ?? 'Không thể hủy booking này',
            type: BookingErrorType.validation,
          );
        }
      }

      throw BookingException(
        'Lỗi kết nối: ${e.message}',
        type: BookingErrorType.network,
        canRetry: true,
      );
    } catch (e) {
      if (e is BookingException) rethrow;
      throw BookingException(
        'Failed to cancel booking: $e',
        type: BookingErrorType.unknown,
      );
    }
  }

  // Update booking
  Future<Booking> updateBooking(
    String bookingId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _dioClient.put(
        '/bookings/$bookingId',
        data: updates,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final bookingData = response.data['data']['booking'];
        return Booking.fromJson(bookingData);
      } else {
        throw Exception(
          response.data['message'] ?? 'Cập nhật booking thất bại',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy booking');
      } else if (e.response?.statusCode == 400) {
        throw Exception(
          e.response?.data['message'] ?? 'Dữ liệu cập nhật không hợp lệ',
        );
      }
      throw Exception('Lỗi kết nối: ${e.message}');
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

        print('🔍 DEBUG: Parsing ${bookingsData.length} bookings');
        final bookings = <Booking>[];
        for (var i = 0; i < bookingsData.length; i++) {
          try {
            print('🔍 DEBUG: Parsing booking $i');
            final booking = Booking.fromJson(bookingsData[i]);
            bookings.add(booking);
            print('✅ DEBUG: Booking $i parsed successfully');
          } catch (e, stack) {
            print('❌ DEBUG: Error parsing booking $i: $e');
            print('📋 DEBUG: Booking data: ${bookingsData[i]}');
            print('📋 DEBUG: Stack trace: $stack');
            rethrow;
          }
        }
        return bookings;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get user bookings: $e');
    }
  }

  // Process payment (generic payment processing, not VNPay specific)
  Future<Map<String, dynamic>> processPayment(
    String bookingId,
    Map<String, dynamic> paymentData,
  ) async {
    try {
      final response = await _dioClient.post(
        '/payments/process',
        data: {'bookingId': bookingId, ...paymentData},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(
          response.data['message'] ?? 'Xử lý thanh toán thất bại',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy booking');
      } else if (e.response?.statusCode == 400) {
        throw Exception(
          e.response?.data['message'] ?? 'Thông tin thanh toán không hợp lệ',
        );
      }
      throw Exception('Lỗi kết nối: ${e.message}');
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

  // Create MoMo payment
  Future<Map<String, dynamic>> createMoMoPayment({
    required String bookingId,
  }) async {
    try {
      final paymentData = <String, dynamic>{
        'bookingId': bookingId,
        'paymentMethod': 'momo',
      };

      final response = await _dioClient.post(
        '/payments/momo/create',
        data: paymentData,
      );

      if (response.data['success'] == true) {
        return response.data;
      } else {
        throw Exception(
          response.data['message'] ?? 'Tạo thanh toán MoMo thất bại',
        );
      }
    } catch (e) {
      throw Exception('Failed to create MoMo payment: $e');
    }
  }

  // Create Stripe payment (Visa/MasterCard)
  Future<Map<String, dynamic>> createStripePayment({
    required String bookingId,
  }) async {
    try {
      final paymentData = <String, dynamic>{
        'bookingId': bookingId,
        'paymentMethod': 'stripe',
      };

      final response = await _dioClient.post(
        '/payments/stripe/create',
        data: paymentData,
      );

      if (response.data['success'] == true) {
        return response.data;
      } else {
        throw Exception(
          response.data['message'] ?? 'Tạo Payment Intent thất bại',
        );
      }
    } catch (e) {
      throw Exception('Failed to create Stripe payment: $e');
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
