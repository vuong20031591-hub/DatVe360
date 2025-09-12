import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../shared/widgets/connectivity_status_card.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final localizations = ref.watch(localizationsProvider(locale));

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Connectivity status
          const ConnectivityStatusCard(),
          const SizedBox(height: 16),

          // Cài đặt section
          _buildSectionHeader(theme, localizations.appearance),
          const SizedBox(height: 8),

          // Thông báo
          _buildSettingsTile(
            context: context,
            icon: Icons.notifications_outlined,
            title: localizations.notifications,
            subtitle: locale.languageCode == 'vi'
                ? 'Quản lý thông báo push'
                : 'Manage push notifications',
            onTap: () {
              // TODO: Navigate to notifications settings
            },
          ),

          // Ngôn ngữ
          _buildSettingsTile(
            context: context,
            icon: Icons.language_outlined,
            title: localizations.language,
            subtitle: locale.languageCode == 'vi'
                ? localizations.vietnamese
                : localizations.english,
            onTap: () => _showLanguageDialog(context, ref),
          ),

          // Giao diện
          _buildSettingsTile(
            context: context,
            icon: Icons.brightness_6_outlined,
            title: localizations.theme,
            subtitle: _getThemeModeText(themeMode, localizations),
            onTap: () => _showThemeDialog(context, ref),
          ),

          const SizedBox(height: 32),

          // Hỗ trợ section
          _buildSectionHeader(
            theme,
            locale.languageCode == 'vi' ? 'Hỗ trợ' : 'Support',
          ),
          const SizedBox(height: 8),

          // Câu hỏi thường gặp
          _buildSettingsTile(
            context: context,
            icon: Icons.help_outline,
            title: locale.languageCode == 'vi' ? 'Câu hỏi thường gặp' : 'FAQ',
            subtitle: locale.languageCode == 'vi'
                ? 'FAQ và hướng dẫn sử dụng'
                : 'FAQ and user guide',
            onTap: () => context.push('/faq'),
          ),

          // Liên hệ hỗ trợ
          _buildSettingsTile(
            context: context,
            icon: Icons.support_agent_outlined,
            title: locale.languageCode == 'vi'
                ? 'Liên hệ hỗ trợ'
                : 'Contact Support',
            subtitle: locale.languageCode == 'vi'
                ? 'Chat hoặc gọi điện hỗ trợ'
                : 'Chat or call support',
            onTap: () => context.push('/contact-support'),
          ),

          // Chính sách & Điều khoản
          _buildSettingsTile(
            context: context,
            icon: Icons.policy_outlined,
            title: locale.languageCode == 'vi'
                ? 'Chính sách & Điều khoản'
                : 'Privacy & Terms',
            subtitle: locale.languageCode == 'vi'
                ? 'Quy định sử dụng dịch vụ'
                : 'Service usage policy',
            onTap: () => context.push('/terms-policy'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode, AppLocalizations localizations) {
    switch (mode) {
      case ThemeMode.light:
        return localizations.lightMode;
      case ThemeMode.dark:
        return localizations.darkMode;
      default:
        return localizations.systemMode;
    }
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentLocale = ref.read(localeProvider);
    final localizations = ref.read(localizationsProvider(currentLocale));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          currentLocale.languageCode == 'vi'
              ? 'Chọn ngôn ngữ'
              : 'Select Language',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Tiếng Việt'),
              value: 'vi',
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                ref
                    .read(localeProvider.notifier)
                    .setLocale(const Locale('vi', 'VN'));
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                ref
                    .read(localeProvider.notifier)
                    .setLocale(const Locale('en', 'US'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(currentLocale.languageCode == 'vi' ? 'Hủy' : 'Cancel'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentTheme = ref.read(themeProvider);
    final currentLocale = ref.read(localeProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          currentLocale.languageCode == 'vi'
              ? 'Chọn giao diện'
              : 'Select Theme',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Text(
                currentLocale.languageCode == 'vi' ? 'Sáng' : 'Light',
              ),
              value: ThemeMode.light,
              groupValue: currentTheme,
              onChanged: (value) {
                ref.read(themeProvider.notifier).setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(currentLocale.languageCode == 'vi' ? 'Tối' : 'Dark'),
              value: ThemeMode.dark,
              groupValue: currentTheme,
              onChanged: (value) {
                ref.read(themeProvider.notifier).setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(
                currentLocale.languageCode == 'vi' ? 'Theo hệ thống' : 'System',
              ),
              value: ThemeMode.system,
              groupValue: currentTheme,
              onChanged: (value) {
                ref.read(themeProvider.notifier).setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(currentLocale.languageCode == 'vi' ? 'Hủy' : 'Cancel'),
          ),
        ],
      ),
    );
  }
}
