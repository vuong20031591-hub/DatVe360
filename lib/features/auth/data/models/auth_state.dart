import 'user.dart';

/// Authentication state enum
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Authentication state model
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.isLoading = false,
  });

  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.initial);
  }

  factory AuthState.loading() {
    return const AuthState(
      status: AuthStatus.loading,
      isLoading: true,
    );
  }

  factory AuthState.authenticated(User user) {
    return AuthState(
      status: AuthStatus.authenticated,
      user: user,
    );
  }

  factory AuthState.unauthenticated() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  factory AuthState.error(String error) {
    return AuthState(
      status: AuthStatus.error,
      error: error,
    );
  }

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get hasError => status == AuthStatus.error && error != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.user == user &&
        other.error == error &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode {
    return Object.hash(status, user, error, isLoading);
  }

  @override
  String toString() {
    return 'AuthState(status: $status, user: $user, error: $error, isLoading: $isLoading)';
  }
}

/// Form validation state
class FormValidationState {
  final Map<String, String?> errors;
  final bool isValid;

  const FormValidationState({
    this.errors = const {},
    this.isValid = false,
  });

  factory FormValidationState.initial() {
    return const FormValidationState();
  }

  FormValidationState copyWith({
    Map<String, String?>? errors,
    bool? isValid,
  }) {
    return FormValidationState(
      errors: errors ?? this.errors,
      isValid: isValid ?? this.isValid,
    );
  }

  String? getError(String field) => errors[field];
  bool hasError(String field) => errors.containsKey(field) && errors[field] != null;

  FormValidationState setError(String field, String? error) {
    final newErrors = Map<String, String?>.from(errors);
    if (error != null) {
      newErrors[field] = error;
    } else {
      newErrors.remove(field);
    }
    
    return copyWith(
      errors: newErrors,
      isValid: newErrors.values.every((error) => error == null),
    );
  }

  FormValidationState clearErrors() {
    return const FormValidationState(isValid: true);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FormValidationState &&
        other.errors.toString() == errors.toString() &&
        other.isValid == isValid;
  }

  @override
  int get hashCode => Object.hash(errors, isValid);

  @override
  String toString() {
    return 'FormValidationState(errors: $errors, isValid: $isValid)';
  }
}
