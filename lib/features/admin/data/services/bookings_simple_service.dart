import '../../../../core/network/dio_client.dart';
import '../models/booking_simple.dart';

class BookingsSimpleService {
  final DioClient _dioClient;

  BookingsSimpleService(this._dioClient);

  Future<Map<String, dynamic>> getBookings({
    String? status,
    String? pnr,
    String? email,
    String? phone,
    String? fromDate,
    String? toDate,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (status != null) queryParams['status'] = status;
    if (pnr != null) queryParams['pnr'] = pnr;
    if (email != null) queryParams['email'] = email;
    if (phone != null) queryParams['phone'] = phone;
    if (fromDate != null) queryParams['fromDate'] = fromDate;
    if (toDate != null) queryParams['toDate'] = toDate;

    final response = await _dioClient.get(
      '/admin/bookings',
      queryParameters: queryParams,
    );

    final bookings = (response.data['data'] as List)
        .map((json) => BookingSimple.fromJson(json))
        .toList();

    return {
      'bookings': bookings,
      'pagination': response.data['pagination'],
    };
  }

  Future<BookingSimple> getBookingById(String id) async {
    final response = await _dioClient.get('/admin/bookings/$id');
    return BookingSimple.fromJson(response.data['data']);
  }

  Future<BookingStatsSimple> getStats({
    String? fromDate,
    String? toDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (fromDate != null) queryParams['fromDate'] = fromDate;
    if (toDate != null) queryParams['toDate'] = toDate;

    final response = await _dioClient.get(
      '/admin/bookings/stats',
      queryParameters: queryParams,
    );

    return BookingStatsSimple.fromJson(response.data['data']);
  }

  Future<BookingSimple> confirmBooking(String id) async {
    final response = await _dioClient.put('/admin/bookings/$id/confirm');
    return BookingSimple.fromJson(response.data['data']);
  }

  Future<BookingSimple> cancelBooking(String id, String reason) async {
    final response = await _dioClient.put(
      '/admin/bookings/$id/cancel',
      data: {'reason': reason},
    );
    return BookingSimple.fromJson(response.data['data']);
  }

  Future<BookingSimple> completeBooking(String id) async {
    final response = await _dioClient.put('/admin/bookings/$id/complete');
    return BookingSimple.fromJson(response.data['data']);
  }

  Future<void> deleteBooking(String id) async {
    await _dioClient.delete('/admin/bookings/$id');
  }
}

