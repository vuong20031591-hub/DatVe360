import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      
      // Add device info
      options.headers['X-Device-Platform'] = 'mobile';
      options.headers['X-App-Version'] = '1.0.0';
      
    } catch (e) {
      // Continue without auth if there's an error
    }
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired or invalid, clear stored token
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        await prefs.remove('refresh_token');
        await prefs.remove('user_data');
      } catch (e) {
        // Ignore error when clearing preferences
      }
    }
    
    handler.next(err);
  }
}
