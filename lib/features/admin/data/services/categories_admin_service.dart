import '../../../../core/network/dio_client.dart';
import '../models/transport_operator.dart';

class CategoriesAdminService {
  final DioClient _dioClient = DioClient.instance;

  /// Get all operators grouped by type
  Future<Map<String, List<TransportOperator>>> getAllCategories() async {
    try {
      final response = await _dioClient.get('/admin/categories');

      if (response.data['success'] == true && response.data['data'] != null) {
        final data = response.data['data'] as Map<String, dynamic>;
        
        return {
          'flight': (data['flight'] as List?)
                  ?.map((json) => TransportOperator.fromJson(json))
                  .toList() ??
              [],
          'train': (data['train'] as List?)
                  ?.map((json) => TransportOperator.fromJson(json))
                  .toList() ??
              [],
          'bus': (data['bus'] as List?)
                  ?.map((json) => TransportOperator.fromJson(json))
                  .toList() ??
              [],
        };
      }

      return {'flight': [], 'train': [], 'bus': []};
    } catch (e) {
      throw Exception('Không thể tải danh mục: ${e.toString()}');
    }
  }

  /// Get operators by type
  Future<List<TransportOperator>> getOperatorsByType(String type) async {
    try {
      final response = await _dioClient.get('/admin/categories/$type');

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => TransportOperator.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw Exception('Không thể tải nhà cung cấp: ${e.toString()}');
    }
  }

  /// Create operator
  Future<TransportOperator> createOperator(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.post('/admin/categories', data: data);

      if (response.data['success'] == true && response.data['data'] != null) {
        return TransportOperator.fromJson(response.data['data']);
      }

      throw Exception('Không thể tạo nhà cung cấp');
    } catch (e) {
      throw Exception('Không thể tạo nhà cung cấp: ${e.toString()}');
    }
  }

  /// Update operator
  Future<TransportOperator> updateOperator(
      String id, Map<String, dynamic> data) async {
    try {
      final response =
          await _dioClient.put('/admin/categories/$id', data: data);

      if (response.data['success'] == true && response.data['data'] != null) {
        return TransportOperator.fromJson(response.data['data']);
      }

      throw Exception('Không thể cập nhật nhà cung cấp');
    } catch (e) {
      throw Exception('Không thể cập nhật nhà cung cấp: ${e.toString()}');
    }
  }

  /// Delete operator
  Future<void> deleteOperator(String id) async {
    try {
      await _dioClient.delete('/admin/categories/$id');
    } catch (e) {
      throw Exception('Không thể xóa nhà cung cấp: ${e.toString()}');
    }
  }

  /// Get statistics
  Future<Map<String, int>> getStats() async {
    try {
      final response = await _dioClient.get('/admin/categories/stats/overview');

      if (response.data['success'] == true && response.data['data'] != null) {
        final data = response.data['data'];
        return {
          'total': data['total'] ?? 0,
          'airlines': data['airlines'] ?? 0,
          'trains': data['trains'] ?? 0,
          'buses': data['buses'] ?? 0,
          'active': data['active'] ?? 0,
          'inactive': data['inactive'] ?? 0,
        };
      }

      return {
        'total': 0,
        'airlines': 0,
        'trains': 0,
        'buses': 0,
        'active': 0,
        'inactive': 0,
      };
    } catch (e) {
      throw Exception('Không thể tải thống kê: ${e.toString()}');
    }
  }
}

