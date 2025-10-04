import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/storage_service.dart';

/// Onboarding state
class OnboardingState {
  final int currentPage;
  final bool isCompleted;
  final bool isLoading;

  const OnboardingState({
    this.currentPage = 0,
    this.isCompleted = false,
    this.isLoading = false,
  });

  OnboardingState copyWith({
    int? currentPage,
    bool? isCompleted,
    bool? isLoading,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Onboarding notifier
class OnboardingNotifier extends Notifier<OnboardingState> {
  static const String _onboardingCompletedKey = 'onboarding_completed';
  late StorageService _storageService;

  @override
  OnboardingState build() {
    _storageService = StorageService.instance;
    _checkOnboardingStatus();
    return const OnboardingState();
  }

  /// Check if onboarding was previously completed
  Future<void> _checkOnboardingStatus() async {
    final isCompleted =
        _storageService.readBool(_onboardingCompletedKey) ?? false;
    state = state.copyWith(isCompleted: isCompleted);
  }

  /// Update current page
  void updatePage(int page) {
    state = state.copyWith(currentPage: page);
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    state = state.copyWith(isLoading: true);

    await _storageService.write(_onboardingCompletedKey, true);

    state = state.copyWith(isCompleted: true, isLoading: false);
  }

  /// Skip onboarding
  Future<void> skipOnboarding() async {
    await completeOnboarding();
  }

  /// Reset onboarding (for testing purposes)
  Future<void> resetOnboarding() async {
    await _storageService.delete(_onboardingCompletedKey);
    state = const OnboardingState();
  }
}

/// Onboarding provider
final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(() {
      return OnboardingNotifier();
    });

/// Check if onboarding is completed
final isOnboardingCompletedProvider = Provider<bool>((ref) {
  return ref.watch(onboardingProvider).isCompleted;
});
