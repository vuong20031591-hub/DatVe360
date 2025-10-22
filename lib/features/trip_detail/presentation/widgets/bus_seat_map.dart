import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import 'seat_data.dart';

/// Widget hiển thị sơ đồ ghế xe khách
/// Layout: 2-1 (2 giường bên trái, 1 giường bên phải) với 2 tầng
class BusSeatMap extends StatefulWidget {
  const BusSeatMap({
    super.key,
    required this.lowerLevel,
    required this.upperLevel,
    required this.selectedSeats,
    required this.onSeatToggle,
  });

  final List<List<SeatData?>> lowerLevel; // Tầng dưới
  final List<List<SeatData?>> upperLevel; // Tầng trên
  final List<String> selectedSeats;
  final Function(String) onSeatToggle;

  @override
  State<BusSeatMap> createState() => _BusSeatMapState();
}

class _BusSeatMapState extends State<BusSeatMap> {
  int _selectedLevel = 0; // 0 = tầng dưới, 1 = tầng trên

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Bus front indicator
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_bus,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Đầu xe',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Level selector
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildLevelButton(theme, 'Tầng dưới', 0),
              ),
              Expanded(
                child: _buildLevelButton(theme, 'Tầng trên', 1),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Seat grid for selected level
        _buildSeatGrid(
          theme,
          _selectedLevel == 0 ? widget.lowerLevel : widget.upperLevel,
        ),
      ],
    );
  }

  Widget _buildLevelButton(ThemeData theme, String label, int level) {
    final isSelected = _selectedLevel == level;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLevel = level;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSeatGrid(ThemeData theme, List<List<SeatData?>> grid) {
    return Column(
      children: grid.asMap().entries.map((entry) {
        final rowIndex = entry.key;
        final row = entry.value;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Row number
              SizedBox(
                width: 28,
                child: Text(
                  '${rowIndex + 1}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(width: 6),

              // Left seats (2 seats)
              ...row.take(2).map((seat) => _buildSeat(theme, seat)),

              // Aisle
              const SizedBox(width: 20),

              // Right seat (1 seat)
              if (row.length > 2) _buildSeat(theme, row[2]),

              const SizedBox(width: 6),

              // Row number (right)
              SizedBox(
                width: 28,
                child: Text(
                  '${rowIndex + 1}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSeat(ThemeData theme, SeatData? seat) {
    if (seat == null) {
      return SizedBox(
        width: AppConstants.seatSize + AppConstants.seatSpacing * 2,
        height: AppConstants.seatSize + AppConstants.seatSpacing * 2,
      );
    }

    final isSelected = widget.selectedSeats.contains(seat.id);
    final isSelectable = seat.status == SeatStatus.available || isSelected;

    Color seatColor;
    switch (seat.status) {
      case SeatStatus.available:
        seatColor = isSelected ? AppColors.selectedColor : AppColors.availableColor;
        break;
      case SeatStatus.booked:
        seatColor = AppColors.bookedColor;
        break;
      case SeatStatus.selected:
        seatColor = AppColors.selectedColor;
        break;
      case SeatStatus.held:
        seatColor = AppColors.heldColor;
        break;
    }

    return Container(
      width: AppConstants.seatSize + AppConstants.seatSpacing * 2,
      height: AppConstants.seatSize + AppConstants.seatSpacing * 2,
      padding: const EdgeInsets.all(AppConstants.seatSpacing),
      child: GestureDetector(
        onTap: isSelectable ? () => widget.onSeatToggle(seat.id) : null,
        child: Container(
          decoration: BoxDecoration(
            color: seatColor,
            borderRadius: BorderRadius.circular(6),
            border: isSelected
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Center(
            child: Icon(
              Icons.airline_seat_flat,
              size: 16,
              color: seat.status == SeatStatus.available
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}

