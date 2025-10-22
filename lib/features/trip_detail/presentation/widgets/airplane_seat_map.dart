import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import 'seat_data.dart';

/// Widget hiển thị sơ đồ ghế máy bay
/// Layout: 3-3-3 hoặc 2-4-2 với lối đi giữa
class AirplaneSeatMap extends StatelessWidget {
  const AirplaneSeatMap({
    super.key,
    required this.seatGrid,
    required this.selectedSeats,
    required this.onSeatToggle,
  });

  final List<List<SeatData?>> seatGrid;
  final List<String> selectedSeats;
  final Function(String) onSeatToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Aircraft front indicator
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
                Icons.flight,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Đầu máy bay',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Seat grid
        Column(
          children: seatGrid.asMap().entries.map((entry) {
            final rowIndex = entry.key;
            final row = entry.value;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Row number (left)
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

                  // Left seats (A, B, C)
                  ...row.take(3).map((seat) => _buildSeat(theme, seat)),

                  // Aisle
                  const SizedBox(width: 20),

                  // Right seats (D, E, F)
                  ...row.skip(3).map((seat) => _buildSeat(theme, seat)),

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
        ),

        const SizedBox(height: 16),

        // Column labels
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 34), // Row number space
            // Left column labels
            ...'ABC'.split('').map(
                  (letter) => Container(
                    width: AppConstants.seatSize + AppConstants.seatSpacing * 2,
                    alignment: Alignment.center,
                    child: Text(
                      letter,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

            const SizedBox(width: 20), // Aisle space
            // Right column labels
            ...'DEF'.split('').map(
                  (letter) => Container(
                    width: AppConstants.seatSize + AppConstants.seatSpacing * 2,
                    alignment: Alignment.center,
                    child: Text(
                      letter,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

            const SizedBox(width: 38), // Row number space
          ],
        ),
      ],
    );
  }

  Widget _buildSeat(ThemeData theme, SeatData? seat) {
    if (seat == null) {
      return SizedBox(
        width: AppConstants.seatSize + AppConstants.seatSpacing * 2,
        height: AppConstants.seatSize + AppConstants.seatSpacing * 2,
      );
    }

    final isSelected = selectedSeats.contains(seat.id);
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
        onTap: isSelectable ? () => onSeatToggle(seat.id) : null,
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
              Icons.airline_seat_recline_normal,
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

