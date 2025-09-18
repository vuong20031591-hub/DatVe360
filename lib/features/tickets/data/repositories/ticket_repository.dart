import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

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
      // TODO: Implement real email sending
      // final response = await _dioClient.post('/tickets/$bookingId/email',
      //   data: {'email': email});
      // return response.data['success'] ?? false;

      // For now, simulate email sending
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      throw Exception('Failed to send ticket email: $e');
    }
  }

  // Get ticket history for user
  Future<List<Map<String, dynamic>>> getTicketHistory(String userId) async {
    try {
      // TODO: Implement real API call
      // final response = await _dioClient.get('/users/$userId/tickets');
      // return List<Map<String, dynamic>>.from(response.data['tickets']);

      // For now, return empty list
      return [];
    } catch (e) {
      throw Exception('Failed to get ticket history: $e');
    }
  }

  // Validate ticket QR code
  Future<Map<String, dynamic>> validateTicket(String qrData) async {
    try {
      // TODO: Implement real ticket validation
      // final response = await _dioClient.post('/tickets/validate',
      //   data: {'qr_data': qrData});
      // return response.data;

      // For now, return invalid
      return {'valid': false, 'error': 'Validation not implemented'};
    } catch (e) {
      throw Exception('Failed to validate ticket: $e');
    }
  }

  // Check-in passenger
  Future<bool> checkInPassenger(String bookingId, String passengerId) async {
    try {
      // TODO: Implement real check-in
      // final response = await _dioClient.post('/tickets/$bookingId/checkin',
      //   data: {'passenger_id': passengerId});
      // return response.data['success'] ?? false;

      // For now, simulate check-in
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      throw Exception('Failed to check-in passenger: $e');
    }
  }
}
