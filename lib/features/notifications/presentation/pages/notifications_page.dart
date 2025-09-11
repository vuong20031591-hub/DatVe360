import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/l10n.dart';
import '../../../../shared/widgets/app_button.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          IconButton(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all),
            tooltip: 'Đánh dấu tất cả đã đọc',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Cài đặt thông báo'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Xóa tất cả'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(context, theme),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme) {
    final notifications = _getNotifications();

    if (notifications.isEmpty) {
      return _buildEmptyState(context, theme);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationItem(context, theme, notification);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Không có thông báo',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Các thông báo về chuyến đi và ưu đãi sẽ xuất hiện ở đây',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, ThemeData theme, Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isRead ? null : theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification['type']).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getNotificationIcon(notification['type']),
                  color: _getNotificationColor(notification['type']),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['message'],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          notification['time'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        const Spacer(),
                        if (notification['actionText'] != null)
                          TextButton(
                            onPressed: () => _handleNotificationAction(notification),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: const Size(0, 32),
                            ),
                            child: Text(notification['actionText']),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getNotifications() {
    return [
      {
        'id': '1',
        'type': 'booking',
        'title': 'Đặt vé thành công',
        'message': 'Vé máy bay Hà Nội - Hồ Chí Minh đã được đặt thành công. Mã đặt chỗ: VN123456',
        'time': '2 giờ trước',
        'isRead': false,
        'actionText': 'Xem vé',
      },
      {
        'id': '2',
        'type': 'promotion',
        'title': 'Ưu đãi đặc biệt',
        'message': 'Giảm 30% cho tất cả chuyến bay nội địa. Áp dụng đến hết 31/12/2024',
        'time': '1 ngày trước',
        'isRead': false,
        'actionText': 'Xem ưu đãi',
      },
      {
        'id': '3',
        'type': 'reminder',
        'title': 'Nhắc nhở check-in',
        'message': 'Chuyến bay VN123 sẽ khởi hành trong 24 giờ. Hãy check-in online để tiết kiệm thời gian',
        'time': '2 ngày trước',
        'isRead': true,
        'actionText': 'Check-in',
      },
      {
        'id': '4',
        'type': 'update',
        'title': 'Cập nhật ứng dụng',
        'message': 'Phiên bản mới với nhiều tính năng hấp dẫn đã có sẵn',
        'time': '3 ngày trước',
        'isRead': true,
        'actionText': 'Cập nhật',
      },
      {
        'id': '5',
        'type': 'system',
        'title': 'Bảo trì hệ thống',
        'message': 'Hệ thống sẽ bảo trì từ 2:00 - 4:00 sáng ngày 15/12/2024',
        'time': '1 tuần trước',
        'isRead': true,
        'actionText': null,
      },
    ];
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'booking':
        return Icons.confirmation_number;
      case 'promotion':
        return Icons.local_offer;
      case 'reminder':
        return Icons.schedule;
      case 'update':
        return Icons.system_update;
      case 'system':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'booking':
        return Colors.green;
      case 'promotion':
        return Colors.orange;
      case 'reminder':
        return Colors.blue;
      case 'update':
        return Colors.purple;
      case 'system':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Mark as read
    setState(() {
      notification['isRead'] = true;
    });

    // Handle navigation based on notification type
    switch (notification['type']) {
      case 'booking':
        _navigateToBookingDetails(notification);
        break;
      case 'promotion':
        _navigateToPromotions(notification);
        break;
      case 'reminder':
        _navigateToCheckIn(notification);
        break;
      default:
        break;
    }
  }

  void _handleNotificationAction(Map<String, dynamic> notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${notification['actionText']}: ${notification['title']}')),
    );
  }

  void _navigateToBookingDetails(Map<String, dynamic> notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chuyển đến chi tiết đặt vé')),
    );
  }

  void _navigateToPromotions(Map<String, dynamic> notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chuyển đến trang ưu đãi')),
    );
  }

  void _navigateToCheckIn(Map<String, dynamic> notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chuyển đến trang check-in')),
    );
  }

  void _markAllAsRead() {
    setState(() {
      final notifications = _getNotifications();
      for (var notification in notifications) {
        notification['isRead'] = true;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã đánh dấu tất cả thông báo là đã đọc')),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'settings':
        _showNotificationSettings();
        break;
      case 'clear':
        _clearAllNotifications();
        break;
    }
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cài đặt thông báo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Thông báo đặt vé'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Thông báo ưu đãi'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Nhắc nhở check-in'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tất cả thông báo'),
        content: const Text('Bạn có chắc chắn muốn xóa tất cả thông báo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa tất cả thông báo')),
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
