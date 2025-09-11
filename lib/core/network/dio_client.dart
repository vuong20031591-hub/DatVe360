import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

class DioClient {
  static DioClient? _instance;
  late Dio _dio;

  DioClient._internal() {
    _dio = Dio();
    _setupInterceptors();
    _setupBaseOptions();
  }

  static DioClient get instance {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  void _setupBaseOptions() {
    _dio.options = BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'DatVe360/${AppConstants.appVersion}',
      },
    );
  }

  void _setupInterceptors() {
    _dio.interceptors.clear();
    
    // Add auth interceptor
    _dio.interceptors.add(AuthInterceptor());
    
    // Add retry interceptor
    _dio.interceptors.add(RetryInterceptor());
    
    // Add logging interceptor (only in debug mode)
    if (kDebugMode) {
      _dio.interceptors.add(LoggingInterceptor());
    }
  }

  // GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Upload file
  Future<Response<T>> upload<T>(
    String path,
    FormData formData, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Download file
  Future<Response> download(
    String urlPath,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Error handler
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return NetworkException('Kết nối mạng bị gián đoạn. Vui lòng thử lại.');
        
        case DioExceptionType.badResponse:
          return _handleHttpError(error.response);
        
        case DioExceptionType.cancel:
          return NetworkException('Yêu cầu đã bị hủy.');
        
        case DioExceptionType.connectionError:
          return NetworkException('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.');
        
        default:
          return NetworkException('Đã xảy ra lỗi không xác định.');
      }
    }
    
    return NetworkException('Đã xảy ra lỗi không xác định.');
  }

  Exception _handleHttpError(Response? response) {
    if (response == null) {
      return NetworkException('Không nhận được phản hồi từ máy chủ.');
    }

    switch (response.statusCode) {
      case 400:
        return BadRequestException(_getErrorMessage(response));
      case 401:
        return UnauthorizedException('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      case 403:
        return ForbiddenException('Bạn không có quyền truy cập tài nguyên này.');
      case 404:
        return NotFoundException('Không tìm thấy tài nguyên yêu cầu.');
      case 422:
        return ValidationException(_getErrorMessage(response));
      case 429:
        return TooManyRequestsException('Quá nhiều yêu cầu. Vui lòng thử lại sau.');
      case 500:
        return ServerException('Lỗi máy chủ nội bộ. Vui lòng thử lại sau.');
      case 502:
        return ServerException('Máy chủ không phản hồi. Vui lòng thử lại sau.');
      case 503:
        return ServerException('Dịch vụ tạm thời không khả dụng. Vui lòng thử lại sau.');
      default:
        return NetworkException('Lỗi HTTP ${response.statusCode}: ${response.statusMessage}');
    }
  }

  String _getErrorMessage(Response response) {
    try {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['message'] ?? data['error'] ?? 'Đã xảy ra lỗi không xác định.';
      }
      return 'Đã xảy ra lỗi không xác định.';
    } catch (e) {
      return 'Đã xảy ra lỗi không xác định.';
    }
  }

  // Update auth token
  void updateAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Clear auth token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Clear all interceptors and recreate
  void reset() {
    _dio.interceptors.clear();
    _setupInterceptors();
  }
}

// Custom exceptions
abstract class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => message;
}

class BadRequestException extends NetworkException {
  BadRequestException(super.message);
}

class UnauthorizedException extends NetworkException {
  UnauthorizedException(super.message);
}

class ForbiddenException extends NetworkException {
  ForbiddenException(super.message);
}

class NotFoundException extends NetworkException {
  NotFoundException(super.message);
}

class ValidationException extends NetworkException {
  ValidationException(super.message);
}

class TooManyRequestsException extends NetworkException {
  TooManyRequestsException(super.message);
}

class ServerException extends NetworkException {
  ServerException(super.message);
}
