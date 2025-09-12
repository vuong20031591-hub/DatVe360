import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/connectivity_service.dart';

/// Provider for connectivity status
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService.instance;
});

/// Provider for current connectivity status
final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.connectivityStream;
});

/// Provider for current connectivity status (synchronous)
final isOnlineProvider = Provider<bool>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.isOnline;
});

/// Notifier for connectivity-aware operations
class ConnectivityNotifier extends Notifier<ConnectivityState> {
  late ConnectivityService _connectivityService;

  @override
  ConnectivityState build() {
    _connectivityService = ref.watch(connectivityServiceProvider);

    // Listen to connectivity changes
    _connectivityService.connectivityStream.listen((isOnline) {
      if (isOnline) {
        state = ConnectivityState.online();
      } else {
        state = ConnectivityState.offline();
      }
    });

    return ConnectivityState.online();
  }

  /// Force connectivity check
  Future<void> checkConnectivity() async {
    state = ConnectivityState.checking();
    final isOnline = await _connectivityService.checkConnectivity();
    state = isOnline ? ConnectivityState.online() : ConnectivityState.offline();
  }
}

/// Provider for connectivity notifier
final connectivityNotifierProvider =
    NotifierProvider<ConnectivityNotifier, ConnectivityState>(() {
      return ConnectivityNotifier();
    });

/// Connectivity state model
class ConnectivityState {
  final bool isOnline;
  final bool isChecking;
  final String? message;

  const ConnectivityState._({
    required this.isOnline,
    required this.isChecking,
    this.message,
  });

  factory ConnectivityState.online() =>
      const ConnectivityState._(isOnline: true, isChecking: false);

  factory ConnectivityState.offline() => const ConnectivityState._(
    isOnline: false,
    isChecking: false,
    message: 'Không có kết nối mạng',
  );

  factory ConnectivityState.checking() => const ConnectivityState._(
    isOnline: false,
    isChecking: true,
    message: 'Đang kiểm tra kết nối...',
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectivityState &&
          runtimeType == other.runtimeType &&
          isOnline == other.isOnline &&
          isChecking == other.isChecking &&
          message == other.message;

  @override
  int get hashCode =>
      isOnline.hashCode ^ isChecking.hashCode ^ message.hashCode;

  @override
  String toString() =>
      'ConnectivityState(isOnline: $isOnline, isChecking: $isChecking, message: $message)';
}
