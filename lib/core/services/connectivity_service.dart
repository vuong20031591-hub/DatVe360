import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Service to monitor network connectivity
class ConnectivityService {
  static ConnectivityService? _instance;
  bool _isOnline = true;
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();

  ConnectivityService._internal();

  static ConnectivityService get instance {
    _instance ??= ConnectivityService._internal();
    return _instance!;
  }

  /// Stream of connectivity status
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Current connectivity status
  bool get isOnline => _isOnline;

  /// Initialize connectivity monitoring
  Future<void> init() async {
    await _checkConnectivity();
    _startPeriodicCheck();
  }

  /// Check connectivity by attempting to reach a reliable server
  Future<bool> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      final isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      _updateConnectivity(isConnected);
      return isConnected;
    } on SocketException catch (_) {
      _updateConnectivity(false);
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Connectivity check error: $e');
      }
      _updateConnectivity(false);
      return false;
    }
  }

  /// Start periodic connectivity checks
  void _startPeriodicCheck() {
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _checkConnectivity();
    });
  }

  /// Update connectivity status and notify listeners
  void _updateConnectivity(bool isConnected) {
    if (_isOnline != isConnected) {
      _isOnline = isConnected;
      _connectivityController.add(_isOnline);
      
      if (kDebugMode) {
        print('Connectivity changed: ${_isOnline ? 'Online' : 'Offline'}');
      }
    }
  }

  /// Force connectivity check
  Future<bool> checkConnectivity() async {
    return await _checkConnectivity();
  }

  /// Dispose resources
  void dispose() {
    _connectivityController.close();
  }
}
