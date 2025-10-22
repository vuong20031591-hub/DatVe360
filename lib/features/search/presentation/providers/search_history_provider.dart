import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/search_history_service.dart';
import '../../data/models/search_query.dart';

/// Search history notifier - handles search history operations
class SearchHistoryNotifier extends Notifier<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> build() {
    // Initial load from service
    return SearchHistoryService.instance.getFormattedSearchHistory();
  }

  final _service = SearchHistoryService.instance;

  /// Reload history from service
  void reload() {
    state = _service.getFormattedSearchHistory();
  }

  /// Add search to history and refresh state
  Future<void> addSearch(SearchQuery query) async {
    await _service.addSearchToHistory(query);
    reload();
  }

  /// Remove specific search from history and refresh state
  Future<void> removeSearch(Map<String, dynamic> item) async {
    await _service.removeSearchFromHistory(item);
    reload();
  }

  /// Clear all history and refresh state
  Future<void> clearAll() async {
    await _service.clearHistory();
    reload();
  }

  /// Convert history item to SearchQuery for form prefill
  SearchQuery itemToQuery(Map<String, dynamic> item) {
    return _service.historyItemToSearchQuery(item);
  }
}

/// Search history list provider instance
final searchHistoryListProvider = NotifierProvider<SearchHistoryNotifier, List<Map<String, dynamic>>>(
  SearchHistoryNotifier.new,
);

