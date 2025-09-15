import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/app_button.dart';
import '../widgets/seat_map_widget.dart';
import '../widgets/fare_selector.dart';
import '../widgets/trip_info_card.dart';

class TripDetailPage extends ConsumerStatefulWidget {
  const TripDetailPage({super.key, required this.tripId, this.schedule});

  final String tripId;
  final dynamic schedule;

  @override
  ConsumerState<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends ConsumerState<TripDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedClassId;
  List<String> _selectedSeatIds = [];
  List<dynamic> _selectedSeatData = []; // Store seat data with price addons
  bool _isLoading = true;
  Map<String, dynamic>? _tripData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTripDetail();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadTripDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use schedule data passed from navigation if available
      if (widget.schedule != null) {
        _tripData = _convertScheduleToTripData(widget.schedule);
      } else {
        // TODO: Fallback to API call if no schedule data
        _tripData = null;
      }
    } catch (e) {
      // Handle error
      _tripData = null;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết chuyến')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_tripData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết chuyến')),
        body: const Center(child: Text('Không tìm thấy thông tin chuyến')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${_tripData!['carrier']} ${_tripData!['flightNumber']}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Thông tin chuyến'),
            Tab(text: 'Chọn ghế'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Trip summary
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_tripData!['from']} → ${_tripData!['to']}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_tripData!['departTime']} - ${_tripData!['arriveTime']} • ${_tripData!['duration']}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_selectedClassId != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _getSelectedClassPrice(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        'VND',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Trip info tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    children: [
                      TripInfoCard(tripData: _tripData!),
                      const SizedBox(height: 16),
                      FareSelector(
                        classes: _tripData!['classes'] is List
                            ? List<Map<String, dynamic>>.from(
                                _tripData!['classes'],
                              )
                            : <Map<String, dynamic>>[],
                        selectedClassId: _selectedClassId,
                        onClassSelected: (classId) {
                          setState(() {
                            _selectedClassId = classId;
                            _selectedSeatIds.clear();
                            _selectedSeatData.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Seat selection tab
                _selectedClassId != null
                    ? SeatMapWidget(
                        tripId: widget.tripId,
                        classId: _selectedClassId!,
                        selectedSeatIds: _selectedSeatIds,
                        onSeatsChanged: (seatIds, seatData) {
                          setState(() {
                            _selectedSeatIds = seatIds;
                            _selectedSeatData = seatData;
                          });
                        },
                      )
                    : const Center(child: Text('Vui lòng chọn hạng vé trước')),
              ],
            ),
          ),

          // Continue button
          if (_selectedClassId != null)
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              child: Column(
                children: [
                  if (_selectedSeatIds.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Text(
                            'Ghế đã chọn: ${_selectedSeatIds.join(', ')}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _getTotalPrice(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      onPressed: _selectedSeatIds.isNotEmpty
                          ? _continueBooking
                          : null,
                      text: 'Tiếp tục',
                      icon: Icons.arrow_forward,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getSelectedClassPrice() {
    if (_selectedClassId == null) return '';

    final classes = _tripData!['classes'];
    if (classes is! List || classes.isEmpty) return '';

    try {
      final selectedClass = classes.firstWhere(
        (c) => c['id'] == _selectedClassId,
        orElse: () => null,
      );
      if (selectedClass == null) return '';
      final price = selectedClass['price'] is num
          ? (selectedClass['price'] as num).toInt()
          : 0;
      return _formatPrice(price);
    } catch (e) {
      return '';
    }
  }

  String _getTotalPrice() {
    if (_selectedClassId == null) return '';

    final classes = _tripData!['classes'];
    if (classes is! List || classes.isEmpty) return '';

    try {
      final selectedClass = classes.firstWhere(
        (c) => c['id'] == _selectedClassId,
        orElse: () => null,
      );
      if (selectedClass == null) return '';

      final basePrice = (selectedClass['price'] is num
          ? (selectedClass['price'] as num).toInt()
          : 0);

      // Calculate real seat price addons
      int seatPrice = 0;
      for (final seatData in _selectedSeatData) {
        if (seatData != null && seatData.priceAddon != null) {
          seatPrice += (seatData.priceAddon as num).toInt();
        }
      }

      return _formatPrice(basePrice + seatPrice);
    } catch (e) {
      return '';
    }
  }

  String _formatPrice(int price) {
    return '${(price / 1000).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}K';
  }

  void _continueBooking() {
    if (_tripData == null) return;

    // Navigate to booking page with trip data and selected seats
    context.pushNamed(
      'booking',
      extra: {
        'trip': _tripData,
        'selectedSeats': _selectedSeatIds,
        'selectedSeatData': _selectedSeatData,
        'selectedClass': _selectedClassId,
      },
    );
  }

  /// Convert Schedule model to trip data format expected by UI
  Map<String, dynamic> _convertScheduleToTripData(dynamic schedule) {
    if (schedule == null) return {};

    // Format time strings
    final departTime = schedule.departureTime.toString().substring(11, 16);
    final arriveTime = schedule.arrivalTime.toString().substring(11, 16);
    final durationHours = schedule.duration.inHours;
    final durationMinutes = schedule.duration.inMinutes % 60;
    final durationStr = '${durationHours}h ${durationMinutes}m';

    // Convert classes Map to List format expected by UI
    List<Map<String, dynamic>> classesList = [];
    if (schedule.classes is Map) {
      final classesMap = schedule.classes as Map<String, dynamic>;
      classesMap.forEach((key, value) {
        if (value is Map) {
          classesList.add({
            'id': key,
            'name': key.toUpperCase(),
            'price': value['price'] is num
                ? (value['price'] as num).toInt()
                : schedule.price.toInt(),
            'currency': value['currency'] ?? schedule.currency,
            'availableSeats':
                value['availableSeats'] ?? schedule.availableSeats,
            'amenities': value['amenities'] is List
                ? List<String>.from(value['amenities'])
                : <String>[],
          });
        }
      });
    }

    // If no classes found, create default economy class
    if (classesList.isEmpty) {
      classesList.add({
        'id': 'economy',
        'name': 'ECONOMY',
        'price': schedule.price.toInt(),
        'currency': schedule.currency,
        'availableSeats': schedule.availableSeats,
        'amenities': [],
      });
    }

    return {
      'id': schedule.id,
      'carrier': schedule.operatorName,
      'flightNumber': schedule.vehicleNumber,
      'from': schedule.from,
      'to': schedule.to,
      'fromCode': schedule.fromCode,
      'toCode': schedule.toCode,
      'departTime': departTime,
      'arriveTime': arriveTime,
      'duration': durationStr,
      'price': schedule.price.toInt(),
      'currency': schedule.currency,
      'availableSeats': schedule.availableSeats,
      'totalSeats': schedule.totalSeats,
      'classes': classesList,
      'transportType': schedule.transportType,
      'vehicleType': schedule.vehicleType,
      'aircraft': schedule.metadata['model'] ?? 'N/A',
      'registrationNumber': schedule.metadata['registrationNumber'] ?? 'N/A',
      'facilities': schedule.metadata['facilities'] ?? [],
      'status': schedule.status,
    };
  }
}
