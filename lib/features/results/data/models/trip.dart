import '../../../../core/constants/app_constants.dart';

/// Trip model for search results
class Trip {
  final String id;
  final String carrierId;
  final String carrierName;
  final String? carrierLogo;
  final TransportMode mode;
  final String from;
  final String fromCode;
  final String to;
  final String toCode;
  final DateTime departAt;
  final DateTime arriveAt;
  final Duration duration;
  final double basePrice;
  final String currency;
  final List<String> stops;
  final List<ClassOption> classOptions;
  final Map<String, dynamic> metadata;

  const Trip({
    required this.id,
    required this.carrierId,
    required this.carrierName,
    this.carrierLogo,
    required this.mode,
    required this.from,
    required this.fromCode,
    required this.to,
    required this.toCode,
    required this.departAt,
    required this.arriveAt,
    required this.duration,
    required this.basePrice,
    required this.currency,
    required this.stops,
    required this.classOptions,
    required this.metadata,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      carrierId: json['carrierId'] as String,
      carrierName: json['carrierName'] as String,
      carrierLogo: json['carrierLogo'] as String?,
      mode: TransportMode.values.firstWhere(
        (e) => e.value == json['mode'],
        orElse: () => TransportMode.flight,
      ),
      from: json['from'] as String,
      fromCode: json['fromCode'] as String,
      to: json['to'] as String,
      toCode: json['toCode'] as String,
      departAt: DateTime.parse(json['departAt'] as String),
      arriveAt: DateTime.parse(json['arriveAt'] as String),
      duration: Duration(minutes: json['duration'] as int),
      basePrice: (json['basePrice'] as num).toDouble(),
      currency: json['currency'] as String,
      stops: List<String>.from(json['stops'] as List),
      classOptions: (json['classOptions'] as List)
          .map((e) => ClassOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carrierId': carrierId,
      'carrierName': carrierName,
      'carrierLogo': carrierLogo,
      'mode': mode.value,
      'from': from,
      'fromCode': fromCode,
      'to': to,
      'toCode': toCode,
      'departAt': departAt.toIso8601String(),
      'arriveAt': arriveAt.toIso8601String(),
      'duration': duration.inMinutes,
      'basePrice': basePrice,
      'currency': currency,
      'stops': stops,
      'classOptions': classOptions.map((e) => e.toJson()).toList(),
      'metadata': metadata,
    };
  }

  Trip copyWith({
    String? id,
    String? carrierId,
    String? carrierName,
    String? carrierLogo,
    TransportMode? mode,
    String? from,
    String? fromCode,
    String? to,
    String? toCode,
    DateTime? departAt,
    DateTime? arriveAt,
    Duration? duration,
    double? basePrice,
    String? currency,
    List<String>? stops,
    List<ClassOption>? classOptions,
    Map<String, dynamic>? metadata,
  }) {
    return Trip(
      id: id ?? this.id,
      carrierId: carrierId ?? this.carrierId,
      carrierName: carrierName ?? this.carrierName,
      carrierLogo: carrierLogo ?? this.carrierLogo,
      mode: mode ?? this.mode,
      from: from ?? this.from,
      fromCode: fromCode ?? this.fromCode,
      to: to ?? this.to,
      toCode: toCode ?? this.toCode,
      departAt: departAt ?? this.departAt,
      arriveAt: arriveAt ?? this.arriveAt,
      duration: duration ?? this.duration,
      basePrice: basePrice ?? this.basePrice,
      currency: currency ?? this.currency,
      stops: stops ?? this.stops,
      classOptions: classOptions ?? this.classOptions,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Trip &&
        other.id == id &&
        other.carrierId == carrierId &&
        other.carrierName == carrierName &&
        other.carrierLogo == carrierLogo &&
        other.mode == mode &&
        other.from == from &&
        other.fromCode == fromCode &&
        other.to == to &&
        other.toCode == toCode &&
        other.departAt == departAt &&
        other.arriveAt == arriveAt &&
        other.duration == duration &&
        other.basePrice == basePrice &&
        other.currency == currency &&
        _listEquals(other.stops, stops) &&
        _listEquals(other.classOptions, classOptions) &&
        _mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      carrierId,
      carrierName,
      carrierLogo,
      mode,
      from,
      fromCode,
      to,
      toCode,
      departAt,
      arriveAt,
      duration,
      basePrice,
      currency,
      Object.hashAll(stops),
      Object.hashAll(classOptions),
      Object.hashAll(metadata.entries),
    );
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

/// Class option for different service classes
class ClassOption {
  final String id;
  final String name;
  final String displayName;
  final double price;
  final double priceAddon;
  final List<String> amenities;
  final Map<String, dynamic> metadata;

  const ClassOption({
    required this.id,
    required this.name,
    required this.displayName,
    required this.price,
    required this.priceAddon,
    required this.amenities,
    required this.metadata,
  });

  factory ClassOption.fromJson(Map<String, dynamic> json) {
    return ClassOption(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      price: (json['price'] as num).toDouble(),
      priceAddon: (json['priceAddon'] as num).toDouble(),
      amenities: List<String>.from(json['amenities'] as List),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'price': price,
      'priceAddon': priceAddon,
      'amenities': amenities,
      'metadata': metadata,
    };
  }

  ClassOption copyWith({
    String? id,
    String? name,
    String? displayName,
    double? price,
    double? priceAddon,
    List<String>? amenities,
    Map<String, dynamic>? metadata,
  }) {
    return ClassOption(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      price: price ?? this.price,
      priceAddon: priceAddon ?? this.priceAddon,
      amenities: amenities ?? this.amenities,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClassOption &&
        other.id == id &&
        other.name == name &&
        other.displayName == displayName &&
        other.price == price &&
        other.priceAddon == priceAddon &&
        _listEquals(other.amenities, amenities) &&
        _mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      displayName,
      price,
      priceAddon,
      Object.hashAll(amenities),
      Object.hashAll(metadata.entries),
    );
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
