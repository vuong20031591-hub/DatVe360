import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/domain/providers/auth_provider.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';

/// Router refresh notifier that listens to auth and onboarding state changes
class RouterRefreshNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterRefreshNotifier(this._ref) {
    // Listen to auth state changes
    _ref.listen(authProvider, (previous, next) {
      notifyListeners();
    });

    // Listen to onboarding state changes
    _ref.listen(onboardingProvider, (previous, next) {
      notifyListeners();
    });
  }
}
