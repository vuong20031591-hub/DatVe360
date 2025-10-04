import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../features/auth/domain/providers/auth_provider.dart';
import '../../features/auth/data/models/auth_state.dart';

/// Route guard to handle app initialization flow
class RouteGuard {
  static String? redirect(WidgetRef ref, GoRouterState state) {
    final onboardingState = ref.read(onboardingProvider);
    final authState = ref.read(authProvider);
    final currentPath = state.uri.path;

    // Don't redirect if already on the target route
    if (currentPath == '/onboarding' || 
        currentPath == '/login' || 
        currentPath == '/register' ||
        currentPath == '/forgot-password') {
      return null;
    }

    // First time user - show onboarding
    if (!onboardingState.isCompleted) {
      return '/onboarding';
    }

    // Onboarding completed but not authenticated - show login
    if (onboardingState.isCompleted && authState.status == AuthStatus.unauthenticated) {
      return '/login';
    }

    // User is authenticated - allow access to protected routes
    if (authState.status == AuthStatus.authenticated) {
      return null; // Allow access
    }

    // Loading state - don't redirect yet
    if (authState.status == AuthStatus.loading || authState.status == AuthStatus.initial) {
      return null;
    }

    // Default fallback
    return '/login';
  }

  /// Check if route requires authentication
  static bool requiresAuth(String path) {
    const publicRoutes = [
      '/onboarding',
      '/login', 
      '/register',
      '/forgot-password',
    ];
    
    return !publicRoutes.contains(path);
  }

  /// Get initial route based on app state
  static String getInitialRoute(WidgetRef ref) {
    final onboardingState = ref.read(onboardingProvider);
    final authState = ref.read(authProvider);

    // First time user
    if (!onboardingState.isCompleted) {
      return '/onboarding';
    }

    // Returning user but not authenticated
    if (authState.status == AuthStatus.unauthenticated) {
      return '/login';
    }

    // Authenticated user
    if (authState.status == AuthStatus.authenticated) {
      return '/';
    }

    // Default to onboarding for safety
    return '/onboarding';
  }
}
