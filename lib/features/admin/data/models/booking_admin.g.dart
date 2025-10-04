// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_admin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookingAdmin _$BookingAdminFromJson(Map<String, dynamic> json) =>
    _BookingAdmin(
      id: json['id'] as String,
      userId: UserInfo.fromJson(json['userId'] as Map<String, dynamic>),
      scheduleId: ScheduleInfo.fromJson(
        json['scheduleId'] as Map<String, dynamic>,
      ),
      pnr: json['pnr'] as String,
      status: json['status'] as String,
      passengers: (json['passengers'] as List<dynamic>)
          .map((e) => PassengerInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      selectedClass: json['selectedClass'] as String,
      selectedSeats: (json['selectedSeats'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      currency: json['currency'] as String,
      contactInfo: ContactInfo.fromJson(
        json['contactInfo'] as Map<String, dynamic>,
      ),
      paymentMethod: json['paymentMethod'] as String,
      paymentId: json['paymentId'] as String?,
      confirmedAt: json['confirmedAt'] == null
          ? null
          : DateTime.parse(json['confirmedAt'] as String),
      cancelledAt: json['cancelledAt'] == null
          ? null
          : DateTime.parse(json['cancelledAt'] as String),
      cancelReason: json['cancelReason'] as String?,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$BookingAdminToJson(_BookingAdmin instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'scheduleId': instance.scheduleId,
      'pnr': instance.pnr,
      'status': instance.status,
      'passengers': instance.passengers,
      'selectedClass': instance.selectedClass,
      'selectedSeats': instance.selectedSeats,
      'totalPrice': instance.totalPrice,
      'currency': instance.currency,
      'contactInfo': instance.contactInfo,
      'paymentMethod': instance.paymentMethod,
      'paymentId': instance.paymentId,
      'confirmedAt': instance.confirmedAt?.toIso8601String(),
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
      'cancelReason': instance.cancelReason,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => _UserInfo(
  id: json['id'] as String,
  displayName: json['displayName'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  avatar: json['avatar'] as String?,
);

Map<String, dynamic> _$UserInfoToJson(_UserInfo instance) => <String, dynamic>{
  'id': instance.id,
  'displayName': instance.displayName,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'avatar': instance.avatar,
};

_ScheduleInfo _$ScheduleInfoFromJson(Map<String, dynamic> json) =>
    _ScheduleInfo(
      id: json['id'] as String,
      routeId: RouteInfo.fromJson(json['routeId'] as Map<String, dynamic>),
      operatorId: OperatorInfo.fromJson(
        json['operatorId'] as Map<String, dynamic>,
      ),
      vehicleNumber: json['vehicleNumber'] as String,
      departureTime: DateTime.parse(json['departureTime'] as String),
      arrivalTime: DateTime.parse(json['arrivalTime'] as String),
      status: json['status'] as String,
    );

Map<String, dynamic> _$ScheduleInfoToJson(_ScheduleInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'routeId': instance.routeId,
      'operatorId': instance.operatorId,
      'vehicleNumber': instance.vehicleNumber,
      'departureTime': instance.departureTime.toIso8601String(),
      'arrivalTime': instance.arrivalTime.toIso8601String(),
      'status': instance.status,
    };

_RouteInfo _$RouteInfoFromJson(Map<String, dynamic> json) => _RouteInfo(
  id: json['id'] as String,
  fromDestination: DestinationInfo.fromJson(
    json['fromDestination'] as Map<String, dynamic>,
  ),
  toDestination: DestinationInfo.fromJson(
    json['toDestination'] as Map<String, dynamic>,
  ),
  transportType: json['transportType'] as String,
  distance: (json['distance'] as num).toInt(),
  estimatedDuration: (json['estimatedDuration'] as num).toInt(),
);

Map<String, dynamic> _$RouteInfoToJson(_RouteInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fromDestination': instance.fromDestination,
      'toDestination': instance.toDestination,
      'transportType': instance.transportType,
      'distance': instance.distance,
      'estimatedDuration': instance.estimatedDuration,
    };

_DestinationInfo _$DestinationInfoFromJson(Map<String, dynamic> json) =>
    _DestinationInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      city: json['city'] as String?,
      country: json['country'] as String?,
    );

Map<String, dynamic> _$DestinationInfoToJson(_DestinationInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'city': instance.city,
      'country': instance.country,
    };

_OperatorInfo _$OperatorInfoFromJson(Map<String, dynamic> json) =>
    _OperatorInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      logo: json['logo'] as String?,
      transportTypes: (json['transportTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$OperatorInfoToJson(_OperatorInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo': instance.logo,
      'transportTypes': instance.transportTypes,
    };

_PassengerInfo _$PassengerInfoFromJson(Map<String, dynamic> json) =>
    _PassengerInfo(
      id: json['id'] as String,
      type: json['type'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String?,
      documentType: json['documentType'] as String,
      documentNumber: json['documentNumber'] as String,
      nationality: json['nationality'] as String?,
      seatNumber: json['seatNumber'] as String?,
    );

Map<String, dynamic> _$PassengerInfoToJson(_PassengerInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'gender': instance.gender,
      'documentType': instance.documentType,
      'documentNumber': instance.documentNumber,
      'nationality': instance.nationality,
      'seatNumber': instance.seatNumber,
    };

_ContactInfo _$ContactInfoFromJson(Map<String, dynamic> json) => _ContactInfo(
  email: json['email'] as String,
  phone: json['phone'] as String,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
);

Map<String, dynamic> _$ContactInfoToJson(_ContactInfo instance) =>
    <String, dynamic>{
      'email': instance.email,
      'phone': instance.phone,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
    };

_BookingStats _$BookingStatsFromJson(Map<String, dynamic> json) =>
    _BookingStats(
      totalBookings: (json['totalBookings'] as num).toInt(),
      totalTickets: (json['totalTickets'] as num).toInt(),
      statusBreakdown: (json['statusBreakdown'] as List<dynamic>)
          .map((e) => StatusBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(),
      revenue: RevenueInfo.fromJson(json['revenue'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BookingStatsToJson(_BookingStats instance) =>
    <String, dynamic>{
      'totalBookings': instance.totalBookings,
      'totalTickets': instance.totalTickets,
      'statusBreakdown': instance.statusBreakdown,
      'revenue': instance.revenue,
    };

_StatusBreakdown _$StatusBreakdownFromJson(Map<String, dynamic> json) =>
    _StatusBreakdown(
      id: json['id'] as String,
      count: (json['count'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
    );

Map<String, dynamic> _$StatusBreakdownToJson(_StatusBreakdown instance) =>
    <String, dynamic>{
      'id': instance.id,
      'count': instance.count,
      'totalRevenue': instance.totalRevenue,
    };

_RevenueInfo _$RevenueInfoFromJson(Map<String, dynamic> json) => _RevenueInfo(
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
  avgBookingValue: (json['avgBookingValue'] as num).toDouble(),
);

Map<String, dynamic> _$RevenueInfoToJson(_RevenueInfo instance) =>
    <String, dynamic>{
      'totalRevenue': instance.totalRevenue,
      'avgBookingValue': instance.avgBookingValue,
    };

_TicketInfo _$TicketInfoFromJson(Map<String, dynamic> json) => _TicketInfo(
  id: json['id'] as String,
  bookingId: json['bookingId'] as String,
  userId: json['userId'] as String,
  passengerId: json['passengerId'] as String,
  pnr: json['pnr'] as String,
  ticketNumber: json['ticketNumber'] as String,
  qrData: json['qrData'] as String,
  qrCodeUrl: json['qrCodeUrl'] as String?,
  pdfUrl: json['pdfUrl'] as String?,
  status: json['status'] as String,
  validUntil: json['validUntil'] == null
      ? null
      : DateTime.parse(json['validUntil'] as String),
  usedAt: json['usedAt'] == null
      ? null
      : DateTime.parse(json['usedAt'] as String),
  usedBy: json['usedBy'] as String?,
  cancelledAt: json['cancelledAt'] == null
      ? null
      : DateTime.parse(json['cancelledAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$TicketInfoToJson(_TicketInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookingId': instance.bookingId,
      'userId': instance.userId,
      'passengerId': instance.passengerId,
      'pnr': instance.pnr,
      'ticketNumber': instance.ticketNumber,
      'qrData': instance.qrData,
      'qrCodeUrl': instance.qrCodeUrl,
      'pdfUrl': instance.pdfUrl,
      'status': instance.status,
      'validUntil': instance.validUntil?.toIso8601String(),
      'usedAt': instance.usedAt?.toIso8601String(),
      'usedBy': instance.usedBy,
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
