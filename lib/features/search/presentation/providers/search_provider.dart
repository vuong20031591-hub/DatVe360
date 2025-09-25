import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/search_history_service.dart';
import '../../data/repositories/real_search_repository.dart';
import '../../data/models/search_query.dart';
import '../../data/models/schedule.dart';

/// Search repository provider
final searchRepositoryProvider = Provider<SearchRepositoryInterface>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return SearchRepositoryImpl(dioClient);
});

/// Search state
class SearchState {
  final bool isLoading;
  final SearchResponse? searchResponse;
  final String? error;
  final SearchQuery? lastQuery;

  const SearchState({
    this.isLoading = false,
    this.searchResponse,
    this.error,
    this.lastQuery,
  });

  SearchState copyWith({
    bool? isLoading,
    SearchResponse? searchResponse,
    String? error,
    SearchQuery? lastQuery,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      searchResponse: searchResponse ?? this.searchResponse,
      error: error,
      lastQuery: lastQuery ?? this.lastQuery,
    );
  }

  bool get hasResults =>
      searchResponse != null && searchResponse!.schedules.isNotEmpty;
  bool get hasError => error != null;
  List<Schedule> get schedules => searchResponse?.schedules ?? [];
  bool get hasMore => searchResponse?.hasMore ?? false;
  int get currentPage => searchResponse?.page ?? 1;
  int get totalResults => searchResponse?.total ?? 0;
}

/// Search provider
class SearchNotifier extends Notifier<SearchState> {
  SearchRepositoryInterface get _repository =>
      ref.read(searchRepositoryProvider);

  @override
  SearchState build() => const SearchState();

  /// Search schedules
  Future<void> searchSchedules(SearchQuery query) async {
    if (!query.isValid) {
      state = state.copyWith(error: 'Thông tin tìm kiếm không hợp lệ');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final searchResponse = await _repository.searchSchedules(query);

      // Save to search history
      await SearchHistoryService.instance.addSearchToHistory(query);

      state = state.copyWith(
        isLoading: false,
        searchResponse: searchResponse,
        lastQuery: query,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Clear search results
  void clearResults() {
    state = const SearchState();
  }

  /// Apply filters to current search results
  void applyFilters(Map<String, dynamic> filters) {
    if (state.searchResponse == null) return;

    var filteredSchedules = List<Schedule>.from(
      state.searchResponse!.schedules,
    );

    // Apply price filter
    if (filters['minPrice'] != null && filters['maxPrice'] != null) {
      final minPrice = (filters['minPrice'] as num).toDouble();
      final maxPrice = (filters['maxPrice'] as num).toDouble();
      filteredSchedules = filteredSchedules.where((schedule) {
        final price = _getSchedulePrice(schedule);
        return price >= minPrice && price <= maxPrice;
      }).toList();
    }

    // Apply time filter
    if (filters['departureTime'] != null) {
      final selectedTimes = filters['departureTime'] as List<String>;
      if (selectedTimes.isNotEmpty) {
        filteredSchedules = filteredSchedules.where((schedule) {
          final hour = schedule.departureTime.hour;
          return selectedTimes.any((timeSlot) {
            switch (timeSlot) {
              case 'morning':
                return hour >= 5 && hour < 12; // 5AM-11:59AM
              case 'afternoon':
                return hour >= 12 && hour < 18; // 12PM-5:59PM
              case 'evening':
                return hour >= 18 && hour < 22; // 6PM-9:59PM
              case 'night':
                return hour >= 22 || hour < 5; // 10PM-4:59AM
              default:
                return false;
            }
          });
        }).toList();
      }
    }

    // Apply duration filter
    if (filters['maxDuration'] != null) {
      final maxDuration = filters['maxDuration'] as double;
      filteredSchedules = filteredSchedules.where((schedule) {
        final duration = schedule.arrivalTime
            .difference(schedule.departureTime)
            .inHours;
        return duration <= maxDuration;
      }).toList();
    }

    // Apply operator filter
    if (filters['operators'] != null) {
      final selectedOperators = filters['operators'] as List<String>;
      if (selectedOperators.isNotEmpty) {
        filteredSchedules = filteredSchedules.where((schedule) {
          return selectedOperators.contains(schedule.operatorName);
        }).toList();
      }
    }

    // Apply sorting
    final sortBy = filters['sortBy'] as String? ?? 'departureTime';
    _sortSchedules(filteredSchedules, sortBy);

    // Update state with filtered results
    final updatedResponse = SearchResponse(
      schedules: filteredSchedules,
      total: filteredSchedules.length,
      page: state.searchResponse!.page,
      limit: state.searchResponse!.limit,
      hasMore: state.searchResponse!.hasMore,
      filters: state.searchResponse!.filters,
    );
    state = state.copyWith(searchResponse: updatedResponse);
  }

  /// Apply sorting to current search results
  void applySorting(String sortBy) {
    if (state.searchResponse == null) return;

    var sortedSchedules = List<Schedule>.from(state.searchResponse!.schedules);

    _sortSchedules(sortedSchedules, sortBy);

    // Update state with sorted results
    final updatedResponse = SearchResponse(
      schedules: sortedSchedules,
      total: sortedSchedules.length,
      page: state.searchResponse!.page,
      limit: state.searchResponse!.limit,
      hasMore: state.searchResponse!.hasMore,
      filters: state.searchResponse!.filters,
    );
    state = state.copyWith(searchResponse: updatedResponse);
  }

  /// Sort schedules by given criteria
  void _sortSchedules(List<Schedule> schedules, String sortBy) {
    switch (sortBy) {
      case 'price_asc':
        schedules.sort(
          (a, b) => _getSchedulePrice(a).compareTo(_getSchedulePrice(b)),
        );
        break;
      case 'price_desc':
        schedules.sort(
          (a, b) => _getSchedulePrice(b).compareTo(_getSchedulePrice(a)),
        );
        break;
      case 'duration_asc':
        schedules.sort((a, b) {
          final aDuration = a.arrivalTime.difference(a.departureTime);
          final bDuration = b.arrivalTime.difference(b.departureTime);
          return aDuration.compareTo(bDuration);
        });
        break;
      case 'departure_asc':
        schedules.sort((a, b) => a.departureTime.compareTo(b.departureTime));
        break;
      case 'departure_desc':
        schedules.sort((a, b) => b.departureTime.compareTo(a.departureTime));
        break;
      // Legacy support
      case 'price':
        schedules.sort(
          (a, b) => _getSchedulePrice(a).compareTo(_getSchedulePrice(b)),
        );
        break;
      case 'departureTime':
        schedules.sort((a, b) => a.departureTime.compareTo(b.departureTime));
        break;
      case 'duration':
        schedules.sort((a, b) {
          final aDuration = a.arrivalTime.difference(a.departureTime);
          final bDuration = b.arrivalTime.difference(b.departureTime);
          return aDuration.compareTo(bDuration);
        });
        break;
      case 'rating':
        // For now, sort by operator name as proxy for rating
        schedules.sort((a, b) => a.operatorName.compareTo(b.operatorName));
        break;
    }
  }

  /// Get the minimum price for a schedule
  double _getSchedulePrice(Schedule schedule) {
    // For now, use the base price from schedule
    // In the future, this could check pricing map for different classes
    return schedule.price;
  }

  /// Load more search results (pagination)
  Future<void> loadMoreResults() async {
    if (state.isLoading || !state.hasMore || state.lastQuery == null) return;

    try {
      // Create query for next page
      final nextPage = state.currentPage + 1;
      final response = await _repository.searchSchedules(
        state.lastQuery!,
        page: nextPage,
      );

      // Append new results to existing ones
      final allSchedules = [...state.schedules, ...response.schedules];
      final updatedResponse = SearchResponse(
        schedules: allSchedules,
        total: response.total,
        page: nextPage,
        limit: response.limit,
        hasMore: response.hasMore,
        filters: response.filters,
      );

      state = state.copyWith(searchResponse: updatedResponse, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Search provider instance
final searchProvider = NotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);

/// Popular destinations provider
final popularDestinationsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) {
  final repository = ref.read(searchRepositoryProvider);
  return repository.getPopularDestinations();
});

/// Destination search provider
final destinationSearchProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, query) {
      final repository = ref.read(searchRepositoryProvider);
      return repository.searchDestinations(query);
    });

/// Search form state
class SearchFormState {
  final String from;
  final String to;
  final DateTime? departDate;
  final DateTime? returnDate;
  final bool isRoundTrip;
  final int adults;
  final int children;
  final int infants;

  const SearchFormState({
    this.from = '',
    this.to = '',
    this.departDate,
    this.returnDate,
    this.isRoundTrip = false,
    this.adults = 1,
    this.children = 0,
    this.infants = 0,
  });

  SearchFormState copyWith({
    String? from,
    String? to,
    DateTime? departDate,
    DateTime? returnDate,
    bool? isRoundTrip,
    int? adults,
    int? children,
    int? infants,
  }) {
    return SearchFormState(
      from: from ?? this.from,
      to: to ?? this.to,
      departDate: departDate ?? this.departDate,
      returnDate: returnDate ?? this.returnDate,
      isRoundTrip: isRoundTrip ?? this.isRoundTrip,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      infants: infants ?? this.infants,
    );
  }

  SearchQuery toSearchQuery(TransportMode mode) {
    return SearchQuery(
      mode: mode,
      from: from,
      to: to,
      departDate: departDate ?? DateTime.now().add(const Duration(days: 1)),
      returnDate: returnDate,
      passengers: PassengerCount(
        adult: adults,
        child: children,
        infant: infants,
      ),
      roundTrip: isRoundTrip,
    );
  }

  bool get isValid {
    return from.isNotEmpty &&
        to.isNotEmpty &&
        from != to &&
        departDate != null &&
        adults >= 1 &&
        (adults + children + infants) <= 9 &&
        (!isRoundTrip || returnDate != null);
  }
}

/// Search form provider
class SearchFormNotifier extends Notifier<SearchFormState> {
  @override
  SearchFormState build() => const SearchFormState();

  void updateFrom(String from) {
    state = state.copyWith(from: from);
  }

  void updateTo(String to) {
    state = state.copyWith(to: to);
  }

  void updateDepartDate(DateTime date) {
    state = state.copyWith(departDate: date);
  }

  void updateReturnDate(DateTime? date) {
    state = state.copyWith(returnDate: date);
  }

  void updateRoundTrip(bool isRoundTrip) {
    state = state.copyWith(
      isRoundTrip: isRoundTrip,
      returnDate: isRoundTrip ? state.returnDate : null,
    );
  }

  void updatePassengers({int? adults, int? children, int? infants}) {
    state = state.copyWith(
      adults: adults ?? state.adults,
      children: children ?? state.children,
      infants: infants ?? state.infants,
    );
  }

  void swapFromTo() {
    state = state.copyWith(from: state.to, to: state.from);
  }

  void reset() {
    state = const SearchFormState();
  }
}

/// Search form provider instance
final searchFormProvider =
    NotifierProvider<SearchFormNotifier, SearchFormState>(
      SearchFormNotifier.new,
    );
