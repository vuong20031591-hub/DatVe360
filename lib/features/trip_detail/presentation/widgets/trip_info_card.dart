import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';

class TripInfoCard extends StatelessWidget {
  const TripInfoCard({
    super.key,
    required this.tripData,
  });

  final Map<String, dynamic> tripData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.flight,
                  color: AppColors.flightColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Thông tin chuyến bay',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Flight route timeline
            _buildRouteTimeline(theme),
            
            const SizedBox(height: 24),
            
            // Flight details
            _buildFlightDetails(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteTimeline(ThemeData theme) {
    final route = tripData['route'] as List<Map<String, dynamic>>;
    
    return Column(
      children: route.asMap().entries.map((entry) {
        final index = entry.key;
        final stop = entry.value;
        final isLast = index == route.length - 1;
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: stop['type'] == 'departure'
                        ? AppColors.flightColor
                        : AppColors.lightSuccess,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: theme.dividerColor,
                  ),
              ],
            ),
            
            const SizedBox(width: 16),
            
            // Stop info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        stop['time'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        stop['type'] == 'departure'
                            ? Icons.flight_takeoff
                            : Icons.flight_land,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stop['airport'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  if (!isLast) const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildFlightDetails(ThemeData theme) {
    return Column(
      children: [
        // Aircraft info
        _buildDetailRow(
          theme,
          Icons.airplanemode_active,
          'Loại máy bay',
          tripData['aircraft'] ?? 'N/A',
        ),
        
        const SizedBox(height: 12),
        
        // Flight number
        _buildDetailRow(
          theme,
          Icons.confirmation_number,
          'Số hiệu chuyến bay',
          '${tripData['carrier']} ${tripData['flightNumber']}',
        ),
        
        const SizedBox(height: 12),
        
        // Duration
        _buildDetailRow(
          theme,
          Icons.schedule,
          'Thời gian bay',
          tripData['duration'],
        ),
        
        const SizedBox(height: 16),
        
        // Additional info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Vui lòng có mặt tại sân bay trước giờ bay ít nhất 2 tiếng để làm thủ tục check-in.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
