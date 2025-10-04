import '../../../../core/network/dio_client.dart';
import '../models/schedule_admin.dart';

class SchedulesAdminService {
  final DioClient _dioClient = DioClient.instance;

  /// Get all schedules with optional filters
  Future<List<ScheduleAdmin>> getSchedules({
    String? transportType,
    String? status,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (transportType != null) {
        queryParams['transportType'] = transportType;
      }

      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _dioClient.get(
        '/admin/schedules',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ScheduleAdmin.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw Exception('Không thể tải lịch trình: ${e.toString()}');
    }
  }

  /// Get schedule by ID
  Future<ScheduleAdmin?> getScheduleById(String id) async {
    try {
      final response = await _dioClient.get('/admin/schedules/$id');

      if (response.data['success'] == true && response.data['data'] != null) {
        return ScheduleAdmin.fromJson(response.data['data']);
      }

      return null;
    } catch (e) {
      throw Exception('Không thể tải lịch trình: ${e.toString()}');
    }
  }

  /// Get schedules statistics
  Future<Map<String, int>> getStatistics() async {
    try {
      final response = await _dioClient.get('/admin/schedules/stats/overview');

      if (response.data['success'] == true && response.data['data'] != null) {
        final data = response.data['data'] as Map<String, dynamic>;
        return {
          'total': data['total'] ?? 0,
          'scheduled': data['scheduled'] ?? 0,
          'active': data['active'] ?? 0,
          'cancelled': data['cancelled'] ?? 0,
          'inactive': data['inactive'] ?? 0,
        };
      }

      return {
        'total': 0,
        'scheduled': 0,
        'active': 0,
        'cancelled': 0,
        'inactive': 0,
      };
    } catch (e) {
      throw Exception('Không thể tải thống kê: ${e.toString()}');
    }
  }

  /// Create schedule
  Future<ScheduleAdmin> createSchedule(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.post('/admin/schedules', data: data);

      if (response.data['success'] == true && response.data['data'] != null) {
        return ScheduleAdmin.fromJson(response.data['data']);
      }

      throw Exception('Không thể tạo lịch trình');
    } catch (e) {
      throw Exception('Không thể tạo lịch trình: ${e.toString()}');
    }
  }

  /// Update schedule
  Future<ScheduleAdmin> updateSchedule(
      String id, Map<String, dynamic> data) async {
    try {
      final response =
          await _dioClient.put('/admin/schedules/$id', data: data);

      if (response.data['success'] == true && response.data['data'] != null) {
        return ScheduleAdmin.fromJson(response.data['data']);
      }

      throw Exception('Không thể cập nhật lịch trình');
    } catch (e) {
      throw Exception('Không thể cập nhật lịch trình: ${e.toString()}');
    }
  }

  /// Delete schedule
  Future<void> deleteSchedule(String id) async {
    try {
      final response = await _dioClient.delete('/admin/schedules/$id');

      if (response.data['success'] != true) {
        throw Exception('Không thể xóa lịch trình');
      }
    } catch (e) {
      throw Exception('Không thể xóa lịch trình: ${e.toString()}');
    }
  }

  /// Toggle schedule active status
  Future<ScheduleAdmin> toggleActive(String id, bool isActive) async {
    try {
      final response = await _dioClient.put(
        '/admin/schedules/$id',
        data: {'isActive': isActive},
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return ScheduleAdmin.fromJson(response.data['data']);
      }

      throw Exception('Không thể cập nhật trạng thái');
    } catch (e) {
      throw Exception('Không thể cập nhật trạng thái: ${e.toString()}');
    }
  }

  /// Update schedule status
  Future<ScheduleAdmin> updateStatus(String id, String status) async {
    try {
      final response = await _dioClient.put(
        '/admin/schedules/$id',
        data: {'status': status},
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return ScheduleAdmin.fromJson(response.data['data']);
      }

      throw Exception('Không thể cập nhật trạng thái');
    } catch (e) {
      throw Exception('Không thể cập nhật trạng thái: ${e.toString()}');
    }
  }

  /// Get routes for dropdown
  Future<List<Map<String, dynamic>>> getRoutes({String? transportType}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (transportType != null) {
        queryParams['transportType'] = transportType;
      }

      final response = await _dioClient.get(
        '/admin/schedules/routes',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }

      return [];
    } catch (e) {
      throw Exception('Không thể tải tuyến đường: ${e.toString()}');
    }
  }
}

