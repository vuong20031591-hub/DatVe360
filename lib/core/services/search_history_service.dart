import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../../features/search/data/models/search_query.dart';

class SearchHistoryService {
  static SearchHistoryService? _instance;
  static SearchHistoryService get instance =>
      _instance ??= SearchHistoryService._();

  SearchHistoryService._();

  Box<List>? _historyBox;

  /// Initialize the search history service
  Future<void> init() async {
    try {
      _historyBox = await Hive.openBox<List>('search_history');
    } catch (e) {
      print('Error initializing search history service: $e');
    }
  }

  /// Add a search query to history
  Future<void> addSearchToHistory(SearchQuery query) async {
    if (_historyBox == null) return;

    try {
      final historyItem = {
        'from': query.from,
        'to': query.to,
        'fromCode': query.from, // TODO: Get actual codes
        'toCode': query.to,
        'mode': query.mode.value,
        'departDate': query.departDate.toIso8601String(),
        'returnDate': query.returnDate?.toIso8601String(),
        'passengers': {
          'adult': query.passengers.adult,
          'child': query.passengers.child,
          'infant': query.passengers.infant,
        },
        'roundTrip': query.roundTrip,
        'searchTime': DateTime.now().toIso8601String(),
      };

      // Get existing history
      final existingHistory = getSearchHistory();

      // Remove duplicate if exists (same from-to-date combination)
      existingHistory.removeWhere(
        (item) =>
            item['from'] == query.from &&
            item['to'] == query.to &&
            item['departDate'] == query.departDate.toIso8601String(),
      );

      // Add new search at the beginning
      existingHistory.insert(0, historyItem);

      // Keep only last 10 searches
      if (existingHistory.length > AppConstants.maxSearchHistory) {
        existingHistory.removeRange(
          AppConstants.maxSearchHistory,
          existingHistory.length,
        );
      }

      // Save back to storage
      await _historyBox!.put('history', existingHistory.cast<dynamic>());

      print('DEBUG: Added search to history: ${query.from} → ${query.to}');
    } catch (e) {
      print('Error adding search to history: $e');
    }
  }

  /// Get search history
  List<Map<String, dynamic>> getSearchHistory() {
    if (_historyBox == null) return [];

    try {
      final history = _historyBox!.get('history', defaultValue: <dynamic>[]);
      if (history == null) return [];

      return List<Map<String, dynamic>>.from(
        history.map((item) {
          if (item is Map) {
            return Map<String, dynamic>.from(item.cast<String, dynamic>());
          }
          return <String, dynamic>{};
        }),
      );
    } catch (e) {
      print('Error getting search history: $e');
      return [];
    }
  }

  /// Clear all search history
  Future<void> clearHistory() async {
    if (_historyBox == null) return;

    try {
      await _historyBox!.delete('history');
      print('DEBUG: Cleared search history');
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  /// Remove a specific search from history
  Future<void> removeSearchFromHistory(Map<String, dynamic> searchItem) async {
    if (_historyBox == null) return;

    try {
      final history = getSearchHistory();
      history.removeWhere(
        (item) =>
            item['from'] == searchItem['from'] &&
            item['to'] == searchItem['to'] &&
            item['departDate'] == searchItem['departDate'],
      );

      await _historyBox!.put('history', history.cast<dynamic>());
      print('DEBUG: Removed search from history');
    } catch (e) {
      print('Error removing search from history: $e');
    }
  }

  /// Get formatted search history for UI
  List<Map<String, dynamic>> getFormattedSearchHistory() {
    final history = getSearchHistory();

    return history.map((item) {
      try {
        final searchTime = DateTime.parse(item['searchTime'] as String);
        final now = DateTime.now();
        final difference = now.difference(searchTime);

        String timeAgo;
        if (difference.inMinutes < 1) {
          timeAgo = 'Vừa tìm';
        } else if (difference.inMinutes < 60) {
          timeAgo = '${difference.inMinutes} phút trước';
        } else if (difference.inHours < 24) {
          timeAgo = '${difference.inHours} giờ trước';
        } else {
          timeAgo = '${difference.inDays} ngày trước';
        }

        final departDate = DateTime.parse(item['departDate'] as String);
        final passengers = Map<String, dynamic>.from(item['passengers'] as Map);
        final totalPassengers =
            (passengers['adult'] as int? ?? 0) +
            (passengers['child'] as int? ?? 0) +
            (passengers['infant'] as int? ?? 0);

        return <String, dynamic>{
          'from': item['from'] as String,
          'to': item['to'] as String,
          'fromCode': item['fromCode'] as String,
          'toCode': item['toCode'] as String,
          'mode': item['mode'] as String,
          'date': '${departDate.day}/${departDate.month}/${departDate.year}',
          'passengers': totalPassengers,
          'searchTime': timeAgo,
          'originalItem': item, // Keep original for removal
        };
      } catch (e) {
        print('Error formatting search history item: $e');
        return <String, dynamic>{
          'from': 'Unknown',
          'to': 'Unknown',
          'fromCode': '',
          'toCode': '',
          'mode': 'flight',
          'date': 'Unknown',
          'passengers': 1,
          'searchTime': 'Unknown',
          'originalItem': item,
        };
      }
    }).toList();
  }

  /// Convert history item back to SearchQuery
  SearchQuery historyItemToSearchQuery(Map<String, dynamic> item) {
    try {
      final originalItem = Map<String, dynamic>.from(
        item['originalItem'] as Map,
      );
      final passengers = Map<String, dynamic>.from(
        originalItem['passengers'] as Map,
      );

      return SearchQuery(
        from: originalItem['from'] as String,
        to: originalItem['to'] as String,
        departDate: DateTime.parse(originalItem['departDate'] as String),
        returnDate: originalItem['returnDate'] != null
            ? DateTime.parse(originalItem['returnDate'] as String)
            : null,
        passengers: PassengerCount(
          adult: passengers['adult'] as int? ?? 1,
          child: passengers['child'] as int? ?? 0,
          infant: passengers['infant'] as int? ?? 0,
        ),
        mode: TransportMode.values.firstWhere(
          (mode) => mode.value == originalItem['mode'],
          orElse: () => TransportMode.flight,
        ),
        roundTrip: originalItem['roundTrip'] as bool? ?? false,
      );
    } catch (e) {
      print('Error converting history item to SearchQuery: $e');
      // Return default SearchQuery
      return SearchQuery(
        from: 'HAN',
        to: 'SGN',
        departDate: DateTime.now(),
        passengers: const PassengerCount(adult: 1, child: 0, infant: 0),
        mode: TransportMode.flight,
        roundTrip: false,
      );
    }
  }
}
