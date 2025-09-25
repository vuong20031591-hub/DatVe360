import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';


import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/connectivity_provider.dart';

import '../../../../shared/widgets/offline_banner.dart';
import '../../../../shared/widgets/app_button.dart';
import '../widgets/search_card.dart';
import '../widgets/transport_mode_tabs.dart';
import '../widgets/destination_card.dart';
import '../widgets/recent_searches_section.dart';
import '../providers/search_provider.dart';
import '../../data/models/search_query.dart';

class HomeSearchPage extends ConsumerStatefulWidget {
  const HomeSearchPage({super.key});

  @override
  ConsumerState<HomeSearchPage> createState() => _HomeSearchPageState();
}

class _HomeSearchPageState extends ConsumerState<HomeSearchPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TransportMode _selectedMode = TransportMode.flight;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: TransportMode.values.length,
      vsync: this,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedMode = TransportMode.values[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final localizations = ref.watch(localizationsProvider(locale));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.flight_takeoff,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              localizations.appName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Navigate to manage booking
            },
            icon: const Icon(Icons.receipt_long),
            tooltip: locale.languageCode == 'vi'
                ? 'Quản lý đặt vé'
                : 'Manage Bookings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Transport mode tabs
          Container(
            color: theme.colorScheme.surface,
            child: TransportModeTabs(
              controller: _tabController,
              onModeChanged: (mode) {
                setState(() {
                  _selectedMode = mode;
                });
              },
            ),
          ),

          // Search content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search card
                  SearchCard(mode: _selectedMode, onSearch: _handleSearch),

                  const SizedBox(height: 32),

                  // Popular destinations
                  _buildPopularDestinations(context),

                  const SizedBox(height: 32),

                  // Recent searches
                  const RecentSearchesSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularDestinations(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final localizations = ref.watch(localizationsProvider(locale));
    final connectivityState = ref.watch(connectivityNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                localizations.popularDestinations,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            CachedDataIndicator(isVisible: !connectivityState.isOnline),
          ],
        ),
        const SizedBox(height: 16),
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







  void _handleSearch(Map<String, dynamic> searchData) {
    print('DEBUG: HomeSearchPage._handleSearch called with: $searchData');

    // Create SearchQuery from form data
    final query = SearchQuery(
      mode: searchData['mode'] as TransportMode,
      from: searchData['from'] as String,
      to: searchData['to'] as String,
      departDate: searchData['departDate'] as DateTime,
      returnDate: searchData['returnDate'] as DateTime?,
      passengers: PassengerCount(
        adult: searchData['adults'] as int,
        child: searchData['children'] as int,
        infant: searchData['infants'] as int,
      ),
      roundTrip: searchData['isRoundTrip'] as bool,
    );

    print('DEBUG: Created SearchQuery: $query');

    // Perform search
    ref.read(searchProvider.notifier).searchSchedules(query);
    print('DEBUG: Called searchSchedules');

    // Navigate to results page (search already triggered)
    context.go('/results');
    print('DEBUG: Navigated to results page');
  }







  void _selectDestination(Map<String, String> destination) {
    // TODO: Pre-fill search form with destination
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chọn điểm đến: ${destination['name'] ?? 'Unknown'}'),
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
            'image':
                'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=400&h=300&fit=crop',
          },
          {
            'name': 'Đà Nẵng',
            'price': '800.000đ',
            'image':
                'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=400&h=300&fit=crop',
          },
          {
            'name': 'Nha Trang',
            'price': '900.000đ',
            'image':
                'https://images.unsplash.com/photo-1539650116574-75c0c6d73f6e?w=400&h=300&fit=crop',
          },
          {
            'name': 'Phú Quốc',
            'price': '1.500.000đ',
            'image':
                'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
          },
        ];
      case TransportMode.train:
        return [
          {
            'name': 'Hồ Chí Minh',
            'price': '600.000đ',
            'image':
                'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=400&h=300&fit=crop',
          },
          {
            'name': 'Huế',
            'price': '400.000đ',
            'image':
                'https://images.unsplash.com/photo-1555400082-8c5cd5b3c3d1?w=400&h=300&fit=crop',
          },
          {
            'name': 'Đà Nẵng',
            'price': '500.000đ',
            'image':
                'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=400&h=300&fit=crop',
          },
          {
            'name': 'Nha Trang',
            'price': '550.000đ',
            'image':
                'https://images.unsplash.com/photo-1539650116574-75c0c6d73f6e?w=400&h=300&fit=crop',
          },
        ];
      case TransportMode.bus:
        return [
          {
            'name': 'Hồ Chí Minh',
            'price': '300.000đ',
            'image':
                'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=400&h=300&fit=crop',
          },
          {
            'name': 'Hải Phòng',
            'price': '200.000đ',
            'image':
                'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop',
          },
          {
            'name': 'Vinh',
            'price': '250.000đ',
            'image':
                'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
          },
          {
            'name': 'Huế',
            'price': '280.000đ',
            'image':
                'https://images.unsplash.com/photo-1555400082-8c5cd5b3c3d1?w=400&h=300&fit=crop',
          },
        ];
    }
    // This should never be reached since all enum values are covered
    return [];
  }


}
