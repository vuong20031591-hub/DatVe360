import '../../../../core/constants/app_constants.dart';

class ContactInfo {
  final String email;
  final String phone;
  final String? firstName;
  final String? lastName;

  const ContactInfo({
    required this.email,
    required this.phone,
    this.firstName,
    this.lastName,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'firstName': firstName,
      'lastName': lastName,
    };
  }

  ContactInfo copyWith({
    String? email,
    String? phone,
    String? firstName,
    String? lastName,
  }) {
    return ContactInfo(
      email: email ?? this.email,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
    );
  }
}

class Booking {
  final String id;
  final String userId;
  final String scheduleId;
  final String pnr;
  final List<Passenger> passengers;
  final String selectedClass;
  final List<String> selectedSeats;
  final BookingStatus status;
  final double totalPrice;
  final String currency;
  final ContactInfo contactInfo;
  final String paymentMethod;
  final String? paymentId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final String? cancelReason;
  final DateTime? expiresAt;
  final Map<String, dynamic> metadata;

  const Booking({
    required this.id,
    required this.userId,
    required this.scheduleId,
    required this.pnr,
    required this.passengers,
    required this.selectedClass,
    required this.selectedSeats,
    required this.status,
    required this.totalPrice,
    required this.currency,
    required this.contactInfo,
    required this.paymentMethod,
    this.paymentId,
    required this.createdAt,
    this.updatedAt,
    this.confirmedAt,
    this.cancelledAt,
    this.cancelReason,
    this.expiresAt,
    this.metadata = const {},
  });

  /// Helper method to extract ID from object or string
  static String _extractId(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      return value['_id'] ?? value['id'] ?? '';
    }
    return '';
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'] ?? json['id'] ?? '',
      userId: _extractId(json['userId']),
      scheduleId: _extractId(json['scheduleId']),
      pnr: json['pnr'] ?? '',
      passengers:
          (json['passengers'] as List?)
              ?.map((e) => Passenger.fromJson(e))
              .toList() ??
          [],
      selectedClass: json['selectedClass'] ?? '',
      selectedSeats: List<String>.from(json['selectedSeats'] ?? []),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'VND',
      contactInfo: json['contactInfo'] != null
          ? ContactInfo.fromJson(json['contactInfo'])
          : const ContactInfo(email: '', phone: ''),
      paymentMethod: json['paymentMethod'] ?? '',
      paymentId: json['paymentId'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'])
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'])
          : null,
      cancelReason: json['cancelReason'],
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'scheduleId': scheduleId,
      'pnr': pnr,
      'passengers': passengers.map((e) => e.toJson()).toList(),
      'selectedClass': selectedClass,
      'selectedSeats': selectedSeats,
      'status': status.name,
      'totalPrice': totalPrice,
      'currency': currency,
      'contactInfo': contactInfo.toJson(),
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancelReason': cancelReason,
      'expiresAt': expiresAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Booking copyWith({
    String? id,
    String? userId,
    String? scheduleId,
    String? pnr,
    List<Passenger>? passengers,
    String? selectedClass,
    List<String>? selectedSeats,
    BookingStatus? status,
    double? totalPrice,
    String? currency,
    ContactInfo? contactInfo,
    String? paymentMethod,
    String? paymentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? confirmedAt,
    DateTime? cancelledAt,
    String? cancelReason,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      scheduleId: scheduleId ?? this.scheduleId,
      pnr: pnr ?? this.pnr,
      passengers: passengers ?? this.passengers,
      selectedClass: selectedClass ?? this.selectedClass,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      currency: currency ?? this.currency,
      contactInfo: contactInfo ?? this.contactInfo,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelReason: cancelReason ?? this.cancelReason,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

class Passenger {
  final String id;
  final String firstName;
  final String lastName;
  final PassengerType type;
  final String documentType;
  final String documentNumber;
  final DateTime? dateOfBirth;
  final String? nationality;
  final String? gender;
  final String? seatNumber;
  final Map<String, dynamic> metadata;

  const Passenger({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.type,
    required this.documentType,
    required this.documentNumber,
    this.dateOfBirth,
    this.nationality,
    this.gender,
    this.seatNumber,
    this.metadata = const {},
  });

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      type: PassengerType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PassengerType.adult,
      ),
      documentType: json['documentType'] ?? '',
      documentNumber: json['documentNumber'] ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      nationality: json['nationality'],
      gender: json['gender'],
      seatNumber: json['seatNumber'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'type': type.name,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'nationality': nationality,
      'gender': gender,
      'seatNumber': seatNumber,
      'metadata': metadata,
    };
  }
}

class BookingRequest {
  final String scheduleId;
  final List<Passenger> passengers;
  final String selectedClass;
  final List<String> selectedSeats;
  final ContactInfo contactInfo;
  final String paymentMethod;
  final Map<String, dynamic> metadata;

  const BookingRequest({
    required this.scheduleId,
    required this.passengers,
    required this.selectedClass,
    required this.selectedSeats,
    required this.contactInfo,
    required this.paymentMethod,
    this.metadata = const {},
  });

  factory BookingRequest.fromJson(Map<String, dynamic> json) {
    return BookingRequest(
      scheduleId: json['scheduleId'] ?? '',
      passengers:
          (json['passengers'] as List?)
              ?.map((e) => Passenger.fromJson(e))
              .toList() ??
          [],
      selectedClass: json['selectedClass'] ?? '',
      selectedSeats: List<String>.from(json['selectedSeats'] ?? []),
      contactInfo: ContactInfo.fromJson(json['contactInfo'] ?? {}),
      paymentMethod: json['paymentMethod'] ?? 'vnpay',
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheduleId': scheduleId,
      'passengers': passengers.map((e) => e.toJson()).toList(),
      'selectedClass': selectedClass,
      'selectedSeats': selectedSeats,
      'contactInfo': contactInfo.toJson(),
      'paymentMethod': paymentMethod,
      'metadata': metadata,
    };
  }
}
