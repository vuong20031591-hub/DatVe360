import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

/// Service to handle automatic token refresh
class TokenRefreshService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  final ApiService _apiService;
  Timer? _refreshTimer;

  TokenRefreshService(this._apiService);

  /// Start automatic token refresh monitoring
  Future<void> startAutoRefresh() async {
    await _scheduleNextRefresh();
  }

  /// Stop automatic token refresh
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Schedule next token refresh
  Future<void> _scheduleNextRefresh() async {
    final expiryTime = await _getTokenExpiryTime();
    if (expiryTime == null) return;

    final now = DateTime.now();
    final timeUntilExpiry = expiryTime.difference(now);

    // Refresh 10 minutes before expiry, or immediately if already expired
    final refreshTime = timeUntilExpiry.inMinutes > 10
        ? timeUntilExpiry - const Duration(minutes: 10)
        : Duration.zero;

    _refreshTimer?.cancel();
    _refreshTimer = Timer(refreshTime, () async {
      await _performTokenRefresh();
    });
  }

  /// Get token expiry time from storage
  Future<DateTime?> _getTokenExpiryTime() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString(_tokenExpiryKey);
    if (expiryString == null) return null;

    try {
      return DateTime.parse(expiryString);
    } catch (e) {
      return null;
    }
  }

  /// Perform token refresh
  Future<void> _performTokenRefresh() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);
      if (refreshToken == null) {
        await _handleRefreshFailure();
        return;
      }

      final success = await _apiService.refreshToken();
      if (success) {
        // Get updated token info
        final newToken = await _apiService.getAuthToken();
        if (newToken != null) {
          await _updateTokenExpiry();
          await _scheduleNextRefresh();
        } else {
          await _handleRefreshFailure();
        }
      } else {
        await _handleRefreshFailure();
      }
    } catch (e) {
      await _handleRefreshFailure();
    }
  }

  /// Update token expiry time based on new token
  Future<void> _updateTokenExpiry() async {
    // JWT tokens expire in 1 hour by default
    final expiryTime = DateTime.now().add(const Duration(hours: 1));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenExpiryKey, expiryTime.toIso8601String());
  }

  /// Handle refresh failure - logout user
  Future<void> _handleRefreshFailure() async {
    stopAutoRefresh();
    // Clear tokens from storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await prefs.remove(_tokenExpiryKey);
  }

  /// Set token expiry when user logs in
  Future<void> setTokenExpiry(String expiresIn) async {
    Duration expiry;

    // Parse expiry string (e.g., "1h", "7d", "30d")
    if (expiresIn.endsWith('h')) {
      final hours = int.tryParse(expiresIn.replaceAll('h', '')) ?? 1;
      expiry = Duration(hours: hours);
    } else if (expiresIn.endsWith('d')) {
      final days = int.tryParse(expiresIn.replaceAll('d', '')) ?? 1;
      expiry = Duration(days: days);
    } else if (expiresIn.endsWith('m')) {
      final minutes = int.tryParse(expiresIn.replaceAll('m', '')) ?? 60;
      expiry = Duration(minutes: minutes);
    } else {
      // Default to 1 hour
      expiry = const Duration(hours: 1);
    }

    final expiryTime = DateTime.now().add(expiry);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenExpiryKey, expiryTime.toIso8601String());

    await startAutoRefresh();
  }

  /// Check if token is about to expire (within 10 minutes)
  Future<bool> isTokenAboutToExpire() async {
    final expiryTime = await _getTokenExpiryTime();
    if (expiryTime == null) return true;

    final now = DateTime.now();
    final timeUntilExpiry = expiryTime.difference(now);

    return timeUntilExpiry.inMinutes <= 10;
  }

  /// Force refresh token now
  Future<bool> forceRefresh() async {
    await _performTokenRefresh();
    final expiryTime = await _getTokenExpiryTime();
    return expiryTime?.isAfter(DateTime.now()) ?? false;
  }
}

/// Provider for TokenRefreshService
final tokenRefreshServiceProvider = Provider<TokenRefreshService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return TokenRefreshService(apiService);
});
