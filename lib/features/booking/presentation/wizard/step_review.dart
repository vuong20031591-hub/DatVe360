import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';

class StepReview extends StatelessWidget {
  const StepReview({
    super.key,
    required this.bookingData,
    required this.onDataChanged,
  });

  final Map<String, dynamic> bookingData;
  final Function(Map<String, dynamic>) onDataChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trip = bookingData['trip'] as Map<String, dynamic>?;
    final selectedSeats = bookingData['selectedSeats'] is List
        ? List<String>.from(bookingData['selectedSeats'])
        : <String>[];
    final selectedSeatData = bookingData['selectedSeatData'] is List
        ? List<dynamic>.from(bookingData['selectedSeatData'])
        : <dynamic>[];
    final selectedClass = bookingData['selectedClass'] as String?;

    if (trip == null) {
      return const Center(child: Text('Không có thông tin chuyến'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip summary card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // DEBUG: Print để kiểm tra
                  Builder(
                    builder: (context) {
                      print(
                        '🔍 StepReview - transportType: ${trip['transportType']}',
                      );
                      print('🔍 StepReview - trip keys: ${trip.keys.toList()}');
                      return const SizedBox.shrink();
                    },
                  ),
                  Row(
                    children: [
                      Icon(_getTripIcon(trip), color: _getTripColor(trip)),
                      const SizedBox(width: 8),
                      Text(
                        _getTripTitle(trip),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Route
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip['departTime'],
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              trip['from'],
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),

                      Column(
                        children: [
                          Icon(_getTripIcon(trip), color: _getTripColor(trip)),
                          Text(
                            trip['duration'],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              trip['arriveTime'],
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              trip['to'],
                              style: theme.textTheme.bodyLarge,
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Flight details
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          theme,
                          'Hãng bay',
                          trip['carrier'],
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          theme,
                          'Số hiệu',
                          _getVehicleNumber(trip),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Seat selection summary
          if (selectedSeats.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.airline_seat_recline_normal,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ghế đã chọn',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedSeats
                          .map(
                            (seat) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                seat,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Price breakdown
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Chi tiết giá',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Calculate real pricing
                  ..._buildPricingRows(
                    theme,
                    trip,
                    selectedClass,
                    selectedSeatData,
                  ),

                  const Divider(height: 24),

                  Row(
                    children: [
                      Text(
                        'Tổng cộng',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatPrice(
                          _calculateTotalPrice(
                            trip,
                            selectedClass,
                            selectedSeatData,
                          ),
                        ),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightSuccess,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Important notes
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Lưu ý quan trọng',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _buildNoteItem(
                    theme,
                    'Vui lòng kiểm tra kỹ thông tin trước khi tiếp tục',
                  ),
                  _buildNoteItem(
                    theme,
                    'Tên hành khách phải trùng với giấy tờ tùy thân',
                  ),
                  _buildNoteItem(
                    theme,
                    'Có mặt tại sân bay trước giờ bay ít nhất 2 tiếng',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(ThemeData theme, String label, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          const Spacer(),
          Text(
            amount,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 8, right: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPricingRows(
    ThemeData theme,
    Map<String, dynamic> trip,
    String? selectedClass,
    List<dynamic> selectedSeatData,
  ) {
    final basePricePerSeat = _getBasePrice(trip, selectedClass);
    final numberOfSeats = selectedSeatData.length;
    final totalBasePrice = basePricePerSeat * numberOfSeats;
    final seatPrice = _getSeatPrice(selectedSeatData);
    final taxPrice = (totalBasePrice * 0.1).round(); // 10% tax

    return [
      _buildPriceRow(
        theme,
        'Giá vé cơ bản (${numberOfSeats}x)',
        _formatPrice(totalBasePrice),
      ),
      if (seatPrice > 0)
        _buildPriceRow(theme, 'Phí chọn ghế', _formatPrice(seatPrice)),
      _buildPriceRow(theme, 'Thuế và phí', _formatPrice(taxPrice)),
    ];
  }

  int _getBasePrice(Map<String, dynamic> trip, String? selectedClass) {
    if (selectedClass == null) return trip['price']?.toInt() ?? 0;

    final classes = trip['classes'] as List?;
    if (classes == null) return trip['price']?.toInt() ?? 0;

    try {
      final classData = classes.firstWhere((c) => c['id'] == selectedClass);
      return (classData['price'] as num?)?.toInt() ??
          trip['price']?.toInt() ??
          0;
    } catch (e) {
      return trip['price']?.toInt() ?? 0;
    }
  }

  int _getSeatPrice(List<dynamic> selectedSeatData) {
    int total = 0;
    for (final seatData in selectedSeatData) {
      if (seatData != null && seatData.priceAddon != null) {
        total += (seatData.priceAddon as num).toInt();
      }
    }
    return total;
  }

  int _calculateTotalPrice(
    Map<String, dynamic> trip,
    String? selectedClass,
    List<dynamic> selectedSeatData,
  ) {
    final basePricePerSeat = _getBasePrice(trip, selectedClass);
    final numberOfSeats = selectedSeatData.length;
    final totalBasePrice = basePricePerSeat * numberOfSeats;
    final seatPrice = _getSeatPrice(selectedSeatData);
    final taxPrice = (totalBasePrice * 0.1).round();
    return totalBasePrice + seatPrice + taxPrice;
  }

  String _formatPrice(int price) {
    return '${(price / 1000).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}K VND';
  }

  String _getVehicleNumber(Map<String, dynamic> trip) {
    final transportType = trip['transportType'] ?? 'flight';
    final carrier = trip['carrier'] ?? '';

    switch (transportType.toLowerCase()) {
      case 'flight':
        final flightNumber = trip['flightNumber'];
        return flightNumber != null ? '$carrier $flightNumber' : carrier;
      case 'train':
        final trainNumber = trip['trainNumber'];
        return trainNumber != null ? '$carrier $trainNumber' : carrier;
      case 'bus':
        final busNumber = trip['busNumber'];
        return busNumber != null ? '$carrier $busNumber' : carrier;
      default:
        return carrier;
    }
  }

  IconData _getTripIcon(Map<String, dynamic> trip) {
    final transportType = trip['transportType'] ?? 'flight';

    switch (transportType.toLowerCase()) {
      case 'flight':
        return Icons.flight_takeoff;
      case 'train':
        return Icons.train;
      case 'bus':
        return Icons.directions_bus;
      default:
        return Icons.flight_takeoff;
    }
  }

  Color _getTripColor(Map<String, dynamic> trip) {
    final transportType = trip['transportType'] ?? 'flight';

    switch (transportType.toLowerCase()) {
      case 'flight':
        return AppColors.flightColor;
      case 'train':
        return AppColors.trainColor;
      case 'bus':
        return AppColors.busColor;
      default:
        return AppColors.flightColor;
    }
  }

  String _getTripTitle(Map<String, dynamic> trip) {
    final transportType = trip['transportType'] ?? 'flight';

    switch (transportType.toLowerCase()) {
      case 'flight':
        return 'Thông tin chuyến bay';
      case 'train':
        return 'Thông tin chuyến tàu';
      case 'bus':
        return 'Thông tin chuyến xe';
      default:
        return 'Thông tin chuyến đi';
    }
  }
}
