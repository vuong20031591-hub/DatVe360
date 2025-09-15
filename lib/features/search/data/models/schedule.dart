/// Schedule model for search results - synced with Backend API
class Schedule {
  final String id;
  final String operatorId;
  final String operatorName;
  final String operatorLogo;
  final String routeId;
  final String vehicleNumber;
  final String from;
  final String to;
  final String fromCode;
  final String toCode;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final Duration duration;
  final double price;
  final String currency;
  final String transportType;
  final String vehicleType;
  final int totalSeats;
  final int availableSeats;
  final String status;
  final Map<String, dynamic> classes;
  final Map<String, dynamic> metadata;

  const Schedule({
    required this.id,
    required this.operatorId,
    required this.operatorName,
    required this.operatorLogo,
    required this.routeId,
    required this.vehicleNumber,
    required this.from,
    required this.to,
    required this.fromCode,
    required this.toCode,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.price,
    required this.currency,
    required this.transportType,
    required this.vehicleType,
    required this.totalSeats,
    required this.availableSeats,
    required this.status,
    required this.classes,
    required this.metadata,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    // Extract route information with safe casting
    final route = _safeMapCast(json['route']) ?? {};
    final fromDestination = _safeMapCast(route['from']) ?? {};
    final toDestination = _safeMapCast(route['to']) ?? {};

    // Extract operator information with safe casting
    final operator = _safeMapCast(json['operator']) ?? {};

    // Extract vehicle information with safe casting
    final vehicle = _safeMapCast(json['vehicle']) ?? {};

    // Extract classes for pricing (use economy class as default price)
    final classes = _safeMapCast(json['classes']) ?? {};
    final economyClass = _safeMapCast(classes['economy']) ?? {};
    final defaultPrice =
        economyClass['price'] as num? ?? 1000000; // Default 1M VND if no price
    final defaultCurrency = economyClass['currency'] as String? ?? 'VND';

    // Safely extract amenities
    Map<String, dynamic> safeAmenities = {};
    try {
      if (classes.isNotEmpty) {
        safeAmenities = Map<String, dynamic>.from(classes);
      }
    } catch (e) {
      // If casting fails, use empty map
      safeAmenities = {};
    }

    // Convert duration from milliseconds to minutes
    final durationMs = json['duration'] as int? ?? 0;
    final durationMinutes = (durationMs / (1000 * 60)).round();

    return Schedule(
      id: json['id'] as String,
      operatorId: operator['id'] as String? ?? '',
      operatorName: operator['name'] as String? ?? '',
      operatorLogo: operator['logo'] as String? ?? '',
      routeId: route['id'] as String? ?? '',
      vehicleNumber: json['vehicleNumber'] as String? ?? '',
      from: fromDestination['name'] as String? ?? '',
      to: toDestination['name'] as String? ?? '',
      fromCode: fromDestination['code'] as String? ?? '',
      toCode: toDestination['code'] as String? ?? '',
      departureTime: DateTime.parse(json['departureTime'] as String),
      arrivalTime: DateTime.parse(json['arrivalTime'] as String),
      duration: Duration(minutes: durationMinutes),
      price: defaultPrice.toDouble(),
      currency: defaultCurrency,
      transportType: route['transportType'] as String? ?? 'flight',
      vehicleType: vehicle['type'] as String? ?? 'aircraft',
      totalSeats:
          json['availableSeats'] as int? ??
          0, // API doesn't provide totalSeats separately
      availableSeats: json['availableSeats'] as int? ?? 0,
      status: json['status'] as String? ?? 'scheduled',
      classes: safeAmenities,
      metadata: Map<String, dynamic>.from(vehicle),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'operatorId': operatorId,
      'operatorName': operatorName,
      'operatorLogo': operatorLogo,
      'routeId': routeId,
      'vehicleNumber': vehicleNumber,
      'from': from,
      'to': to,
      'fromCode': fromCode,
      'toCode': toCode,
      'departureTime': departureTime.toIso8601String(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'duration': duration.inMinutes,
      'price': price,
      'currency': currency,
      'transportType': transportType,
      'vehicleType': vehicleType,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'status': status,
      'classes': classes,
      'metadata': metadata,
    };
  }
}

/// Search response model
class SearchResponse {
  final List<Schedule> schedules;
  final int total;
  final int page;
  final int limit;
  final bool hasMore;
  final Map<String, dynamic> filters;

  const SearchResponse({
    required this.schedules,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasMore,
    required this.filters,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final schedulesData = data['schedules'];

    List<Schedule> schedules = [];
    if (schedulesData is List) {
      schedules = schedulesData
          .map((item) => Schedule.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // Get pagination info from API response structure
    final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
    final total = pagination['total'] as int? ?? 0;
    final currentPage = pagination['current'] as int? ?? 1;
    final limit = pagination['limit'] as int? ?? 50;
    final totalPages = pagination['pages'] as int? ?? 1;

    return SearchResponse(
      schedules: schedules,
      total: total,
      page: currentPage,
      limit: limit,
      hasMore: currentPage < totalPages,
      filters: Map<String, dynamic>.from(data['filters'] ?? {}),
    );
  }
}

/// Extensions for Schedule
extension ScheduleX on Schedule {
  bool get isAvailable => status == 'active' && availableSeats > 0;

  bool get isAlmostFull => availableSeats <= (totalSeats * 0.1);

  String get formattedPrice => '${price.toStringAsFixed(0)} $currency';

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get departureTimeFormatted {
    return '${departureTime.hour.toString().padLeft(2, '0')}:'
        '${departureTime.minute.toString().padLeft(2, '0')}';
  }

  String get arrivalTimeFormatted {
    return '${arrivalTime.hour.toString().padLeft(2, '0')}:'
        '${arrivalTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Safe map casting helper
Map<String, dynamic>? _safeMapCast(dynamic value) {
  if (value == null) return null;
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    try {
      return Map<String, dynamic>.from(value);
    } catch (e) {
      return null;
    }
  }
  return null;
}
