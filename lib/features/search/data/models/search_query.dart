import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/constants/app_constants.dart';

part 'search_query.freezed.dart';
part 'search_query.g.dart';

@freezed
class SearchQuery with _$SearchQuery {
  const factory SearchQuery({
    required TransportMode mode,
    required String from,
    required String to,
    required DateTime departDate,
    DateTime? returnDate,
    required PassengerCount passengers,
    @Default(false) bool roundTrip,
  }) = _SearchQuery;

  factory SearchQuery.fromJson(Map<String, dynamic> json) =>
      _$SearchQueryFromJson(json);
}

@freezed
class PassengerCount with _$PassengerCount {
  const factory PassengerCount({
    @Default(1) int adult,
    @Default(0) int child,
    @Default(0) int infant,
  }) = _PassengerCount;

  factory PassengerCount.fromJson(Map<String, dynamic> json) =>
      _$PassengerCountFromJson(json);
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
