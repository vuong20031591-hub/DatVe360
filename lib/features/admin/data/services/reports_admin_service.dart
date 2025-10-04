import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class ReportsAdminService {
  final Dio _dio = DioClient.instance.dio;

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dio.get('/admin/reports/dashboard');
      return response.data;
    } catch (e) {
      throw Exception('Không thể tải thống kê dashboard: $e');
    }
  }

  Future<Map<String, dynamic>> getBookingStats({
    DateTime? fromDate,
    DateTime? toDate,
    String groupBy = 'day',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'groupBy': groupBy,
      };

      if (fromDate != null) {
        queryParams['fromDate'] = fromDate.toIso8601String();
      }
      if (toDate != null) {
        queryParams['toDate'] = toDate.toIso8601String();
      }

      final response = await _dio.get(
        '/admin/reports/bookings',
        queryParameters: queryParams,
      );

      return response.data;
    } catch (e) {
      throw Exception('Không thể tải thống kê đặt vé: $e');
    }
  }

  Future<Map<String, dynamic>> getRevenueStats({
    DateTime? fromDate,
    DateTime? toDate,
    String groupBy = 'day',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'groupBy': groupBy,
      };

      if (fromDate != null) {
        queryParams['fromDate'] = fromDate.toIso8601String();
      }
      if (toDate != null) {
        queryParams['toDate'] = toDate.toIso8601String();
      }

      final response = await _dio.get(
        '/admin/reports/revenue',
        queryParameters: queryParams,
      );

      return response.data;
    } catch (e) {
      throw Exception('Không thể tải thống kê doanh thu: $e');
    }
  }

  Future<Map<String, dynamic>> getPopularRoutes({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/admin/reports/popular-routes',
        queryParameters: {'limit': limit},
      );

      return response.data;
    } catch (e) {
      throw Exception('Không thể tải tuyến đường phổ biến: $e');
    }
  }

  Future<Map<String, dynamic>> getUserActivity({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (fromDate != null) {
        queryParams['fromDate'] = fromDate.toIso8601String();
      }
      if (toDate != null) {
        queryParams['toDate'] = toDate.toIso8601String();
      }

      final response = await _dio.get(
        '/admin/reports/user-activity',
        queryParameters: queryParams,
      );

      return response.data;
    } catch (e) {
      throw Exception('Không thể tải hoạt động người dùng: $e');
    }
  }

  Future<Map<String, dynamic>> exportReport({
    required String type,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'type': type,
      };

      if (fromDate != null) {
        queryParams['fromDate'] = fromDate.toIso8601String();
      }
      if (toDate != null) {
        queryParams['toDate'] = toDate.toIso8601String();
      }

      final response = await _dio.get(
        '/admin/reports/export',
        queryParameters: queryParams,
      );

      return response.data;
    } catch (e) {
      throw Exception('Không thể xuất báo cáo: $e');
    }
  }
}

