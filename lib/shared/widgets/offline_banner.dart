import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/connectivity_provider.dart';
import '../../core/providers/locale_provider.dart';

/// Banner widget to show offline status
class OfflineBanner extends ConsumerWidget {
  final Widget child;

  const OfflineBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityState = ref.watch(connectivityNotifierProvider);
    final locale = ref.watch(localeProvider);
    final localizations = ref.watch(localizationsProvider(locale));

    return Column(
      children: [
        // Offline banner
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: connectivityState.isOnline ? 0 : 40,
          child: connectivityState.isOnline
              ? const SizedBox.shrink()
              : Container(
                  width: double.infinity,
                  color: Colors.red.shade600,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.wifi_off,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          connectivityState.isChecking
                              ? (localizations.locale.languageCode == 'vi'
                                    ? 'Đang kiểm tra kết nối...'
                                    : 'Checking connection...')
                              : (localizations.locale.languageCode == 'vi'
                                    ? 'Không có kết nối mạng'
                                    : 'No internet connection'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (!connectivityState.isChecking) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              ref
                                  .read(connectivityNotifierProvider.notifier)
                                  .checkConnectivity();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                localizations.locale.languageCode == 'vi'
                                    ? 'Thử lại'
                                    : 'Retry',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
        ),
        // Main content
        Expanded(child: child),
      ],
    );
  }
}

/// Snackbar for connectivity changes
class ConnectivitySnackbar {
  static void show(BuildContext context, bool isOnline) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isOnline ? Icons.wifi : Icons.wifi_off,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              isOnline ? 'Đã kết nối mạng' : 'Mất kết nối mạng',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: isOnline ? Colors.green : Colors.red,
        duration: Duration(seconds: isOnline ? 2 : 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// Widget to show cached data indicator
class CachedDataIndicator extends StatelessWidget {
  final bool isVisible;

  const CachedDataIndicator({super.key, this.isVisible = false});

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cached,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            'Dữ liệu đã lưu',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
