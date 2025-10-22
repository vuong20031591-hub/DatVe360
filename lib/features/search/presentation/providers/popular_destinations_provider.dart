import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/search_repository.dart';

/// Popular destinations state
class PopularDestinationsState {
  final List<Map<String, dynamic>> destinations;
  final bool isLoading;
  final String? error;

  const PopularDestinationsState({
    this.destinations = const [],
    this.isLoading = false,
    this.error,
  });

  PopularDestinationsState copyWith({
    List<Map<String, dynamic>>? destinations,
    bool? isLoading,
    String? error,
  }) {
    return PopularDestinationsState(
      destinations: destinations ?? this.destinations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Popular destinations notifier
class PopularDestinationsNotifier extends Notifier<PopularDestinationsState> {
  @override
  PopularDestinationsState build() {
    print('🔧 PopularDestinationsNotifier.build() called');
    // Load popular destinations on initialization (async)
    Future.microtask(() => loadPopularDestinations());
    return const PopularDestinationsState(isLoading: true);
  }

  Future<void> loadPopularDestinations() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(realSearchRepositoryProvider);
      final destinations = await repository.getPopularDestinations();

      print('🌟 Popular destinations loaded: ${destinations.length}');
      for (var dest in destinations) {
        print('   - ${dest['name']} (${dest['code']}) - Type: ${dest['type']}');
      }

      state = state.copyWith(
        destinations: destinations,
        isLoading: false,
      );
    } catch (e) {
      print('❌ Error loading popular destinations: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Filter destinations by transport type
  List<Map<String, dynamic>> filterByType(String type) {
    final filtered = state.destinations.where((dest) {
      final destType = dest['type'] as String?;
      switch (type) {
        case 'flight':
          return destType == 'airport';
        case 'train':
          return destType == 'train_station';
        case 'bus':
          return destType == 'bus_station';
        default:
          return true;
      }
    }).toList();
    
    print('🔍 Filter by $type: ${filtered.length} destinations');
    return filtered;
  }
}

/// Popular destinations provider
final popularDestinationsProvider =
    NotifierProvider<PopularDestinationsNotifier, PopularDestinationsState>(
  () => PopularDestinationsNotifier(),
);
