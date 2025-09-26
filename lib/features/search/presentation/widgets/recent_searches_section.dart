import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/services/search_history_service.dart';


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
        _buildRecentSearchesList(context, theme, localizations),
      ],
    );
  }

  Widget _buildRecentSearchesList(BuildContext context, ThemeData theme, AppLocalizations localizations) {
    // Mock data for recent searches
    final recentSearches = [
      {
        'from': 'Hà Nội',
        'to': 'Hồ Chí Minh',
        'mode': TransportMode.flight,
        'date': '15/12/2024',
      },
      {
        'from': 'Hà Nội',
        'to': 'Đà Nẵng',
        'mode': TransportMode.train,
        'date': '10/12/2024',
      },
      {
        'from': 'Hồ Chí Minh',
        'to': 'Nha Trang',
        'mode': TransportMode.bus,
        'date': '05/12/2024',
      },
    ];

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
        return _buildRecentSearchItem(context, theme, search);
      },
    );
  }

  Widget _buildRecentSearchItem(BuildContext context, ThemeData theme, Map<String, dynamic> search) {
    final mode = search['mode'] as TransportMode;
    
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
          onPressed: () {
            // TODO: Remove from recent searches
          },
        ),
        onTap: () {
          // TODO: Pre-fill search form with this search
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tìm kiếm: ${search['from']} → ${search['to']}'),
              duration: const Duration(seconds: 2),
            ),
          );
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
