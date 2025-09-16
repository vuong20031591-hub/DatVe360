import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../auth/domain/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final locale = ref.watch(localeProvider);
    final localizations = ref.watch(localizationsProvider(locale));

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.profile),
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
                                ? authState.user!.displayName
                                : localizations.guest,
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
            _buildMenuSection(context, localizations.bookingAndManagement, [
              _MenuItem(
                icon: Icons.history,
                title: localizations.searchHistory,
                subtitle: localizations.viewRecentSearches,
                onTap: () => context.pushNamed('searchHistory'),
              ),
              _MenuItem(
                icon: Icons.receipt_long,
                title: locale.languageCode == 'vi'
                    ? 'Quản lý đặt vé'
                    : 'Manage Bookings',
                subtitle: locale.languageCode == 'vi'
                    ? 'Tra cứu và quản lý vé đã đặt'
                    : 'Search and manage booked tickets',
                onTap: () => context.pushNamed('manage'),
              ),
              _MenuItem(
                icon: Icons.favorite,
                title: locale.languageCode == 'vi' ? 'Yêu thích' : 'Favorites',
                subtitle: locale.languageCode == 'vi'
                    ? 'Các chuyến và địa điểm yêu thích'
                    : 'Favorite trips and destinations',
                onTap: () => context.pushNamed('favorites'),
              ),
            ]),

            const SizedBox(height: 16),

            _buildMenuSection(context, localizations.settings, [
              _MenuItem(
                icon: Icons.settings,
                title: localizations.settings,
                subtitle: locale.languageCode == 'vi'
                    ? 'Thông báo, ngôn ngữ, giao diện'
                    : 'Notifications, language, theme',
                onTap: () => context.push('/settings'),
              ),
            ]),

            const SizedBox(height: 16),

            _buildMenuSection(
              context,
              localizations.locale.languageCode == 'vi'
                  ? 'Thông tin'
                  : 'Information',
              [
                _MenuItem(
                  icon: Icons.info,
                  title: localizations.aboutDatVe360,
                  subtitle: '${localizations.version} 1.0.0',
                  onTap: () => _showAbout(context),
                ),
              ],
            ),

            const SizedBox(height: 32),
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
