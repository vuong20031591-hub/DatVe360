import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/constants/app_constants.dart';

part 'trip.freezed.dart';
part 'trip.g.dart';

@freezed
class Trip with _$Trip {
  const factory Trip({
    required String id,
    required String carrierId,
    required String carrierName,
    required String carrierLogo,
    required TransportMode mode,
    required String from,
    required String fromCode,
    required String to,
    required String toCode,
    required DateTime departAt,
    required DateTime arriveAt,
    required Duration duration,
    required double basePrice,
    required String currency,
    @Default([]) List<String> stops,
    @Default([]) List<ClassOption> classOptions,
    @Default({}) Map<String, dynamic> metadata,
  }) = _Trip;

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
}

@freezed
class ClassOption with _$ClassOption {
  const factory ClassOption({
    required String id,
    required String name,
    required String code,
    required double price,
    required int availableSeats,
    @Default([]) List<String> amenities,
    @Default({}) Map<String, dynamic> policies,
  }) = _ClassOption;

  factory ClassOption.fromJson(Map<String, dynamic> json) =>
      _$ClassOptionFromJson(json);
}

extension TripX on Trip {
  String get durationText {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get departTimeText {
    return '${departAt.hour.toString().padLeft(2, '0')}:'
        '${departAt.minute.toString().padLeft(2, '0')}';
  }

  String get arriveTimeText {
    return '${arriveAt.hour.toString().padLeft(2, '0')}:'
        '${arriveAt.minute.toString().padLeft(2, '0')}';
  }

  String get routeText => '$from → $to';

  String get stopsText {
    if (stops.isEmpty) return 'Bay thẳng';
    return '${stops.length} điểm dừng';
  }

  bool get hasAvailableSeats {
    return classOptions.any((option) => option.availableSeats > 0);
  }

  double get lowestPrice {
    if (classOptions.isEmpty) return basePrice;
    return classOptions
        .where((option) => option.availableSeats > 0)
        .map((option) => option.price)
        .reduce((a, b) => a < b ? a : b);
  }

  ClassOption? get cheapestClass {
    if (classOptions.isEmpty) return null;
    final available = classOptions.where((option) => option.availableSeats > 0);
    if (available.isEmpty) return null;
    return available.reduce((a, b) => a.price < b.price ? a : b);
  }
}
