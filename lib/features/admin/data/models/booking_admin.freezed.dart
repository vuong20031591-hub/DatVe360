// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_admin.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookingAdmin {

 String get id; UserInfo get userId; ScheduleInfo get scheduleId; String get pnr; String get status; List<PassengerInfo> get passengers; String get selectedClass; List<String> get selectedSeats; double get totalPrice; String get currency; ContactInfo get contactInfo; String get paymentMethod; String? get paymentId; DateTime? get confirmedAt; DateTime? get cancelledAt; String? get cancelReason; DateTime? get expiresAt; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of BookingAdmin
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingAdminCopyWith<BookingAdmin> get copyWith => _$BookingAdminCopyWithImpl<BookingAdmin>(this as BookingAdmin, _$identity);

  /// Serializes this BookingAdmin to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingAdmin&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.scheduleId, scheduleId) || other.scheduleId == scheduleId)&&(identical(other.pnr, pnr) || other.pnr == pnr)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.passengers, passengers)&&(identical(other.selectedClass, selectedClass) || other.selectedClass == selectedClass)&&const DeepCollectionEquality().equals(other.selectedSeats, selectedSeats)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.contactInfo, contactInfo) || other.contactInfo == contactInfo)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.cancelReason, cancelReason) || other.cancelReason == cancelReason)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,scheduleId,pnr,status,const DeepCollectionEquality().hash(passengers),selectedClass,const DeepCollectionEquality().hash(selectedSeats),totalPrice,currency,contactInfo,paymentMethod,paymentId,confirmedAt,cancelledAt,cancelReason,expiresAt,createdAt,updatedAt]);

@override
String toString() {
  return 'BookingAdmin(id: $id, userId: $userId, scheduleId: $scheduleId, pnr: $pnr, status: $status, passengers: $passengers, selectedClass: $selectedClass, selectedSeats: $selectedSeats, totalPrice: $totalPrice, currency: $currency, contactInfo: $contactInfo, paymentMethod: $paymentMethod, paymentId: $paymentId, confirmedAt: $confirmedAt, cancelledAt: $cancelledAt, cancelReason: $cancelReason, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $BookingAdminCopyWith<$Res>  {
  factory $BookingAdminCopyWith(BookingAdmin value, $Res Function(BookingAdmin) _then) = _$BookingAdminCopyWithImpl;
@useResult
$Res call({
 String id, UserInfo userId, ScheduleInfo scheduleId, String pnr, String status, List<PassengerInfo> passengers, String selectedClass, List<String> selectedSeats, double totalPrice, String currency, ContactInfo contactInfo, String paymentMethod, String? paymentId, DateTime? confirmedAt, DateTime? cancelledAt, String? cancelReason, DateTime? expiresAt, DateTime createdAt, DateTime updatedAt
});


$UserInfoCopyWith<$Res> get userId;$ScheduleInfoCopyWith<$Res> get scheduleId;$ContactInfoCopyWith<$Res> get contactInfo;

}
/// @nodoc
class _$BookingAdminCopyWithImpl<$Res>
    implements $BookingAdminCopyWith<$Res> {
  _$BookingAdminCopyWithImpl(this._self, this._then);

  final BookingAdmin _self;
  final $Res Function(BookingAdmin) _then;

/// Create a copy of BookingAdmin
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? scheduleId = null,Object? pnr = null,Object? status = null,Object? passengers = null,Object? selectedClass = null,Object? selectedSeats = null,Object? totalPrice = null,Object? currency = null,Object? contactInfo = null,Object? paymentMethod = null,Object? paymentId = freezed,Object? confirmedAt = freezed,Object? cancelledAt = freezed,Object? cancelReason = freezed,Object? expiresAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as UserInfo,scheduleId: null == scheduleId ? _self.scheduleId : scheduleId // ignore: cast_nullable_to_non_nullable
as ScheduleInfo,pnr: null == pnr ? _self.pnr : pnr // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,passengers: null == passengers ? _self.passengers : passengers // ignore: cast_nullable_to_non_nullable
as List<PassengerInfo>,selectedClass: null == selectedClass ? _self.selectedClass : selectedClass // ignore: cast_nullable_to_non_nullable
as String,selectedSeats: null == selectedSeats ? _self.selectedSeats : selectedSeats // ignore: cast_nullable_to_non_nullable
as List<String>,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,contactInfo: null == contactInfo ? _self.contactInfo : contactInfo // ignore: cast_nullable_to_non_nullable
as ContactInfo,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,paymentId: freezed == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String?,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelReason: freezed == cancelReason ? _self.cancelReason : cancelReason // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of BookingAdmin
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserInfoCopyWith<$Res> get userId {
  
  return $UserInfoCopyWith<$Res>(_self.userId, (value) {
    return _then(_self.copyWith(userId: value));
  });
}/// Create a copy of BookingAdmin
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScheduleInfoCopyWith<$Res> get scheduleId {
  
  return $ScheduleInfoCopyWith<$Res>(_self.scheduleId, (value) {
    return _then(_self.copyWith(scheduleId: value));
  });
}/// Create a copy of BookingAdmin
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactInfoCopyWith<$Res> get contactInfo {
  
  return $ContactInfoCopyWith<$Res>(_self.contactInfo, (value) {
    return _then(_self.copyWith(contactInfo: value));
  });
}
}


/// Adds pattern-matching-related methods to [BookingAdmin].
extension BookingAdminPatterns on BookingAdmin {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingAdmin value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingAdmin() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingAdmin value)  $default,){
final _that = this;
switch (_that) {
case _BookingAdmin():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingAdmin value)?  $default,){
final _that = this;
switch (_that) {
case _BookingAdmin() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  UserInfo userId,  ScheduleInfo scheduleId,  String pnr,  String status,  List<PassengerInfo> passengers,  String selectedClass,  List<String> selectedSeats,  double totalPrice,  String currency,  ContactInfo contactInfo,  String paymentMethod,  String? paymentId,  DateTime? confirmedAt,  DateTime? cancelledAt,  String? cancelReason,  DateTime? expiresAt,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingAdmin() when $default != null:
return $default(_that.id,_that.userId,_that.scheduleId,_that.pnr,_that.status,_that.passengers,_that.selectedClass,_that.selectedSeats,_that.totalPrice,_that.currency,_that.contactInfo,_that.paymentMethod,_that.paymentId,_that.confirmedAt,_that.cancelledAt,_that.cancelReason,_that.expiresAt,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  UserInfo userId,  ScheduleInfo scheduleId,  String pnr,  String status,  List<PassengerInfo> passengers,  String selectedClass,  List<String> selectedSeats,  double totalPrice,  String currency,  ContactInfo contactInfo,  String paymentMethod,  String? paymentId,  DateTime? confirmedAt,  DateTime? cancelledAt,  String? cancelReason,  DateTime? expiresAt,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _BookingAdmin():
return $default(_that.id,_that.userId,_that.scheduleId,_that.pnr,_that.status,_that.passengers,_that.selectedClass,_that.selectedSeats,_that.totalPrice,_that.currency,_that.contactInfo,_that.paymentMethod,_that.paymentId,_that.confirmedAt,_that.cancelledAt,_that.cancelReason,_that.expiresAt,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  UserInfo userId,  ScheduleInfo scheduleId,  String pnr,  String status,  List<PassengerInfo> passengers,  String selectedClass,  List<String> selectedSeats,  double totalPrice,  String currency,  ContactInfo contactInfo,  String paymentMethod,  String? paymentId,  DateTime? confirmedAt,  DateTime? cancelledAt,  String? cancelReason,  DateTime? expiresAt,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _BookingAdmin() when $default != null:
return $default(_that.id,_that.userId,_that.scheduleId,_that.pnr,_that.status,_that.passengers,_that.selectedClass,_that.selectedSeats,_that.totalPrice,_that.currency,_that.contactInfo,_that.paymentMethod,_that.paymentId,_that.confirmedAt,_that.cancelledAt,_that.cancelReason,_that.expiresAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookingAdmin extends BookingAdmin {
  const _BookingAdmin({required this.id, required this.userId, required this.scheduleId, required this.pnr, required this.status, required final  List<PassengerInfo> passengers, required this.selectedClass, required final  List<String> selectedSeats, required this.totalPrice, required this.currency, required this.contactInfo, required this.paymentMethod, this.paymentId, this.confirmedAt, this.cancelledAt, this.cancelReason, this.expiresAt, required this.createdAt, required this.updatedAt}): _passengers = passengers,_selectedSeats = selectedSeats,super._();
  factory _BookingAdmin.fromJson(Map<String, dynamic> json) => _$BookingAdminFromJson(json);

@override final  String id;
@override final  UserInfo userId;
@override final  ScheduleInfo scheduleId;
@override final  String pnr;
@override final  String status;
 final  List<PassengerInfo> _passengers;
@override List<PassengerInfo> get passengers {
  if (_passengers is EqualUnmodifiableListView) return _passengers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_passengers);
}

@override final  String selectedClass;
 final  List<String> _selectedSeats;
@override List<String> get selectedSeats {
  if (_selectedSeats is EqualUnmodifiableListView) return _selectedSeats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedSeats);
}

@override final  double totalPrice;
@override final  String currency;
@override final  ContactInfo contactInfo;
@override final  String paymentMethod;
@override final  String? paymentId;
@override final  DateTime? confirmedAt;
@override final  DateTime? cancelledAt;
@override final  String? cancelReason;
@override final  DateTime? expiresAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of BookingAdmin
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingAdminCopyWith<_BookingAdmin> get copyWith => __$BookingAdminCopyWithImpl<_BookingAdmin>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingAdminToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingAdmin&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.scheduleId, scheduleId) || other.scheduleId == scheduleId)&&(identical(other.pnr, pnr) || other.pnr == pnr)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._passengers, _passengers)&&(identical(other.selectedClass, selectedClass) || other.selectedClass == selectedClass)&&const DeepCollectionEquality().equals(other._selectedSeats, _selectedSeats)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.contactInfo, contactInfo) || other.contactInfo == contactInfo)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.cancelReason, cancelReason) || other.cancelReason == cancelReason)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,scheduleId,pnr,status,const DeepCollectionEquality().hash(_passengers),selectedClass,const DeepCollectionEquality().hash(_selectedSeats),totalPrice,currency,contactInfo,paymentMethod,paymentId,confirmedAt,cancelledAt,cancelReason,expiresAt,createdAt,updatedAt]);

@override
String toString() {
  return 'BookingAdmin(id: $id, userId: $userId, scheduleId: $scheduleId, pnr: $pnr, status: $status, passengers: $passengers, selectedClass: $selectedClass, selectedSeats: $selectedSeats, totalPrice: $totalPrice, currency: $currency, contactInfo: $contactInfo, paymentMethod: $paymentMethod, paymentId: $paymentId, confirmedAt: $confirmedAt, cancelledAt: $cancelledAt, cancelReason: $cancelReason, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BookingAdminCopyWith<$Res> implements $BookingAdminCopyWith<$Res> {
  factory _$BookingAdminCopyWith(_BookingAdmin value, $Res Function(_BookingAdmin) _then) = __$BookingAdminCopyWithImpl;
@override @useResult
$Res call({
 String id, UserInfo userId, ScheduleInfo scheduleId, String pnr, String status, List<PassengerInfo> passengers, String selectedClass, List<String> selectedSeats, double totalPrice, String currency, ContactInfo contactInfo, String paymentMethod, String? paymentId, DateTime? confirmedAt, DateTime? cancelledAt, String? cancelReason, DateTime? expiresAt, DateTime createdAt, DateTime updatedAt
});


@override $UserInfoCopyWith<$Res> get userId;@override $ScheduleInfoCopyWith<$Res> get scheduleId;@override $ContactInfoCopyWith<$Res> get contactInfo;

}
/// @nodoc
class __$BookingAdminCopyWithImpl<$Res>
    implements _$BookingAdminCopyWith<$Res> {
  __$BookingAdminCopyWithImpl(this._self, this._then);

  final _BookingAdmin _self;
  final $Res Function(_BookingAdmin) _then;

/// Create a copy of BookingAdmin
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? scheduleId = null,Object? pnr = null,Object? status = null,Object? passengers = null,Object? selectedClass = null,Object? selectedSeats = null,Object? totalPrice = null,Object? currency = null,Object? contactInfo = null,Object? paymentMethod = null,Object? paymentId = freezed,Object? confirmedAt = freezed,Object? cancelledAt = freezed,Object? cancelReason = freezed,Object? expiresAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_BookingAdmin(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as UserInfo,scheduleId: null == scheduleId ? _self.scheduleId : scheduleId // ignore: cast_nullable_to_non_nullable
as ScheduleInfo,pnr: null == pnr ? _self.pnr : pnr // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,passengers: null == passengers ? _self._passengers : passengers // ignore: cast_nullable_to_non_nullable
as List<PassengerInfo>,selectedClass: null == selectedClass ? _self.selectedClass : selectedClass // ignore: cast_nullable_to_non_nullable
as String,selectedSeats: null == selectedSeats ? _self._selectedSeats : selectedSeats // ignore: cast_nullable_to_non_nullable
as List<String>,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,contactInfo: null == contactInfo ? _self.contactInfo : contactInfo // ignore: cast_nullable_to_non_nullable
as ContactInfo,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,paymentId: freezed == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String?,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelReason: freezed == cancelReason ? _self.cancelReason : cancelReason // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of BookingAdmin
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserInfoCopyWith<$Res> get userId {
  
  return $UserInfoCopyWith<$Res>(_self.userId, (value) {
    return _then(_self.copyWith(userId: value));
  });
}/// Create a copy of BookingAdmin
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScheduleInfoCopyWith<$Res> get scheduleId {
  
  return $ScheduleInfoCopyWith<$Res>(_self.scheduleId, (value) {
    return _then(_self.copyWith(scheduleId: value));
  });
}/// Create a copy of BookingAdmin
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactInfoCopyWith<$Res> get contactInfo {
  
  return $ContactInfoCopyWith<$Res>(_self.contactInfo, (value) {
    return _then(_self.copyWith(contactInfo: value));
  });
}
}


/// @nodoc
mixin _$UserInfo {

 String get id; String? get displayName; String? get email; String? get phoneNumber; String? get avatar;
/// Create a copy of UserInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserInfoCopyWith<UserInfo> get copyWith => _$UserInfoCopyWithImpl<UserInfo>(this as UserInfo, _$identity);

  /// Serializes this UserInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.avatar, avatar) || other.avatar == avatar));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,email,phoneNumber,avatar);

@override
String toString() {
  return 'UserInfo(id: $id, displayName: $displayName, email: $email, phoneNumber: $phoneNumber, avatar: $avatar)';
}


}

/// @nodoc
abstract mixin class $UserInfoCopyWith<$Res>  {
  factory $UserInfoCopyWith(UserInfo value, $Res Function(UserInfo) _then) = _$UserInfoCopyWithImpl;
@useResult
$Res call({
 String id, String? displayName, String? email, String? phoneNumber, String? avatar
});




}
/// @nodoc
class _$UserInfoCopyWithImpl<$Res>
    implements $UserInfoCopyWith<$Res> {
  _$UserInfoCopyWithImpl(this._self, this._then);

  final UserInfo _self;
  final $Res Function(UserInfo) _then;

/// Create a copy of UserInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayName = freezed,Object? email = freezed,Object? phoneNumber = freezed,Object? avatar = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserInfo].
extension UserInfoPatterns on UserInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserInfo value)  $default,){
final _that = this;
switch (_that) {
case _UserInfo():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserInfo value)?  $default,){
final _that = this;
switch (_that) {
case _UserInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? displayName,  String? email,  String? phoneNumber,  String? avatar)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserInfo() when $default != null:
return $default(_that.id,_that.displayName,_that.email,_that.phoneNumber,_that.avatar);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? displayName,  String? email,  String? phoneNumber,  String? avatar)  $default,) {final _that = this;
switch (_that) {
case _UserInfo():
return $default(_that.id,_that.displayName,_that.email,_that.phoneNumber,_that.avatar);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? displayName,  String? email,  String? phoneNumber,  String? avatar)?  $default,) {final _that = this;
switch (_that) {
case _UserInfo() when $default != null:
return $default(_that.id,_that.displayName,_that.email,_that.phoneNumber,_that.avatar);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserInfo implements UserInfo {
  const _UserInfo({required this.id, this.displayName, this.email, this.phoneNumber, this.avatar});
  factory _UserInfo.fromJson(Map<String, dynamic> json) => _$UserInfoFromJson(json);

@override final  String id;
@override final  String? displayName;
@override final  String? email;
@override final  String? phoneNumber;
@override final  String? avatar;

/// Create a copy of UserInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserInfoCopyWith<_UserInfo> get copyWith => __$UserInfoCopyWithImpl<_UserInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.avatar, avatar) || other.avatar == avatar));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,email,phoneNumber,avatar);

@override
String toString() {
  return 'UserInfo(id: $id, displayName: $displayName, email: $email, phoneNumber: $phoneNumber, avatar: $avatar)';
}


}

/// @nodoc
abstract mixin class _$UserInfoCopyWith<$Res> implements $UserInfoCopyWith<$Res> {
  factory _$UserInfoCopyWith(_UserInfo value, $Res Function(_UserInfo) _then) = __$UserInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String? displayName, String? email, String? phoneNumber, String? avatar
});




}
/// @nodoc
class __$UserInfoCopyWithImpl<$Res>
    implements _$UserInfoCopyWith<$Res> {
  __$UserInfoCopyWithImpl(this._self, this._then);

  final _UserInfo _self;
  final $Res Function(_UserInfo) _then;

/// Create a copy of UserInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayName = freezed,Object? email = freezed,Object? phoneNumber = freezed,Object? avatar = freezed,}) {
  return _then(_UserInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ScheduleInfo {

 String get id; RouteInfo get routeId; OperatorInfo get operatorId; String get vehicleNumber; DateTime get departureTime; DateTime get arrivalTime; String get status;
/// Create a copy of ScheduleInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleInfoCopyWith<ScheduleInfo> get copyWith => _$ScheduleInfoCopyWithImpl<ScheduleInfo>(this as ScheduleInfo, _$identity);

  /// Serializes this ScheduleInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.routeId, routeId) || other.routeId == routeId)&&(identical(other.operatorId, operatorId) || other.operatorId == operatorId)&&(identical(other.vehicleNumber, vehicleNumber) || other.vehicleNumber == vehicleNumber)&&(identical(other.departureTime, departureTime) || other.departureTime == departureTime)&&(identical(other.arrivalTime, arrivalTime) || other.arrivalTime == arrivalTime)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,routeId,operatorId,vehicleNumber,departureTime,arrivalTime,status);

@override
String toString() {
  return 'ScheduleInfo(id: $id, routeId: $routeId, operatorId: $operatorId, vehicleNumber: $vehicleNumber, departureTime: $departureTime, arrivalTime: $arrivalTime, status: $status)';
}


}

/// @nodoc
abstract mixin class $ScheduleInfoCopyWith<$Res>  {
  factory $ScheduleInfoCopyWith(ScheduleInfo value, $Res Function(ScheduleInfo) _then) = _$ScheduleInfoCopyWithImpl;
@useResult
$Res call({
 String id, RouteInfo routeId, OperatorInfo operatorId, String vehicleNumber, DateTime departureTime, DateTime arrivalTime, String status
});


$RouteInfoCopyWith<$Res> get routeId;$OperatorInfoCopyWith<$Res> get operatorId;

}
/// @nodoc
class _$ScheduleInfoCopyWithImpl<$Res>
    implements $ScheduleInfoCopyWith<$Res> {
  _$ScheduleInfoCopyWithImpl(this._self, this._then);

  final ScheduleInfo _self;
  final $Res Function(ScheduleInfo) _then;

/// Create a copy of ScheduleInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? routeId = null,Object? operatorId = null,Object? vehicleNumber = null,Object? departureTime = null,Object? arrivalTime = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,routeId: null == routeId ? _self.routeId : routeId // ignore: cast_nullable_to_non_nullable
as RouteInfo,operatorId: null == operatorId ? _self.operatorId : operatorId // ignore: cast_nullable_to_non_nullable
as OperatorInfo,vehicleNumber: null == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String,departureTime: null == departureTime ? _self.departureTime : departureTime // ignore: cast_nullable_to_non_nullable
as DateTime,arrivalTime: null == arrivalTime ? _self.arrivalTime : arrivalTime // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of ScheduleInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RouteInfoCopyWith<$Res> get routeId {
  
  return $RouteInfoCopyWith<$Res>(_self.routeId, (value) {
    return _then(_self.copyWith(routeId: value));
  });
}/// Create a copy of ScheduleInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OperatorInfoCopyWith<$Res> get operatorId {
  
  return $OperatorInfoCopyWith<$Res>(_self.operatorId, (value) {
    return _then(_self.copyWith(operatorId: value));
  });
}
}


/// Adds pattern-matching-related methods to [ScheduleInfo].
extension ScheduleInfoPatterns on ScheduleInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduleInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduleInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduleInfo value)  $default,){
final _that = this;
switch (_that) {
case _ScheduleInfo():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduleInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduleInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  RouteInfo routeId,  OperatorInfo operatorId,  String vehicleNumber,  DateTime departureTime,  DateTime arrivalTime,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduleInfo() when $default != null:
return $default(_that.id,_that.routeId,_that.operatorId,_that.vehicleNumber,_that.departureTime,_that.arrivalTime,_that.status);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  RouteInfo routeId,  OperatorInfo operatorId,  String vehicleNumber,  DateTime departureTime,  DateTime arrivalTime,  String status)  $default,) {final _that = this;
switch (_that) {
case _ScheduleInfo():
return $default(_that.id,_that.routeId,_that.operatorId,_that.vehicleNumber,_that.departureTime,_that.arrivalTime,_that.status);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  RouteInfo routeId,  OperatorInfo operatorId,  String vehicleNumber,  DateTime departureTime,  DateTime arrivalTime,  String status)?  $default,) {final _that = this;
switch (_that) {
case _ScheduleInfo() when $default != null:
return $default(_that.id,_that.routeId,_that.operatorId,_that.vehicleNumber,_that.departureTime,_that.arrivalTime,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScheduleInfo implements ScheduleInfo {
  const _ScheduleInfo({required this.id, required this.routeId, required this.operatorId, required this.vehicleNumber, required this.departureTime, required this.arrivalTime, required this.status});
  factory _ScheduleInfo.fromJson(Map<String, dynamic> json) => _$ScheduleInfoFromJson(json);

@override final  String id;
@override final  RouteInfo routeId;
@override final  OperatorInfo operatorId;
@override final  String vehicleNumber;
@override final  DateTime departureTime;
@override final  DateTime arrivalTime;
@override final  String status;

/// Create a copy of ScheduleInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduleInfoCopyWith<_ScheduleInfo> get copyWith => __$ScheduleInfoCopyWithImpl<_ScheduleInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduleInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduleInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.routeId, routeId) || other.routeId == routeId)&&(identical(other.operatorId, operatorId) || other.operatorId == operatorId)&&(identical(other.vehicleNumber, vehicleNumber) || other.vehicleNumber == vehicleNumber)&&(identical(other.departureTime, departureTime) || other.departureTime == departureTime)&&(identical(other.arrivalTime, arrivalTime) || other.arrivalTime == arrivalTime)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,routeId,operatorId,vehicleNumber,departureTime,arrivalTime,status);

@override
String toString() {
  return 'ScheduleInfo(id: $id, routeId: $routeId, operatorId: $operatorId, vehicleNumber: $vehicleNumber, departureTime: $departureTime, arrivalTime: $arrivalTime, status: $status)';
}


}

/// @nodoc
abstract mixin class _$ScheduleInfoCopyWith<$Res> implements $ScheduleInfoCopyWith<$Res> {
  factory _$ScheduleInfoCopyWith(_ScheduleInfo value, $Res Function(_ScheduleInfo) _then) = __$ScheduleInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, RouteInfo routeId, OperatorInfo operatorId, String vehicleNumber, DateTime departureTime, DateTime arrivalTime, String status
});


@override $RouteInfoCopyWith<$Res> get routeId;@override $OperatorInfoCopyWith<$Res> get operatorId;

}
/// @nodoc
class __$ScheduleInfoCopyWithImpl<$Res>
    implements _$ScheduleInfoCopyWith<$Res> {
  __$ScheduleInfoCopyWithImpl(this._self, this._then);

  final _ScheduleInfo _self;
  final $Res Function(_ScheduleInfo) _then;

/// Create a copy of ScheduleInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? routeId = null,Object? operatorId = null,Object? vehicleNumber = null,Object? departureTime = null,Object? arrivalTime = null,Object? status = null,}) {
  return _then(_ScheduleInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,routeId: null == routeId ? _self.routeId : routeId // ignore: cast_nullable_to_non_nullable
as RouteInfo,operatorId: null == operatorId ? _self.operatorId : operatorId // ignore: cast_nullable_to_non_nullable
as OperatorInfo,vehicleNumber: null == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String,departureTime: null == departureTime ? _self.departureTime : departureTime // ignore: cast_nullable_to_non_nullable
as DateTime,arrivalTime: null == arrivalTime ? _self.arrivalTime : arrivalTime // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of ScheduleInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RouteInfoCopyWith<$Res> get routeId {
  
  return $RouteInfoCopyWith<$Res>(_self.routeId, (value) {
    return _then(_self.copyWith(routeId: value));
  });
}/// Create a copy of ScheduleInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OperatorInfoCopyWith<$Res> get operatorId {
  
  return $OperatorInfoCopyWith<$Res>(_self.operatorId, (value) {
    return _then(_self.copyWith(operatorId: value));
  });
}
}


/// @nodoc
mixin _$RouteInfo {

 String get id; DestinationInfo get fromDestination; DestinationInfo get toDestination; String get transportType; int get distance; int get estimatedDuration;
/// Create a copy of RouteInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteInfoCopyWith<RouteInfo> get copyWith => _$RouteInfoCopyWithImpl<RouteInfo>(this as RouteInfo, _$identity);

  /// Serializes this RouteInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.fromDestination, fromDestination) || other.fromDestination == fromDestination)&&(identical(other.toDestination, toDestination) || other.toDestination == toDestination)&&(identical(other.transportType, transportType) || other.transportType == transportType)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.estimatedDuration, estimatedDuration) || other.estimatedDuration == estimatedDuration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fromDestination,toDestination,transportType,distance,estimatedDuration);

@override
String toString() {
  return 'RouteInfo(id: $id, fromDestination: $fromDestination, toDestination: $toDestination, transportType: $transportType, distance: $distance, estimatedDuration: $estimatedDuration)';
}


}

/// @nodoc
abstract mixin class $RouteInfoCopyWith<$Res>  {
  factory $RouteInfoCopyWith(RouteInfo value, $Res Function(RouteInfo) _then) = _$RouteInfoCopyWithImpl;
@useResult
$Res call({
 String id, DestinationInfo fromDestination, DestinationInfo toDestination, String transportType, int distance, int estimatedDuration
});


$DestinationInfoCopyWith<$Res> get fromDestination;$DestinationInfoCopyWith<$Res> get toDestination;

}
/// @nodoc
class _$RouteInfoCopyWithImpl<$Res>
    implements $RouteInfoCopyWith<$Res> {
  _$RouteInfoCopyWithImpl(this._self, this._then);

  final RouteInfo _self;
  final $Res Function(RouteInfo) _then;

/// Create a copy of RouteInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fromDestination = null,Object? toDestination = null,Object? transportType = null,Object? distance = null,Object? estimatedDuration = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromDestination: null == fromDestination ? _self.fromDestination : fromDestination // ignore: cast_nullable_to_non_nullable
as DestinationInfo,toDestination: null == toDestination ? _self.toDestination : toDestination // ignore: cast_nullable_to_non_nullable
as DestinationInfo,transportType: null == transportType ? _self.transportType : transportType // ignore: cast_nullable_to_non_nullable
as String,distance: null == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as int,estimatedDuration: null == estimatedDuration ? _self.estimatedDuration : estimatedDuration // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of RouteInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DestinationInfoCopyWith<$Res> get fromDestination {
  
  return $DestinationInfoCopyWith<$Res>(_self.fromDestination, (value) {
    return _then(_self.copyWith(fromDestination: value));
  });
}/// Create a copy of RouteInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DestinationInfoCopyWith<$Res> get toDestination {
  
  return $DestinationInfoCopyWith<$Res>(_self.toDestination, (value) {
    return _then(_self.copyWith(toDestination: value));
  });
}
}


/// Adds pattern-matching-related methods to [RouteInfo].
extension RouteInfoPatterns on RouteInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RouteInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RouteInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RouteInfo value)  $default,){
final _that = this;
switch (_that) {
case _RouteInfo():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RouteInfo value)?  $default,){
final _that = this;
switch (_that) {
case _RouteInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DestinationInfo fromDestination,  DestinationInfo toDestination,  String transportType,  int distance,  int estimatedDuration)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteInfo() when $default != null:
return $default(_that.id,_that.fromDestination,_that.toDestination,_that.transportType,_that.distance,_that.estimatedDuration);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DestinationInfo fromDestination,  DestinationInfo toDestination,  String transportType,  int distance,  int estimatedDuration)  $default,) {final _that = this;
switch (_that) {
case _RouteInfo():
return $default(_that.id,_that.fromDestination,_that.toDestination,_that.transportType,_that.distance,_that.estimatedDuration);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DestinationInfo fromDestination,  DestinationInfo toDestination,  String transportType,  int distance,  int estimatedDuration)?  $default,) {final _that = this;
switch (_that) {
case _RouteInfo() when $default != null:
return $default(_that.id,_that.fromDestination,_that.toDestination,_that.transportType,_that.distance,_that.estimatedDuration);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RouteInfo implements RouteInfo {
  const _RouteInfo({required this.id, required this.fromDestination, required this.toDestination, required this.transportType, required this.distance, required this.estimatedDuration});
  factory _RouteInfo.fromJson(Map<String, dynamic> json) => _$RouteInfoFromJson(json);

@override final  String id;
@override final  DestinationInfo fromDestination;
@override final  DestinationInfo toDestination;
@override final  String transportType;
@override final  int distance;
@override final  int estimatedDuration;

/// Create a copy of RouteInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteInfoCopyWith<_RouteInfo> get copyWith => __$RouteInfoCopyWithImpl<_RouteInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RouteInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.fromDestination, fromDestination) || other.fromDestination == fromDestination)&&(identical(other.toDestination, toDestination) || other.toDestination == toDestination)&&(identical(other.transportType, transportType) || other.transportType == transportType)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.estimatedDuration, estimatedDuration) || other.estimatedDuration == estimatedDuration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fromDestination,toDestination,transportType,distance,estimatedDuration);

@override
String toString() {
  return 'RouteInfo(id: $id, fromDestination: $fromDestination, toDestination: $toDestination, transportType: $transportType, distance: $distance, estimatedDuration: $estimatedDuration)';
}


}

/// @nodoc
abstract mixin class _$RouteInfoCopyWith<$Res> implements $RouteInfoCopyWith<$Res> {
  factory _$RouteInfoCopyWith(_RouteInfo value, $Res Function(_RouteInfo) _then) = __$RouteInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, DestinationInfo fromDestination, DestinationInfo toDestination, String transportType, int distance, int estimatedDuration
});


@override $DestinationInfoCopyWith<$Res> get fromDestination;@override $DestinationInfoCopyWith<$Res> get toDestination;

}
/// @nodoc
class __$RouteInfoCopyWithImpl<$Res>
    implements _$RouteInfoCopyWith<$Res> {
  __$RouteInfoCopyWithImpl(this._self, this._then);

  final _RouteInfo _self;
  final $Res Function(_RouteInfo) _then;

/// Create a copy of RouteInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fromDestination = null,Object? toDestination = null,Object? transportType = null,Object? distance = null,Object? estimatedDuration = null,}) {
  return _then(_RouteInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromDestination: null == fromDestination ? _self.fromDestination : fromDestination // ignore: cast_nullable_to_non_nullable
as DestinationInfo,toDestination: null == toDestination ? _self.toDestination : toDestination // ignore: cast_nullable_to_non_nullable
as DestinationInfo,transportType: null == transportType ? _self.transportType : transportType // ignore: cast_nullable_to_non_nullable
as String,distance: null == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as int,estimatedDuration: null == estimatedDuration ? _self.estimatedDuration : estimatedDuration // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of RouteInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DestinationInfoCopyWith<$Res> get fromDestination {
  
  return $DestinationInfoCopyWith<$Res>(_self.fromDestination, (value) {
    return _then(_self.copyWith(fromDestination: value));
  });
}/// Create a copy of RouteInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DestinationInfoCopyWith<$Res> get toDestination {
  
  return $DestinationInfoCopyWith<$Res>(_self.toDestination, (value) {
    return _then(_self.copyWith(toDestination: value));
  });
}
}


/// @nodoc
mixin _$DestinationInfo {

 String get id; String get name; String get code; String? get city; String? get country;
/// Create a copy of DestinationInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DestinationInfoCopyWith<DestinationInfo> get copyWith => _$DestinationInfoCopyWithImpl<DestinationInfo>(this as DestinationInfo, _$identity);

  /// Serializes this DestinationInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DestinationInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,code,city,country);

@override
String toString() {
  return 'DestinationInfo(id: $id, name: $name, code: $code, city: $city, country: $country)';
}


}

/// @nodoc
abstract mixin class $DestinationInfoCopyWith<$Res>  {
  factory $DestinationInfoCopyWith(DestinationInfo value, $Res Function(DestinationInfo) _then) = _$DestinationInfoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String code, String? city, String? country
});




}
/// @nodoc
class _$DestinationInfoCopyWithImpl<$Res>
    implements $DestinationInfoCopyWith<$Res> {
  _$DestinationInfoCopyWithImpl(this._self, this._then);

  final DestinationInfo _self;
  final $Res Function(DestinationInfo) _then;

/// Create a copy of DestinationInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? code = null,Object? city = freezed,Object? country = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DestinationInfo].
extension DestinationInfoPatterns on DestinationInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DestinationInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DestinationInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DestinationInfo value)  $default,){
final _that = this;
switch (_that) {
case _DestinationInfo():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DestinationInfo value)?  $default,){
final _that = this;
switch (_that) {
case _DestinationInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String code,  String? city,  String? country)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DestinationInfo() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.city,_that.country);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String code,  String? city,  String? country)  $default,) {final _that = this;
switch (_that) {
case _DestinationInfo():
return $default(_that.id,_that.name,_that.code,_that.city,_that.country);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String code,  String? city,  String? country)?  $default,) {final _that = this;
switch (_that) {
case _DestinationInfo() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.city,_that.country);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DestinationInfo implements DestinationInfo {
  const _DestinationInfo({required this.id, required this.name, required this.code, this.city, this.country});
  factory _DestinationInfo.fromJson(Map<String, dynamic> json) => _$DestinationInfoFromJson(json);

@override final  String id;
@override final  String name;
@override final  String code;
@override final  String? city;
@override final  String? country;

/// Create a copy of DestinationInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DestinationInfoCopyWith<_DestinationInfo> get copyWith => __$DestinationInfoCopyWithImpl<_DestinationInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DestinationInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DestinationInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,code,city,country);

@override
String toString() {
  return 'DestinationInfo(id: $id, name: $name, code: $code, city: $city, country: $country)';
}


}

/// @nodoc
abstract mixin class _$DestinationInfoCopyWith<$Res> implements $DestinationInfoCopyWith<$Res> {
  factory _$DestinationInfoCopyWith(_DestinationInfo value, $Res Function(_DestinationInfo) _then) = __$DestinationInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String code, String? city, String? country
});




}
/// @nodoc
class __$DestinationInfoCopyWithImpl<$Res>
    implements _$DestinationInfoCopyWith<$Res> {
  __$DestinationInfoCopyWithImpl(this._self, this._then);

  final _DestinationInfo _self;
  final $Res Function(_DestinationInfo) _then;

/// Create a copy of DestinationInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? code = null,Object? city = freezed,Object? country = freezed,}) {
  return _then(_DestinationInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$OperatorInfo {

 String get id; String get name; String? get logo; List<String>? get transportTypes;
/// Create a copy of OperatorInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OperatorInfoCopyWith<OperatorInfo> get copyWith => _$OperatorInfoCopyWithImpl<OperatorInfo>(this as OperatorInfo, _$identity);

  /// Serializes this OperatorInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OperatorInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.logo, logo) || other.logo == logo)&&const DeepCollectionEquality().equals(other.transportTypes, transportTypes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,logo,const DeepCollectionEquality().hash(transportTypes));

@override
String toString() {
  return 'OperatorInfo(id: $id, name: $name, logo: $logo, transportTypes: $transportTypes)';
}


}

/// @nodoc
abstract mixin class $OperatorInfoCopyWith<$Res>  {
  factory $OperatorInfoCopyWith(OperatorInfo value, $Res Function(OperatorInfo) _then) = _$OperatorInfoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? logo, List<String>? transportTypes
});




}
/// @nodoc
class _$OperatorInfoCopyWithImpl<$Res>
    implements $OperatorInfoCopyWith<$Res> {
  _$OperatorInfoCopyWithImpl(this._self, this._then);

  final OperatorInfo _self;
  final $Res Function(OperatorInfo) _then;

/// Create a copy of OperatorInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? logo = freezed,Object? transportTypes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,logo: freezed == logo ? _self.logo : logo // ignore: cast_nullable_to_non_nullable
as String?,transportTypes: freezed == transportTypes ? _self.transportTypes : transportTypes // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [OperatorInfo].
extension OperatorInfoPatterns on OperatorInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OperatorInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OperatorInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OperatorInfo value)  $default,){
final _that = this;
switch (_that) {
case _OperatorInfo():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OperatorInfo value)?  $default,){
final _that = this;
switch (_that) {
case _OperatorInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? logo,  List<String>? transportTypes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OperatorInfo() when $default != null:
return $default(_that.id,_that.name,_that.logo,_that.transportTypes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? logo,  List<String>? transportTypes)  $default,) {final _that = this;
switch (_that) {
case _OperatorInfo():
return $default(_that.id,_that.name,_that.logo,_that.transportTypes);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? logo,  List<String>? transportTypes)?  $default,) {final _that = this;
switch (_that) {
case _OperatorInfo() when $default != null:
return $default(_that.id,_that.name,_that.logo,_that.transportTypes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OperatorInfo implements OperatorInfo {
  const _OperatorInfo({required this.id, required this.name, this.logo, final  List<String>? transportTypes}): _transportTypes = transportTypes;
  factory _OperatorInfo.fromJson(Map<String, dynamic> json) => _$OperatorInfoFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? logo;
 final  List<String>? _transportTypes;
@override List<String>? get transportTypes {
  final value = _transportTypes;
  if (value == null) return null;
  if (_transportTypes is EqualUnmodifiableListView) return _transportTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of OperatorInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OperatorInfoCopyWith<_OperatorInfo> get copyWith => __$OperatorInfoCopyWithImpl<_OperatorInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OperatorInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OperatorInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.logo, logo) || other.logo == logo)&&const DeepCollectionEquality().equals(other._transportTypes, _transportTypes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,logo,const DeepCollectionEquality().hash(_transportTypes));

@override
String toString() {
  return 'OperatorInfo(id: $id, name: $name, logo: $logo, transportTypes: $transportTypes)';
}


}

/// @nodoc
abstract mixin class _$OperatorInfoCopyWith<$Res> implements $OperatorInfoCopyWith<$Res> {
  factory _$OperatorInfoCopyWith(_OperatorInfo value, $Res Function(_OperatorInfo) _then) = __$OperatorInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? logo, List<String>? transportTypes
});




}
/// @nodoc
class __$OperatorInfoCopyWithImpl<$Res>
    implements _$OperatorInfoCopyWith<$Res> {
  __$OperatorInfoCopyWithImpl(this._self, this._then);

  final _OperatorInfo _self;
  final $Res Function(_OperatorInfo) _then;

/// Create a copy of OperatorInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? logo = freezed,Object? transportTypes = freezed,}) {
  return _then(_OperatorInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,logo: freezed == logo ? _self.logo : logo // ignore: cast_nullable_to_non_nullable
as String?,transportTypes: freezed == transportTypes ? _self._transportTypes : transportTypes // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}


/// @nodoc
mixin _$PassengerInfo {

 String get id; String get type; String get firstName; String get lastName; DateTime? get dateOfBirth; String? get gender; String get documentType; String get documentNumber; String? get nationality; String? get seatNumber;
/// Create a copy of PassengerInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PassengerInfoCopyWith<PassengerInfo> get copyWith => _$PassengerInfoCopyWithImpl<PassengerInfo>(this as PassengerInfo, _$identity);

  /// Serializes this PassengerInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PassengerInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.documentNumber, documentNumber) || other.documentNumber == documentNumber)&&(identical(other.nationality, nationality) || other.nationality == nationality)&&(identical(other.seatNumber, seatNumber) || other.seatNumber == seatNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,firstName,lastName,dateOfBirth,gender,documentType,documentNumber,nationality,seatNumber);

@override
String toString() {
  return 'PassengerInfo(id: $id, type: $type, firstName: $firstName, lastName: $lastName, dateOfBirth: $dateOfBirth, gender: $gender, documentType: $documentType, documentNumber: $documentNumber, nationality: $nationality, seatNumber: $seatNumber)';
}


}

/// @nodoc
abstract mixin class $PassengerInfoCopyWith<$Res>  {
  factory $PassengerInfoCopyWith(PassengerInfo value, $Res Function(PassengerInfo) _then) = _$PassengerInfoCopyWithImpl;
@useResult
$Res call({
 String id, String type, String firstName, String lastName, DateTime? dateOfBirth, String? gender, String documentType, String documentNumber, String? nationality, String? seatNumber
});




}
/// @nodoc
class _$PassengerInfoCopyWithImpl<$Res>
    implements $PassengerInfoCopyWith<$Res> {
  _$PassengerInfoCopyWithImpl(this._self, this._then);

  final PassengerInfo _self;
  final $Res Function(PassengerInfo) _then;

/// Create a copy of PassengerInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? firstName = null,Object? lastName = null,Object? dateOfBirth = freezed,Object? gender = freezed,Object? documentType = null,Object? documentNumber = null,Object? nationality = freezed,Object? seatNumber = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as String,documentNumber: null == documentNumber ? _self.documentNumber : documentNumber // ignore: cast_nullable_to_non_nullable
as String,nationality: freezed == nationality ? _self.nationality : nationality // ignore: cast_nullable_to_non_nullable
as String?,seatNumber: freezed == seatNumber ? _self.seatNumber : seatNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PassengerInfo].
extension PassengerInfoPatterns on PassengerInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PassengerInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PassengerInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PassengerInfo value)  $default,){
final _that = this;
switch (_that) {
case _PassengerInfo():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PassengerInfo value)?  $default,){
final _that = this;
switch (_that) {
case _PassengerInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String firstName,  String lastName,  DateTime? dateOfBirth,  String? gender,  String documentType,  String documentNumber,  String? nationality,  String? seatNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PassengerInfo() when $default != null:
return $default(_that.id,_that.type,_that.firstName,_that.lastName,_that.dateOfBirth,_that.gender,_that.documentType,_that.documentNumber,_that.nationality,_that.seatNumber);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String firstName,  String lastName,  DateTime? dateOfBirth,  String? gender,  String documentType,  String documentNumber,  String? nationality,  String? seatNumber)  $default,) {final _that = this;
switch (_that) {
case _PassengerInfo():
return $default(_that.id,_that.type,_that.firstName,_that.lastName,_that.dateOfBirth,_that.gender,_that.documentType,_that.documentNumber,_that.nationality,_that.seatNumber);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String firstName,  String lastName,  DateTime? dateOfBirth,  String? gender,  String documentType,  String documentNumber,  String? nationality,  String? seatNumber)?  $default,) {final _that = this;
switch (_that) {
case _PassengerInfo() when $default != null:
return $default(_that.id,_that.type,_that.firstName,_that.lastName,_that.dateOfBirth,_that.gender,_that.documentType,_that.documentNumber,_that.nationality,_that.seatNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PassengerInfo extends PassengerInfo {
  const _PassengerInfo({required this.id, required this.type, required this.firstName, required this.lastName, this.dateOfBirth, this.gender, required this.documentType, required this.documentNumber, this.nationality, this.seatNumber}): super._();
  factory _PassengerInfo.fromJson(Map<String, dynamic> json) => _$PassengerInfoFromJson(json);

@override final  String id;
@override final  String type;
@override final  String firstName;
@override final  String lastName;
@override final  DateTime? dateOfBirth;
@override final  String? gender;
@override final  String documentType;
@override final  String documentNumber;
@override final  String? nationality;
@override final  String? seatNumber;

/// Create a copy of PassengerInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PassengerInfoCopyWith<_PassengerInfo> get copyWith => __$PassengerInfoCopyWithImpl<_PassengerInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PassengerInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PassengerInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.documentNumber, documentNumber) || other.documentNumber == documentNumber)&&(identical(other.nationality, nationality) || other.nationality == nationality)&&(identical(other.seatNumber, seatNumber) || other.seatNumber == seatNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,firstName,lastName,dateOfBirth,gender,documentType,documentNumber,nationality,seatNumber);

@override
String toString() {
  return 'PassengerInfo(id: $id, type: $type, firstName: $firstName, lastName: $lastName, dateOfBirth: $dateOfBirth, gender: $gender, documentType: $documentType, documentNumber: $documentNumber, nationality: $nationality, seatNumber: $seatNumber)';
}


}

/// @nodoc
abstract mixin class _$PassengerInfoCopyWith<$Res> implements $PassengerInfoCopyWith<$Res> {
  factory _$PassengerInfoCopyWith(_PassengerInfo value, $Res Function(_PassengerInfo) _then) = __$PassengerInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String firstName, String lastName, DateTime? dateOfBirth, String? gender, String documentType, String documentNumber, String? nationality, String? seatNumber
});




}
/// @nodoc
class __$PassengerInfoCopyWithImpl<$Res>
    implements _$PassengerInfoCopyWith<$Res> {
  __$PassengerInfoCopyWithImpl(this._self, this._then);

  final _PassengerInfo _self;
  final $Res Function(_PassengerInfo) _then;

/// Create a copy of PassengerInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? firstName = null,Object? lastName = null,Object? dateOfBirth = freezed,Object? gender = freezed,Object? documentType = null,Object? documentNumber = null,Object? nationality = freezed,Object? seatNumber = freezed,}) {
  return _then(_PassengerInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as String,documentNumber: null == documentNumber ? _self.documentNumber : documentNumber // ignore: cast_nullable_to_non_nullable
as String,nationality: freezed == nationality ? _self.nationality : nationality // ignore: cast_nullable_to_non_nullable
as String?,seatNumber: freezed == seatNumber ? _self.seatNumber : seatNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ContactInfo {

 String get email; String get phone; String? get firstName; String? get lastName;
/// Create a copy of ContactInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactInfoCopyWith<ContactInfo> get copyWith => _$ContactInfoCopyWithImpl<ContactInfo>(this as ContactInfo, _$identity);

  /// Serializes this ContactInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactInfo&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,phone,firstName,lastName);

@override
String toString() {
  return 'ContactInfo(email: $email, phone: $phone, firstName: $firstName, lastName: $lastName)';
}


}

/// @nodoc
abstract mixin class $ContactInfoCopyWith<$Res>  {
  factory $ContactInfoCopyWith(ContactInfo value, $Res Function(ContactInfo) _then) = _$ContactInfoCopyWithImpl;
@useResult
$Res call({
 String email, String phone, String? firstName, String? lastName
});




}
/// @nodoc
class _$ContactInfoCopyWithImpl<$Res>
    implements $ContactInfoCopyWith<$Res> {
  _$ContactInfoCopyWithImpl(this._self, this._then);

  final ContactInfo _self;
  final $Res Function(ContactInfo) _then;

/// Create a copy of ContactInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? phone = null,Object? firstName = freezed,Object? lastName = freezed,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContactInfo].
extension ContactInfoPatterns on ContactInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactInfo value)  $default,){
final _that = this;
switch (_that) {
case _ContactInfo():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ContactInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String phone,  String? firstName,  String? lastName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactInfo() when $default != null:
return $default(_that.email,_that.phone,_that.firstName,_that.lastName);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String phone,  String? firstName,  String? lastName)  $default,) {final _that = this;
switch (_that) {
case _ContactInfo():
return $default(_that.email,_that.phone,_that.firstName,_that.lastName);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String phone,  String? firstName,  String? lastName)?  $default,) {final _that = this;
switch (_that) {
case _ContactInfo() when $default != null:
return $default(_that.email,_that.phone,_that.firstName,_that.lastName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContactInfo implements ContactInfo {
  const _ContactInfo({required this.email, required this.phone, this.firstName, this.lastName});
  factory _ContactInfo.fromJson(Map<String, dynamic> json) => _$ContactInfoFromJson(json);

@override final  String email;
@override final  String phone;
@override final  String? firstName;
@override final  String? lastName;

/// Create a copy of ContactInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactInfoCopyWith<_ContactInfo> get copyWith => __$ContactInfoCopyWithImpl<_ContactInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContactInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactInfo&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,phone,firstName,lastName);

@override
String toString() {
  return 'ContactInfo(email: $email, phone: $phone, firstName: $firstName, lastName: $lastName)';
}


}

/// @nodoc
abstract mixin class _$ContactInfoCopyWith<$Res> implements $ContactInfoCopyWith<$Res> {
  factory _$ContactInfoCopyWith(_ContactInfo value, $Res Function(_ContactInfo) _then) = __$ContactInfoCopyWithImpl;
@override @useResult
$Res call({
 String email, String phone, String? firstName, String? lastName
});




}
/// @nodoc
class __$ContactInfoCopyWithImpl<$Res>
    implements _$ContactInfoCopyWith<$Res> {
  __$ContactInfoCopyWithImpl(this._self, this._then);

  final _ContactInfo _self;
  final $Res Function(_ContactInfo) _then;

/// Create a copy of ContactInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? phone = null,Object? firstName = freezed,Object? lastName = freezed,}) {
  return _then(_ContactInfo(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$BookingStats {

 int get totalBookings; int get totalTickets; List<StatusBreakdown> get statusBreakdown; RevenueInfo get revenue;
/// Create a copy of BookingStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingStatsCopyWith<BookingStats> get copyWith => _$BookingStatsCopyWithImpl<BookingStats>(this as BookingStats, _$identity);

  /// Serializes this BookingStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingStats&&(identical(other.totalBookings, totalBookings) || other.totalBookings == totalBookings)&&(identical(other.totalTickets, totalTickets) || other.totalTickets == totalTickets)&&const DeepCollectionEquality().equals(other.statusBreakdown, statusBreakdown)&&(identical(other.revenue, revenue) || other.revenue == revenue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalBookings,totalTickets,const DeepCollectionEquality().hash(statusBreakdown),revenue);

@override
String toString() {
  return 'BookingStats(totalBookings: $totalBookings, totalTickets: $totalTickets, statusBreakdown: $statusBreakdown, revenue: $revenue)';
}


}

/// @nodoc
abstract mixin class $BookingStatsCopyWith<$Res>  {
  factory $BookingStatsCopyWith(BookingStats value, $Res Function(BookingStats) _then) = _$BookingStatsCopyWithImpl;
@useResult
$Res call({
 int totalBookings, int totalTickets, List<StatusBreakdown> statusBreakdown, RevenueInfo revenue
});


$RevenueInfoCopyWith<$Res> get revenue;

}
/// @nodoc
class _$BookingStatsCopyWithImpl<$Res>
    implements $BookingStatsCopyWith<$Res> {
  _$BookingStatsCopyWithImpl(this._self, this._then);

  final BookingStats _self;
  final $Res Function(BookingStats) _then;

/// Create a copy of BookingStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalBookings = null,Object? totalTickets = null,Object? statusBreakdown = null,Object? revenue = null,}) {
  return _then(_self.copyWith(
totalBookings: null == totalBookings ? _self.totalBookings : totalBookings // ignore: cast_nullable_to_non_nullable
as int,totalTickets: null == totalTickets ? _self.totalTickets : totalTickets // ignore: cast_nullable_to_non_nullable
as int,statusBreakdown: null == statusBreakdown ? _self.statusBreakdown : statusBreakdown // ignore: cast_nullable_to_non_nullable
as List<StatusBreakdown>,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as RevenueInfo,
  ));
}
/// Create a copy of BookingStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RevenueInfoCopyWith<$Res> get revenue {
  
  return $RevenueInfoCopyWith<$Res>(_self.revenue, (value) {
    return _then(_self.copyWith(revenue: value));
  });
}
}


/// Adds pattern-matching-related methods to [BookingStats].
extension BookingStatsPatterns on BookingStats {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingStats() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingStats value)  $default,){
final _that = this;
switch (_that) {
case _BookingStats():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingStats value)?  $default,){
final _that = this;
switch (_that) {
case _BookingStats() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalBookings,  int totalTickets,  List<StatusBreakdown> statusBreakdown,  RevenueInfo revenue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingStats() when $default != null:
return $default(_that.totalBookings,_that.totalTickets,_that.statusBreakdown,_that.revenue);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalBookings,  int totalTickets,  List<StatusBreakdown> statusBreakdown,  RevenueInfo revenue)  $default,) {final _that = this;
switch (_that) {
case _BookingStats():
return $default(_that.totalBookings,_that.totalTickets,_that.statusBreakdown,_that.revenue);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalBookings,  int totalTickets,  List<StatusBreakdown> statusBreakdown,  RevenueInfo revenue)?  $default,) {final _that = this;
switch (_that) {
case _BookingStats() when $default != null:
return $default(_that.totalBookings,_that.totalTickets,_that.statusBreakdown,_that.revenue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookingStats implements BookingStats {
  const _BookingStats({required this.totalBookings, required this.totalTickets, required final  List<StatusBreakdown> statusBreakdown, required this.revenue}): _statusBreakdown = statusBreakdown;
  factory _BookingStats.fromJson(Map<String, dynamic> json) => _$BookingStatsFromJson(json);

@override final  int totalBookings;
@override final  int totalTickets;
 final  List<StatusBreakdown> _statusBreakdown;
@override List<StatusBreakdown> get statusBreakdown {
  if (_statusBreakdown is EqualUnmodifiableListView) return _statusBreakdown;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_statusBreakdown);
}

@override final  RevenueInfo revenue;

/// Create a copy of BookingStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingStatsCopyWith<_BookingStats> get copyWith => __$BookingStatsCopyWithImpl<_BookingStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingStats&&(identical(other.totalBookings, totalBookings) || other.totalBookings == totalBookings)&&(identical(other.totalTickets, totalTickets) || other.totalTickets == totalTickets)&&const DeepCollectionEquality().equals(other._statusBreakdown, _statusBreakdown)&&(identical(other.revenue, revenue) || other.revenue == revenue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalBookings,totalTickets,const DeepCollectionEquality().hash(_statusBreakdown),revenue);

@override
String toString() {
  return 'BookingStats(totalBookings: $totalBookings, totalTickets: $totalTickets, statusBreakdown: $statusBreakdown, revenue: $revenue)';
}


}

/// @nodoc
abstract mixin class _$BookingStatsCopyWith<$Res> implements $BookingStatsCopyWith<$Res> {
  factory _$BookingStatsCopyWith(_BookingStats value, $Res Function(_BookingStats) _then) = __$BookingStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalBookings, int totalTickets, List<StatusBreakdown> statusBreakdown, RevenueInfo revenue
});


@override $RevenueInfoCopyWith<$Res> get revenue;

}
/// @nodoc
class __$BookingStatsCopyWithImpl<$Res>
    implements _$BookingStatsCopyWith<$Res> {
  __$BookingStatsCopyWithImpl(this._self, this._then);

  final _BookingStats _self;
  final $Res Function(_BookingStats) _then;

/// Create a copy of BookingStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalBookings = null,Object? totalTickets = null,Object? statusBreakdown = null,Object? revenue = null,}) {
  return _then(_BookingStats(
totalBookings: null == totalBookings ? _self.totalBookings : totalBookings // ignore: cast_nullable_to_non_nullable
as int,totalTickets: null == totalTickets ? _self.totalTickets : totalTickets // ignore: cast_nullable_to_non_nullable
as int,statusBreakdown: null == statusBreakdown ? _self._statusBreakdown : statusBreakdown // ignore: cast_nullable_to_non_nullable
as List<StatusBreakdown>,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as RevenueInfo,
  ));
}

/// Create a copy of BookingStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RevenueInfoCopyWith<$Res> get revenue {
  
  return $RevenueInfoCopyWith<$Res>(_self.revenue, (value) {
    return _then(_self.copyWith(revenue: value));
  });
}
}


/// @nodoc
mixin _$StatusBreakdown {

 String get id; int get count; double get totalRevenue;
/// Create a copy of StatusBreakdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatusBreakdownCopyWith<StatusBreakdown> get copyWith => _$StatusBreakdownCopyWithImpl<StatusBreakdown>(this as StatusBreakdown, _$identity);

  /// Serializes this StatusBreakdown to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatusBreakdown&&(identical(other.id, id) || other.id == id)&&(identical(other.count, count) || other.count == count)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,count,totalRevenue);

@override
String toString() {
  return 'StatusBreakdown(id: $id, count: $count, totalRevenue: $totalRevenue)';
}


}

/// @nodoc
abstract mixin class $StatusBreakdownCopyWith<$Res>  {
  factory $StatusBreakdownCopyWith(StatusBreakdown value, $Res Function(StatusBreakdown) _then) = _$StatusBreakdownCopyWithImpl;
@useResult
$Res call({
 String id, int count, double totalRevenue
});




}
/// @nodoc
class _$StatusBreakdownCopyWithImpl<$Res>
    implements $StatusBreakdownCopyWith<$Res> {
  _$StatusBreakdownCopyWithImpl(this._self, this._then);

  final StatusBreakdown _self;
  final $Res Function(StatusBreakdown) _then;

/// Create a copy of StatusBreakdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? count = null,Object? totalRevenue = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [StatusBreakdown].
extension StatusBreakdownPatterns on StatusBreakdown {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatusBreakdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatusBreakdown() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatusBreakdown value)  $default,){
final _that = this;
switch (_that) {
case _StatusBreakdown():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatusBreakdown value)?  $default,){
final _that = this;
switch (_that) {
case _StatusBreakdown() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int count,  double totalRevenue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatusBreakdown() when $default != null:
return $default(_that.id,_that.count,_that.totalRevenue);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int count,  double totalRevenue)  $default,) {final _that = this;
switch (_that) {
case _StatusBreakdown():
return $default(_that.id,_that.count,_that.totalRevenue);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int count,  double totalRevenue)?  $default,) {final _that = this;
switch (_that) {
case _StatusBreakdown() when $default != null:
return $default(_that.id,_that.count,_that.totalRevenue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatusBreakdown implements StatusBreakdown {
  const _StatusBreakdown({required this.id, required this.count, required this.totalRevenue});
  factory _StatusBreakdown.fromJson(Map<String, dynamic> json) => _$StatusBreakdownFromJson(json);

@override final  String id;
@override final  int count;
@override final  double totalRevenue;

/// Create a copy of StatusBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatusBreakdownCopyWith<_StatusBreakdown> get copyWith => __$StatusBreakdownCopyWithImpl<_StatusBreakdown>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatusBreakdownToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatusBreakdown&&(identical(other.id, id) || other.id == id)&&(identical(other.count, count) || other.count == count)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,count,totalRevenue);

@override
String toString() {
  return 'StatusBreakdown(id: $id, count: $count, totalRevenue: $totalRevenue)';
}


}

/// @nodoc
abstract mixin class _$StatusBreakdownCopyWith<$Res> implements $StatusBreakdownCopyWith<$Res> {
  factory _$StatusBreakdownCopyWith(_StatusBreakdown value, $Res Function(_StatusBreakdown) _then) = __$StatusBreakdownCopyWithImpl;
@override @useResult
$Res call({
 String id, int count, double totalRevenue
});




}
/// @nodoc
class __$StatusBreakdownCopyWithImpl<$Res>
    implements _$StatusBreakdownCopyWith<$Res> {
  __$StatusBreakdownCopyWithImpl(this._self, this._then);

  final _StatusBreakdown _self;
  final $Res Function(_StatusBreakdown) _then;

/// Create a copy of StatusBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? count = null,Object? totalRevenue = null,}) {
  return _then(_StatusBreakdown(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$RevenueInfo {

 double get totalRevenue; double get avgBookingValue;
/// Create a copy of RevenueInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevenueInfoCopyWith<RevenueInfo> get copyWith => _$RevenueInfoCopyWithImpl<RevenueInfo>(this as RevenueInfo, _$identity);

  /// Serializes this RevenueInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevenueInfo&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.avgBookingValue, avgBookingValue) || other.avgBookingValue == avgBookingValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalRevenue,avgBookingValue);

@override
String toString() {
  return 'RevenueInfo(totalRevenue: $totalRevenue, avgBookingValue: $avgBookingValue)';
}


}

/// @nodoc
abstract mixin class $RevenueInfoCopyWith<$Res>  {
  factory $RevenueInfoCopyWith(RevenueInfo value, $Res Function(RevenueInfo) _then) = _$RevenueInfoCopyWithImpl;
@useResult
$Res call({
 double totalRevenue, double avgBookingValue
});




}
/// @nodoc
class _$RevenueInfoCopyWithImpl<$Res>
    implements $RevenueInfoCopyWith<$Res> {
  _$RevenueInfoCopyWithImpl(this._self, this._then);

  final RevenueInfo _self;
  final $Res Function(RevenueInfo) _then;

/// Create a copy of RevenueInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalRevenue = null,Object? avgBookingValue = null,}) {
  return _then(_self.copyWith(
totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,avgBookingValue: null == avgBookingValue ? _self.avgBookingValue : avgBookingValue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [RevenueInfo].
extension RevenueInfoPatterns on RevenueInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RevenueInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RevenueInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RevenueInfo value)  $default,){
final _that = this;
switch (_that) {
case _RevenueInfo():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RevenueInfo value)?  $default,){
final _that = this;
switch (_that) {
case _RevenueInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double totalRevenue,  double avgBookingValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RevenueInfo() when $default != null:
return $default(_that.totalRevenue,_that.avgBookingValue);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double totalRevenue,  double avgBookingValue)  $default,) {final _that = this;
switch (_that) {
case _RevenueInfo():
return $default(_that.totalRevenue,_that.avgBookingValue);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double totalRevenue,  double avgBookingValue)?  $default,) {final _that = this;
switch (_that) {
case _RevenueInfo() when $default != null:
return $default(_that.totalRevenue,_that.avgBookingValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RevenueInfo implements RevenueInfo {
  const _RevenueInfo({required this.totalRevenue, required this.avgBookingValue});
  factory _RevenueInfo.fromJson(Map<String, dynamic> json) => _$RevenueInfoFromJson(json);

@override final  double totalRevenue;
@override final  double avgBookingValue;

/// Create a copy of RevenueInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevenueInfoCopyWith<_RevenueInfo> get copyWith => __$RevenueInfoCopyWithImpl<_RevenueInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RevenueInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevenueInfo&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.avgBookingValue, avgBookingValue) || other.avgBookingValue == avgBookingValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalRevenue,avgBookingValue);

@override
String toString() {
  return 'RevenueInfo(totalRevenue: $totalRevenue, avgBookingValue: $avgBookingValue)';
}


}

/// @nodoc
abstract mixin class _$RevenueInfoCopyWith<$Res> implements $RevenueInfoCopyWith<$Res> {
  factory _$RevenueInfoCopyWith(_RevenueInfo value, $Res Function(_RevenueInfo) _then) = __$RevenueInfoCopyWithImpl;
@override @useResult
$Res call({
 double totalRevenue, double avgBookingValue
});




}
/// @nodoc
class __$RevenueInfoCopyWithImpl<$Res>
    implements _$RevenueInfoCopyWith<$Res> {
  __$RevenueInfoCopyWithImpl(this._self, this._then);

  final _RevenueInfo _self;
  final $Res Function(_RevenueInfo) _then;

/// Create a copy of RevenueInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalRevenue = null,Object? avgBookingValue = null,}) {
  return _then(_RevenueInfo(
totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,avgBookingValue: null == avgBookingValue ? _self.avgBookingValue : avgBookingValue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$TicketInfo {

 String get id; String get bookingId; String get userId; String get passengerId; String get pnr; String get ticketNumber; String get qrData; String? get qrCodeUrl; String? get pdfUrl; String get status; DateTime? get validUntil; DateTime? get usedAt; String? get usedBy; DateTime? get cancelledAt; DateTime get createdAt;
/// Create a copy of TicketInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TicketInfoCopyWith<TicketInfo> get copyWith => _$TicketInfoCopyWithImpl<TicketInfo>(this as TicketInfo, _$identity);

  /// Serializes this TicketInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TicketInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.passengerId, passengerId) || other.passengerId == passengerId)&&(identical(other.pnr, pnr) || other.pnr == pnr)&&(identical(other.ticketNumber, ticketNumber) || other.ticketNumber == ticketNumber)&&(identical(other.qrData, qrData) || other.qrData == qrData)&&(identical(other.qrCodeUrl, qrCodeUrl) || other.qrCodeUrl == qrCodeUrl)&&(identical(other.pdfUrl, pdfUrl) || other.pdfUrl == pdfUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.usedAt, usedAt) || other.usedAt == usedAt)&&(identical(other.usedBy, usedBy) || other.usedBy == usedBy)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bookingId,userId,passengerId,pnr,ticketNumber,qrData,qrCodeUrl,pdfUrl,status,validUntil,usedAt,usedBy,cancelledAt,createdAt);

@override
String toString() {
  return 'TicketInfo(id: $id, bookingId: $bookingId, userId: $userId, passengerId: $passengerId, pnr: $pnr, ticketNumber: $ticketNumber, qrData: $qrData, qrCodeUrl: $qrCodeUrl, pdfUrl: $pdfUrl, status: $status, validUntil: $validUntil, usedAt: $usedAt, usedBy: $usedBy, cancelledAt: $cancelledAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TicketInfoCopyWith<$Res>  {
  factory $TicketInfoCopyWith(TicketInfo value, $Res Function(TicketInfo) _then) = _$TicketInfoCopyWithImpl;
@useResult
$Res call({
 String id, String bookingId, String userId, String passengerId, String pnr, String ticketNumber, String qrData, String? qrCodeUrl, String? pdfUrl, String status, DateTime? validUntil, DateTime? usedAt, String? usedBy, DateTime? cancelledAt, DateTime createdAt
});




}
/// @nodoc
class _$TicketInfoCopyWithImpl<$Res>
    implements $TicketInfoCopyWith<$Res> {
  _$TicketInfoCopyWithImpl(this._self, this._then);

  final TicketInfo _self;
  final $Res Function(TicketInfo) _then;

/// Create a copy of TicketInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? bookingId = null,Object? userId = null,Object? passengerId = null,Object? pnr = null,Object? ticketNumber = null,Object? qrData = null,Object? qrCodeUrl = freezed,Object? pdfUrl = freezed,Object? status = null,Object? validUntil = freezed,Object? usedAt = freezed,Object? usedBy = freezed,Object? cancelledAt = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,passengerId: null == passengerId ? _self.passengerId : passengerId // ignore: cast_nullable_to_non_nullable
as String,pnr: null == pnr ? _self.pnr : pnr // ignore: cast_nullable_to_non_nullable
as String,ticketNumber: null == ticketNumber ? _self.ticketNumber : ticketNumber // ignore: cast_nullable_to_non_nullable
as String,qrData: null == qrData ? _self.qrData : qrData // ignore: cast_nullable_to_non_nullable
as String,qrCodeUrl: freezed == qrCodeUrl ? _self.qrCodeUrl : qrCodeUrl // ignore: cast_nullable_to_non_nullable
as String?,pdfUrl: freezed == pdfUrl ? _self.pdfUrl : pdfUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,validUntil: freezed == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,usedAt: freezed == usedAt ? _self.usedAt : usedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,usedBy: freezed == usedBy ? _self.usedBy : usedBy // ignore: cast_nullable_to_non_nullable
as String?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TicketInfo].
extension TicketInfoPatterns on TicketInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TicketInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TicketInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TicketInfo value)  $default,){
final _that = this;
switch (_that) {
case _TicketInfo():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TicketInfo value)?  $default,){
final _that = this;
switch (_that) {
case _TicketInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String bookingId,  String userId,  String passengerId,  String pnr,  String ticketNumber,  String qrData,  String? qrCodeUrl,  String? pdfUrl,  String status,  DateTime? validUntil,  DateTime? usedAt,  String? usedBy,  DateTime? cancelledAt,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TicketInfo() when $default != null:
return $default(_that.id,_that.bookingId,_that.userId,_that.passengerId,_that.pnr,_that.ticketNumber,_that.qrData,_that.qrCodeUrl,_that.pdfUrl,_that.status,_that.validUntil,_that.usedAt,_that.usedBy,_that.cancelledAt,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String bookingId,  String userId,  String passengerId,  String pnr,  String ticketNumber,  String qrData,  String? qrCodeUrl,  String? pdfUrl,  String status,  DateTime? validUntil,  DateTime? usedAt,  String? usedBy,  DateTime? cancelledAt,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _TicketInfo():
return $default(_that.id,_that.bookingId,_that.userId,_that.passengerId,_that.pnr,_that.ticketNumber,_that.qrData,_that.qrCodeUrl,_that.pdfUrl,_that.status,_that.validUntil,_that.usedAt,_that.usedBy,_that.cancelledAt,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String bookingId,  String userId,  String passengerId,  String pnr,  String ticketNumber,  String qrData,  String? qrCodeUrl,  String? pdfUrl,  String status,  DateTime? validUntil,  DateTime? usedAt,  String? usedBy,  DateTime? cancelledAt,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TicketInfo() when $default != null:
return $default(_that.id,_that.bookingId,_that.userId,_that.passengerId,_that.pnr,_that.ticketNumber,_that.qrData,_that.qrCodeUrl,_that.pdfUrl,_that.status,_that.validUntil,_that.usedAt,_that.usedBy,_that.cancelledAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TicketInfo extends TicketInfo {
  const _TicketInfo({required this.id, required this.bookingId, required this.userId, required this.passengerId, required this.pnr, required this.ticketNumber, required this.qrData, this.qrCodeUrl, this.pdfUrl, required this.status, this.validUntil, this.usedAt, this.usedBy, this.cancelledAt, required this.createdAt}): super._();
  factory _TicketInfo.fromJson(Map<String, dynamic> json) => _$TicketInfoFromJson(json);

@override final  String id;
@override final  String bookingId;
@override final  String userId;
@override final  String passengerId;
@override final  String pnr;
@override final  String ticketNumber;
@override final  String qrData;
@override final  String? qrCodeUrl;
@override final  String? pdfUrl;
@override final  String status;
@override final  DateTime? validUntil;
@override final  DateTime? usedAt;
@override final  String? usedBy;
@override final  DateTime? cancelledAt;
@override final  DateTime createdAt;

/// Create a copy of TicketInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TicketInfoCopyWith<_TicketInfo> get copyWith => __$TicketInfoCopyWithImpl<_TicketInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TicketInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TicketInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.passengerId, passengerId) || other.passengerId == passengerId)&&(identical(other.pnr, pnr) || other.pnr == pnr)&&(identical(other.ticketNumber, ticketNumber) || other.ticketNumber == ticketNumber)&&(identical(other.qrData, qrData) || other.qrData == qrData)&&(identical(other.qrCodeUrl, qrCodeUrl) || other.qrCodeUrl == qrCodeUrl)&&(identical(other.pdfUrl, pdfUrl) || other.pdfUrl == pdfUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.usedAt, usedAt) || other.usedAt == usedAt)&&(identical(other.usedBy, usedBy) || other.usedBy == usedBy)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bookingId,userId,passengerId,pnr,ticketNumber,qrData,qrCodeUrl,pdfUrl,status,validUntil,usedAt,usedBy,cancelledAt,createdAt);

@override
String toString() {
  return 'TicketInfo(id: $id, bookingId: $bookingId, userId: $userId, passengerId: $passengerId, pnr: $pnr, ticketNumber: $ticketNumber, qrData: $qrData, qrCodeUrl: $qrCodeUrl, pdfUrl: $pdfUrl, status: $status, validUntil: $validUntil, usedAt: $usedAt, usedBy: $usedBy, cancelledAt: $cancelledAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TicketInfoCopyWith<$Res> implements $TicketInfoCopyWith<$Res> {
  factory _$TicketInfoCopyWith(_TicketInfo value, $Res Function(_TicketInfo) _then) = __$TicketInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String bookingId, String userId, String passengerId, String pnr, String ticketNumber, String qrData, String? qrCodeUrl, String? pdfUrl, String status, DateTime? validUntil, DateTime? usedAt, String? usedBy, DateTime? cancelledAt, DateTime createdAt
});




}
/// @nodoc
class __$TicketInfoCopyWithImpl<$Res>
    implements _$TicketInfoCopyWith<$Res> {
  __$TicketInfoCopyWithImpl(this._self, this._then);

  final _TicketInfo _self;
  final $Res Function(_TicketInfo) _then;

/// Create a copy of TicketInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? bookingId = null,Object? userId = null,Object? passengerId = null,Object? pnr = null,Object? ticketNumber = null,Object? qrData = null,Object? qrCodeUrl = freezed,Object? pdfUrl = freezed,Object? status = null,Object? validUntil = freezed,Object? usedAt = freezed,Object? usedBy = freezed,Object? cancelledAt = freezed,Object? createdAt = null,}) {
  return _then(_TicketInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,passengerId: null == passengerId ? _self.passengerId : passengerId // ignore: cast_nullable_to_non_nullable
as String,pnr: null == pnr ? _self.pnr : pnr // ignore: cast_nullable_to_non_nullable
as String,ticketNumber: null == ticketNumber ? _self.ticketNumber : ticketNumber // ignore: cast_nullable_to_non_nullable
as String,qrData: null == qrData ? _self.qrData : qrData // ignore: cast_nullable_to_non_nullable
as String,qrCodeUrl: freezed == qrCodeUrl ? _self.qrCodeUrl : qrCodeUrl // ignore: cast_nullable_to_non_nullable
as String?,pdfUrl: freezed == pdfUrl ? _self.pdfUrl : pdfUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,validUntil: freezed == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,usedAt: freezed == usedAt ? _self.usedAt : usedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,usedBy: freezed == usedBy ? _self.usedBy : usedBy // ignore: cast_nullable_to_non_nullable
as String?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
