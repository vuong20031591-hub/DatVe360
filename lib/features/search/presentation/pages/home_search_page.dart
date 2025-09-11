import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/l10n.dart';
import '../../../../shared/widgets/app_button.dart';
import '../widgets/search_card.dart';
import '../widgets/transport_mode_tabs.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
              l10n.appName,
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
            tooltip: 'Quản lý đặt vé',
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
                  SearchCard(
                    mode: _selectedMode,
                    onSearch: _handleSearch,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Popular destinations
                  _buildPopularDestinations(context),
                  
                  const SizedBox(height: 32),
                  
                  // Recent searches
                  _buildRecentSearches(context),
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
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Điểm đến phổ biến',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _getPopularDestinations().length,
            itemBuilder: (context, index) {
              final destination = _getPopularDestinations()[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _selectDestination(destination),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getModeColor(_selectedMode).withOpacity(0.7),
                                  _getModeColor(_selectedMode),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                _getModeIcon(_selectedMode),
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                destination['name'],
                                style: theme.textTheme.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Từ ${destination['price']}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.lightSuccess,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSearches(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tìm kiếm gần đây',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        // TODO: Implement recent searches from provider
        Container(
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
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Chưa có tìm kiếm nào',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleSearch(Map<String, dynamic> searchData) {
    // TODO: Navigate to results page with search data
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tìm kiếm: ${searchData.toString()}'),
      ),
    );
  }

  void _selectDestination(Map<String, String> destination) {
    // TODO: Pre-fill search form with destination
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chọn điểm đến: ${destination['name']}'),
      ),
    );
  }

  List<Map<String, String>> _getPopularDestinations() {
    switch (_selectedMode) {
      case TransportMode.flight:
        return [
          {'name': 'Hồ Chí Minh', 'price': '1.200.000đ'},
          {'name': 'Đà Nẵng', 'price': '800.000đ'},
          {'name': 'Nha Trang', 'price': '900.000đ'},
          {'name': 'Phú Quốc', 'price': '1.500.000đ'},
        ];
      case TransportMode.train:
        return [
          {'name': 'Hồ Chí Minh', 'price': '600.000đ'},
          {'name': 'Huế', 'price': '400.000đ'},
          {'name': 'Đà Nẵng', 'price': '500.000đ'},
          {'name': 'Nha Trang', 'price': '550.000đ'},
        ];
      case TransportMode.bus:
        return [
          {'name': 'Hồ Chí Minh', 'price': '300.000đ'},
          {'name': 'Hải Phòng', 'price': '200.000đ'},
          {'name': 'Vinh', 'price': '250.000đ'},
          {'name': 'Huế', 'price': '280.000đ'},
        ];
      case TransportMode.ferry:
        return [
          {'name': 'Phú Quốc', 'price': '150.000đ'},
          {'name': 'Côn Đảo', 'price': '200.000đ'},
          {'name': 'Cát Bà', 'price': '100.000đ'},
          {'name': 'Lý Sơn', 'price': '120.000đ'},
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
