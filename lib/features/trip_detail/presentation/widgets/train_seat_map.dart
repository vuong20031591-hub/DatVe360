import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import 'seat_data.dart';

/// Widget hiển thị sơ đồ ghế tàu hỏa
/// Layout: Compartments với berths (giường tầng)
/// Mỗi compartment có 4-6 giường (2-3 tầng x 2 bên)
class TrainSeatMap extends StatelessWidget {
  const TrainSeatMap({
    super.key,
    required this.compartments,
    required this.selectedSeats,
    required this.onSeatToggle,
  });

  final List<TrainCompartment> compartments;
  final List<String> selectedSeats;
  final Function(String) onSeatToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Group compartments by coach (10 compartments per coach)
    final compartmentsPerCoach = 10;
    final totalCoaches = (compartments.length / compartmentsPerCoach).ceil();

    return Column(
      children: [
        // Train front indicator
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
              Icon(Icons.train, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Đầu tàu',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Coaches with compartments
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: totalCoaches,
          separatorBuilder: (context, index) => const SizedBox(height: 24),
          itemBuilder: (context, coachIndex) {
            final startIndex = coachIndex * compartmentsPerCoach;
            final endIndex = ((coachIndex + 1) * compartmentsPerCoach).clamp(
              0,
              compartments.length,
            );
            final coachCompartments = compartments.sublist(
              startIndex,
              endIndex,
            );

            return _buildCoach(
              theme,
              coachIndex + 1,
              coachCompartments,
              startIndex,
            );
          },
        ),
      ],
    );
  }

  Widget _buildCoach(
    ThemeData theme,
    int coachNumber,
    List<TrainCompartment> coachCompartments,
    int startCompartmentIndex,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coach header
          Row(
            children: [
              Icon(
                Icons.train_outlined,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Toa $coachNumber',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${coachCompartments.length} khoang',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Compartments in this coach
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: coachCompartments.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final compartmentNumber = index + 1;
              return _buildCompartment(
                theme,
                coachCompartments[index],
                compartmentNumber,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompartment(
    ThemeData theme,
    TrainCompartment compartment,
    int number,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compartment number
          Text(
            'Khoang $number',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Berths layout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Left side berths
              _buildBerthColumn(theme, compartment.leftBerths),

              // Aisle
              Container(
                width: 40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.door_sliding,
                      size: 24,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lối đi',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Right side berths
              _buildBerthColumn(theme, compartment.rightBerths),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBerthColumn(ThemeData theme, List<SeatData?> berths) {
    return Column(
      children: berths.reversed.toList().asMap().entries.map((entry) {
        final level = berths.length - entry.key; // 3, 2, 1 (top to bottom)
        final berth = entry.value;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Level indicator
              SizedBox(
                width: 24,
                child: Text(
                  level == 3
                      ? 'Trên'
                      : level == 2
                      ? 'Giữa'
                      : 'Dưới',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _buildBerth(theme, berth),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBerth(ThemeData theme, SeatData? berth) {
    if (berth == null) {
      return SizedBox(width: 80, height: 32);
    }

    final isSelected = selectedSeats.contains(berth.id);
    final isSelectable = berth.status == SeatStatus.available || isSelected;

    Color berthColor;
    switch (berth.status) {
      case SeatStatus.available:
        berthColor = isSelected
            ? AppColors.selectedColor
            : AppColors.availableColor;
        break;
      case SeatStatus.booked:
        berthColor = AppColors.bookedColor;
        break;
      case SeatStatus.selected:
        berthColor = AppColors.selectedColor;
        break;
      case SeatStatus.held:
        berthColor = AppColors.heldColor;
        break;
    }

    return GestureDetector(
      onTap: isSelectable ? () => onSeatToggle(berth.id) : null,
      child: Container(
        width: 80,
        height: 32,
        decoration: BoxDecoration(
          color: berthColor,
          borderRadius: BorderRadius.circular(4),
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            berth.id,
            style: theme.textTheme.bodySmall?.copyWith(
              color: berth.status == SeatStatus.available
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.8)
                  : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}

/// Data model for train compartment
class TrainCompartment {
  final List<SeatData?> leftBerths; // 2-3 berths (tầng dưới → trên)
  final List<SeatData?> rightBerths; // 2-3 berths (tầng dưới → trên)

  const TrainCompartment({required this.leftBerths, required this.rightBerths});
}
