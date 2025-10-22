import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/booking_provider.dart';

class ManageBookingPage extends ConsumerStatefulWidget {
  const ManageBookingPage({super.key});

  @override
  ConsumerState<ManageBookingPage> createState() => _ManageBookingPageState();
}

class _ManageBookingPageState extends ConsumerState<ManageBookingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Fetch bookings when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBookings();
    });
  }

  void _fetchBookings() {
    ref.read(bookingProvider.notifier).getUserBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý đặt vé'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm theo mã đặt chỗ, tên...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  onChanged: (value) {
                    // TODO: Implement search
                  },
                ),
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Tất cả'),
                  Tab(text: 'Sắp tới'),
                  Tab(text: 'Đã hoàn thành'),
                  Tab(text: 'Đã hủy'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList(context, theme, 'all'),
          _buildBookingList(context, theme, 'upcoming'),
          _buildBookingList(context, theme, 'completed'),
          _buildBookingList(context, theme, 'cancelled'),
        ],
      ),
    );
  }

  Widget _buildBookingList(
    BuildContext context,
    ThemeData theme,
    String filter,
  ) {
    final bookings = _getFilteredBookings(filter);

    if (bookings.isEmpty) {
      return _buildEmptyState(context, theme, filter);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(context, theme, booking);
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    String filter,
  ) {
    String title;
    String subtitle;
    IconData icon;

    switch (filter) {
      case 'upcoming':
        title = 'Không có chuyến đi sắp tới';
        subtitle = 'Đặt vé ngay để bắt đầu hành trình';
        icon = Icons.upcoming;
        break;
      case 'completed':
        title = 'Chưa có chuyến đi nào hoàn thành';
        subtitle = 'Lịch sử chuyến đi sẽ xuất hiện ở đây';
        icon = Icons.done_all;
        break;
      case 'cancelled':
        title = 'Không có vé nào bị hủy';
        subtitle = 'Các vé đã hủy sẽ hiển thị ở đây';
        icon = Icons.cancel;
        break;
      default:
        title = 'Chưa có đặt vé nào';
        subtitle = 'Bắt đầu đặt vé để quản lý chuyến đi';
        icon = Icons.confirmation_number;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.add),
            label: const Text('Đặt vé ngay'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> booking,
  ) {
    final status = (booking['status'] as String?) ?? 'pending';
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewBookingDetails(booking),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getTransportIcon(booking['mode']),
                    color: _getTransportColor(booking['mode']),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${booking['from']} → ${booking['to']}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          booking['operator'] ?? 'N/A',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.confirmation_number,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    booking['pnr'] ?? 'N/A',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    booking['date'] ?? 'N/A',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    booking['price'] ?? '0 đ',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.lightSuccess,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (status == 'upcoming') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _checkIn(booking),
                        icon: const Icon(Icons.check_circle, size: 16),
                        label: const Text('Check-in'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _cancelBooking(booking),
                        icon: const Icon(Icons.cancel, size: 16),
                        label: const Text('Hủy vé'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredBookings(String filter) {
    final allBookings = _getAllBookings();

    switch (filter) {
      case 'upcoming':
        return allBookings.where((b) => b['status'] == 'upcoming').toList();
      case 'completed':
        return allBookings.where((b) => b['status'] == 'completed').toList();
      case 'cancelled':
        return allBookings.where((b) => b['status'] == 'cancelled').toList();
      default:
        return allBookings;
    }
  }

  List<Map<String, dynamic>> _getAllBookings() {
    // Get bookings from provider
    final bookingState = ref.watch(bookingProvider);

    print('📋 DEBUG: userBookings count = ${bookingState.userBookings.length}');
    if (bookingState.userBookings.isNotEmpty) {
      print('📋 DEBUG: First booking = ${bookingState.userBookings.first.pnr}');
      print('📋 DEBUG: Schedule = ${bookingState.userBookings.first.schedule}');
    }

    // Convert Booking objects to Map for compatibility with existing UI
    return bookingState.userBookings.map((booking) {
      final schedule = booking.schedule;
      final departureTime = schedule != null
          ? DateTime.tryParse(schedule.departureTime)
          : null;

      print(
        '🔍 DEBUG: Mapping booking - PNR: ${booking.pnr}, ID: ${booking.id}',
      );

      return {
        'id': booking.id ?? '',
        'pnr': booking.pnr ?? 'N/A',
        'mode': schedule?.transportType ?? 'flight',
        'from': schedule?.route.from ?? 'N/A',
        'to': schedule?.route.to ?? 'N/A',
        'operator': schedule?.vehicleNumber ?? 'N/A',
        'date': departureTime != null
            ? '${departureTime.day}/${departureTime.month}/${departureTime.year}'
            : booking.createdAt.toString().split(' ')[0],
        'time': departureTime != null
            ? '${departureTime.hour}:${departureTime.minute.toString().padLeft(2, '0')}'
            : '${booking.createdAt.hour}:${booking.createdAt.minute.toString().padLeft(2, '0')}',
        'status': booking.status.value ?? 'pending',
        'price': '${booking.totalPrice.toStringAsFixed(0)} đ',
      };
    }).toList();
  }

  IconData _getTransportIcon(String mode) {
    switch (mode) {
      case 'flight':
        return Icons.flight;
      case 'train':
        return Icons.train;
      case 'bus':
        return Icons.directions_bus;
      case 'ferry':
        return Icons.directions_boat;
      default:
        return Icons.confirmation_number;
    }
  }

  Color _getTransportColor(String mode) {
    switch (mode) {
      case 'flight':
        return AppColors.flightColor;
      case 'train':
        return AppColors.trainColor;
      case 'bus':
        return AppColors.busColor;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'upcoming':
        return 'Sắp tới';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  void _viewBookingDetails(Map<String, dynamic> booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildBookingDetailSheet(booking),
    );
  }

  Widget _buildBookingDetailSheet(Map<String, dynamic> booking) {
    final theme = Theme.of(context);
    final status = booking['status'] ?? 'pending';

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Chi tiết đặt vé',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Booking Code (PNR)
                _buildInfoRow(
                  'Mã đặt chỗ (PNR)',
                  booking['pnr'] ?? 'N/A',
                  Icons.confirmation_number,
                  theme,
                ),
                const Divider(height: 32),

                // Route Info
                _buildInfoRow(
                  'Tuyến đường',
                  '${booking['from']} → ${booking['to']}',
                  Icons.route,
                  theme,
                ),
                const Divider(height: 32),

                // Transport
                _buildInfoRow(
                  'Phương tiện',
                  _getTransportName(booking['mode']),
                  _getTransportIcon(booking['mode']),
                  theme,
                ),
                const Divider(height: 32),

                // Operator
                _buildInfoRow(
                  'Nhà vận hành',
                  booking['operator'] ?? 'N/A',
                  Icons.business,
                  theme,
                ),
                const Divider(height: 32),

                // Date & Time
                _buildInfoRow(
                  'Ngày khởi hành',
                  '${booking['date']} - ${booking['time']}',
                  Icons.access_time,
                  theme,
                ),
                const Divider(height: 32),

                // Price
                _buildInfoRow(
                  'Tổng tiền',
                  booking['price'] ?? '0 đ',
                  Icons.attach_money,
                  theme,
                  valueColor: AppColors.lightSuccess,
                ),
                const SizedBox(height: 32),

                // Actions
                if (status == 'upcoming') ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _checkIn(booking);
                          },
                          icon: const Icon(Icons.check_circle, size: 18),
                          label: const Text('Check-in'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 44),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _cancelBooking(booking);
                          },
                          icon: const Icon(Icons.cancel, size: 18),
                          label: const Text('Hủy vé'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            minimumSize: const Size(0, 44),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    ThemeData theme, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
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
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getTransportName(String mode) {
    switch (mode) {
      case 'flight':
        return 'Máy bay';
      case 'train':
        return 'Tàu hỏa';
      case 'bus':
        return 'Xe khách';
      case 'ferry':
        return 'Phà';
      default:
        return 'N/A';
    }
  }

  void _checkIn(Map<String, dynamic> booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Check-in cho vé ${booking['pnr']}'),
        action: SnackBarAction(
          label: 'Xem vé',
          onPressed: () {
            // Navigate to ticket page
          },
        ),
      ),
    );
  }

  void _cancelBooking(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy vé'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn có chắc chắn muốn hủy vé ${booking['pnr']}?'),
            const SizedBox(height: 8),
            Text(
              'Tuyến: ${booking['from']} → ${booking['to']}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Ngày: ${booking['date']}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Cancel booking via API
              final bookingId = booking['id'];
              final reason = 'User cancelled'; // Default reason
              if (bookingId != null && bookingId.isNotEmpty) {
                final success = await ref.read(bookingProvider.notifier).cancelBooking(bookingId, reason);
                
                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã hủy vé ${booking['pnr']}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Refresh bookings list
                    _fetchBookings();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Không thể hủy vé. Vui lòng thử lại.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Hủy vé'),
          ),
        ],
      ),
    );
  }
}
