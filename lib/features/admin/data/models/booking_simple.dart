// Simple booking models without Freezed to avoid compatibility issues

class BookingSimple {
  final String id;
  final UserInfoSimple userId;
  final ScheduleInfoSimple scheduleId;
  final String pnr;
  final String status;
  final int totalPassengers;
  final int totalTickets;
  final double totalAmount;
  final String currency;
  final String paymentMethod;
  final ContactInfoSimple contactInfo;
  final List<PassengerInfoSimple> passengers;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final DateTime? completedAt;

  BookingSimple({
    required this.id,
    required this.userId,
    required this.scheduleId,
    required this.pnr,
    required this.status,
    required this.totalPassengers,
    required this.totalTickets,
    required this.totalAmount,
    required this.currency,
    required this.paymentMethod,
    required this.contactInfo,
    required this.passengers,
    required this.createdAt,
    this.confirmedAt,
    this.cancelledAt,
    this.completedAt,
  });

  factory BookingSimple.fromJson(Map<String, dynamic> json) {
    return BookingSimple(
      id: json['_id'] ?? '',
      userId: UserInfoSimple.fromJson(json['userId'] ?? {}),
      scheduleId: ScheduleInfoSimple.fromJson(json['scheduleId'] ?? {}),
      pnr: json['pnr'] ?? '',
      status: json['status'] ?? 'pending',
      totalPassengers: json['totalPassengers'] ?? 0,
      totalTickets: (json['selectedSeats'] as List?)?.length ?? json['totalPassengers'] ?? 0,
      totalAmount: (json['totalPrice'] ?? json['totalAmount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'VND',
      paymentMethod: json['paymentMethod'] ?? 'cash',
      contactInfo: ContactInfoSimple.fromJson(json['contactInfo'] ?? {}),
      passengers: (json['passengers'] as List?)
              ?.map((p) => PassengerInfoSimple.fromJson(p))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      confirmedAt: json['confirmedAt'] != null ? DateTime.parse(json['confirmedAt']) : null,
      cancelledAt: json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'cancelled':
        return 'Đã hủy';
      case 'completed':
        return 'Hoàn thành';
      case 'expired':
        return 'Hết hạn';
      default:
        return status;
    }
  }
}

class UserInfoSimple {
  final String id;
  final String displayName;
  final String email;
  final String? phoneNumber;

  UserInfoSimple({
    required this.id,
    required this.displayName,
    required this.email,
    this.phoneNumber,
  });

  factory UserInfoSimple.fromJson(Map<String, dynamic> json) {
    return UserInfoSimple(
      id: json['_id'] ?? '',
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
    );
  }
}

class ScheduleInfoSimple {
  final String id;
  final RouteInfoSimple routeId;
  final OperatorInfoSimple operatorId;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double basePrice;
  final String flightNumber;
  final String duration;

  ScheduleInfoSimple({
    required this.id,
    required this.routeId,
    required this.operatorId,
    required this.departureTime,
    required this.arrivalTime,
    required this.basePrice,
    required this.flightNumber,
    required this.duration,
  });

  factory ScheduleInfoSimple.fromJson(Map<String, dynamic> json) {
    return ScheduleInfoSimple(
      id: json['_id'] ?? '',
      routeId: RouteInfoSimple.fromJson(json['routeId'] ?? {}),
      operatorId: OperatorInfoSimple.fromJson(json['operatorId'] ?? {}),
      departureTime: DateTime.parse(json['departureTime'] ?? DateTime.now().toIso8601String()),
      arrivalTime: DateTime.parse(json['arrivalTime'] ?? DateTime.now().toIso8601String()),
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      flightNumber: json['flightNumber'] ?? json['trainNumber'] ?? json['busNumber'] ?? '',
      duration: json['duration'] ?? '0h 0m',
    );
  }
}

class RouteInfoSimple {
  final String id;
  final DestinationInfoSimple fromDestination;
  final DestinationInfoSimple toDestination;
  final String transportType;

  RouteInfoSimple({
    required this.id,
    required this.fromDestination,
    required this.toDestination,
    required this.transportType,
  });

  factory RouteInfoSimple.fromJson(Map<String, dynamic> json) {
    return RouteInfoSimple(
      id: json['_id'] ?? '',
      fromDestination: DestinationInfoSimple.fromJson(json['fromDestination'] ?? {}),
      toDestination: DestinationInfoSimple.fromJson(json['toDestination'] ?? {}),
      transportType: json['transportType'] ?? 'flight',
    );
  }
}

class DestinationInfoSimple {
  final String id;
  final String name;
  final String code;
  final String city;

  DestinationInfoSimple({
    required this.id,
    required this.name,
    required this.code,
    required this.city,
  });

  factory DestinationInfoSimple.fromJson(Map<String, dynamic> json) {
    return DestinationInfoSimple(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      city: json['city'] ?? '',
    );
  }
}

class OperatorInfoSimple {
  final String id;
  final String name;
  final String? logo;
  final String type;

  OperatorInfoSimple({
    required this.id,
    required this.name,
    this.logo,
    required this.type,
  });

  factory OperatorInfoSimple.fromJson(Map<String, dynamic> json) {
    // Determine type from transportTypes array or default to 'airline'
    String operatorType = 'airline';
    if (json['transportTypes'] != null && (json['transportTypes'] as List).isNotEmpty) {
      final types = json['transportTypes'] as List;
      operatorType = types.first.toString();
    }

    return OperatorInfoSimple(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      logo: json['metadata']?['logo'] ?? json['logo'],
      type: operatorType,
    );
  }
}

class PassengerInfoSimple {
  final String id;
  final String type;
  final String firstName;
  final String lastName;
  final String? seatNumber;

  PassengerInfoSimple({
    required this.id,
    required this.type,
    required this.firstName,
    required this.lastName,
    this.seatNumber,
  });

  factory PassengerInfoSimple.fromJson(Map<String, dynamic> json) {
    return PassengerInfoSimple(
      id: json['_id'] ?? '',
      type: json['type'] ?? 'adult',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      seatNumber: json['seatNumber'],
    );
  }

  String get fullName => '$firstName $lastName';

  String get typeDisplay {
    switch (type) {
      case 'adult':
        return 'Người lớn';
      case 'child':
        return 'Trẻ em';
      case 'infant':
        return 'Em bé';
      default:
        return type;
    }
  }
}

class ContactInfoSimple {
  final String email;
  final String phone;
  final String? firstName;
  final String? lastName;

  ContactInfoSimple({
    required this.email,
    required this.phone,
    this.firstName,
    this.lastName,
  });

  factory ContactInfoSimple.fromJson(Map<String, dynamic> json) {
    return ContactInfoSimple(
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }
}

class BookingStatsSimple {
  final int total;
  final int pending;
  final int confirmed;
  final int cancelled;
  final int completed;
  final double totalRevenue;
  final String currency;

  BookingStatsSimple({
    required this.total,
    required this.pending,
    required this.confirmed,
    required this.cancelled,
    required this.completed,
    required this.totalRevenue,
    required this.currency,
  });

  factory BookingStatsSimple.fromJson(Map<String, dynamic> json) {
    return BookingStatsSimple(
      total: json['total'] ?? 0,
      pending: json['statusBreakdown']?['pending'] ?? 0,
      confirmed: json['statusBreakdown']?['confirmed'] ?? 0,
      cancelled: json['statusBreakdown']?['cancelled'] ?? 0,
      completed: json['statusBreakdown']?['completed'] ?? 0,
      totalRevenue: (json['revenue']?['total'] ?? 0).toDouble(),
      currency: json['revenue']?['currency'] ?? 'VND',
    );
  }
}

