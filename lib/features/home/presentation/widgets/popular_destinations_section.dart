import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../shared/widgets/offline_banner.dart';

import '../../../search/presentation/widgets/destination_card.dart';

class PopularDestinationsSection extends ConsumerStatefulWidget {
  const PopularDestinationsSection({super.key});

  @override
  ConsumerState<PopularDestinationsSection> createState() => _PopularDestinationsSectionState();
}

class _PopularDestinationsSectionState extends ConsumerState<PopularDestinationsSection> {
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
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
          child: SizedBox(
            key: ValueKey(_selectedMode),
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _getPopularDestinations().length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final destination = _getPopularDestinations()[index];
                return DestinationCard(
                  destination: destination,
                  mode: _selectedMode,
                  onTap: () => _selectDestination(destination),
                );
              },
            ),
          ),
        ),
      ],
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

  String _getTransportLabel(TransportMode mode, AppLocalizations localizations) {
    return mode.displayName;
  }

  void _selectDestination(Map<String, String> destination) {
    // TODO: Navigate to search with pre-filled destination
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chọn điểm đến: ${destination['name'] ?? 'Unknown'}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<Map<String, String>> _getPopularDestinations() {
    switch (_selectedMode) {
      case TransportMode.flight:
        return [
          {
            'name': 'Hồ Chí Minh',
            'price': '1.200.000đ',
            'image': 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=400&h=300&fit=crop',
          },
          {
            'name': 'Đà Nẵng',
            'price': '800.000đ',
            'image': 'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=400&h=300&fit=crop',
          },
          {
            'name': 'Nha Trang',
            'price': '900.000đ',
            'image': 'https://images.unsplash.com/photo-1539650116574-75c0c6d73f6e?w=400&h=300&fit=crop',
          },
          {
            'name': 'Phú Quốc',
            'price': '1.500.000đ',
            'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
          },
        ];
      case TransportMode.train:
        return [
          {
            'name': 'Hồ Chí Minh',
            'price': '600.000đ',
            'image': 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=400&h=300&fit=crop',
          },
          {
            'name': 'Huế',
            'price': '400.000đ',
            'image': 'https://images.unsplash.com/photo-1555400082-8c5cd5b3c3d1?w=400&h=300&fit=crop',
          },
          {
            'name': 'Đà Nẵng',
            'price': '500.000đ',
            'image': 'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=400&h=300&fit=crop',
          },
          {
            'name': 'Nha Trang',
            'price': '550.000đ',
            'image': 'https://images.unsplash.com/photo-1539650116574-75c0c6d73f6e?w=400&h=300&fit=crop',
          },
        ];
      case TransportMode.bus:
        return [
          {
            'name': 'Hồ Chí Minh',
            'price': '300.000đ',
            'image': 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=400&h=300&fit=crop',
          },
          {
            'name': 'Hải Phòng',
            'price': '200.000đ',
            'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop',
          },
          {
            'name': 'Vinh',
            'price': '250.000đ',
            'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
          },
          {
            'name': 'Huế',
            'price': '280.000đ',
            'image': 'https://images.unsplash.com/photo-1555400082-8c5cd5b3c3d1?w=400&h=300&fit=crop',
          },
        ];
    }
  }
}
