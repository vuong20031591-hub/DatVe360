class TransportOperator {
  final String id;
  final String name;
  final String code;
  final List<String> transportTypes;
  final ContactInfo? contactInfo;
  final bool isActive;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TransportOperator({
    required this.id,
    required this.name,
    required this.code,
    required this.transportTypes,
    this.contactInfo,
    required this.isActive,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory TransportOperator.fromJson(Map<String, dynamic> json) {
    return TransportOperator(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      transportTypes: List<String>.from(json['transportTypes'] ?? []),
      contactInfo: json['contactInfo'] != null
          ? ContactInfo.fromJson(json['contactInfo'])
          : null,
      isActive: json['isActive'] ?? true,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'transportTypes': transportTypes,
      if (contactInfo != null) 'contactInfo': contactInfo!.toJson(),
      'isActive': isActive,
      if (metadata != null) 'metadata': metadata,
    };
  }

  String get displayName => '$name ($code)';

  String get logo => metadata?['logo'] ?? '';

  String get description => metadata?['description'] ?? '';

  String get transportTypeDisplay {
    if (transportTypes.contains('flight')) return 'Máy bay';
    if (transportTypes.contains('train')) return 'Tàu hỏa';
    if (transportTypes.contains('bus')) return 'Xe khách';
    return 'Khác';
  }
}

class ContactInfo {
  final String? phone;
  final String? email;
  final String? website;
  final String? address;

  ContactInfo({
    this.phone,
    this.email,
    this.website,
    this.address,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (website != null) 'website': website,
      if (address != null) 'address': address,
    };
  }
}

