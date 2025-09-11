import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';

class SeatMapWidget extends ConsumerStatefulWidget {
  const SeatMapWidget({
    super.key,
    required this.tripId,
    required this.classId,
    required this.selectedSeatIds,
    required this.onSeatsChanged,
  });

  final String tripId;
  final String classId;
  final List<String> selectedSeatIds;
  final Function(List<String>) onSeatsChanged;

  @override
  ConsumerState<SeatMapWidget> createState() => _SeatMapWidgetState();
}

class _SeatMapWidgetState extends ConsumerState<SeatMapWidget> {
  bool _isLoading = true;
  List<List<SeatData?>> _seatGrid = [];
  late List<String> _selectedSeats;

  @override
  void initState() {
    super.initState();
    _selectedSeats = List.from(widget.selectedSeatIds);
    _loadSeatMap();
  }

  void _loadSeatMap() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    _seatGrid = _generateMockSeatMap();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        // Legend
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              bottom: BorderSide(color: theme.dividerColor),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(theme, 'Trống', AppColors.availableColor),
              _buildLegendItem(theme, 'Đã đặt', AppColors.bookedColor),
              _buildLegendItem(theme, 'Đang chọn', AppColors.selectedColor),
            ],
          ),
        ),

        // Seat map
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Aircraft front indicator
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
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
                  children: _seatGrid.asMap().entries.map((entry) {
                    final rowIndex = entry.key;
                    final row = entry.value;
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Row number
                          SizedBox(
                            width: 30,
                            child: Text(
                              '${rowIndex + 1}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          // Left seats (A, B, C)
                          ...row.take(3).map((seat) => _buildSeat(theme, seat)),
                          
                          // Aisle
                          const SizedBox(width: 24),
                          
                          // Right seats (D, E, F)
                          ...row.skip(3).map((seat) => _buildSeat(theme, seat)),
                          
                          const SizedBox(width: 8),
                          
                          // Row number (right)
                          SizedBox(
                            width: 30,
                            child: Text(
                              '${rowIndex + 1}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
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
                    const SizedBox(width: 38), // Row number space
                    
                    // Left column labels
                    ...'ABC'.split('').map((letter) => Container(
                      width: AppConstants.seatSize + AppConstants.seatSpacing * 2,
                      alignment: Alignment.center,
                      child: Text(
                        letter,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )),
                    
                    const SizedBox(width: 24), // Aisle space
                    
                    // Right column labels
                    ...'DEF'.split('').map((letter) => Container(
                      width: AppConstants.seatSize + AppConstants.seatSpacing * 2,
                      alignment: Alignment.center,
                      child: Text(
                        letter,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )),
                    
                    const SizedBox(width: 38), // Row number space
                  ],
                ),
              ],
            ),
          ),
        ),

        // Selected seats summary
        if (_selectedSeats.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.dividerColor),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.airline_seat_recline_normal,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Đã chọn: ${_selectedSeats.join(', ')}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${_selectedSeats.length} ghế',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLegendItem(ThemeData theme, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSeat(ThemeData theme, SeatData? seat) {
    if (seat == null) {
      return Container(
        width: AppConstants.seatSize + AppConstants.seatSpacing * 2,
        height: AppConstants.seatSize + AppConstants.seatSpacing * 2,
      );
    }

    final isSelected = _selectedSeats.contains(seat.id);
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
        onTap: isSelectable ? () => _toggleSeat(seat.id) : null,
        child: Container(
          decoration: BoxDecoration(
            color: seatColor,
            borderRadius: BorderRadius.circular(6),
            border: isSelected
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              seat.id,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleSeat(String seatId) {
    setState(() {
      if (_selectedSeats.contains(seatId)) {
        _selectedSeats.remove(seatId);
      } else {
        _selectedSeats.add(seatId);
      }
    });
    
    widget.onSeatsChanged(_selectedSeats);
  }

  List<List<SeatData?>> _generateMockSeatMap() {
    final grid = <List<SeatData?>>[];
    final columns = ['A', 'B', 'C', 'D', 'E', 'F'];
    
    for (int row = 1; row <= 20; row++) {
      final rowSeats = <SeatData?>[];
      
      for (final col in columns) {
        final seatId = '$row$col';
        
        // Simulate some booked seats
        SeatStatus status = SeatStatus.available;
        if ((row == 5 && col == 'A') || 
            (row == 8 && col == 'F') ||
            (row == 12 && col == 'C')) {
          status = SeatStatus.booked;
        }
        
        rowSeats.add(SeatData(
          id: seatId,
          status: status,
          type: SeatType.standard,
          priceAddon: 0,
        ));
      }
      
      grid.add(rowSeats);
    }
    
    return grid;
  }
}

class SeatData {
  final String id;
  final SeatStatus status;
  final SeatType type;
  final double priceAddon;

  SeatData({
    required this.id,
    required this.status,
    required this.type,
    required this.priceAddon,
  });
}

enum SeatStatus { available, booked, selected, held }
enum SeatType { standard, premium, exit, window, aisle }
