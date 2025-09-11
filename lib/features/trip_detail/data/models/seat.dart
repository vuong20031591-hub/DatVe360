import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/constants/app_constants.dart';

part 'seat.freezed.dart';
part 'seat.g.dart';

@freezed
class Seat with _$Seat {
  const factory Seat({
    required String id,
    required String tripId,
    required int row,
    required String col,
    required SeatType type,
    required SeatStatus status,
    required double priceAddon,
    @Default({}) Map<String, dynamic> metadata,
  }) = _Seat;

  factory Seat.fromJson(Map<String, dynamic> json) => _$SeatFromJson(json);
}

@freezed
class SeatMap with _$SeatMap {
  const factory SeatMap({
    required String tripId,
    required String classId,
    required int rows,
    required List<String> cols,
    required List<Seat> seats,
    @Default([]) List<int> aisleAfterRows,
    @Default([]) List<String> aisleAfterCols,
    @Default({}) Map<String, dynamic> layout,
  }) = _SeatMap;

  factory SeatMap.fromJson(Map<String, dynamic> json) =>
      _$SeatMapFromJson(json);
}

enum SeatType {
  @JsonValue('standard')
  standard('standard', 'Ghế thường'),
  @JsonValue('premium')
  premium('premium', 'Ghế cao cấp'),
  @JsonValue('exit')
  exit('exit', 'Ghế lối thoát'),
  @JsonValue('window')
  window('window', 'Ghế cửa sổ'),
  @JsonValue('aisle')
  aisle('aisle', 'Ghế lối đi');

  const SeatType(this.value, this.displayName);
  final String value;
  final String displayName;
}

extension SeatX on Seat {
  String get seatNumber => '$row$col';
  
  bool get isAvailable => status == SeatStatus.available;
  bool get isBooked => status == SeatStatus.booked;
  bool get isSelected => status == SeatStatus.selected;
  bool get isHeld => status == SeatStatus.held;
  
  bool get isSelectable => isAvailable || isSelected;
  
  String get displayName => 'Ghế $seatNumber';
}

extension SeatMapX on SeatMap {
  List<List<Seat?>> get grid {
    final grid = List.generate(
      rows,
      (row) => List.generate(cols.length, (col) => null as Seat?),
    );
    
    for (final seat in seats) {
      final colIndex = cols.indexOf(seat.col);
      if (colIndex != -1 && seat.row <= rows) {
        grid[seat.row - 1][colIndex] = seat;
      }
    }
    
    return grid;
  }
  
  List<Seat> get availableSeats {
    return seats.where((seat) => seat.isAvailable).toList();
  }
  
  List<Seat> get selectedSeats {
    return seats.where((seat) => seat.isSelected).toList();
  }
  
  int get totalSeats => seats.length;
  int get availableCount => availableSeats.length;
  int get selectedCount => selectedSeats.length;
  
  double get totalSelectedPrice {
    return selectedSeats.fold(0.0, (sum, seat) => sum + seat.priceAddon);
  }
}
