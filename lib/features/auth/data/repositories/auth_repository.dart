import '../models/user.dart';

/// Authentication repository interface
abstract class AuthRepository {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);
  Future<void> logout();
  Future<AuthResponse?> refreshToken(String refreshToken);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String token, String newPassword);
  Future<User?> getCurrentUser();
  Future<void> updateProfile(User user);
}

/// Mock implementation of AuthRepository for development
class MockAuthRepository implements AuthRepository {
  // Simulate network delay
  static const Duration _networkDelay = Duration(seconds: 2);

  // Mock users database
  static final List<User> _users = [
    User(
      id: '1',
      email: 'admin@datve360.com',
      displayName: 'Admin User',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      isVerified: true,
    ),
    User(
      id: '2',
      email: 'user@example.com',
      phoneNumber: '0123456789',
      displayName: 'Test User',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      isVerified: true,
    ),
  ];

  // Mock passwords (in real app, these would be hashed)
  static final Map<String, String> _passwords = {
    'admin@datve360.com': 'admin123',
    'user@example.com': 'password123',
  };

  User? _currentUser;

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    await Future.delayed(_networkDelay);

    // Find user by email
    final user = _users.firstWhere(
      (u) => u.email == request.email,
      orElse: () => throw Exception('Tài khoản không tồn tại'),
    );

    // Check password
    final storedPassword = _passwords[user.email];
    if (storedPassword != request.password) {
      throw Exception('Mật khẩu không chính xác');
    }

    // Update last login
    final updatedUser = user.copyWith(lastLoginAt: DateTime.now());
    final userIndex = _users.indexWhere((u) => u.id == user.id);
    _users[userIndex] = updatedUser;

    _currentUser = updatedUser;

    return AuthResponse(
      user: updatedUser,
      accessToken: 'mock_access_token_${updatedUser.id}',
      refreshToken: 'mock_refresh_token_${updatedUser.id}',
      expiresIn: '24h',
    );
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    await Future.delayed(_networkDelay);

    // Check if user already exists
    final existingUser = _users.where(
      (u) =>
          u.email == request.email ||
          (request.phoneNumber != null && u.phoneNumber == request.phoneNumber),
    );

    if (existingUser.isNotEmpty) {
      throw Exception('Email hoặc số điện thoại đã được sử dụng');
    }

    // Validate password confirmation
    if (request.password != request.confirmPassword) {
      throw Exception('Mật khẩu xác nhận không khớp');
    }

    // Create new user
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: request.email,
      phoneNumber: request.phoneNumber,
      displayName: request.displayName,
      createdAt: DateTime.now(),
      isVerified: false,
    );

    // Add to mock database
    _users.add(newUser);
    _passwords[newUser.email] = request.password;

    _currentUser = newUser;

    return AuthResponse(
      user: newUser,
      accessToken: 'mock_access_token_${newUser.id}',
      refreshToken: 'mock_refresh_token_${newUser.id}',
      expiresIn: '24h',
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  @override
  Future<AuthResponse?> refreshToken(String refreshToken) async {
    await Future.delayed(const Duration(seconds: 1));

    if (_currentUser == null) {
      return null;
    }

    return AuthResponse(
      user: _currentUser!,
      accessToken: 'mock_access_token_${_currentUser!.id}_refreshed',
      refreshToken: 'mock_refresh_token_${_currentUser!.id}_refreshed',
      expiresIn: '24h',
    );
  }

  @override
  Future<void> forgotPassword(String email) async {
    await Future.delayed(_networkDelay);

    final user = _users.where((u) => u.email == email);
    if (user.isEmpty) {
      throw Exception('Email không tồn tại trong hệ thống');
    }

    // In real app, send reset password email
    // For now, just simulate success
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    await Future.delayed(_networkDelay);
    // In real app, validate token and update password
    // For now, just simulate success
  }

  @override
  Future<User?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentUser;
  }

  @override
  Future<void> updateProfile(User user) async {
    await Future.delayed(_networkDelay);

    final userIndex = _users.indexWhere((u) => u.id == user.id);
    if (userIndex != -1) {
      _users[userIndex] = user;
      if (_currentUser?.id == user.id) {
        _currentUser = user;
      }
    }
  }
}
