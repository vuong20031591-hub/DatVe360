import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;
  final List<int> retryStatusCodes;

  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.retryStatusCodes = const [502, 503, 504],
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final shouldRetry = _shouldRetry(err);
    
    if (!shouldRetry) {
      handler.next(err);
      return;
    }

    final retryCount = err.requestOptions.extra['retry_count'] ?? 0;
    
    if (retryCount >= maxRetries) {
      handler.next(err);
      return;
    }

    // Wait before retrying
    await Future.delayed(retryDelay * (retryCount + 1));

    // Update retry count
    err.requestOptions.extra['retry_count'] = retryCount + 1;

    try {
      // Retry the request
      final response = await Dio().fetch(err.requestOptions);
      handler.resolve(response);
    } catch (e) {
      if (e is DioException) {
        handler.next(e);
      } else {
        handler.next(err);
      }
    }
  }

  bool _shouldRetry(DioException err) {
    // Don't retry if it's a cancel request
    if (err.type == DioExceptionType.cancel) {
      return false;
    }

    // Retry on connection timeout, send timeout, receive timeout
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    // Retry on specific HTTP status codes
    if (err.response != null && 
        retryStatusCodes.contains(err.response!.statusCode)) {
      return true;
    }

    // Retry on connection errors
    if (err.type == DioExceptionType.connectionError) {
      return true;
    }

    return false;
  }
}
