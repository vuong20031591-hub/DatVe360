import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class PaymentsAdminService {
  final Dio _dio = DioClient.instance.dio;

  Future<Map<String, dynamic>> getPayments({
    String? status,
    String? paymentMethod,
    String? transactionId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null) queryParams['status'] = status;
      if (paymentMethod != null) queryParams['paymentMethod'] = paymentMethod;
      if (transactionId != null) queryParams['transactionId'] = transactionId;

      final response = await _dio.get(
        '/admin/payments',
        queryParameters: queryParams,
      );

      return response.data;
    } catch (e) {
      throw Exception('Không thể tải danh sách thanh toán: $e');
    }
  }

  Future<Map<String, dynamic>> getPaymentStats() async {
    try {
      final response = await _dio.get('/admin/payments/stats/overview');
      return response.data;
    } catch (e) {
      throw Exception('Không thể tải thống kê thanh toán: $e');
    }
  }

  Future<Map<String, dynamic>> getPaymentById(String id) async {
    try {
      final response = await _dio.get('/admin/payments/$id');
      return response.data;
    } catch (e) {
      throw Exception('Không thể tải chi tiết thanh toán: $e');
    }
  }

  Future<Map<String, dynamic>> refundPayment(
    String id, {
    double? refundAmount,
    String? refundReason,
  }) async {
    try {
      final response = await _dio.put(
        '/admin/payments/$id/refund',
        data: {
          if (refundAmount != null) 'refundAmount': refundAmount,
          if (refundReason != null) 'refundReason': refundReason,
        },
      );

      return response.data;
    } catch (e) {
      throw Exception('Không thể hoàn tiền: $e');
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
        '/admin/payments/stats/revenue',
        queryParameters: queryParams,
      );

      return response.data;
    } catch (e) {
      throw Exception('Không thể tải thống kê doanh thu: $e');
    }
  }
}

