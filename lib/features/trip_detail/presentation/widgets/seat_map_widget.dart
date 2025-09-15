import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';

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
  final Function(List<String>, List<SeatData>) onSeatsChanged;

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

    try {
      // Call seat map API
      final response = await _apiCall(
        '/api/v1/seats/schedule/${widget.tripId}',
      );
      if (response['success'] == true && response['data'] != null) {
        final seatMapData = response['data']['seatMap'] as List;
        _seatGrid = _convertApiSeatMapToWidget(seatMapData);
      } else {
        throw Exception('Failed to load seat map');
      }
    } catch (e) {
      // Handle error - fallback to mock data
      _seatGrid = _generateMockSeatMap();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _apiCall(String endpoint) async {
    try {
      // Use DioClient to make real API call
      final dioClient = DioClient.instance;
      final response = await dioClient.dio.get(endpoint);
      return response.data;
    } catch (e) {
      // Fallback to mock data on error
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'success': true,
        'data': {
          'seatMap': _generateMockSeatMapData(),
          'layout': '3-3',
          'totalSeats': 120,
          'availableSeats': 95,
        },
      };
    }
  }

  List<List<SeatData?>> _convertApiSeatMapToWidget(List seatMapData) {
    return seatMapData.map<List<SeatData?>>((row) {
      if (row is! List) return <SeatData?>[];

      return row.map<SeatData?>((seat) {
        if (seat == null) return null; // Aisle space

        if (seat is! Map) return null;

        return SeatData(
          id: seat['id'] ?? '',
          status: _parseSeatStatus(seat['status']),
          type: _parseSeatType(seat['type']),
          priceAddon: (seat['priceAddon'] ?? 0).toDouble(),
        );
      }).toList();
    }).toList();
  }

  SeatStatus _parseSeatStatus(dynamic status) {
    switch (status?.toString()) {
      case 'available':
        return SeatStatus.available;
      case 'booked':
        return SeatStatus.booked;
      case 'selected':
        return SeatStatus.selected;
      default:
        return SeatStatus.available;
    }
  }

  SeatType _parseSeatType(dynamic type) {
    switch (type?.toString()) {
      case 'business':
      case 'premium':
        return SeatType.premium;
      case 'window':
        return SeatType.window;
      case 'aisle':
        return SeatType.aisle;
      case 'exit':
        return SeatType.exit;
      default:
        return SeatType.standard;
    }
  }

  List<List<Map<String, dynamic>?>> _generateMockSeatMapData() {
    final seatMap = <List<Map<String, dynamic>?>>[];
    final columns = ['A', 'B', 'C', null, 'D', 'E', 'F']; // null = aisle

    for (int row = 1; row <= 20; row++) {
      final rowSeats = <Map<String, dynamic>?>[];

      for (final col in columns) {
        if (col == null) {
          rowSeats.add(null); // Aisle space
          continue;
        }

        final seatId = '$row$col';

        // Simulate some booked seats
        String status = 'available';
        if ((row == 5 && col == 'A') ||
            (row == 8 && col == 'F') ||
            (row == 12 && col == 'C')) {
          status = 'booked';
        }

        String seatType = 'standard';
        if (row <= 3)
          seatType = 'premium';
        else if (col == 'A' || col == 'F')
          seatType = 'window';
        else if (col == 'C' || col == 'D')
          seatType = 'aisle';

        rowSeats.add({
          'id': seatId,
          'row': row,
          'col': col,
          'type': seatType,
          'status': status,
          'priceAddon': seatType == 'premium'
              ? 500000
              : seatType == 'window' || seatType == 'aisle'
              ? 50000
              : 0,
        });
      }

      seatMap.add(rowSeats);
    }

    return seatMap;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Legend
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(bottom: BorderSide(color: theme.dividerColor)),
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
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
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
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
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
                    ...'ABC'
                        .split('')
                        .map(
                          (letter) => Container(
                            width:
                                AppConstants.seatSize +
                                AppConstants.seatSpacing * 2,
                            alignment: Alignment.center,
                            child: Text(
                              letter,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                    const SizedBox(width: 24), // Aisle space
                    // Right column labels
                    ...'DEF'
                        .split('')
                        .map(
                          (letter) => Container(
                            width:
                                AppConstants.seatSize +
                                AppConstants.seatSpacing * 2,
                            alignment: Alignment.center,
                            child: Text(
                              letter,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

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
              border: Border(top: BorderSide(color: theme.dividerColor)),
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
        Text(label, style: theme.textTheme.bodySmall),
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
        seatColor = isSelected
            ? AppColors.selectedColor
            : AppColors.availableColor;
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

    // Get selected seat data with price addons
    final selectedSeatData = <SeatData>[];
    for (final seatId in _selectedSeats) {
      for (final row in _seatGrid) {
        for (final seat in row) {
          if (seat != null && seat.id == seatId) {
            selectedSeatData.add(seat);
            break;
          }
        }
      }
    }

    widget.onSeatsChanged(_selectedSeats, selectedSeatData);
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

        rowSeats.add(
          SeatData(
            id: seatId,
            status: status,
            type: SeatType.standard,
            priceAddon: 0,
          ),
        );
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
