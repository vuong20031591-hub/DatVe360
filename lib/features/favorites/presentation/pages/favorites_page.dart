import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/l10n.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/shimmer_loading.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu thích'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Chuyến đi', icon: Icon(Icons.flight)),
            Tab(text: 'Điểm đến', icon: Icon(Icons.location_on)),
            Tab(text: 'Tuyến đường', icon: Icon(Icons.route)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFavoriteTrips(context, theme),
          _buildFavoriteDestinations(context, theme),
          _buildFavoriteRoutes(context, theme),
        ],
      ),
    );
  }

  Widget _buildFavoriteTrips(BuildContext context, ThemeData theme) {
    final favoriteTrips = _getFavoriteTrips();

    if (favoriteTrips.isEmpty) {
      return _buildEmptyState(
        context,
        theme,
        Icons.flight_takeoff,
        'Chưa có chuyến đi yêu thích',
        'Thêm chuyến đi vào danh sách yêu thích để dễ dàng đặt lại',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: favoriteTrips.length,
      itemBuilder: (context, index) {
        final trip = favoriteTrips[index];
        return _buildTripCard(context, theme, trip);
      },
    );
  }

  Widget _buildFavoriteDestinations(BuildContext context, ThemeData theme) {
    final favoriteDestinations = _getFavoriteDestinations();

    if (favoriteDestinations.isEmpty) {
      return _buildEmptyState(
        context,
        theme,
        Icons.location_on,
        'Chưa có điểm đến yêu thích',
        'Lưu các điểm đến bạn muốn ghé thăm',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: favoriteDestinations.length,
      itemBuilder: (context, index) {
        final destination = favoriteDestinations[index];
        return _buildDestinationCard(context, theme, destination);
      },
    );
  }

  Widget _buildFavoriteRoutes(BuildContext context, ThemeData theme) {
    final favoriteRoutes = _getFavoriteRoutes();

    if (favoriteRoutes.isEmpty) {
      return _buildEmptyState(
        context,
        theme,
        Icons.route,
        'Chưa có tuyến đường yêu thích',
        'Lưu các tuyến đường bạn thường đi',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: favoriteRoutes.length,
      itemBuilder: (context, index) {
        final route = favoriteRoutes[index];
        return _buildRouteCard(context, theme, route);
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AppButton(
            onPressed: () => Navigator.of(context).pop(),
            text: 'Khám phá ngay',
            icon: Icons.explore,
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> trip,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _bookTrip(trip),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getTransportIcon(trip['mode']),
                    color: _getTransportColor(trip['mode']),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${trip['from']} → ${trip['to']}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          trip['airline'] ?? trip['operator'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeFavorite(trip),
                    icon: const Icon(Icons.favorite, color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Từ ${trip['price']}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.lightSuccess,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${trip['duration']}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationCard(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> destination,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _searchDestination(destination),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: destination['image'],
                fit: BoxFit.cover,
                memCacheWidth: 400,
                memCacheHeight: 300,
                placeholder: (context, url) => const ShimmerCard(),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey[400]!, Colors.grey[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.error, color: Colors.white),
                ),
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () => _removeFavorite(destination),
                        icon: const Icon(Icons.favorite, color: Colors.red),
                      ),
                    ),
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
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
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
    );
  }

  Widget _buildRouteCard(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> route,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _searchRoute(route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                _getTransportIcon(route['mode']),
                color: _getTransportColor(route['mode']),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${route['from']} → ${route['to']}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Tìm kiếm ${route['searchCount']} lần',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _removeFavorite(route),
                icon: const Icon(Icons.favorite, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mock data methods
  List<Map<String, dynamic>> _getFavoriteTrips() {
    return [
      {
        'from': 'Hà Nội',
        'to': 'Hồ Chí Minh',
        'mode': 'flight',
        'airline': 'Vietnam Airlines',
        'price': '2.500.000đ',
        'duration': '2h 15m',
      },
      {
        'from': 'Đà Nẵng',
        'to': 'Nha Trang',
        'mode': 'train',
        'operator': 'Đường sắt Việt Nam',
        'price': '450.000đ',
        'duration': '10h 30m',
      },
    ];
  }

  List<Map<String, dynamic>> _getFavoriteDestinations() {
    return [
      {
        'name': 'Phú Quốc',
        'price': '1.500.000đ',
        'image':
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
      },
      {
        'name': 'Đà Nẵng',
        'price': '800.000đ',
        'image':
            'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=400&h=300&fit=crop',
      },
    ];
  }

  List<Map<String, dynamic>> _getFavoriteRoutes() {
    return [
      {
        'from': 'Hà Nội',
        'to': 'Hồ Chí Minh',
        'mode': 'flight',
        'searchCount': 5,
      },
      {'from': 'Hà Nội', 'to': 'Đà Nẵng', 'mode': 'train', 'searchCount': 3},
    ];
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

  void _bookTrip(Map<String, dynamic> trip) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đặt vé: ${trip['from']} → ${trip['to']}')),
    );
  }

  void _searchDestination(Map<String, dynamic> destination) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tìm chuyến đi đến ${destination['name']}')),
    );
  }

  void _searchRoute(Map<String, dynamic> route) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tìm kiếm: ${route['from']} → ${route['to']}')),
    );
  }

  void _removeFavorite(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã xóa khỏi danh sách yêu thích'),
        action: SnackBarAction(
          label: 'Hoàn tác',
          onPressed: () {
            // TODO: Restore favorite
          },
        ),
      ),
    );
  }
}
