import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/domain/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            // User info section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authState.isAuthenticated
                                ? authState.user!.fullName
                                : 'Khách hàng',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            authState.isAuthenticated
                                ? authState.user!.email
                                : 'Chưa đăng nhập',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (authState.isAuthenticated) {
                          _showLogoutDialog(context, ref);
                        } else {
                          context.push('/login');
                        }
                      },
                      child: Text(
                        authState.isAuthenticated ? 'Đăng xuất' : 'Đăng nhập',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Menu sections
            _buildMenuSection(context, 'Đặt vé & Quản lý', [
              _MenuItem(
                icon: Icons.history,
                title: 'Lịch sử tìm kiếm',
                subtitle: 'Xem các tìm kiếm gần đây',
                onTap: () => context.pushNamed('searchHistory'),
              ),
              _MenuItem(
                icon: Icons.receipt_long,
                title: 'Quản lý đặt vé',
                subtitle: 'Tra cứu và quản lý vé đã đặt',
                onTap: () => context.pushNamed('manage'),
              ),
              _MenuItem(
                icon: Icons.favorite,
                title: 'Yêu thích',
                subtitle: 'Các chuyến và địa điểm yêu thích',
                onTap: () => context.pushNamed('favorites'),
              ),
            ]),

            const SizedBox(height: 16),

            _buildMenuSection(context, 'Cài đặt', [
              _MenuItem(
                icon: Icons.notifications,
                title: 'Thông báo',
                subtitle: 'Quản lý thông báo push',
                onTap: () => context.pushNamed('notifications'),
              ),
              _MenuItem(
                icon: Icons.language,
                title: 'Ngôn ngữ',
                subtitle: 'Tiếng Việt',
                onTap: () => _showLanguageSettings(context),
              ),
              _MenuItem(
                icon: Icons.dark_mode,
                title: 'Giao diện',
                subtitle: 'Sáng/Tối',
                onTap: () => _showThemeSettings(context),
              ),
            ]),

            const SizedBox(height: 16),

            _buildMenuSection(context, 'Hỗ trợ', [
              _MenuItem(
                icon: Icons.help,
                title: 'Câu hỏi thường gặp',
                subtitle: 'FAQ và hướng dẫn sử dụng',
                onTap: () => context.pushNamed('faq'),
              ),
              _MenuItem(
                icon: Icons.support_agent,
                title: 'Liên hệ hỗ trợ',
                subtitle: 'Chat hoặc gọi điện hỗ trợ',
                onTap: () => context.pushNamed('contactSupport'),
              ),
              _MenuItem(
                icon: Icons.policy,
                title: 'Chính sách & Điều khoản',
                subtitle: 'Quy định sử dụng dịch vụ',
                onTap: () => context.pushNamed('termsPolicy'),
              ),
              _MenuItem(
                icon: Icons.info,
                title: 'Về DatVe360',
                subtitle: 'Phiên bản 1.0.0',
                onTap: () => _showAbout(context),
              ),
            ]),

            const SizedBox(height: 32),

            // Logout button (placeholder)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showComingSoon(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                ),
                child: const Text('Đăng xuất'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    String title,
    List<_MenuItem> items,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Card(
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon),
                    title: Text(item.title),
                    subtitle: item.subtitle != null
                        ? Text(item.subtitle!)
                        : null,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: item.onTap,
                  ),
                  if (index < items.length - 1) const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tính năng này sẽ được cập nhật trong phiên bản tiếp theo',
        ),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cài đặt thông báo'),
        content: const Text(
          'Tính năng cài đặt thông báo sẽ được cập nhật sau.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn ngôn ngữ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Tiếng Việt'),
              value: 'vi',
              groupValue: 'vi',
              onChanged: (value) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã chọn Tiếng Việt')),
                );
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: 'vi',
              onChanged: (value) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('English selected')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn giao diện'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Theo hệ thống'),
              value: 'system',
              groupValue: 'system',
              onChanged: (value) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã chọn theo hệ thống')),
                );
              },
            ),
            RadioListTile<String>(
              title: const Text('Sáng'),
              value: 'light',
              groupValue: 'system',
              onChanged: (value) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã chọn giao diện sáng')),
                );
              },
            ),
            RadioListTile<String>(
              title: const Text('Tối'),
              value: 'dark',
              groupValue: 'system',
              onChanged: (value) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã chọn giao diện tối')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Liên hệ hỗ trợ'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📧 Email: support@datve360.com'),
            SizedBox(height: 8),
            Text('📞 Hotline: 1900 1234'),
            SizedBox(height: 8),
            Text('🕒 Thời gian: 24/7'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'DatVe360',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.flight_takeoff, size: 48),
      children: const [
        Text('Ứng dụng đặt vé đa phương tiện hàng đầu Việt Nam.'),
        SizedBox(height: 16),
        Text('© 2024 DatVe360. All rights reserved.'),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}

void _showLogoutDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Đăng xuất'),
      content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            ref.read(authProvider.notifier).logout();
          },
          child: const Text('Đăng xuất'),
        ),
      ],
    ),
  );
}
