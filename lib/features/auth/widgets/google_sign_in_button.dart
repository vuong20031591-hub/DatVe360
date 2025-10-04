import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/google_auth_provider.dart';

class GoogleSignInButton extends ConsumerWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  final String? text;
  final bool showIcon;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const GoogleSignInButton({
    super.key,
    this.onSuccess,
    this.onError,
    this.text,
    this.showIcon = true,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(googleAuthProvider);
    final authNotifier = ref.read(googleAuthProvider.notifier);

    // Listen to auth state changes
    ref.listen<GoogleAuthState>(googleAuthProvider, (previous, next) {
      if (previous?.error != next.error && next.error != null) {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
        onError?.call();
      }
      
      if (previous?.user != next.user && next.user != null) {
        // Success
        onSuccess?.call();
      }
    });

    return SizedBox(
      width: width,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: authState.isLoading ? null : () => authNotifier.signIn(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
          shadowColor: Colors.black26,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.grey, width: 0.5),
          ),
        ),
        child: authState.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showIcon) ...[
                    Image.asset(
                      'assets/icons/google_logo.png',
                      width: 20,
                      height: 20,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback icon nếu không có asset
                        return const Icon(
                          Icons.account_circle,
                          size: 20,
                          color: Colors.blue,
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    text ?? 'Đăng nhập với Google',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Compact version for smaller spaces
class GoogleSignInIconButton extends ConsumerWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  final double size;

  const GoogleSignInIconButton({
    super.key,
    this.onSuccess,
    this.onError,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(googleAuthProvider);
    final authNotifier = ref.read(googleAuthProvider.notifier);

    // Listen to auth state changes
    ref.listen<GoogleAuthState>(googleAuthProvider, (previous, next) {
      if (previous?.error != next.error && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
        onError?.call();
      }
      
      if (previous?.user != next.user && next.user != null) {
        onSuccess?.call();
      }
    });

    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: authState.isLoading ? null : () => authNotifier.signIn(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
          shadowColor: Colors.black26,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size / 2),
            side: const BorderSide(color: Colors.grey, width: 0.5),
          ),
        ),
        child: authState.isLoading
            ? SizedBox(
                width: size * 0.4,
                height: size * 0.4,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              )
            : Image.asset(
                'assets/icons/google_logo.png',
                width: size * 0.5,
                height: size * 0.5,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.account_circle,
                    size: size * 0.5,
                    color: Colors.blue,
                  );
                },
              ),
      ),
    );
  }
}
