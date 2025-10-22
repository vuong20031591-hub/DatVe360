import '../../../../core/constants/app_constants.dart';

/// Data model for a seat
class SeatData {
  final String id;
  final SeatStatus status;
  final SeatType type;
  final double priceAddon;

  const SeatData({
    required this.id,
    required this.status,
    required this.type,
    this.priceAddon = 0.0,
  });

  SeatData copyWith({
    String? id,
    SeatStatus? status,
    SeatType? type,
    double? priceAddon,
  }) {
    return SeatData(
      id: id ?? this.id,
      status: status ?? this.status,
      type: type ?? this.type,
      priceAddon: priceAddon ?? this.priceAddon,
    );
  }
}
