/// User model for authentication - synced with Backend API
class User {
  final String id;
  final String email;
  final String? phoneNumber;
  final String displayName;
  final String? avatar;
  final String role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isVerified;
  final Map<String, dynamic> preferences;

  const User({
    required this.id,
    required this.email,
    this.phoneNumber,
    required this.displayName,
    this.avatar,
    this.role = 'user',
    required this.createdAt,
    this.lastLoginAt,
    this.isVerified = false,
    this.preferences = const {},
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      displayName: json['displayName'] as String,
      avatar: json['avatar'] as String?,
      role: json['role'] as String? ?? 'user',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      isVerified: json['isVerified'] as bool? ?? false,
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'avatar': avatar,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isVerified': isVerified,
      'preferences': preferences,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? displayName,
    String? avatar,
    String? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isVerified,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isVerified: isVerified ?? this.isVerified,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, email: $email, displayName: $displayName)';
  }
}

/// Login request model - synced with Backend API
class LoginRequest {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password, 'rememberMe': rememberMe};
  }
}

/// Register request model - synced with Backend API
class RegisterRequest {
  final String displayName;
  final String email;
  final String? phoneNumber;
  final String password;
  final String confirmPassword;
  final bool agreeToTerms;

  const RegisterRequest({
    required this.displayName,
    required this.email,
    this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    required this.agreeToTerms,
  });

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'confirmPassword': confirmPassword,
      'agreeToTerms': agreeToTerms,
    };
  }
}

/// Auth response model - synced with Backend API
class AuthResponse {
  final User user;
  final String accessToken;
  final String refreshToken;
  final String expiresIn;

  const AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Backend API format: { "data": { "user": {...}, "tokens": {...} } }
    final data = json['data'] as Map<String, dynamic>;
    final tokens = data['tokens'] as Map<String, dynamic>;

    return AuthResponse(
      user: User.fromJson(data['user'] as Map<String, dynamic>),
      accessToken: tokens['accessToken'] as String,
      refreshToken: tokens['refreshToken'] as String,
      expiresIn: tokens['expiresIn'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
    };
  }
}
