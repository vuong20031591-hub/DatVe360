import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/providers/bookings_simple_provider.dart';
import '../../data/models/booking_simple.dart';

class BookingsSimpleScreen extends ConsumerStatefulWidget {
  const BookingsSimpleScreen({super.key});

  @override
  ConsumerState<BookingsSimpleScreen> createState() => _BookingsSimpleScreenState();
}

class _BookingsSimpleScreenState extends ConsumerState<BookingsSimpleScreen> {
  final _searchController = TextEditingController();
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    // Load data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingsSimpleProvider.notifier).loadBookings();
      ref.read(bookingsSimpleProvider.notifier).loadStats();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingsSimpleProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // Stats Cards
          if (state.stats != null) _buildStatsCards(state.stats!, theme),

          // Filters
          _buildFilters(theme),

          // Bookings List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Lỗi: ${state.error}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => ref.read(bookingsSimpleProvider.notifier).refresh(),
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : state.bookings.isEmpty
                        ? const Center(child: Text('Không có đặt vé nào'))
                        : _buildBookingsList(state.bookings, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BookingStatsSimple stats, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Tổng đặt vé',
              stats.total.toString(),
              Icons.receipt_long,
              Colors.blue,
              theme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Chờ xác nhận',
              stats.pending.toString(),
              Icons.pending,
              Colors.orange,
              theme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Đã xác nhận',
              stats.confirmed.toString(),
              Icons.check_circle,
              Colors.green,
              theme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Doanh thu',
              NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(stats.totalRevenue),
              Icons.attach_money,
              Colors.purple,
              theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Search
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo PNR, email, SĐT...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (value) {
                ref.read(bookingsSimpleProvider.notifier).setSearch(value.isEmpty ? null : value);
              },
            ),
          ),
          const SizedBox(width: 12),
          // Status Filter
          DropdownButton<String?>(
            value: _selectedStatus,
            hint: const Text('Trạng thái'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Tất cả')),
              const DropdownMenuItem(value: 'pending', child: Text('Chờ xác nhận')),
              const DropdownMenuItem(value: 'confirmed', child: Text('Đã xác nhận')),
              const DropdownMenuItem(value: 'cancelled', child: Text('Đã hủy')),
              const DropdownMenuItem(value: 'completed', child: Text('Hoàn thành')),
            ],
            onChanged: (value) {
              setState(() => _selectedStatus = value);
              ref.read(bookingsSimpleProvider.notifier).setFilter(value);
            },
          ),
          const SizedBox(width: 12),
          // Refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(bookingsSimpleProvider.notifier).refresh(),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(List<BookingSimple> bookings, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(booking, theme);
      },
    );
  }

  Widget _buildBookingCard(BookingSimple booking, ThemeData theme) {
    final route = booking.scheduleId?.routeId;
    final operator = booking.scheduleId?.operatorId;
    final schedule = booking.scheduleId;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PNR: ${booking.pnr}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        operator?.name ?? 'N/A',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(booking.status, theme),
              ],
            ),
            const Divider(height: 24),

            // Route Info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route?.fromDestination?.city ?? 'N/A',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        route?.fromDestination?.code ?? 'N/A',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        schedule?.departureTime != null
                          ? DateFormat('HH:mm').format(schedule!.departureTime)
                          : 'N/A',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    const Icon(Icons.arrow_forward, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      schedule?.duration ?? 'N/A',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        route?.toDestination?.city ?? 'N/A',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        route?.toDestination?.code ?? 'N/A',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        schedule?.arrivalTime != null
                          ? DateFormat('HH:mm').format(schedule!.arrivalTime)
                          : 'N/A',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Flight/Trip Number
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    operator?.type == 'airline' ? Icons.flight :
                    operator?.type == 'train' ? Icons.train : Icons.directions_bus,
                    size: 16,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    schedule?.flightNumber ?? 'N/A',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Booking Info
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    Icons.person,
                    '${booking.totalPassengers} hành khách',
                    theme,
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    Icons.confirmation_number,
                    '${booking.totalTickets} vé',
                    theme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    Icons.attach_money,
                    NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(booking.totalAmount),
                    theme,
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    Icons.payment,
                    booking.paymentMethod == 'credit_card' ? 'Thẻ tín dụng' :
                    booking.paymentMethod == 'bank_transfer' ? 'Chuyển khoản' :
                    booking.paymentMethod == 'e_wallet' ? 'Ví điện tử' : 'Tiền mặt',
                    theme,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Contact Info
            Text(
              'Thông tin liên hệ',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.person_outline,
              '${booking.contactInfo?.firstName ?? ''} ${booking.contactInfo?.lastName ?? ''}',
              theme,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.email,
              booking.contactInfo?.email ?? 'N/A',
              theme,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.phone,
              booking.contactInfo?.phone ?? 'N/A',
              theme,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today,
              'Đặt lúc: ${DateFormat('dd/MM/yyyy HH:mm').format(booking.createdAt)}',
              theme,
            ),

            // Passengers List
            if (booking.passengers != null && booking.passengers!.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                'Danh sách hành khách',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...booking.passengers!.map((passenger) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${passenger.firstName} ${passenger.lastName}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: passenger.type == 'adult' ? Colors.blue[50] :
                               passenger.type == 'child' ? Colors.green[50] : Colors.orange[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        passenger.type == 'adult' ? 'Người lớn' :
                        passenger.type == 'child' ? 'Trẻ em' : 'Em bé',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: passenger.type == 'adult' ? Colors.blue[700] :
                                 passenger.type == 'child' ? Colors.green[700] : Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
            // Actions
            if (booking.status == 'pending' || booking.status == 'confirmed')
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (booking.status == 'pending') ...[
                      TextButton.icon(
                        onPressed: () => _confirmBooking(booking.id),
                        icon: const Icon(Icons.check),
                        label: const Text('Xác nhận'),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (booking.status == 'confirmed')
                      TextButton.icon(
                        onPressed: () => _completeBooking(booking.id),
                        icon: const Icon(Icons.done_all),
                        label: const Text('Hoàn thành'),
                      ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _cancelBooking(booking.id),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Hủy'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ThemeData theme) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'confirmed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      case 'completed':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        _getStatusText(status),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'cancelled':
        return 'Đã hủy';
      case 'completed':
        return 'Hoàn thành';
      default:
        return status;
    }
  }

  Widget _buildInfoRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmBooking(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đặt vé'),
        content: const Text('Bạn có chắc muốn xác nhận đặt vé này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(bookingsSimpleProvider.notifier).confirmBooking(id);
    }
  }

  Future<void> _completeBooking(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hoàn thành đặt vé'),
        content: const Text('Bạn có chắc muốn đánh dấu đặt vé này là hoàn thành?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hoàn thành'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(bookingsSimpleProvider.notifier).completeBooking(id);
    }
  }

  Future<void> _cancelBooking(String id) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Hủy đặt vé'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Lý do hủy',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hủy vé'),
            ),
          ],
        );
      },
    );

    if (reason != null && reason.isNotEmpty && mounted) {
      await ref.read(bookingsSimpleProvider.notifier).cancelBooking(id, reason);
    }
  }
}

