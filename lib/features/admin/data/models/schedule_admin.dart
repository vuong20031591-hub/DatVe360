class ScheduleAdmin {
  final String id;
  final RouteInfo routeId;
  final OperatorInfo operatorId;
  final String vehicleNumber;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String status;
  final bool isActive;
  final SeatConfiguration seatConfiguration;
  final VehicleInfo? vehicle;
  final String? gate;
  final String? terminal;
  final String frequency;
  final List<int>? recurringDays;
  final DateTime? validFrom;
  final DateTime? validTo;
  final SpecialPricing? specialPricing;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ScheduleAdmin({
    required this.id,
    required this.routeId,
    required this.operatorId,
    required this.vehicleNumber,
    required this.departureTime,
    required this.arrivalTime,
    required this.status,
    required this.isActive,
    required this.seatConfiguration,
    this.vehicle,
    this.gate,
    this.terminal,
    this.frequency = 'one-time',
    this.recurringDays,
    this.validFrom,
    this.validTo,
    this.specialPricing,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory ScheduleAdmin.fromJson(Map<String, dynamic> json) {
    return ScheduleAdmin(
      id: json['_id'] ?? json['id'] ?? '',
      routeId: RouteInfo.fromJson(json['routeId'] ?? {}),
      operatorId: OperatorInfo.fromJson(json['operatorId'] ?? {}),
      vehicleNumber: json['vehicleNumber'] ?? '',
      departureTime: DateTime.parse(json['departureTime']),
      arrivalTime: DateTime.parse(json['arrivalTime']),
      status: json['status'] ?? 'scheduled',
      isActive: json['isActive'] ?? true,
      seatConfiguration: SeatConfiguration.fromJson(json['seatConfiguration'] ?? {}),
      vehicle: json['vehicle'] != null ? VehicleInfo.fromJson(json['vehicle']) : null,
      gate: json['gate'],
      terminal: json['terminal'],
      frequency: json['frequency'] ?? 'one-time',
      recurringDays: json['recurringDays'] != null 
          ? List<int>.from(json['recurringDays']) 
          : null,
      validFrom: json['validFrom'] != null ? DateTime.parse(json['validFrom']) : null,
      validTo: json['validTo'] != null ? DateTime.parse(json['validTo']) : null,
      specialPricing: json['specialPricing'] != null 
          ? SpecialPricing.fromJson(json['specialPricing']) 
          : null,
      metadata: json['metadata'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'routeId': routeId.id,
      'operatorId': operatorId.id,
      'vehicleNumber': vehicleNumber,
      'departureTime': departureTime.toIso8601String(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'status': status,
      'isActive': isActive,
      'seatConfiguration': seatConfiguration.toJson(),
      if (vehicle != null) 'vehicle': vehicle!.toJson(),
      if (gate != null) 'gate': gate,
      if (terminal != null) 'terminal': terminal,
      'frequency': frequency,
      if (recurringDays != null) 'recurringDays': recurringDays,
      if (validFrom != null) 'validFrom': validFrom!.toIso8601String(),
      if (validTo != null) 'validTo': validTo!.toIso8601String(),
      if (specialPricing != null) 'specialPricing': specialPricing!.toJson(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  String get transportType => routeId.transportType;

  String get transportTypeDisplay {
    switch (transportType) {
      case 'flight':
        return 'Máy bay';
      case 'train':
        return 'Tàu hỏa';
      case 'bus':
        return 'Xe khách';
      default:
        return 'Khác';
    }
  }

  String get statusDisplay {
    switch (status) {
      case 'scheduled':
        return 'Đã lên lịch';
      case 'delayed':
        return 'Bị trễ';
      case 'cancelled':
        return 'Đã hủy';
      case 'departed':
        return 'Đã khởi hành';
      case 'arrived':
        return 'Đã đến';
      case 'maintenance':
        return 'Bảo trì';
      default:
        return 'Không xác định';
    }
  }

  String get routeDisplay => '${routeId.fromName} → ${routeId.toName}';
}

class RouteInfo {
  final String id;
  final DestinationInfo fromDestination;
  final DestinationInfo toDestination;
  final String transportType;
  final double distance;
  final int estimatedDuration;

  RouteInfo({
    required this.id,
    required this.fromDestination,
    required this.toDestination,
    required this.transportType,
    required this.distance,
    required this.estimatedDuration,
  });

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    return RouteInfo(
      id: json['_id'] ?? json['id'] ?? '',
      fromDestination: DestinationInfo.fromJson(json['fromDestination'] ?? {}),
      toDestination: DestinationInfo.fromJson(json['toDestination'] ?? {}),
      transportType: json['transportType'] ?? '',
      distance: (json['distance'] ?? 0).toDouble(),
      estimatedDuration: json['estimatedDuration'] ?? 0,
    );
  }

  String get fromName => fromDestination.name;
  String get toName => toDestination.name;
  String get fromCode => fromDestination.code;
  String get toCode => toDestination.code;
}

class DestinationInfo {
  final String id;
  final String name;
  final String code;
  final String city;
  final String country;

  DestinationInfo({
    required this.id,
    required this.name,
    required this.code,
    required this.city,
    required this.country,
  });

  factory DestinationInfo.fromJson(Map<String, dynamic> json) {
    return DestinationInfo(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
    );
  }
}

class OperatorInfo {
  final String id;
  final String name;
  final String code;
  final List<String> transportTypes;
  final Map<String, dynamic>? metadata;

  OperatorInfo({
    required this.id,
    required this.name,
    required this.code,
    required this.transportTypes,
    this.metadata,
  });

  factory OperatorInfo.fromJson(Map<String, dynamic> json) {
    return OperatorInfo(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      transportTypes: json['transportTypes'] != null 
          ? List<String>.from(json['transportTypes']) 
          : [],
      metadata: json['metadata'],
    );
  }

  String get displayName => '$name ($code)';
  String get logo => metadata?['logo'] ?? '';
}

class SeatConfiguration {
  final int totalSeats;
  final int availableSeats;
  final String? layout;
  final Map<String, SeatClass> classes;

  SeatConfiguration({
    required this.totalSeats,
    required this.availableSeats,
    this.layout,
    required this.classes,
  });

  factory SeatConfiguration.fromJson(Map<String, dynamic> json) {
    final classesMap = <String, SeatClass>{};
    if (json['classes'] != null) {
      final classesData = json['classes'] as Map<String, dynamic>;
      classesData.forEach((key, value) {
        classesMap[key] = SeatClass.fromJson(value);
      });
    }

    return SeatConfiguration(
      totalSeats: json['totalSeats'] ?? 0,
      availableSeats: json['availableSeats'] ?? 0,
      layout: json['layout'],
      classes: classesMap,
    );
  }

  Map<String, dynamic> toJson() {
    final classesMap = <String, dynamic>{};
    classes.forEach((key, value) {
      classesMap[key] = value.toJson();
    });

    return {
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      if (layout != null) 'layout': layout,
      'classes': classesMap,
    };
  }
}

class SeatClass {
  final int totalSeats;
  final int availableSeats;
  final double price;
  final String currency;
  final List<String> amenities;

  SeatClass({
    required this.totalSeats,
    required this.availableSeats,
    required this.price,
    this.currency = 'VND',
    this.amenities = const [],
  });

  factory SeatClass.fromJson(Map<String, dynamic> json) {
    return SeatClass(
      totalSeats: json['totalSeats'] ?? 0,
      availableSeats: json['availableSeats'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'VND',
      amenities: json['amenities'] != null 
          ? List<String>.from(json['amenities']) 
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'price': price,
      'currency': currency,
      'amenities': amenities,
    };
  }
}

class VehicleInfo {
  final String type;
  final String? model;
  final String? registrationNumber;
  final List<String> facilities;

  VehicleInfo({
    required this.type,
    this.model,
    this.registrationNumber,
    this.facilities = const [],
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      type: json['type'] ?? '',
      model: json['model'],
      registrationNumber: json['registrationNumber'],
      facilities: json['facilities'] != null 
          ? List<String>.from(json['facilities']) 
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (model != null) 'model': model,
      if (registrationNumber != null) 'registrationNumber': registrationNumber,
      'facilities': facilities,
    };
  }
}

class SpecialPricing {
  final bool isPromotional;
  final double discount;
  final DateTime? validUntil;

  SpecialPricing({
    this.isPromotional = false,
    this.discount = 0,
    this.validUntil,
  });

  factory SpecialPricing.fromJson(Map<String, dynamic> json) {
    return SpecialPricing(
      isPromotional: json['isPromotional'] ?? false,
      discount: (json['discount'] ?? 0).toDouble(),
      validUntil: json['validUntil'] != null 
          ? DateTime.parse(json['validUntil']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isPromotional': isPromotional,
      'discount': discount,
      if (validUntil != null) 'validUntil': validUntil!.toIso8601String(),
    };
  }
}

