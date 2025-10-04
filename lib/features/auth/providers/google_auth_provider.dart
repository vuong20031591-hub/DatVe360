import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/services/google_sign_in_service.dart';

// State cho Google Sign-In
class GoogleAuthState {
  final bool isLoading;
  final GoogleSignInAccount? user;
  final String? error;

  const GoogleAuthState({this.isLoading = false, this.user, this.error});

  GoogleAuthState copyWith({
    bool? isLoading,
    GoogleSignInAccount? user,
    String? error,
  }) {
    return GoogleAuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

// Provider cho Google Auth State
class GoogleAuthNotifier extends Notifier<GoogleAuthState> {
  @override
  GoogleAuthState build() => const GoogleAuthState();

  final GoogleSignInService _googleSignInService = GoogleSignInService();

  /// Khởi tạo Google Sign-In
  void initialize({String? webClientId}) {
    _googleSignInService.initialize(webClientId: webClientId);
    _checkCurrentUser();
  }

  /// Kiểm tra user hiện tại
  Future<void> _checkCurrentUser() async {
    try {
      final isSignedIn = await _googleSignInService.isSignedIn();
      if (isSignedIn) {
        final user = _googleSignInService.currentUser;
        state = state.copyWith(user: user);
      }
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  /// Đăng nhập với Google
  Future<void> signIn() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _googleSignInService.signIn();
      if (user != null) {
        state = state.copyWith(isLoading: false, user: user, error: null);
      } else {
        state = state.copyWith(isLoading: false, error: 'Đăng nhập thất bại');
      }
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await _googleSignInService.signOut();
      state = state.copyWith(isLoading: false, user: null, error: null);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  /// Ngắt kết nối
  Future<void> disconnect() async {
    state = state.copyWith(isLoading: true);

    try {
      await _googleSignInService.disconnect();
      state = state.copyWith(isLoading: false, user: null, error: null);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  /// Lấy access token
  Future<String?> getAccessToken() async {
    return await _googleSignInService.getAccessToken();
  }

  /// Lấy ID token
  Future<String?> getIdToken() async {
    return await _googleSignInService.getIdToken();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final googleAuthProvider =
    NotifierProvider<GoogleAuthNotifier, GoogleAuthState>(
      GoogleAuthNotifier.new,
    );

// Computed providers
final isGoogleSignedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(googleAuthProvider);
  return authState.user != null;
});

final googleUserProvider = Provider<GoogleSignInAccount?>((ref) {
  final authState = ref.watch(googleAuthProvider);
  return authState.user;
});

final googleAuthLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(googleAuthProvider);
  return authState.isLoading;
});

final googleAuthErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(googleAuthProvider);
  return authState.error;
});
