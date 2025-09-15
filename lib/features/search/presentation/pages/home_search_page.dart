import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';

import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../core/services/search_history_service.dart';
import '../../../../shared/widgets/offline_banner.dart';
import '../../../../shared/widgets/app_button.dart';
import '../widgets/search_card.dart';
import '../widgets/transport_mode_tabs.dart';
import '../widgets/destination_card.dart';
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

                  // Special offers
                  _buildSpecialOffers(context),

                  const SizedBox(height: 32),

                  // Featured services
                  _buildFeaturedServices(context),

                  const SizedBox(height: 32),

                  // Recent searches
                  _buildRecentSearches(context, localizations),
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

  Widget _buildSpecialOffers(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final localizations = ref.watch(localizationsProvider(locale));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.specialOffers,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  Icons.local_offer,
                  size: 100,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      localizations.firstTripDiscount,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.useCode,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedServices(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final localizations = ref.watch(localizationsProvider(locale));

    final services = [
      {
        'title': localizations.quickBooking,
        'subtitle': localizations.quickBookingDesc,
        'icon': Icons.flash_on,
        'color': Colors.orange,
      },
      {
        'title': localizations.support247,
        'subtitle': localizations.support247Desc,
        'icon': Icons.support_agent,
        'color': Colors.green,
      },
      {
        'title': localizations.securePayment,
        'subtitle': localizations.securePaymentDesc,
        'icon': Icons.security,
        'color': Colors.blue,
      },
      {
        'title': localizations.easyRefund,
        'subtitle': localizations.easyRefundDesc,
        'icon': Icons.money_off,
        'color': Colors.purple,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.featuredServices,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      service['icon'] as IconData,
                      color: service['color'] as Color,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      service['title'] as String,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service['subtitle'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentSearches(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.recentSearches,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildRecentSearchesList(theme, localizations),
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

  Widget _buildRecentSearchesList(
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    final recentSearches = SearchHistoryService.instance
        .getFormattedSearchHistory();

    if (recentSearches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có tìm kiếm gần đây',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    // Show only first 3 recent searches on homepage
    final displaySearches = recentSearches.take(3).toList();

    return Column(
      children: [
        ...displaySearches.map(
          (search) => _buildRecentSearchItem(search, theme),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            // Navigate to search history page
            context.go('/search-history');
          },
          child: const Text('Xem tất cả'),
        ),
      ],
    );
  }

  Widget _buildRecentSearchItem(Map<String, dynamic> search, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _repeatSearch(search),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Icon(
                _getTransportIcon(search['mode']),
                color: _getTransportColor(search['mode']),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${search['from']} → ${search['to']}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${search['date']} • ${search['passengers']} hành khách',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                search['searchTime'],
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _repeatSearch(Map<String, dynamic> search) {
    // Convert history item back to SearchQuery and perform search
    final searchQuery = SearchHistoryService.instance.historyItemToSearchQuery(
      search,
    );
    ref.read(searchProvider.notifier).searchSchedules(searchQuery);

    // Navigate to results page
    context.go('/results');
  }

  IconData _getTransportIcon(String mode) {
    switch (mode) {
      case 'flight':
        return Icons.flight;
      case 'train':
        return Icons.train;
      case 'bus':
        return Icons.directions_bus;
      case 'ferry':
        return Icons.directions_boat;
      default:
        return Icons.search;
    }
  }

  Color _getTransportColor(String mode) {
    switch (mode) {
      case 'flight':
        return AppColors.flightColor;
      case 'train':
        return AppColors.trainColor;
      case 'bus':
        return AppColors.busColor;
      case 'ferry':
        return AppColors.ferryColor;
      default:
        return Colors.grey;
    }
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
      case TransportMode.ferry:
        return [
          {
            'name': 'Phú Quốc',
            'price': '150.000đ',
            'image':
                'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
          },
          {
            'name': 'Côn Đảo',
            'price': '200.000đ',
            'image':
                'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&h=300&fit=crop',
          },
          {
            'name': 'Cát Bà',
            'price': '100.000đ',
            'image':
                'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop',
          },
          {
            'name': 'Lý Sơn',
            'price': '120.000đ',
            'image':
                'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&h=300&fit=crop',
          },
        ];
    }
  }

  Color _getModeColor(TransportMode mode) {
    switch (mode) {
      case TransportMode.flight:
        return AppColors.flightColor;
      case TransportMode.train:
        return AppColors.trainColor;
      case TransportMode.bus:
        return AppColors.busColor;
      case TransportMode.ferry:
        return AppColors.ferryColor;
    }
  }

  IconData _getModeIcon(TransportMode mode) {
    switch (mode) {
      case TransportMode.flight:
        return Icons.flight;
      case TransportMode.train:
        return Icons.train;
      case TransportMode.bus:
        return Icons.directions_bus;
      case TransportMode.ferry:
        return Icons.directions_boat;
    }
  }
}
