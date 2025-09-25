import '../../../../core/services/api_service.dart';
import '../../../../core/storage/storage_service.dart';
import '../models/user.dart';
import 'auth_repository.dart';

/// Real authentication repository that connects to Backend API
class RealAuthRepository implements AuthRepository {
  static RealAuthRepository? _instance;
  late ApiService _apiService;
  late StorageService _storage;

  User? _currentUser;

  RealAuthRepository._internal() {
    _apiService = ApiService.instance;
    _storage = StorageService.instance;
  }

  static RealAuthRepository get instance {
    _instance ??= RealAuthRepository._internal();
    return _instance!;
  }

  /// Get current authenticated user
  User? get currentUser => _currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  /// Initialize auth state from storage
  Future<void> initialize() async {
    try {
      final token = await _apiService.getAuthToken();
      if (token != null) {
        // Try to get current user from API
        final response = await _apiService.getCurrentUser();
        if (response['success'] == true && response['data'] != null) {
          _currentUser = User.fromJson(response['data']['user']);
        }
      }
    } catch (e) {
      // Token might be expired, clear it
      await _apiService.clearAuthToken();
      _currentUser = null;
    }
  }

  /// Login with email and password
  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiService.login(
        email: request.email,
        password: request.password,
        rememberMe: request.rememberMe,
      );

      if (response['success'] == true && response['data'] != null) {
        final authResponse = AuthResponse.fromJson(response);
        _currentUser = authResponse.user;

        // Store user data locally for offline access
        await _storage.write('current_user', authResponse.user.toJson());

        return authResponse;
      } else {
        throw Exception(response['message'] ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      throw Exception(_apiService.getErrorMessage(e));
    }
  }

  /// Register new user
  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiService.register(
        email: request.email,
        password: request.password,
        displayName: request.displayName,
        phoneNumber: request.phoneNumber,
      );

      if (response['success'] == true && response['data'] != null) {
        final authResponse = AuthResponse.fromJson(response);
        _currentUser = authResponse.user;

        // Store user data locally for offline access
        await _storage.write('current_user', authResponse.user.toJson());

        return authResponse;
      } else {
        throw Exception(response['message'] ?? 'Đăng ký thất bại');
      }
    } catch (e) {
      throw Exception(_apiService.getErrorMessage(e));
    }
  }

  /// Logout user
  @override
  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // Ignore logout errors
    } finally {
      _currentUser = null;
      await _storage.delete('current_user');
    }
  }

  /// Refresh authentication token
  @override
  Future<AuthResponse?> refreshToken(String refreshToken) async {
    try {
      final success = await _apiService.refreshToken();
      if (success) {
        // Get updated user info
        final response = await _apiService.getCurrentUser();
        if (response['success'] == true && response['data'] != null) {
          _currentUser = User.fromJson(response['data']['user']);
          await _storage.write('current_user', _currentUser!.toJson());

          // Create a mock AuthResponse for refresh
          return AuthResponse(
            user: _currentUser!,
            accessToken: await _apiService.getAuthToken() ?? '',
            refreshToken: _storage.read('refresh_token') ?? '',
            expiresIn: '7d',
          );
        }
      }
      return null;
    } catch (e) {
      await logout();
      return null;
    }
  }

  /// Update user profile
  @override
  Future<void> updateProfile(User user) async {
    try {
      final response = await _apiService.updateProfile(user.toJson());

      if (response['success'] == true && response['data'] != null) {
        _currentUser = User.fromJson(response['data']['user']);
        await _storage.write('current_user', _currentUser!.toJson());
      } else {
        throw Exception(response['message'] ?? 'Cập nhật thông tin thất bại');
      }
    } catch (e) {
      throw Exception(_apiService.getErrorMessage(e));
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Đổi mật khẩu thất bại');
      }
    } catch (e) {
      throw Exception(_apiService.getErrorMessage(e));
    }
  }

  /// Get current authenticated user
  @override
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }

    // Try to get from storage
    return await getUserFromStorage();
  }

  /// Forgot password
  @override
  Future<void> forgotPassword(String email) async {
    // TODO: Implement forgot password API call
    throw UnimplementedError('Forgot password not implemented yet');
  }

  /// Reset password
  @override
  Future<void> resetPassword(String token, String newPassword) async {
    // TODO: Implement reset password API call
    throw UnimplementedError('Reset password not implemented yet');
  }

  /// Get user from local storage (for offline access)
  Future<User?> getUserFromStorage() async {
    try {
      final userData = await _storage.read('current_user');
      if (userData != null && userData is Map<String, dynamic>) {
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Clear all auth data
  Future<void> clearAuthData() async {
    _currentUser = null;
    await _apiService.clearAuthToken();
    await _storage.delete('refresh_token');
    await _storage.delete('current_user');
  }
}
