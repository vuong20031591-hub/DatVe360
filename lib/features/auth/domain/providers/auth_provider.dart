import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/auth_state.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/real_auth_repository.dart';
import '../../../../core/services/token_refresh_service.dart';

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return RealAuthRepository.instance;
});

/// Auth state notifier
class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _authRepository;
  late final TokenRefreshService _tokenRefreshService;

  @override
  AuthState build() {
    _authRepository = ref.read(authRepositoryProvider);
    _tokenRefreshService = ref.read(tokenRefreshServiceProvider);
    _initializeAuth();
    return AuthState.initial();
  }

  /// Initialize authentication
  Future<void> _initializeAuth() async {
    // Initialize RealAuthRepository if needed
    if (_authRepository is RealAuthRepository) {
      final realRepo = _authRepository as RealAuthRepository;
      await realRepo.initialize();
    }
    _checkAuthStatus();
  }

  /// Check current authentication status
  Future<void> _checkAuthStatus() async {
    try {
      state = AuthState.loading();
      final user = await _authRepository.getCurrentUser();

      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Login with email/phone and password
  Future<void> login(LoginRequest request) async {
    try {
      state = AuthState.loading();
      final response = await _authRepository.login(request);

      // Start auto-refresh for token
      await _tokenRefreshService.setTokenExpiry(response.expiresIn);

      state = AuthState.authenticated(response.user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Register new user
  Future<void> register(RegisterRequest request) async {
    try {
      state = AuthState.loading();
      final response = await _authRepository.register(request);

      // Start auto-refresh for token
      await _tokenRefreshService.setTokenExpiry(response.expiresIn);

      state = AuthState.authenticated(response.user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      state = AuthState.loading();

      // Stop auto-refresh
      _tokenRefreshService.stopAutoRefresh();

      await _authRepository.logout();
      state = AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Forgot password
  Future<void> forgotPassword(String email) async {
    try {
      state = AuthState.loading();
      await _authRepository.forgotPassword(email);
      state = state.copyWith(status: AuthStatus.initial, isLoading: false);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Clear error state
  void clearError() {
    if (state.hasError) {
      state = state.copyWith(status: AuthStatus.initial, error: null);
    }
  }

  /// Update user profile
  Future<void> updateProfile(User user) async {
    try {
      await _authRepository.updateProfile(user);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
}

/// Auth state provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

/// Form validation provider for login
class LoginFormNotifier extends Notifier<FormValidationState> {
  @override
  FormValidationState build() {
    return FormValidationState.initial();
  }

  void validateEmailOrPhone(String value) {
    String? error;

    if (value.isEmpty) {
      error = 'Vui lòng nhập email hoặc số điện thoại';
    } else if (!_isValidEmailOrPhone(value)) {
      error = 'Email hoặc số điện thoại không hợp lệ';
    }

    state = state.setError('emailOrPhone', error);
  }

  void validatePassword(String value) {
    String? error;

    if (value.isEmpty) {
      error = 'Vui lòng nhập mật khẩu';
    } else if (value.length < 6) {
      error = 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    state = state.setError('password', error);
  }

  bool _isValidEmailOrPhone(String value) {
    // Email regex
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    // Phone regex (Vietnamese format)
    final phoneRegex = RegExp(r'^(0|\+84)[3-9][0-9]{8}$');

    return emailRegex.hasMatch(value) || phoneRegex.hasMatch(value);
  }

  void clearValidation() {
    state = FormValidationState.initial();
  }
}

/// Login form validation provider
final loginFormProvider =
    NotifierProvider<LoginFormNotifier, FormValidationState>(() {
      return LoginFormNotifier();
    });

/// Form validation provider for register
class RegisterFormNotifier extends Notifier<FormValidationState> {
  @override
  FormValidationState build() {
    return FormValidationState.initial();
  }

  void validateFullName(String value) {
    String? error;

    if (value.isEmpty) {
      error = 'Vui lòng nhập họ tên';
    } else if (value.trim().length < 2) {
      error = 'Họ tên phải có ít nhất 2 ký tự';
    }

    state = state.setError('fullName', error);
  }

  void validateEmail(String value) {
    String? error;

    if (value.isEmpty) {
      error = 'Vui lòng nhập email';
    } else if (!_isValidEmail(value)) {
      error = 'Email không hợp lệ';
    }

    state = state.setError('email', error);
  }

  void validatePhone(String value) {
    String? error;

    if (value.isNotEmpty && !_isValidPhone(value)) {
      error = 'Số điện thoại không hợp lệ';
    }

    state = state.setError('phone', error);
  }

  void validatePassword(String value) {
    String? error;

    if (value.isEmpty) {
      error = 'Vui lòng nhập mật khẩu';
    } else if (value.length < 8) {
      error = 'Mật khẩu phải có ít nhất 8 ký tự';
    } else if (!_isStrongPassword(value)) {
      error = 'Mật khẩu phải chứa chữ hoa, chữ thường và số';
    }

    state = state.setError('password', error);
  }

  void validateConfirmPassword(String value, String password) {
    String? error;

    if (value.isEmpty) {
      error = 'Vui lòng xác nhận mật khẩu';
    } else if (value != password) {
      error = 'Mật khẩu xác nhận không khớp';
    }

    state = state.setError('confirmPassword', error);
  }

  void validateTermsAgreement(bool agreed) {
    String? error;

    if (!agreed) {
      error = 'Vui lòng đồng ý với điều khoản sử dụng';
    }

    state = state.setError('agreeToTerms', error);
  }

  bool _isValidEmail(String value) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(value);
  }

  bool _isValidPhone(String value) {
    final phoneRegex = RegExp(r'^(0|\+84)[3-9][0-9]{8}$');
    return phoneRegex.hasMatch(value);
  }

  bool _isStrongPassword(String value) {
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(value);
    final hasDigits = RegExp(r'[0-9]').hasMatch(value);

    return hasUppercase && hasLowercase && hasDigits;
  }

  void clearValidation() {
    state = FormValidationState.initial();
  }
}

/// Register form validation provider
final registerFormProvider =
    NotifierProvider<RegisterFormNotifier, FormValidationState>(() {
      return RegisterFormNotifier();
    });
