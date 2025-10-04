class DestinationAdmin {
  final String? id;
  final String name;
  final String? nameEn;
  final String code;
  final String type;
  final String city;
  final String country;
  final double? latitude;
  final double? longitude;
  final String? timezone;
  final bool active;
  final bool popular;
  final String? imageUrl;
  final String? description;
  final List<String>? facilities;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DestinationAdmin({
    this.id,
    required this.name,
    this.nameEn,
    required this.code,
    required this.type,
    required this.city,
    this.country = 'Vietnam',
    this.latitude,
    this.longitude,
    this.timezone = 'Asia/Ho_Chi_Minh',
    this.active = true,
    this.popular = false,
    this.imageUrl,
    this.description,
    this.facilities,
    this.createdAt,
    this.updatedAt,
  });

  factory DestinationAdmin.fromJson(Map<String, dynamic> json) {
    return DestinationAdmin(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      nameEn: json['nameEn'],
      code: json['code'] ?? '',
      type: json['type'] ?? 'airport',
      city: json['city'] ?? '',
      country: json['country'] ?? 'Vietnam',
      latitude: json['coordinates']?['latitude']?.toDouble(),
      longitude: json['coordinates']?['longitude']?.toDouble(),
      timezone: json['timezone'] ?? 'Asia/Ho_Chi_Minh',
      active: json['active'] ?? true,
      popular: json['popular'] ?? false,
      imageUrl: json['imageUrl'],
      description: json['metadata']?['description'],
      facilities: json['metadata']?['facilities'] != null
          ? List<String>.from(json['metadata']['facilities'])
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
      if (id != null) '_id': id,
      'name': name,
      if (nameEn != null) 'nameEn': nameEn,
      'code': code,
      'type': type,
      'city': city,
      'country': country,
      'coordinates': {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
      'timezone': timezone,
      'active': active,
      'popular': popular,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'metadata': {
        if (description != null) 'description': description,
        if (facilities != null) 'facilities': facilities,
      },
    };
  }

  DestinationAdmin copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? code,
    String? type,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    String? timezone,
    bool? active,
    bool? popular,
    String? imageUrl,
    String? description,
    List<String>? facilities,
  }) {
    return DestinationAdmin(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      code: code ?? this.code,
      type: type ?? this.type,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezone: timezone ?? this.timezone,
      active: active ?? this.active,
      popular: popular ?? this.popular,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      facilities: facilities ?? this.facilities,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  double? getDistanceFrom(double? userLat, double? userLon) {
    if (latitude == null || longitude == null || userLat == null || userLon == null) {
      return null;
    }

    const R = 6371; // Earth's radius in kilometers
    final dLat = (userLat - latitude!) * 3.141592653589793 / 180;
    final dLon = (userLon - longitude!) * 3.141592653589793 / 180;

    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(latitude! * 3.141592653589793 / 180) *
            _cos(userLat * 3.141592653589793 / 180) *
            _sin(dLon / 2) *
            _sin(dLon / 2);

    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    final distance = R * c;

    return (distance * 100).round() / 100; // Round to 2 decimal places
  }

  // Math helper functions
  double _sin(double x) => x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  double _cos(double x) => 1 - (x * x) / 2 + (x * x * x * x) / 24;
  double _sqrt(double x) {
    if (x == 0) return 0;
    double z = x;
    for (int i = 0; i < 10; i++) {
      z = (z + x / z) / 2;
    }
    return z;
  }
  double _atan2(double y, double x) {
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + 3.141592653589793;
    if (x < 0 && y < 0) return _atan(y / x) - 3.141592653589793;
    if (x == 0 && y > 0) return 3.141592653589793 / 2;
    if (x == 0 && y < 0) return -3.141592653589793 / 2;
    return 0;
  }
  double _atan(double x) {
    return x - (x * x * x) / 3 + (x * x * x * x * x) / 5;
  }

  String get typeDisplayName {
    switch (type) {
      case 'airport':
        return 'Sân bay';
      case 'bus_station':
        return 'Bến xe';
      case 'train_station':
        return 'Ga tàu';
      case 'port':
        return 'Cảng';
      default:
        return type;
    }
  }
}

