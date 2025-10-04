import '../../../../core/network/dio_client.dart';
import '../models/destination_admin.dart';

class DestinationsAdminService {
  final DioClient _dioClient = DioClient.instance;

  /// Get all destinations
  Future<List<DestinationAdmin>> getAllDestinations() async {
    try {
      final response = await _dioClient.get('/destinations');

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => DestinationAdmin.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw Exception('Không thể tải danh sách điểm đến: ${e.toString()}');
    }
  }

  /// Get popular destinations
  Future<List<DestinationAdmin>> getPopularDestinations() async {
    try {
      final response = await _dioClient.get('/destinations/popular');

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => DestinationAdmin.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw Exception('Không thể tải điểm đến phổ biến: ${e.toString()}');
    }
  }

  /// Search destinations
  Future<List<DestinationAdmin>> searchDestinations(String query) async {
    try {
      final response = await _dioClient.get(
        '/destinations/search',
        queryParameters: {'q': query},
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => DestinationAdmin.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw Exception('Không thể tìm kiếm điểm đến: ${e.toString()}');
    }
  }

  /// Get destination by ID
  Future<DestinationAdmin?> getDestinationById(String id) async {
    try {
      final response = await _dioClient.get('/destinations/$id');

      if (response.data['success'] == true && response.data['data'] != null) {
        return DestinationAdmin.fromJson(response.data['data']);
      }

      return null;
    } catch (e) {
      throw Exception('Không thể tải thông tin điểm đến: ${e.toString()}');
    }
  }

  /// Create new destination
  Future<DestinationAdmin> createDestination(DestinationAdmin destination) async {
    try {
      final response = await _dioClient.post(
        '/destinations',
        data: destination.toJson(),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return DestinationAdmin.fromJson(response.data['data']);
      }

      throw Exception('Không thể tạo điểm đến mới');
    } catch (e) {
      throw Exception('Lỗi khi tạo điểm đến: ${e.toString()}');
    }
  }

  /// Update destination
  Future<DestinationAdmin> updateDestination(
    String id,
    DestinationAdmin destination,
  ) async {
    try {
      final response = await _dioClient.put(
        '/destinations/$id',
        data: destination.toJson(),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return DestinationAdmin.fromJson(response.data['data']);
      }

      throw Exception('Không thể cập nhật điểm đến');
    } catch (e) {
      throw Exception('Lỗi khi cập nhật điểm đến: ${e.toString()}');
    }
  }

  /// Delete destination
  Future<bool> deleteDestination(String id) async {
    try {
      final response = await _dioClient.delete('/destinations/$id');

      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Lỗi khi xóa điểm đến: ${e.toString()}');
    }
  }

  /// Upload destination image (placeholder - needs implementation)
  Future<String> uploadDestinationImage(String filePath) async {
    try {
      // TODO: Implement file upload
      throw UnimplementedError('Upload image chưa được implement');
    } catch (e) {
      throw Exception('Lỗi khi tải ảnh: ${e.toString()}');
    }
  }
}

