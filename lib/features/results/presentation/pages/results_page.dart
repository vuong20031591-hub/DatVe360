import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/i18n/l10n.dart';
import '../../../search/presentation/providers/search_provider.dart';
import '../../../search/data/models/schedule.dart';
import '../../../search/data/models/search_query.dart';

import '../widgets/filter_bottom_sheet.dart';
import '../widgets/sort_dropdown.dart';
import '../widgets/results_shimmer.dart';
import '../widgets/empty_results.dart';
import '../widgets/schedule_card.dart';

class ResultsPage extends ConsumerStatefulWidget {
  const ResultsPage({super.key});

  @override
  ConsumerState<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends ConsumerState<ResultsPage> {
  String _sortBy = 'price_asc';
  Map<String, dynamic> _filters = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.results),
        actions: [
          // Sort dropdown
          SortDropdown(
            value: _sortBy,
            onChanged: (value) {
              setState(() {
                _sortBy = value;
              });
              _sortTrips();
            },
          ),
          const SizedBox(width: 8),
          // Filter button
          IconButton(
            onPressed: _showFilterSheet,
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (_filters.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search summary
          _buildSearchSummary(context),

          // Results
          Expanded(child: _buildResultsList(context)),
        ],
      ),
    );
  }

  Widget _buildSearchSummary(BuildContext context) {
    final theme = Theme.of(context);
    final searchState = ref.watch(searchProvider);

    if (searchState.lastQuery == null) {
      return const SizedBox.shrink();
    }

    final query = searchState.lastQuery!;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${query.from} → ${query.to}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatSearchDate(query),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          if (!searchState.isLoading && searchState.hasResults)
            Text(
              '${searchState.schedules.length} chuyến',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    if (searchState.isLoading) {
      return const ResultsShimmer();
    }

    if (searchState.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              searchState.error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (searchState.lastQuery != null) {
                  ref
                      .read(searchProvider.notifier)
                      .searchSchedules(searchState.lastQuery!);
                }
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (!searchState.hasResults) {
      return EmptyResults(
        onRetry: () {
          if (searchState.lastQuery != null) {
            ref
                .read(searchProvider.notifier)
                .searchSchedules(searchState.lastQuery!);
          }
        },
        onChangeSearch: () {
          Navigator.pop(context);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (searchState.lastQuery != null) {
          await ref
              .read(searchProvider.notifier)
              .searchSchedules(searchState.lastQuery!);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: searchState.schedules.length + (searchState.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Show load more button at the end
          if (index == searchState.schedules.length) {
            return _buildLoadMoreButton();
          }

          final schedule = searchState.schedules[index];
          return ScheduleCard(
            schedule: schedule,
            onSelect: () => _selectSchedule(schedule),
          );
        },
      ),
    );
  }

  String _formatSearchDate(SearchQuery query) {
    final departDate = query.departDate;
    final returnDate = query.returnDate;
    final passengers = '${query.passengers.adult} người lớn';

    final departStr = '${departDate.day}/${departDate.month}';
    if (returnDate != null) {
      final returnStr = '${returnDate.day}/${returnDate.month}';
      return '$departStr - $returnStr • $passengers';
    }

    return '$departStr • $passengers';
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(
        currentFilters: _filters,
        onApply: (filters) {
          setState(() {
            _filters = filters;
          });
          _applyFilters();
        },
      ),
    );
  }

  void _sortTrips() {
    // Apply sorting directly through search provider
    ref.read(searchProvider.notifier).applySorting(_sortBy);
  }

  void _applyFilters() {
    ref.read(searchProvider.notifier).applyFilters(_filters);
  }

  Widget _buildLoadMoreButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            ref.read(searchProvider.notifier).loadMoreResults();
          },
          child: const Text('Tải thêm kết quả'),
        ),
      ),
    );
  }

  void _selectSchedule(Schedule schedule) {
    // Navigate to trip detail page with schedule data
    context.pushNamed(
      'tripDetail',
      pathParameters: {'tripId': schedule.id},
      extra: {'schedule': schedule},
    );
  }
}
