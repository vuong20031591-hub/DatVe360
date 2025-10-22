import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import 'seat_data.dart';
import 'airplane_seat_map.dart';
import 'train_seat_map.dart';
import 'bus_seat_map.dart';

class SeatMapWidget extends ConsumerStatefulWidget {
  const SeatMapWidget({
    super.key,
    required this.tripId,
    required this.classId,
    required this.selectedSeatIds,
    required this.onSeatsChanged,
    this.transportType = 'flight',
  });

  final String tripId;
  final String classId;
  final List<String> selectedSeatIds;
  final Function(List<String>, List<SeatData>) onSeatsChanged;
  final String transportType;

  @override
  ConsumerState<SeatMapWidget> createState() => _SeatMapWidgetState();
}

class _SeatMapWidgetState extends ConsumerState<SeatMapWidget> {
  bool _isLoading = true;
  late List<String> _selectedSeats;

  // Data for different transport types
  List<List<SeatData?>> _airplaneSeatGrid = [];
  List<TrainCompartment> _trainCompartments = [];
  List<List<SeatData?>> _busLowerLevel = [];
  List<List<SeatData?>> _busUpperLevel = [];

  @override
  void initState() {
    super.initState();
    _selectedSeats = List.from(widget.selectedSeatIds);
    _loadSeatMap();
  }

  void _loadSeatMap() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Call seat map API
      final response = await _apiCall('/seats/schedule/${widget.tripId}');
      if (response['success'] == true && response['data'] != null) {
        final seatMapData = response['data']['seatMap'] as List;

        // Parse data based on transport type
        switch (widget.transportType.toLowerCase()) {
          case 'flight':
            _airplaneSeatGrid = _convertApiSeatMapToWidget(seatMapData);
            break;
          case 'train':
            _trainCompartments = _convertToTrainCompartments(seatMapData);
            break;
          case 'bus':
            _convertToBusLevels(seatMapData);
            break;
        }
      } else {
        throw Exception('Failed to load seat map');
      }
    } catch (e) {
      // Throw error instead of fallback to mock
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _apiCall(String endpoint) async {
    try {
      // Use DioClient to make real API call
      final dioClient = DioClient.instance;
      final response = await dioClient.dio.get(endpoint);
      return response.data;
    } catch (e) {
      // Throw error instead of fallback to mock
      rethrow;
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
      case 'vip':
        return SeatType.vip;
      case 'emergency':
        return SeatType.emergency;
      default:
        return SeatType.standard;
    }
  }

  List<TrainCompartment> _convertToTrainCompartments(List seatMapData) {
    final allCompartments = <TrainCompartment>[];

    // New API structure: Array of coaches, each with compartments
    // [{ coachNumber: 1, compartments: [...] }, { coachNumber: 2, compartments: [...] }, ...]
    for (var coachData in seatMapData) {
      if (coachData is! Map) continue;

      final compartments = coachData['compartments'] as List?;
      if (compartments == null) continue;

      // Process each compartment in this coach
      for (var compartmentData in compartments) {
        if (compartmentData is! Map) continue;

        final leftBerths =
            (compartmentData['leftBerths'] as List?)
                ?.map(
                  (seat) => seat == null
                      ? null
                      : SeatData(
                          id: seat['id'] ?? '',
                          status: _parseSeatStatus(seat['status']),
                          type: _parseSeatType(seat['type']),
                          priceAddon: (seat['priceAddon'] ?? 0).toDouble(),
                        ),
                )
                .toList() ??
            [];

        final rightBerths =
            (compartmentData['rightBerths'] as List?)
                ?.map(
                  (seat) => seat == null
                      ? null
                      : SeatData(
                          id: seat['id'] ?? '',
                          status: _parseSeatStatus(seat['status']),
                          type: _parseSeatType(seat['type']),
                          priceAddon: (seat['priceAddon'] ?? 0).toDouble(),
                        ),
                )
                .toList() ??
            [];

        allCompartments.add(
          TrainCompartment(leftBerths: leftBerths, rightBerths: rightBerths),
        );
      }
    }

    return allCompartments;
  }

  void _convertToBusLevels(List seatMapData) {
    // Assume API returns {lowerLevel: [...], upperLevel: [...]}
    if (seatMapData.isEmpty) return;

    final data = seatMapData[0] as Map;

    _busLowerLevel = _convertApiSeatMapToWidget(
      data['lowerLevel'] as List? ?? [],
    );
    _busUpperLevel = _convertApiSeatMapToWidget(
      data['upperLevel'] as List? ?? [],
    );
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

        // Seat map - Factory pattern based on transport type
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildSeatMapByType(),
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

  Widget _buildSeatMapByType() {
    switch (widget.transportType.toLowerCase()) {
      case 'flight':
        return AirplaneSeatMap(
          seatGrid: _airplaneSeatGrid,
          selectedSeats: _selectedSeats,
          onSeatToggle: _toggleSeat,
        );
      case 'train':
        return TrainSeatMap(
          compartments: _trainCompartments,
          selectedSeats: _selectedSeats,
          onSeatToggle: _toggleSeat,
        );
      case 'bus':
        return BusSeatMap(
          lowerLevel: _busLowerLevel,
          upperLevel: _busUpperLevel,
          selectedSeats: _selectedSeats,
          onSeatToggle: _toggleSeat,
        );
      default:
        return const Center(child: Text('Loại phương tiện không được hỗ trợ'));
    }
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
      SeatData? foundSeat;

      // Search in airplane grid
      for (final row in _airplaneSeatGrid) {
        for (final seat in row) {
          if (seat != null && seat.id == seatId) {
            foundSeat = seat;
            break;
          }
        }
        if (foundSeat != null) break;
      }

      // Search in train compartments
      if (foundSeat == null) {
        for (final compartment in _trainCompartments) {
          for (final berth in [
            ...compartment.leftBerths,
            ...compartment.rightBerths,
          ]) {
            if (berth != null && berth.id == seatId) {
              foundSeat = berth;
              break;
            }
          }
          if (foundSeat != null) break;
        }
      }

      // Search in bus levels
      if (foundSeat == null) {
        for (final row in [..._busLowerLevel, ..._busUpperLevel]) {
          for (final seat in row) {
            if (seat != null && seat.id == seatId) {
              foundSeat = seat;
              break;
            }
          }
          if (foundSeat != null) break;
        }
      }

      if (foundSeat != null) {
        selectedSeatData.add(foundSeat);
      }
    }

    widget.onSeatsChanged(_selectedSeats, selectedSeatData);
  }
}
