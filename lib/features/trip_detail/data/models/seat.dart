import '../../../../core/constants/app_constants.dart';

class Seat {
  final String id;
  final String tripId;

  // For airplane/bus: row and column
  final int? row;
  final String? col;

  // For train: coach (toa xe) and compartment (khoang)
  final int? coachNumber;
  final int? compartmentNumber;
  final String? position; // L1, L2, R1, R2 for train berths

  final SeatType type;
  final SeatStatus status;
  final double priceAddon;
  final Map<String, dynamic> metadata;

  const Seat({
    required this.id,
    required this.tripId,
    this.row,
    this.col,
    this.coachNumber,
    this.compartmentNumber,
    this.position,
    required this.type,
    required this.status,
    required this.priceAddon,
    this.metadata = const {},
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: json['id'] ?? '',
      tripId: json['tripId'] ?? '',
      row: json['row'],
      col: json['col'],
      coachNumber: json['coachNumber'],
      compartmentNumber: json['compartmentNumber'],
      position: json['position'],
      type: SeatType.values.firstWhere(
        (e) => e.value == json['type'],
        orElse: () => SeatType.standard,
      ),
      status: SeatStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SeatStatus.available,
      ),
      priceAddon: (json['priceAddon'] ?? 0).toDouble(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      if (row != null) 'row': row,
      if (col != null) 'col': col,
      if (coachNumber != null) 'coachNumber': coachNumber,
      if (compartmentNumber != null) 'compartmentNumber': compartmentNumber,
      if (position != null) 'position': position,
      'type': type.value,
      'status': status.name,
      'priceAddon': priceAddon,
      'metadata': metadata,
    };
  }

  // Helper to check if this is a train seat
  bool get isTrainSeat => coachNumber != null && compartmentNumber != null;

  // Helper to check if this is an airplane/bus seat
  bool get isAirplaneBusSeat => row != null && col != null;
}

class SeatMap {
  final String tripId;
  final String classId;
  final int rows;
  final List<String> cols;
  final List<Seat> seats;
  final List<int> aisleAfterRows;
  final List<String> aisleAfterCols;
  final Map<String, dynamic> layout;

  const SeatMap({
    required this.tripId,
    required this.classId,
    required this.rows,
    required this.cols,
    required this.seats,
    this.aisleAfterRows = const [],
    this.aisleAfterCols = const [],
    this.layout = const {},
  });

  factory SeatMap.fromJson(Map<String, dynamic> json) {
    return SeatMap(
      tripId: json['tripId'] ?? '',
      classId: json['classId'] ?? '',
      rows: json['rows'] ?? 0,
      cols: List<String>.from(json['cols'] ?? []),
      seats:
          (json['seats'] as List?)?.map((e) => Seat.fromJson(e)).toList() ?? [],
      aisleAfterRows: List<int>.from(json['aisleAfterRows'] ?? []),
      aisleAfterCols: List<String>.from(json['aisleAfterCols'] ?? []),
      layout: Map<String, dynamic>.from(json['layout'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'classId': classId,
      'rows': rows,
      'cols': cols,
      'seats': seats.map((e) => e.toJson()).toList(),
      'aisleAfterRows': aisleAfterRows,
      'aisleAfterCols': aisleAfterCols,
      'layout': layout,
    };
  }
}

extension SeatX on Seat {
  String get seatNumber {
    if (isTrainSeat) {
      return id; // For train, use full ID (e.g., C101-L1)
    }
    return '$row$col'; // For airplane/bus
  }

  bool get isAvailable => status == SeatStatus.available;
  bool get isBooked => status == SeatStatus.booked;
  bool get isSelected => status == SeatStatus.selected;
  bool get isHeld => status == SeatStatus.held;

  bool get isSelectable => isAvailable || isSelected;

  String get displayName {
    if (isTrainSeat) {
      return 'Toa $coachNumber - Khoang $compartmentNumber - $position';
    }
    return 'Ghế $seatNumber';
  }
}

extension SeatMapX on SeatMap {
  List<List<Seat?>> get grid {
    final grid = List.generate(
      rows,
      (row) => List.generate(cols.length, (col) => null as Seat?),
    );

    for (final seat in seats) {
      // Only process airplane/bus seats (with row and col)
      if (seat.row != null && seat.col != null) {
        final colIndex = cols.indexOf(seat.col!);
        if (colIndex != -1 && seat.row! <= rows) {
          grid[seat.row! - 1][colIndex] = seat;
        }
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
