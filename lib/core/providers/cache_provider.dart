import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cache_service.dart';

/// Provider for cache service
final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService.instance;
});

/// Provider for cache status
final cacheStatusProvider = NotifierProvider<CacheStatusNotifier, CacheStatus>(
  () {
    return CacheStatusNotifier();
  },
);

/// Cache status notifier
class CacheStatusNotifier extends Notifier<CacheStatus> {
  late CacheService _cacheService;

  @override
  CacheStatus build() {
    _cacheService = ref.watch(cacheServiceProvider);
    return CacheStatus.idle();
  }

  /// Clear all cache
  Future<void> clearCache() async {
    state = CacheStatus.clearing();
    try {
      await _cacheService.clearCache();
      state = CacheStatus.cleared();
    } catch (e) {
      state = CacheStatus.error(e.toString());
    }
  }

  /// Clear expired cache
  Future<void> clearExpiredCache() async {
    state = CacheStatus.clearing();
    try {
      await _cacheService.clearExpiredCache();
      state = CacheStatus.cleared();
    } catch (e) {
      state = CacheStatus.error(e.toString());
    }
  }

  /// Reset status
  void resetStatus() {
    state = CacheStatus.idle();
  }
}

/// Cache status model
class CacheStatus {
  final bool isClearing;
  final bool isCleared;
  final String? error;

  const CacheStatus._({
    required this.isClearing,
    required this.isCleared,
    this.error,
  });

  factory CacheStatus.idle() =>
      const CacheStatus._(isClearing: false, isCleared: false);

  factory CacheStatus.clearing() =>
      const CacheStatus._(isClearing: true, isCleared: false);

  factory CacheStatus.cleared() =>
      const CacheStatus._(isClearing: false, isCleared: true);

  factory CacheStatus.error(String error) =>
      CacheStatus._(isClearing: false, isCleared: false, error: error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheStatus &&
          runtimeType == other.runtimeType &&
          isClearing == other.isClearing &&
          isCleared == other.isCleared &&
          error == other.error;

  @override
  int get hashCode => isClearing.hashCode ^ isCleared.hashCode ^ error.hashCode;

  @override
  String toString() =>
      'CacheStatus(isClearing: $isClearing, isCleared: $isCleared, error: $error)';
}
