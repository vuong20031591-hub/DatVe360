import '../../../../core/constants/app_constants.dart';

class Booking {
  final String id;
  final String pnr;
  final String tripId;
  final List<Passenger> passengers;
  final String selectedClass;
  final List<String> selectedSeats;
  final BookingStatus status;
  final double totalPrice;
  final String currency;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final Map<String, dynamic> metadata;

  const Booking({
    required this.id,
    required this.pnr,
    required this.tripId,
    required this.passengers,
    required this.selectedClass,
    required this.selectedSeats,
    required this.status,
    required this.totalPrice,
    required this.currency,
    required this.createdAt,
    this.confirmedAt,
    this.cancelledAt,
    this.metadata = const {},
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      pnr: json['pnr'] ?? '',
      tripId: json['tripId'] ?? '',
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
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'])
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'])
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pnr': pnr,
      'tripId': tripId,
      'passengers': passengers.map((e) => e.toJson()).toList(),
      'selectedClass': selectedClass,
      'selectedSeats': selectedSeats,
      'status': status.name,
      'totalPrice': totalPrice,
      'currency': currency,
      'createdAt': createdAt.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Booking copyWith({
    String? id,
    String? pnr,
    String? tripId,
    List<Passenger>? passengers,
    String? selectedClass,
    List<String>? selectedSeats,
    BookingStatus? status,
    double? totalPrice,
    String? currency,
    DateTime? createdAt,
    DateTime? confirmedAt,
    DateTime? cancelledAt,
    Map<String, dynamic>? metadata,
  }) {
    return Booking(
      id: id ?? this.id,
      pnr: pnr ?? this.pnr,
      tripId: tripId ?? this.tripId,
      passengers: passengers ?? this.passengers,
      selectedClass: selectedClass ?? this.selectedClass,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
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
  final String documentId;
  final DateTime? dateOfBirth;
  final String? nationality;
  final String? gender;
  final Map<String, dynamic> metadata;

  const Passenger({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.type,
    required this.documentType,
    required this.documentId,
    this.dateOfBirth,
    this.nationality,
    this.gender,
    this.metadata = const {},
  });

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      type: PassengerType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PassengerType.adult,
      ),
      documentType: json['documentType'] ?? '',
      documentId: json['documentId'] ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      nationality: json['nationality'],
      gender: json['gender'],
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
      'documentId': documentId,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'nationality': nationality,
      'gender': gender,
      'metadata': metadata,
    };
  }
}

class BookingRequest {
  final String tripId;
  final List<Passenger> passengers;
  final String selectedClass;
  final List<String> selectedSeats;
  final ContactInfo contactInfo;
  final PaymentMethod paymentMethod;
  final Map<String, dynamic> metadata;

  const BookingRequest({
    required this.tripId,
    required this.passengers,
    required this.selectedClass,
    required this.selectedSeats,
    required this.contactInfo,
    required this.paymentMethod,
    this.metadata = const {},
  });

  factory BookingRequest.fromJson(Map<String, dynamic> json) {
    return BookingRequest(
      tripId: json['tripId'] ?? '',
      passengers:
          (json['passengers'] as List?)
              ?.map((e) => Passenger.fromJson(e))
              .toList() ??
          [],
      selectedClass: json['selectedClass'] ?? '',
      selectedSeats: List<String>.from(json['selectedSeats'] ?? []),
      contactInfo: ContactInfo.fromJson(json['contactInfo'] ?? {}),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['paymentMethod'],
        orElse: () => PaymentMethod.vnpay,
      ),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'passengers': passengers.map((e) => e.toJson()).toList(),
      'selectedClass': selectedClass,
      'selectedSeats': selectedSeats,
      'contactInfo': contactInfo.toJson(),
      'paymentMethod': paymentMethod.name,
      'metadata': metadata,
    };
  }
}

class ContactInfo {
  final String email;
  final String phone;
  final String? firstName;
  final String? lastName;
  final String? address;
  final String? city;
  final String? country;

  const ContactInfo({
    required this.email,
    required this.phone,
    this.firstName,
    this.lastName,
    this.address,
    this.city,
    this.country,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
      'city': city,
      'country': country,
    };
  }
}
