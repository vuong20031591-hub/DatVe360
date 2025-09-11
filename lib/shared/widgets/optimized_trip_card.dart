import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'shimmer_loading.dart';

/// Optimized trip card widget with performance enhancements
class OptimizedTripCard extends StatelessWidget {
  final Map<String, dynamic> trip;
  final VoidCallback? onTap;
  final bool showImage;
  final bool showFavoriteButton;

  const OptimizedTripCard({
    super.key,
    required this.trip,
    this.onTap,
    this.showImage = true,
    this.showFavoriteButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showImage && trip['image'] != null) _buildImage(),
            _buildContent(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: CachedNetworkImage(
        imageUrl: trip['image'],
        fit: BoxFit.cover,
        memCacheWidth: 600,
        memCacheHeight: 320,
        placeholder: (context, url) => const ShimmerCard(
          height: 160,
          borderRadius: BorderRadius.zero,
        ),
        errorWidget: (context, url, error) => Container(
          height: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getTransportColor(trip['mode']).withValues(alpha: 0.7),
                _getTransportColor(trip['mode']),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Icon(
              _getTransportIcon(trip['mode']),
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
        imageBuilder: (context, imageProvider) => Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
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
            ),
            if (showFavoriteButton)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => _toggleFavorite(),
                  icon: Icon(
                    trip['isFavorite'] == true
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getTransportIcon(trip['mode']),
                color: _getTransportColor(trip['mode']),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  trip['carrierName'] ?? 'Unknown Carrier',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trip['price'] != null)
                Text(
                  'Từ ${trip['price']}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.lightSuccess,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLocationInfo(
                  theme,
                  trip['from'] ?? 'Unknown',
                  trip['departTime'] ?? '',
                  isDestination: false,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  Icons.arrow_forward,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Expanded(
                child: _buildLocationInfo(
                  theme,
                  trip['to'] ?? 'Unknown',
                  trip['arriveTime'] ?? '',
                  isDestination: true,
                ),
              ),
            ],
          ),
          if (trip['duration'] != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  trip['duration'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (trip['stops'] != null && trip['stops'] > 0) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.circle,
                    size: 4,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${trip['stops']} điểm dừng',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationInfo(
    ThemeData theme,
    String location,
    String time, {
    required bool isDestination,
  }) {
    return Column(
      crossAxisAlignment:
          isDestination ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          location,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: isDestination ? TextAlign.end : TextAlign.start,
        ),
        if (time.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            time,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: isDestination ? TextAlign.end : TextAlign.start,
          ),
        ],
      ],
    );
  }

  void _toggleFavorite() {
    // TODO: Implement favorite toggle logic
  }

  IconData _getTransportIcon(String? mode) {
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
        return Icons.confirmation_number;
    }
  }

  Color _getTransportColor(String? mode) {
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
}
