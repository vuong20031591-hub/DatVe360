import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../network/dio_client.dart';
import '../storage/storage_service.dart';

/// Centralized API service for DatVe360 backend
class ApiService {
  static ApiService? _instance;
  late DioClient _dioClient;
  late StorageService _storage;

  ApiService._internal() {
    _dioClient = DioClient.instance;
    _storage = StorageService.instance;
  }

  static ApiService get instance {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  // Auth token management
  Future<void> setAuthToken(String token) async {
    await _storage.write('auth_token', token);
    _dioClient.updateAuthToken(token);
  }

  Future<void> clearAuthToken() async {
    await _storage.delete('auth_token');
    _dioClient.clearAuthToken();
  }

  Future<String?> getAuthToken() async {
    return await _storage.read('auth_token');
  }

  // Auth endpoints
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
  }) async {
    try {
      final response = await _dioClient.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'displayName': displayName,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
        },
      );

      final data = response.data;
      if (data['success'] == true && data['data']['tokens'] != null) {
        await setAuthToken(data['data']['tokens']['accessToken']);
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await _dioClient.post(
        '/auth/login',
        data: {'email': email, 'password': password, 'rememberMe': rememberMe},
      );

      final data = response.data;
      if (data['success'] == true && data['data']['tokens'] != null) {
        await setAuthToken(data['data']['tokens']['accessToken']);
        await _storage.write(
          'refresh_token',
          data['data']['tokens']['refreshToken'],
        );
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _storage.read('refresh_token');
      await _dioClient.post(
        '/auth/logout',
        data: {if (refreshToken != null) 'refreshToken': refreshToken},
      );
    } finally {
      await clearAuthToken();
      await _storage.delete('refresh_token');
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _dioClient.get('/auth/me');
    return response.data;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _dioClient.put('/auth/profile', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _dioClient.post(
      '/auth/change-password',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
    return response.data;
  }

  // Search endpoints
  Future<Map<String, dynamic>> searchSchedules({
    required String from,
    required String to,
    required String departureDate,
    String? returnDate,
    int passengers = 1,
    String? className,
    double? maxPrice,
    String sortBy = 'departureTime',
    String? transportType,
    int limit = 50,
    int page = 1,
  }) async {
    final response = await _dioClient.get(
      '/schedules/search',
      queryParameters: {
        'from': from,
        'to': to,
        'departureDate': departureDate,
        if (returnDate != null) 'returnDate': returnDate,
        'passengers': passengers,
        if (className != null) 'class': className,
        if (maxPrice != null) 'maxPrice': maxPrice,
        'sortBy': sortBy,
        if (transportType != null) 'transportType': transportType,
        'limit': limit,
        'page': page,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getPopularRoutes({int limit = 10}) async {
    final response = await _dioClient.get(
      '/schedules/popular-routes',
      queryParameters: {'limit': limit},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getScheduleDetails(String scheduleId) async {
    final response = await _dioClient.get('/schedules/$scheduleId');
    return response.data;
  }

  Future<Map<String, dynamic>> getScheduleAvailability(
    String scheduleId,
  ) async {
    final response = await _dioClient.get(
      '/schedules/$scheduleId/availability',
    );
    return response.data;
  }

  // Booking endpoints
  Future<Map<String, dynamic>> createBooking({
    required String scheduleId,
    required List<Map<String, dynamic>> passengers,
    required String selectedClass,
    List<String>? selectedSeats,
    required Map<String, dynamic> contactInfo,
    required String paymentMethod,
  }) async {
    final response = await _dioClient.post(
      '/bookings',
      data: {
        'scheduleId': scheduleId,
        'passengers': passengers,
        'selectedClass': selectedClass,
        if (selectedSeats != null) 'selectedSeats': selectedSeats,
        'contactInfo': contactInfo,
        'paymentMethod': paymentMethod,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getBookings({
    String? status,
    int limit = 20,
    int page = 1,
  }) async {
    final response = await _dioClient.get(
      '/bookings',
      queryParameters: {
        if (status != null) 'status': status,
        'limit': limit,
        'page': page,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getBookingById(String bookingId) async {
    final response = await _dioClient.get('/bookings/$bookingId');
    return response.data;
  }

  Future<Map<String, dynamic>> getBookingByPNR(String pnr) async {
    final response = await _dioClient.get('/bookings/pnr/$pnr');
    return response.data;
  }

  Future<Map<String, dynamic>> confirmBooking(String bookingId) async {
    final response = await _dioClient.post('/bookings/$bookingId/confirm');
    return response.data;
  }

  Future<Map<String, dynamic>> cancelBooking(
    String bookingId, {
    String? reason,
  }) async {
    final response = await _dioClient.post(
      '/bookings/$bookingId/cancel',
      data: {if (reason != null) 'reason': reason},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> updatePassenger(
    String bookingId,
    String passengerId,
    Map<String, dynamic> data,
  ) async {
    final response = await _dioClient.put(
      '/bookings/$bookingId/passengers/$passengerId',
      data: data,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> extendBookingExpiry(
    String bookingId, {
    int minutes = 15,
  }) async {
    final response = await _dioClient.post(
      '/bookings/$bookingId/extend',
      data: {'minutes': minutes},
    );
    return response.data;
  }

  // Ticket endpoints
  Future<Map<String, dynamic>> getBookingTickets(String bookingId) async {
    final response = await _dioClient.get('/bookings/$bookingId/tickets');
    return response.data;
  }

  Future<Map<String, dynamic>> getTickets({
    String? status,
    int limit = 20,
    int page = 1,
  }) async {
    final response = await _dioClient.get(
      '/tickets',
      queryParameters: {
        if (status != null) 'status': status,
        'limit': limit,
        'page': page,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getTicketByNumber(String ticketNumber) async {
    final response = await _dioClient.get('/tickets/$ticketNumber');
    return response.data;
  }

  // Destination endpoints
  Future<Map<String, dynamic>> searchDestinations(
    String query, {
    String? type,
    String? city,
    int limit = 20,
  }) async {
    final response = await _dioClient.get(
      '/destinations/search',
      queryParameters: {
        'q': query,
        if (type != null) 'type': type,
        if (city != null) 'city': city,
        'limit': limit,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getDestinations({
    String? type,
    bool popularOnly = false,
    int limit = 100,
  }) async {
    final response = await _dioClient.get(
      '/destinations',
      queryParameters: {
        if (type != null) 'type': type,
        'popularOnly': popularOnly,
        'limit': limit,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getDestinationByCode(String code) async {
    final response = await _dioClient.get('/destinations/code/$code');
    return response.data;
  }

  // Payment endpoints
  Future<Map<String, dynamic>> processPayment({
    required String bookingId,
    required String paymentMethod,
    String? returnUrl,
  }) async {
    final response = await _dioClient.post(
      '/payments/process',
      data: {
        'bookingId': bookingId,
        'paymentMethod': paymentMethod,
        if (returnUrl != null) 'returnUrl': returnUrl,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getPaymentStatus(String paymentId) async {
    final response = await _dioClient.get('/payments/$paymentId/status');
    return response.data;
  }

  // File upload
  Future<Map<String, dynamic>> uploadFile(
    File file, {
    String? category,
    Function(int, int)? onProgress,
  }) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
      if (category != null) 'category': category,
    });

    final response = await _dioClient.upload(
      '/uploads',
      formData,
      onSendProgress: onProgress,
    );
    return response.data;
  }

  // Error handling helper
  String getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null && error.response!.data is Map) {
        final errorData = error.response!.data as Map<String, dynamic>;
        return errorData['message'] ?? 'Đã xảy ra lỗi không xác định';
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Kết nối bị timeout. Vui lòng thử lại.';
        case DioExceptionType.badResponse:
          return 'Lỗi phản hồi từ server. Mã lỗi: ${error.response?.statusCode}';
        case DioExceptionType.cancel:
          return 'Yêu cầu đã bị hủy.';
        case DioExceptionType.connectionError:
          return 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
        case DioExceptionType.badCertificate:
          return 'Lỗi chứng chỉ bảo mật.';
        case DioExceptionType.unknown:
        default:
          return 'Đã xảy ra lỗi không xác định.';
      }
    }
    return 'Đã xảy ra lỗi không xác định.';
  }

  // Refresh token handling
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _storage.read('refresh_token');
      if (refreshToken == null) return false;

      final response = await _dioClient.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data;
      if (data['success'] == true && data['data']['tokens'] != null) {
        await setAuthToken(data['data']['tokens']['accessToken']);
        await _storage.write(
          'refresh_token',
          data['data']['tokens']['refreshToken'],
        );
        return true;
      }
      return false;
    } catch (e) {
      await clearAuthToken();
      await _storage.delete('refresh_token');
      return false;
    }
  }
}

/// Provider for ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService.instance;
});
