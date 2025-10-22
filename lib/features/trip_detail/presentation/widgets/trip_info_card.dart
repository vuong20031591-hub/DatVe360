import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';

class TripInfoCard extends StatelessWidget {
  const TripInfoCard({super.key, required this.tripData});

  final Map<String, dynamic> tripData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transportType = tripData['transportType'] ?? 'flight';

    // DEBUG: Print để kiểm tra transportType
    print('🔍 TripInfoCard - transportType: $transportType');
    print('🔍 TripInfoCard - tripData keys: ${tripData.keys.toList()}');

    // Lấy icon và text động theo transport mode
    IconData icon;
    Color iconColor;
    String title;

    switch (transportType.toLowerCase()) {
      case 'flight':
        icon = Icons.flight;
        iconColor = AppColors.flightColor;
        title = 'Thông tin chuyến bay';
        break;
      case 'train':
        icon = Icons.train;
        iconColor = AppColors.trainColor;
        title = 'Thông tin chuyến tàu';
        break;
      case 'bus':
        icon = Icons.directions_bus;
        iconColor = AppColors.busColor;
        title = 'Thông tin chuyến xe';
        break;
      default:
        icon = Icons.directions;
        iconColor = AppColors.flightColor;
        title = 'Thông tin chuyến';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
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
    final transportType = tripData['transportType'] ?? 'flight';

    // Icon động theo transport mode
    IconData departureIcon;
    IconData arrivalIcon;
    Color departureColor;
    Color arrivalColor;

    switch (transportType.toLowerCase()) {
      case 'flight':
        departureIcon = Icons.flight_takeoff;
        arrivalIcon = Icons.flight_land;
        departureColor = AppColors.flightColor;
        arrivalColor = AppColors.lightSuccess;
        break;
      case 'train':
        departureIcon = Icons.train;
        arrivalIcon = Icons.train;
        departureColor = AppColors.trainColor;
        arrivalColor = AppColors.lightSuccess;
        break;
      case 'bus':
        departureIcon = Icons.directions_bus;
        arrivalIcon = Icons.directions_bus;
        departureColor = AppColors.busColor;
        arrivalColor = AppColors.lightSuccess;
        break;
      default:
        departureIcon = Icons.directions;
        arrivalIcon = Icons.directions;
        departureColor = AppColors.flightColor;
        arrivalColor = AppColors.lightSuccess;
    }

    // Use route timeline from API if available, otherwise fallback to basic route
    final route =
        tripData['route'] is Map && tripData['route']['timeline'] is List
        ? List<Map<String, dynamic>>.from(tripData['route']['timeline'])
        : tripData['route'] is List
        ? List<Map<String, dynamic>>.from(tripData['route'])
        : [
            {
              'type': 'departure',
              'time': tripData['departTime'] ?? 'N/A',
              'location': '${tripData['from']} (${tripData['fromCode']})',
            },
            {
              'type': 'arrival',
              'time': tripData['arriveTime'] ?? 'N/A',
              'location': '${tripData['to']} (${tripData['toCode']})',
            },
          ];

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
                        ? departureColor
                        : arrivalColor,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(width: 2, height: 40, color: theme.dividerColor),
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
                            ? departureIcon
                            : arrivalIcon,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stop['location'] ?? stop['airport'] ?? 'N/A',
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
    final transportType = tripData['transportType'] ?? 'flight';

    // Labels động theo transport mode
    String vehicleLabel;
    String vehicleNumberLabel;
    String durationLabel;
    String checkInMessage;
    IconData vehicleIcon;

    switch (transportType.toLowerCase()) {
      case 'flight':
        vehicleLabel = 'Loại máy bay';
        vehicleNumberLabel = 'Số hiệu chuyến bay';
        durationLabel = 'Thời gian bay';
        checkInMessage =
            'Vui lòng có mặt tại sân bay trước giờ bay ít nhất 2 tiếng để làm thủ tục check-in.';
        vehicleIcon = Icons.airplanemode_active;
        break;
      case 'train':
        vehicleLabel = 'Loại tàu';
        vehicleNumberLabel = 'Số hiệu chuyến tàu';
        durationLabel = 'Thời gian di chuyển';
        checkInMessage =
            'Vui lòng có mặt tại ga trước giờ tàu chạy ít nhất 30 phút để làm thủ tục lên tàu.';
        vehicleIcon = Icons.train;
        break;
      case 'bus':
        vehicleLabel = 'Loại xe';
        vehicleNumberLabel = 'Số hiệu chuyến xe';
        durationLabel = 'Thời gian di chuyển';
        checkInMessage =
            'Vui lòng có mặt tại bến xe trước giờ xe chạy ít nhất 15 phút để làm thủ tục lên xe.';
        vehicleIcon = Icons.directions_bus;
        break;
      default:
        vehicleLabel = 'Loại phương tiện';
        vehicleNumberLabel = 'Số hiệu chuyến';
        durationLabel = 'Thời gian di chuyển';
        checkInMessage = 'Vui lòng có mặt trước giờ khởi hành để làm thủ tục.';
        vehicleIcon = Icons.directions;
    }

    return Column(
      children: [
        // Vehicle info
        _buildDetailRow(
          theme,
          vehicleIcon,
          vehicleLabel,
          tripData['aircraft'] ?? tripData['vehicleType'] ?? 'N/A',
        ),

        const SizedBox(height: 12),

        // Vehicle number
        _buildDetailRow(
          theme,
          Icons.confirmation_number,
          vehicleNumberLabel,
          _getVehicleNumber(transportType),
        ),

        const SizedBox(height: 12),

        // Duration
        _buildDetailRow(
          theme,
          Icons.schedule,
          durationLabel,
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
                  checkInMessage,
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

  String _getVehicleNumber(String transportType) {
    final carrier = tripData['carrier'] ?? '';

    switch (transportType.toLowerCase()) {
      case 'flight':
        final flightNumber = tripData['flightNumber'];
        return flightNumber != null ? '$carrier $flightNumber' : carrier;
      case 'train':
        final trainNumber = tripData['trainNumber'];
        return trainNumber != null ? '$carrier $trainNumber' : carrier;
      case 'bus':
        final busNumber = tripData['busNumber'];
        return busNumber != null ? '$carrier $busNumber' : carrier;
      default:
        return carrier;
    }
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
