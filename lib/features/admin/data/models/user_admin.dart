class UserAdmin {
  final String? id;
  final String email;
  final String displayName;
  final String? phoneNumber;
  final String? avatar;
  final String role;
  final bool isVerified;
  final bool isActive;
  final DateTime? suspendedUntil;
  final String? suspensionReason;
  final bool isPermanentlySuspended;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  const UserAdmin({
    this.id,
    required this.email,
    required this.displayName,
    this.phoneNumber,
    this.avatar,
    this.role = 'user',
    this.isVerified = false,
    this.isActive = true,
    this.suspendedUntil,
    this.suspensionReason,
    this.isPermanentlySuspended = false,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  factory UserAdmin.fromJson(Map<String, dynamic> json) {
    return UserAdmin(
      id: json['_id'] ?? json['id'],
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      phoneNumber: json['phoneNumber'],
      avatar: json['avatar'],
      role: json['role'] ?? 'user',
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      suspendedUntil: json['suspendedUntil'] != null
          ? DateTime.parse(json['suspendedUntil'])
          : null,
      suspensionReason: json['suspensionReason'],
      isPermanentlySuspended: json['isPermanentlySuspended'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'email': email,
      'displayName': displayName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (avatar != null) 'avatar': avatar,
      'role': role,
      'isVerified': isVerified,
      'isActive': isActive,
      if (suspendedUntil != null) 'suspendedUntil': suspendedUntil!.toIso8601String(),
      if (suspensionReason != null) 'suspensionReason': suspensionReason,
      'isPermanentlySuspended': isPermanentlySuspended,
    };
  }

  UserAdmin copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? avatar,
    String? role,
    bool? isVerified,
    bool? isActive,
    DateTime? suspendedUntil,
    String? suspensionReason,
    bool? isPermanentlySuspended,
    bool clearSuspension = false,
  }) {
    return UserAdmin(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      suspendedUntil: clearSuspension ? null : (suspendedUntil ?? this.suspendedUntil),
      suspensionReason: clearSuspension ? null : (suspensionReason ?? this.suspensionReason),
      isPermanentlySuspended: clearSuspension ? false : (isPermanentlySuspended ?? this.isPermanentlySuspended),
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastLoginAt: lastLoginAt,
    );
  }

  String get roleDisplayName {
    switch (role) {
      case 'admin':
        return 'Quản trị viên';
      case 'operator':
        return 'Nhà điều hành';
      case 'user':
        return 'Người dùng';
      default:
        return role;
    }
  }

  String get statusDisplayName {
    if (isPermanentlySuspended) {
      return 'Khóa vĩnh viễn';
    }
    if (suspendedUntil != null && suspendedUntil!.isAfter(DateTime.now())) {
      return 'Đang bị khóa';
    }
    if (!isActive) {
      return 'Không hoạt động';
    }
    if (!isVerified) {
      return 'Chưa xác thực';
    }
    return 'Hoạt động';
  }

  bool get isSuspended {
    if (isPermanentlySuspended) return true;
    if (suspendedUntil != null && suspendedUntil!.isAfter(DateTime.now())) {
      return true;
    }
    return false;
  }

  String? get suspensionTimeRemaining {
    if (isPermanentlySuspended) {
      return 'Vĩnh viễn';
    }
    if (suspendedUntil != null && suspendedUntil!.isAfter(DateTime.now())) {
      final duration = suspendedUntil!.difference(DateTime.now());
      if (duration.inDays > 0) {
        return '${duration.inDays} ngày';
      } else if (duration.inHours > 0) {
        return '${duration.inHours} giờ';
      } else if (duration.inMinutes > 0) {
        return '${duration.inMinutes} phút';
      }
      return 'Sắp hết hạn';
    }
    return null;
  }
}

