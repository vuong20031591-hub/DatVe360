import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../features/auth/domain/providers/auth_provider.dart';
import '../features/auth/data/models/auth_state.dart';

/// App initializer to determine initial route
class AppInitializer {
  /// Get the initial route based on app state
  static String getInitialRoute(WidgetRef ref) {
    final onboardingState = ref.read(onboardingProvider);
    final authState = ref.read(authProvider);

    // First time user - show onboarding
    if (!onboardingState.isCompleted) {
      return '/onboarding';
    }

    // Onboarding completed but not authenticated - show login
    if (onboardingState.isCompleted && authState.status == AuthStatus.unauthenticated) {
      return '/login';
    }

    // User is authenticated - go to home
    if (authState.status == AuthStatus.authenticated) {
      return '/';
    }

    // Loading or initial state - default to onboarding for safety
    return '/onboarding';
  }

  /// Check if user should see onboarding
  static bool shouldShowOnboarding(WidgetRef ref) {
    final onboardingState = ref.read(onboardingProvider);
    return !onboardingState.isCompleted;
  }

  /// Check if user is authenticated
  static bool isAuthenticated(WidgetRef ref) {
    final authState = ref.read(authProvider);
    return authState.status == AuthStatus.authenticated;
  }
}
