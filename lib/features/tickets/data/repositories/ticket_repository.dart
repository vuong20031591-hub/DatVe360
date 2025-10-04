import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/ticket.dart';

class TicketRepository {
  // ignore: unused_field
  final DioClient _dioClient;

  TicketRepository(this._dioClient);

  // Get booking details by ID
  Future<Map<String, dynamic>?> getBookingById(String bookingId) async {
    try {
      final response = await _dioClient.get('/bookings/$bookingId');
      if (response.data['success'] == true) {
        return response.data['data']['booking'];
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get booking: $e');
    }
  }

  // Get tickets by booking ID
  Future<List<Map<String, dynamic>>> getTicketsByBookingId(
    String bookingId,
  ) async {
    try {
      final response = await _dioClient.get('/bookings/$bookingId/tickets');
      if (response.data['success'] == true) {
        final tickets = response.data['data']['tickets'] as List;
        return tickets.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get tickets: $e');
    }
  }

  // Get ticket by booking ID (legacy method - now uses booking + tickets)
  Future<Map<String, dynamic>?> getTicketByBookingId(String bookingId) async {
    try {
      final booking = await getBookingById(bookingId);
      final tickets = await getTicketsByBookingId(bookingId);

      if (booking != null) {
        return {'booking': booking, 'tickets': tickets};
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get ticket: $e');
    }
  }

  // Generate QR code data
  Future<String> generateQRData(String bookingId) async {
    try {
      final response = await _dioClient.post('/tickets/$bookingId/qr');
      return response.data['qr_data'];
    } catch (e) {
      throw Exception('Failed to generate QR code: $e');
    }
  }

  // Generate PDF ticket
  Future<Uint8List> generatePDF(String bookingId) async {
    try {
      final response = await _dioClient.get(
        '/tickets/$bookingId/pdf',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to generate PDF: $e');
    }
  }

  // Send ticket via email
  Future<bool> sendTicketEmail(String bookingId, String email) async {
    try {
      final response = await _dioClient.post(
        '/tickets/$bookingId/email',
        data: {'email': email},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Gửi email thất bại');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy vé');
      }
      throw Exception('Lỗi kết nối: ${e.message}');
    } catch (e) {
      throw Exception('Failed to send ticket email: $e');
    }
  }

  // Get ticket history for user
  Future<List<Map<String, dynamic>>> getTicketHistory(String userId) async {
    try {
      final response = await _dioClient.get('/tickets/history/$userId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> ticketsData =
            response.data['data']['tickets'] ?? [];
        return List<Map<String, dynamic>>.from(ticketsData);
      } else {
        return [];
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // No tickets found
      }
      throw Exception('Lỗi kết nối: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get ticket history: $e');
    }
  }

  // Validate ticket QR code
  Future<Map<String, dynamic>> validateTicket(String qrData) async {
    try {
      final response = await _dioClient.post(
        '/tickets/validate',
        data: {'qrData': qrData},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        return {
          'valid': false,
          'error': response.data['message'] ?? 'Vé không hợp lệ',
        };
      }
    } on DioException catch (e) {
      return {
        'valid': false,
        'error': e.response?.data['message'] ?? 'Lỗi xác thực vé',
      };
    } catch (e) {
      throw Exception('Failed to validate ticket: $e');
    }
  }

  // Check-in passenger
  Future<bool> checkInPassenger(String bookingId, String passengerId) async {
    try {
      final response = await _dioClient.post(
        '/tickets/$bookingId/checkin',
        data: {'passengerId': passengerId},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Check-in thất bại');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy vé hoặc hành khách');
      } else if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['message'] ?? 'Không thể check-in');
      }
      throw Exception('Lỗi kết nối: ${e.message}');
    } catch (e) {
      throw Exception('Failed to check-in passenger: $e');
    }
  }
}
