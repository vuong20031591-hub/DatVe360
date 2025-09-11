/// Base network exception
abstract class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const NetworkException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'NetworkException: $message';
}

/// General network exception
class GeneralNetworkException extends NetworkException {
  const GeneralNetworkException(String message, {int? statusCode, dynamic data})
      : super(message, statusCode: statusCode, data: data);
}

/// Bad request exception (400)
class BadRequestException extends NetworkException {
  const BadRequestException(String message, {dynamic data})
      : super(message, statusCode: 400, data: data);
}

/// Unauthorized exception (401)
class UnauthorizedException extends NetworkException {
  const UnauthorizedException(String message, {dynamic data})
      : super(message, statusCode: 401, data: data);
}

/// Forbidden exception (403)
class ForbiddenException extends NetworkException {
  const ForbiddenException(String message, {dynamic data})
      : super(message, statusCode: 403, data: data);
}

/// Not found exception (404)
class NotFoundException extends NetworkException {
  const NotFoundException(String message, {dynamic data})
      : super(message, statusCode: 404, data: data);
}

/// Server error exception (500+)
class ServerException extends NetworkException {
  const ServerException(String message, {int? statusCode, dynamic data})
      : super(message, statusCode: statusCode, data: data);
}

/// Connection timeout exception
class TimeoutException extends NetworkException {
  const TimeoutException(String message, {dynamic data})
      : super(message, data: data);
}

/// No internet connection exception
class NoInternetException extends NetworkException {
  const NoInternetException(String message, {dynamic data})
      : super(message, data: data);
}
