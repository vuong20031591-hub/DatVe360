import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/locale_provider.dart';
import '../providers/search_history_provider.dart';
import '../providers/search_provider.dart';

class RecentSearchesSection extends ConsumerWidget {
  const RecentSearchesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final localizations = ref.watch(localizationsProvider(locale));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            localizations.recentSearches,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildRecentSearchesList(context, ref, theme, localizations),
      ],
    );
  }

  Widget _buildRecentSearchesList(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    // Watch provider for reactive updates
    final recentSearches = ref.watch(searchHistoryListProvider);

    if (recentSearches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 48,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                localizations.noRecentSearches,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: recentSearches.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final search = recentSearches[index];
        return _buildRecentSearchItem(context, ref, theme, search);
      },
    );
  }

  Widget _buildRecentSearchItem(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    Map<String, dynamic> search,
  ) {
    // Parse mode string to TransportMode enum
    final modeString = search['mode'] as String;
    final mode = TransportMode.values.firstWhere(
      (m) => m.value == modeString,
      orElse: () => TransportMode.flight,
    );

    return Card(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getTransportColor(mode).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTransportIcon(mode),
            color: _getTransportColor(mode),
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                search['from'] as String,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_forward,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                search['to'] as String,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Text(
          search['date'] as String,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.close,
            size: 18,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          onPressed: () async {
            // Remove from history via provider
            await ref.read(searchHistoryListProvider.notifier).removeSearch(
              search['originalItem'] as Map<String, dynamic>
            );
            
            // Show confirmation
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa khỏi lịch sử'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
        onTap: () async {
          // Convert history item to SearchQuery
          final searchQuery = ref.read(searchHistoryListProvider.notifier)
              .itemToQuery(search);

          // Update search form (for when user comes back)
          final formNotifier = ref.read(searchFormProvider.notifier);
          formNotifier.updateFrom(searchQuery.from);
          formNotifier.updateTo(searchQuery.to);
          formNotifier.updateDepartDate(searchQuery.departDate);
          
          if (searchQuery.roundTrip && searchQuery.returnDate != null) {
            formNotifier.updateRoundTrip(true);
            formNotifier.updateReturnDate(searchQuery.returnDate);
          }
          
          formNotifier.updatePassengers(
            adults: searchQuery.passengers.adult,
            children: searchQuery.passengers.child,
            infants: searchQuery.passengers.infant,
          );

          // Trigger search
          await ref.read(searchProvider.notifier).searchSchedules(searchQuery);

          // Navigate to results page
          if (context.mounted) {
            context.go('/results');
          }
        },
      ),
    );
  }

  IconData _getTransportIcon(TransportMode mode) {
    switch (mode) {
      case TransportMode.flight:
        return Icons.flight;
      case TransportMode.train:
        return Icons.train;
      case TransportMode.bus:
        return Icons.directions_bus;
    }
  }

  Color _getTransportColor(TransportMode mode) {
    switch (mode) {
      case TransportMode.flight:
        return Colors.blue;
      case TransportMode.train:
        return Colors.green;
      case TransportMode.bus:
        return Colors.orange;
    }
  }
}
