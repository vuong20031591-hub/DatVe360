import 'dart:typed_data';
import '../../../../core/network/dio_client.dart';

class TicketRepository {
  // ignore: unused_field
  final DioClient _dioClient;

  TicketRepository(this._dioClient);

  // Get ticket by booking ID
  Future<Map<String, dynamic>?> getTicketByBookingId(String bookingId) async {
    try {
      // TODO: Implement real API call
      // final response = await _dioClient.get('/tickets/booking/$bookingId');
      // return response.data;

      // For now, return mock ticket data
      return _getMockTicketData(bookingId);
    } catch (e) {
      throw Exception('Failed to get ticket: $e');
    }
  }

  // Generate QR code data
  Future<String> generateQRData(String bookingId) async {
    try {
      // TODO: Implement real QR generation
      // final response = await _dioClient.post('/tickets/$bookingId/qr');
      // return response.data['qr_data'];

      // For now, generate mock QR data
      return _generateMockQRData(bookingId);
    } catch (e) {
      throw Exception('Failed to generate QR code: $e');
    }
  }

  // Generate PDF ticket
  Future<Uint8List> generatePDF(String bookingId) async {
    try {
      // TODO: Implement real PDF generation
      // final response = await _dioClient.get('/tickets/$bookingId/pdf',
      //   options: Options(responseType: ResponseType.bytes));
      // return response.data;

      // For now, return empty PDF data
      throw UnimplementedError('PDF generation not implemented yet');
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

      // For now, return mock ticket history
      return _getMockTicketHistory(userId);
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

      // For now, simulate validation
      return _validateMockTicket(qrData);
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

  // Mock data methods
  Map<String, dynamic>? _getMockTicketData(String bookingId) {
    if (bookingId == 'DV360123') {
      return {
        'id': 'ticket_$bookingId',
        'booking_id': bookingId,
        'pnr': 'ABC123',
        'passenger_name': 'Nguyễn Văn A',
        'seat_number': '12A',
        'qr_data': _generateMockQRData(bookingId),
        'issued_at': DateTime.now().toIso8601String(),
        'trip': {
          'carrier': 'Vietnam Airlines',
          'flight_number': 'VN210',
          'from': 'Hà Nội (HAN)',
          'to': 'TP.HCM (SGN)',
          'depart_time': '06:00',
          'arrive_time': '08:15',
          'duration': '2h 15m',
          'depart_date': DateTime.now()
              .add(const Duration(days: 7))
              .toIso8601String(),
        },
        'status': 'active',
        'check_in_status': 'not_checked_in',
      };
    }

    return null;
  }

  String _generateMockQRData(String bookingId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'DATVE360|$bookingId|ABC123|Nguyễn Văn A|HAN|SGN|${DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch}|12A|Vietnam Airlines|$timestamp';
  }

  List<Map<String, dynamic>> _getMockTicketHistory(String userId) {
    return [
      {
        'id': 'ticket_DV360123',
        'booking_id': 'DV360123',
        'pnr': 'ABC123',
        'passenger_name': 'Nguyễn Văn A',
        'seat_number': '12A',
        'trip': {
          'carrier': 'Vietnam Airlines',
          'flight_number': 'VN210',
          'from': 'Hà Nội (HAN)',
          'to': 'TP.HCM (SGN)',
          'depart_time': '06:00',
          'arrive_time': '08:15',
          'depart_date': DateTime.now()
              .add(const Duration(days: 7))
              .toIso8601String(),
        },
        'status': 'active',
        'issued_at': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
      },
      {
        'id': 'ticket_DV360122',
        'booking_id': 'DV360122',
        'pnr': 'XYZ789',
        'passenger_name': 'Nguyễn Văn A',
        'seat_number': '8C',
        'trip': {
          'carrier': 'VietJet Air',
          'flight_number': 'VJ150',
          'from': 'TP.HCM (SGN)',
          'to': 'Đà Nẵng (DAD)',
          'depart_time': '14:30',
          'arrive_time': '15:45',
          'depart_date': DateTime.now()
              .subtract(const Duration(days: 15))
              .toIso8601String(),
        },
        'status': 'used',
        'issued_at': DateTime.now()
            .subtract(const Duration(days: 16))
            .toIso8601String(),
      },
    ];
  }

  Map<String, dynamic> _validateMockTicket(String qrData) {
    final parts = qrData.split('|');
    if (parts.length >= 10 && parts[0] == 'DATVE360') {
      return {
        'valid': true,
        'booking_id': parts[1],
        'pnr': parts[2],
        'passenger_name': parts[3],
        'from': parts[4],
        'to': parts[5],
        'depart_date': DateTime.fromMillisecondsSinceEpoch(
          int.parse(parts[6]),
        ).toIso8601String(),
        'seat': parts[7],
        'carrier': parts[8],
        'validated_at': DateTime.now().toIso8601String(),
      };
    }

    return {'valid': false, 'error': 'Invalid QR code format'};
  }
}
