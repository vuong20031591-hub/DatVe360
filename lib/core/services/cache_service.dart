import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

/// Cache service for offline support and performance optimization
class CacheService {
  static CacheService? _instance;
  late Box _cacheBox;
  late Box _searchCacheBox;
  late Box _destinationsCacheBox;
  late Box _airportsCacheBox;

  CacheService._internal();

  static CacheService get instance {
    _instance ??= CacheService._internal();
    return _instance!;
  }

  /// Initialize cache service
  Future<void> init() async {
    _cacheBox = await Hive.openBox(AppConstants.cacheBox);
    _searchCacheBox = await Hive.openBox(AppConstants.searchCacheBox);
    _destinationsCacheBox = await Hive.openBox(
      AppConstants.destinationsCacheBox,
    );
    _airportsCacheBox = await Hive.openBox(AppConstants.airportsCacheBox);

    // Clean expired cache on startup
    await _cleanExpiredCache();
  }

  /// Generic cache methods
  Future<void> put(String key, dynamic data, {Duration? expiry}) async {
    final cacheItem = CacheItem(
      data: data,
      timestamp: DateTime.now(),
      expiry: expiry,
    );
    await _cacheBox.put(key, cacheItem.toJson());
  }

  T? get<T>(String key) {
    final jsonData = _cacheBox.get(key);
    if (jsonData == null) return null;

    final cacheItem = CacheItem.fromJson(jsonData);
    if (cacheItem.isExpired) {
      _cacheBox.delete(key);
      return null;
    }

    return cacheItem.data as T?;
  }

  /// Search cache methods
  Future<void> cacheSearchResults(
    String searchKey,
    List<Map<String, dynamic>> results,
  ) async {
    final cacheItem = CacheItem(
      data: results,
      timestamp: DateTime.now(),
      expiry: AppConstants.searchCacheExpiry,
    );

    await _searchCacheBox.put(searchKey, cacheItem.toJson());
    await _maintainCacheSize(_searchCacheBox);
  }

  List<Map<String, dynamic>>? getCachedSearchResults(String searchKey) {
    final jsonData = _searchCacheBox.get(searchKey);
    if (jsonData == null) return null;

    try {
      final cacheItem = CacheItem.fromJson(Map<String, dynamic>.from(jsonData));
      if (cacheItem.isExpired) {
        _searchCacheBox.delete(searchKey);
        return null;
      }

      if (cacheItem.data is List) {
        return List<Map<String, dynamic>>.from(cacheItem.data);
      }
      return null;
    } catch (e) {
      // If parsing fails, delete the corrupted cache
      _searchCacheBox.delete(searchKey);
      return null;
    }
  }

  /// Destinations cache methods
  Future<void> cacheDestinations(
    List<Map<String, dynamic>> destinations,
  ) async {
    final cacheItem = CacheItem(
      data: destinations,
      timestamp: DateTime.now(),
      expiry: AppConstants.destinationsCacheExpiry,
    );

    await _destinationsCacheBox.put('popular_destinations', cacheItem.toJson());
  }

  List<Map<String, dynamic>>? getCachedDestinations() {
    final jsonData = _destinationsCacheBox.get('popular_destinations');
    if (jsonData == null) return null;

    try {
      final cacheItem = CacheItem.fromJson(Map<String, dynamic>.from(jsonData));
      if (cacheItem.isExpired) {
        _destinationsCacheBox.delete('popular_destinations');
        return null;
      }

      if (cacheItem.data is List) {
        return List<Map<String, dynamic>>.from(cacheItem.data);
      }
      return null;
    } catch (e) {
      // If parsing fails, delete the corrupted cache
      _destinationsCacheBox.delete('popular_destinations');
      return null;
    }
  }

  /// Airports cache methods
  Future<void> cacheAirports(List<Map<String, dynamic>> airports) async {
    final cacheItem = CacheItem(
      data: airports,
      timestamp: DateTime.now(),
      expiry: AppConstants.airportsCacheExpiry,
    );

    await _airportsCacheBox.put('airports', cacheItem.toJson());
  }

  List<Map<String, dynamic>>? getCachedAirports() {
    final jsonData = _airportsCacheBox.get('airports');
    if (jsonData == null) return null;

    try {
      final cacheItem = CacheItem.fromJson(Map<String, dynamic>.from(jsonData));
      if (cacheItem.isExpired) {
        _airportsCacheBox.delete('airports');
        return null;
      }

      if (cacheItem.data is List) {
        return List<Map<String, dynamic>>.from(cacheItem.data);
      }
      return null;
    } catch (e) {
      // If parsing fails, delete the corrupted cache
      _airportsCacheBox.delete('airports');
      return null;
    }
  }

  /// Utility methods
  Future<void> clearCache() async {
    await _cacheBox.clear();
    await _searchCacheBox.clear();
    await _destinationsCacheBox.clear();
    await _airportsCacheBox.clear();
  }

  Future<void> clearExpiredCache() async {
    await _cleanExpiredCache();
  }

  bool isOnline = true;

  void setOnlineStatus(bool online) {
    isOnline = online;
  }

  /// Private methods
  Future<void> _cleanExpiredCache() async {
    await _cleanExpiredFromBox(_cacheBox);
    await _cleanExpiredFromBox(_searchCacheBox);
    await _cleanExpiredFromBox(_destinationsCacheBox);
    await _cleanExpiredFromBox(_airportsCacheBox);
  }

  Future<void> _cleanExpiredFromBox(Box box) async {
    final keysToDelete = <String>[];

    for (final key in box.keys) {
      final jsonData = box.get(key);
      if (jsonData != null) {
        try {
          final cacheItem = CacheItem.fromJson(
            Map<String, dynamic>.from(jsonData),
          );
          if (cacheItem.isExpired) {
            keysToDelete.add(key.toString());
          }
        } catch (e) {
          // If parsing fails, mark for deletion
          keysToDelete.add(key.toString());
        }
      }
    }

    for (final key in keysToDelete) {
      await box.delete(key);
    }
  }

  Future<void> _maintainCacheSize(Box box) async {
    if (box.length <= AppConstants.maxCacheSize) return;

    // Get all items with timestamps
    final items = <MapEntry<String, DateTime>>[];
    for (final key in box.keys) {
      final jsonData = box.get(key);
      if (jsonData != null) {
        final cacheItem = CacheItem.fromJson(jsonData);
        items.add(MapEntry(key.toString(), cacheItem.timestamp));
      }
    }

    // Sort by timestamp (oldest first)
    items.sort((a, b) => a.value.compareTo(b.value));

    // Remove oldest items
    final itemsToRemove = items.length - AppConstants.maxCacheSize;
    for (int i = 0; i < itemsToRemove; i++) {
      await box.delete(items[i].key);
    }
  }
}

/// Cache item model
class CacheItem {
  final dynamic data;
  final DateTime timestamp;
  final Duration? expiry;

  CacheItem({required this.data, required this.timestamp, this.expiry});

  bool get isExpired {
    if (expiry == null) return false;
    return DateTime.now().difference(timestamp) > expiry!;
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'expiry': expiry?.inMilliseconds,
    };
  }

  factory CacheItem.fromJson(Map<String, dynamic> json) {
    return CacheItem(
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      expiry: json['expiry'] != null
          ? Duration(milliseconds: json['expiry'])
          : null,
    );
  }
}
