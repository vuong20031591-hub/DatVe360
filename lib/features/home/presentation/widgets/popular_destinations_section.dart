import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../shared/widgets/offline_banner.dart';
import '../../../search/presentation/providers/popular_destinations_provider.dart';
import '../../../search/presentation/widgets/destination_card.dart';

class PopularDestinationsSection extends ConsumerStatefulWidget {
  const PopularDestinationsSection({super.key});

  @override
  ConsumerState<PopularDestinationsSection> createState() =>
      _PopularDestinationsSectionState();
}

class _PopularDestinationsSectionState
    extends ConsumerState<PopularDestinationsSection> {
  TransportMode _selectedMode = TransportMode.flight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final localizations = ref.watch(localizationsProvider(locale));
    final connectivityState = ref.watch(connectivityNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  localizations.popularDestinations,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CachedDataIndicator(isVisible: !connectivityState.isOnline),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Transport mode tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: TransportMode.values.map((mode) {
              final isSelected = _selectedMode == mode;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMode = mode;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getTransportIcon(mode),
                            size: 16,
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getTransportLabel(mode, localizations),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Destinations list
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildDestinationsList(),
        ),
      ],
    );
  }

  Widget _buildDestinationsList() {
    final popularState = ref.watch(popularDestinationsProvider);
    final theme = Theme.of(context);

    print('📍 Building destinations list - Loading: ${popularState.isLoading}, Error: ${popularState.error}, Count: ${popularState.destinations.length}');

    // Loading state
    if (popularState.isLoading) {
      return SizedBox(
        key: const ValueKey('loading'),
        height: 120,
        child: Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    // Error state
    if (popularState.error != null) {
      return SizedBox(
        key: const ValueKey('error'),
        height: 120,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 32,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 8),
              Text(
                'Không thể tải điểm đến',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(popularDestinationsProvider.notifier).loadPopularDestinations();
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    // Filter destinations by transport mode
    final destinations = _getPopularDestinations();

    // Empty state
    if (destinations.isEmpty) {
      return SizedBox(
        key: const ValueKey('empty'),
        height: 120,
        child: Center(
          child: Text(
            'Chưa có điểm đến phổ biến',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    // Success state - show destinations
    return SizedBox(
      key: ValueKey(_selectedMode),
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: destinations.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final destination = destinations[index];
          return DestinationCard(
            destination: destination,
            mode: _selectedMode,
            onTap: () => _selectDestination(destination),
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

  String _getTransportLabel(
    TransportMode mode,
    AppLocalizations localizations,
  ) {
    return mode.displayName;
  }

  void _selectDestination(Map<String, dynamic> destination) {
    // TODO: Navigate to search with pre-filled destination
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chọn điểm đến: ${destination['name'] ?? 'Unknown'}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<Map<String, dynamic>> _getPopularDestinations() {
    // Watch provider to rebuild when data changes
    ref.watch(popularDestinationsProvider);
    
    // Filter by selected transport mode
    final transportType = _selectedMode == TransportMode.flight
        ? 'flight'
        : _selectedMode == TransportMode.train
            ? 'train'
            : 'bus';
    
    return ref.read(popularDestinationsProvider.notifier).filterByType(transportType);
  }
}
