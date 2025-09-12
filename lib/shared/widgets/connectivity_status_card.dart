import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/connectivity_provider.dart';
import '../../core/providers/cache_provider.dart';
import '../../core/providers/locale_provider.dart';

/// Card widget to show connectivity status and cache management
class ConnectivityStatusCard extends ConsumerWidget {
  const ConnectivityStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final connectivityState = ref.watch(connectivityNotifierProvider);
    final cacheStatus = ref.watch(cacheStatusProvider);
    final locale = ref.watch(localeProvider);
    final localizations = ref.watch(localizationsProvider(locale));

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  connectivityState.isOnline ? Icons.wifi : Icons.wifi_off,
                  color: connectivityState.isOnline ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  localizations.locale.languageCode == 'vi'
                      ? 'Trạng thái kết nối'
                      : 'Connection Status',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Connection status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: connectivityState.isOnline
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: connectivityState.isOnline
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.red.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    connectivityState.isOnline
                        ? Icons.check_circle
                        : Icons.error,
                    size: 16,
                    color: connectivityState.isOnline
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      connectivityState.isChecking
                          ? (localizations.locale.languageCode == 'vi'
                                ? 'Đang kiểm tra kết nối...'
                                : 'Checking connection...')
                          : connectivityState.isOnline
                          ? (localizations.locale.languageCode == 'vi'
                                ? 'Đã kết nối mạng'
                                : 'Connected to internet')
                          : (localizations.locale.languageCode == 'vi'
                                ? 'Không có kết nối mạng'
                                : 'No internet connection'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: connectivityState.isOnline
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (!connectivityState.isChecking)
                    TextButton(
                      onPressed: () {
                        ref
                            .read(connectivityNotifierProvider.notifier)
                            .checkConnectivity();
                      },
                      child: Text(
                        localizations.locale.languageCode == 'vi'
                            ? 'Kiểm tra'
                            : 'Check',
                        style: TextStyle(
                          color: connectivityState.isOnline
                              ? Colors.green
                              : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Cache management
            Row(
              children: [
                Icon(Icons.storage, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  localizations.locale.languageCode == 'vi'
                      ? 'Quản lý bộ nhớ đệm'
                      : 'Cache Management',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Cache actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: cacheStatus.isClearing
                        ? null
                        : () {
                            ref
                                .read(cacheStatusProvider.notifier)
                                .clearExpiredCache();
                          },
                    icon: cacheStatus.isClearing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cleaning_services, size: 16),
                    label: Text(
                      localizations.locale.languageCode == 'vi'
                          ? 'Xóa cache cũ'
                          : 'Clear Old Cache',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: cacheStatus.isClearing
                        ? null
                        : () {
                            _showClearAllCacheDialog(
                              context,
                              ref,
                              localizations,
                            );
                          },
                    icon: const Icon(Icons.delete_sweep, size: 16),
                    label: Text(
                      localizations.locale.languageCode == 'vi'
                          ? 'Xóa tất cả'
                          : 'Clear All',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),

            // Cache status message
            if (cacheStatus.isCleared)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  localizations.locale.languageCode == 'vi'
                      ? 'Đã xóa cache thành công'
                      : 'Cache cleared successfully',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            if (cacheStatus.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  cacheStatus.error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showClearAllCacheDialog(
    BuildContext context,
    WidgetRef ref,
    dynamic localizations,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          localizations.locale.languageCode == 'vi'
              ? 'Xóa tất cả cache'
              : 'Clear All Cache',
        ),
        content: Text(
          localizations.locale.languageCode == 'vi'
              ? 'Bạn có chắc chắn muốn xóa tất cả dữ liệu đã lưu? Điều này sẽ làm chậm ứng dụng khi tải dữ liệu lần đầu.'
              : 'Are you sure you want to clear all cached data? This will slow down the app when loading data for the first time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              localizations.locale.languageCode == 'vi' ? 'Hủy' : 'Cancel',
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(cacheStatusProvider.notifier).clearCache();
            },
            child: Text(
              localizations.locale.languageCode == 'vi' ? 'Xóa' : 'Clear',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
