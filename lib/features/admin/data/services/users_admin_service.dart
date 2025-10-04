import '../../../../core/network/dio_client.dart';
import '../models/user_admin.dart';

class UsersAdminService {
  final DioClient _dioClient = DioClient.instance;

  /// Get all users
  Future<List<UserAdmin>> getAllUsers() async {
    try {
      final response = await _dioClient.get('/admin/users');
      
      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => UserAdmin.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Không thể tải danh sách người dùng: ${e.toString()}');
    }
  }

  /// Search users
  Future<List<UserAdmin>> searchUsers(String query) async {
    try {
      final response = await _dioClient.get(
        '/admin/users/search',
        queryParameters: {'q': query},
      );
      
      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => UserAdmin.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Không thể tìm kiếm người dùng: ${e.toString()}');
    }
  }

  /// Get user by ID
  Future<UserAdmin?> getUserById(String id) async {
    try {
      final response = await _dioClient.get('/admin/users/$id');
      
      if (response.data['success'] == true && response.data['data'] != null) {
        return UserAdmin.fromJson(response.data['data']);
      }
      
      return null;
    } catch (e) {
      throw Exception('Không thể tải thông tin người dùng: ${e.toString()}');
    }
  }

  /// Create new user
  Future<UserAdmin> createUser(UserAdmin user, String password) async {
    try {
      final data = user.toJson();
      data['password'] = password;
      
      final response = await _dioClient.post(
        '/admin/users',
        data: data,
      );
      
      if (response.data['success'] == true && response.data['data'] != null) {
        return UserAdmin.fromJson(response.data['data']);
      }
      
      throw Exception('Không thể tạo người dùng mới');
    } catch (e) {
      throw Exception('Lỗi khi tạo người dùng: ${e.toString()}');
    }
  }

  /// Update user
  Future<UserAdmin> updateUser(String id, UserAdmin user) async {
    try {
      final response = await _dioClient.put(
        '/admin/users/$id',
        data: user.toJson(),
      );
      
      if (response.data['success'] == true && response.data['data'] != null) {
        return UserAdmin.fromJson(response.data['data']);
      }
      
      throw Exception('Không thể cập nhật người dùng');
    } catch (e) {
      throw Exception('Lỗi khi cập nhật người dùng: ${e.toString()}');
    }
  }

  /// Suspend user temporarily
  Future<UserAdmin> suspendUser({
    required String id,
    required int durationInDays,
    required String reason,
  }) async {
    try {
      final response = await _dioClient.post(
        '/admin/users/$id/suspend',
        data: {
          'durationInDays': durationInDays,
          'reason': reason,
        },
      );
      
      if (response.data['success'] == true && response.data['data'] != null) {
        return UserAdmin.fromJson(response.data['data']);
      }
      
      throw Exception('Không thể khóa tài khoản');
    } catch (e) {
      throw Exception('Lỗi khi khóa tài khoản: ${e.toString()}');
    }
  }

  /// Suspend user permanently
  Future<UserAdmin> suspendUserPermanently({
    required String id,
    required String reason,
  }) async {
    try {
      final response = await _dioClient.post(
        '/admin/users/$id/suspend-permanent',
        data: {
          'reason': reason,
        },
      );
      
      if (response.data['success'] == true && response.data['data'] != null) {
        return UserAdmin.fromJson(response.data['data']);
      }
      
      throw Exception('Không thể khóa vĩnh viễn tài khoản');
    } catch (e) {
      throw Exception('Lỗi khi khóa vĩnh viễn tài khoản: ${e.toString()}');
    }
  }

  /// Unsuspend user
  Future<UserAdmin> unsuspendUser(String id) async {
    try {
      final response = await _dioClient.post('/admin/users/$id/unsuspend');
      
      if (response.data['success'] == true && response.data['data'] != null) {
        return UserAdmin.fromJson(response.data['data']);
      }
      
      throw Exception('Không thể mở khóa tài khoản');
    } catch (e) {
      throw Exception('Lỗi khi mở khóa tài khoản: ${e.toString()}');
    }
  }

  /// Delete user
  Future<bool> deleteUser(String id) async {
    try {
      final response = await _dioClient.delete('/admin/users/$id');
      
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Lỗi khi xóa người dùng: ${e.toString()}');
    }
  }

  /// Change user role
  Future<UserAdmin> changeUserRole(String id, String role) async {
    try {
      final response = await _dioClient.put(
        '/admin/users/$id/role',
        data: {'role': role},
      );
      
      if (response.data['success'] == true && response.data['data'] != null) {
        return UserAdmin.fromJson(response.data['data']);
      }
      
      throw Exception('Không thể thay đổi vai trò');
    } catch (e) {
      throw Exception('Lỗi khi thay đổi vai trò: ${e.toString()}');
    }
  }

  /// Verify user email
  Future<UserAdmin> verifyUser(String id) async {
    try {
      final response = await _dioClient.post('/admin/users/$id/verify');
      
      if (response.data['success'] == true && response.data['data'] != null) {
        return UserAdmin.fromJson(response.data['data']);
      }
      
      throw Exception('Không thể xác thực người dùng');
    } catch (e) {
      throw Exception('Lỗi khi xác thực người dùng: ${e.toString()}');
    }
  }

  /// Reset user password
  Future<bool> resetUserPassword(String id, String newPassword) async {
    try {
      final response = await _dioClient.post(
        '/admin/users/$id/reset-password',
        data: {'newPassword': newPassword},
      );
      
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Lỗi khi đặt lại mật khẩu: ${e.toString()}');
    }
  }
}

