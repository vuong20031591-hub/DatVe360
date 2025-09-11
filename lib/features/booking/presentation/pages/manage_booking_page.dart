import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/l10n.dart';
import '../../../../shared/widgets/app_button.dart';

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

  Widget _buildBookingList(BuildContext context, ThemeData theme, String filter) {
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

  Widget _buildEmptyState(BuildContext context, ThemeData theme, String filter) {
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
          AppButton(
            onPressed: () => Navigator.of(context).pop(),
            text: 'Đặt vé ngay',
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, ThemeData theme, Map<String, dynamic> booking) {
    final status = booking['status'] as String;
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
                          booking['operator'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    booking['bookingCode'],
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
                    booking['date'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    booking['price'],
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
    return [
      {
        'bookingCode': 'VN123456',
        'from': 'Hà Nội',
        'to': 'Hồ Chí Minh',
        'mode': 'flight',
        'operator': 'Vietnam Airlines',
        'date': '20/12/2024',
        'time': '14:30',
        'price': '2.500.000đ',
        'status': 'upcoming',
      },
      {
        'bookingCode': 'SE789012',
        'from': 'Đà Nẵng',
        'to': 'Nha Trang',
        'mode': 'train',
        'operator': 'Đường sắt Việt Nam',
        'date': '18/12/2024',
        'time': '08:00',
        'price': '450.000đ',
        'status': 'completed',
      },
      {
        'bookingCode': 'BUS345678',
        'from': 'Hà Nội',
        'to': 'Hải Phòng',
        'mode': 'bus',
        'operator': 'Hoàng Long',
        'date': '15/12/2024',
        'time': '09:00',
        'price': '200.000đ',
        'status': 'cancelled',
      },
    ];
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
      case 'ferry':
        return AppColors.ferryColor;
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Xem chi tiết: ${booking['bookingCode']}')),
    );
  }

  void _checkIn(Map<String, dynamic> booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Check-in: ${booking['bookingCode']}')),
    );
  }

  void _cancelBooking(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy vé'),
        content: Text('Bạn có chắc chắn muốn hủy vé ${booking['bookingCode']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã hủy vé ${booking['bookingCode']}')),
              );
            },
            child: const Text('Hủy vé'),
          ),
        ],
      ),
    );
  }
}
