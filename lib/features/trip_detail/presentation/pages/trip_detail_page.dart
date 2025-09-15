import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/app_button.dart';
import '../widgets/seat_map_widget.dart';
import '../widgets/fare_selector.dart';
import '../widgets/trip_info_card.dart';

class TripDetailPage extends ConsumerStatefulWidget {
  const TripDetailPage({super.key, required this.tripId});

  final String tripId;

  @override
  ConsumerState<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends ConsumerState<TripDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedClassId;
  List<String> _selectedSeatIds = [];
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
      // TODO: Replace with real API call
      // final tripRepository = TripRepository(DioClient());
      // _tripData = await tripRepository.getTripById(widget.tripId);

      // For now, set empty data
      _tripData = null;
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
                        classes: _tripData!['classes'],
                        selectedClassId: _selectedClassId,
                        onClassSelected: (classId) {
                          setState(() {
                            _selectedClassId = classId;
                            _selectedSeatIds.clear();
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
                        onSeatsChanged: (seatIds) {
                          setState(() {
                            _selectedSeatIds = seatIds;
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
    final classes = _tripData!['classes'] as List;
    final selectedClass = classes.firstWhere(
      (c) => c['id'] == _selectedClassId,
    );
    return _formatPrice(selectedClass['price']);
  }

  String _getTotalPrice() {
    if (_selectedClassId == null) return '';
    final classes = _tripData!['classes'] as List;
    final selectedClass = classes.firstWhere(
      (c) => c['id'] == _selectedClassId,
    );
    final basePrice = selectedClass['price'] as int;
    final seatPrice = _selectedSeatIds.length * 50000; // Mock seat price
    return _formatPrice(basePrice + seatPrice);
  }

  String _formatPrice(int price) {
    return '${(price / 1000).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}K';
  }

  void _continueBooking() {
    // TODO: Navigate to booking page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tiếp tục đặt vé với ${_selectedSeatIds.length} ghế: ${_selectedSeatIds.join(', ')}',
        ),
      ),
    );
  }
}
