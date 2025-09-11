import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../trip_detail/data/models/seat.dart';
import '../../results/data/models/trip.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

@freezed
class Booking with _$Booking {
  const factory Booking({
    required String id,
    required String pnr,
    required Trip trip,
    required List<Passenger> passengers,
    required ClassOption selectedClass,
    required List<Seat> selectedSeats,
    required BookingStatus status,
    required double totalPrice,
    required String currency,
    required DateTime createdAt,
    DateTime? confirmedAt,
    DateTime? cancelledAt,
    @Default({}) Map<String, dynamic> metadata,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);
}

@freezed
class Passenger with _$Passenger {
  const factory Passenger({
    required String id,
    required PassengerType type,
    required String firstName,
    required String lastName,
    DateTime? dateOfBirth,
    String? documentId,
    String? email,
    String? phone,
    @Default({}) Map<String, dynamic> metadata,
  }) = _Passenger;

  factory Passenger.fromJson(Map<String, dynamic> json) =>
      _$PassengerFromJson(json);
}

@freezed
class BookingRequest with _$BookingRequest {
  const factory BookingRequest({
    required String tripId,
    required String classId,
    required List<String> seatIds,
    required List<Passenger> passengers,
    required ContactInfo contactInfo,
    @Default({}) Map<String, dynamic> metadata,
  }) = _BookingRequest;

  factory BookingRequest.fromJson(Map<String, dynamic> json) =>
      _$BookingRequestFromJson(json);
}

@freezed
class ContactInfo with _$ContactInfo {
  const factory ContactInfo({
    required String email,
    required String phone,
    String? firstName,
    String? lastName,
  }) = _ContactInfo;

  factory ContactInfo.fromJson(Map<String, dynamic> json) =>
      _$ContactInfoFromJson(json);
}

extension PassengerX on Passenger {
  String get fullName => '$firstName $lastName';
  
  String get displayName {
    final typeText = type.displayName;
    return '$fullName ($typeText)';
  }
  
  bool get requiresDateOfBirth {
    return type == PassengerType.child || type == PassengerType.infant;
  }
  
  bool get requiresDocumentId {
    return type == PassengerType.adult;
  }
  
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    final age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      return age - 1;
    }
    return age;
  }
  
  bool get isValid {
    if (firstName.isEmpty || lastName.isEmpty) return false;
    if (requiresDateOfBirth && dateOfBirth == null) return false;
    if (requiresDocumentId && (documentId == null || documentId!.isEmpty)) {
      return false;
    }
    return true;
  }
}

extension BookingX on Booking {
  String get statusText => status.displayName;
  
  bool get canCancel {
    return status == BookingStatus.pending || status == BookingStatus.confirmed;
  }
  
  bool get isActive {
    return status == BookingStatus.confirmed || status == BookingStatus.pending;
  }
  
  String get departureText {
    return '${trip.departTimeText} - ${trip.from}';
  }
  
  String get arrivalText {
    return '${trip.arriveTimeText} - ${trip.to}';
  }
  
  String get passengerSummary {
    final adults = passengers.where((p) => p.type == PassengerType.adult).length;
    final children = passengers.where((p) => p.type == PassengerType.child).length;
    final infants = passengers.where((p) => p.type == PassengerType.infant).length;
    
    final parts = <String>[];
    if (adults > 0) parts.add('$adults người lớn');
    if (children > 0) parts.add('$children trẻ em');
    if (infants > 0) parts.add('$infants em bé');
    
    return parts.join(', ');
  }
  
  String get seatSummary {
    if (selectedSeats.isEmpty) return 'Chưa chọn ghế';
    return selectedSeats.map((seat) => seat.seatNumber).join(', ');
  }
  
  double get basePrice {
    return selectedClass.price * passengers.length;
  }
  
  double get seatPrice {
    return selectedSeats.fold(0.0, (sum, seat) => sum + seat.priceAddon);
  }
  
  double get taxes {
    return totalPrice * 0.1; // 10% tax
  }
  
  double get serviceFee {
    return 50000; // Fixed service fee
  }
}
