import '../../../../core/constants/app_constants.dart';

class SearchQuery {
  final TransportMode mode;
  final String from;
  final String to;
  final DateTime departDate;
  final DateTime? returnDate;
  final PassengerCount passengers;
  final bool roundTrip;

  const SearchQuery({
    required this.mode,
    required this.from,
    required this.to,
    required this.departDate,
    this.returnDate,
    required this.passengers,
    this.roundTrip = false,
  });

  factory SearchQuery.fromJson(Map<String, dynamic> json) {
    return SearchQuery(
      mode: TransportMode.values.firstWhere(
        (e) => e.name == json['mode'],
        orElse: () => TransportMode.flight,
      ),
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      departDate: DateTime.parse(
        json['departDate'] ?? DateTime.now().toIso8601String(),
      ),
      returnDate: json['returnDate'] != null
          ? DateTime.parse(json['returnDate'])
          : null,
      passengers: PassengerCount.fromJson(json['passengers'] ?? {}),
      roundTrip: json['roundTrip'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.name,
      'from': from,
      'to': to,
      'departDate': departDate.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
      'passengers': passengers.toJson(),
      'roundTrip': roundTrip,
    };
  }
}

class PassengerCount {
  final int adult;
  final int child;
  final int infant;

  const PassengerCount({this.adult = 1, this.child = 0, this.infant = 0});

  factory PassengerCount.fromJson(Map<String, dynamic> json) {
    return PassengerCount(
      adult: json['adult'] ?? 1,
      child: json['child'] ?? 0,
      infant: json['infant'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'adult': adult, 'child': child, 'infant': infant};
  }
}

extension PassengerCountX on PassengerCount {
  int get total => adult + child + infant;

  bool get isValid => adult >= 1 && total <= AppConstants.maxPassengers;

  String get displayText {
    final parts = <String>[];
    if (adult > 0) parts.add('$adult người lớn');
    if (child > 0) parts.add('$child trẻ em');
    if (infant > 0) parts.add('$infant em bé');
    return parts.join(', ');
  }
}

extension SearchQueryX on SearchQuery {
  bool get isValid {
    return from.isNotEmpty &&
        to.isNotEmpty &&
        from != to &&
        departDate.isAfter(DateTime.now().subtract(const Duration(days: 1))) &&
        passengers.isValid &&
        (returnDate == null || returnDate!.isAfter(departDate));
  }

  String get cacheKey {
    return '${mode.value}_${from}_${to}_${departDate.millisecondsSinceEpoch}_'
        '${returnDate?.millisecondsSinceEpoch ?? 'null'}_'
        '${passengers.adult}_${passengers.child}_${passengers.infant}_$roundTrip';
  }
}
