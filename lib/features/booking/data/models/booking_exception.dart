/// Enum định nghĩa các loại lỗi booking
enum BookingErrorType {
  /// Lỗi conflict - ghế đã được đặt (race condition)
  conflict,
  
  /// Lỗi validation - dữ liệu không hợp lệ
  validation,
  
  /// Lỗi not found - không tìm thấy resource
  notFound,
  
  /// Lỗi server - 500+
  serverError,
  
  /// Lỗi timeout
  timeout,
  
  /// Lỗi network
  network,
  
  /// Lỗi parse response
  parseError,
  
  /// Response không hợp lệ
  invalidResponse,
  
  /// Lỗi API
  apiError,
  
  /// Lỗi không xác định
  unknown,
}

/// Custom exception cho booking operations
class BookingException implements Exception {
  final String message;
  final BookingErrorType type;
  final bool canRetry;
  final dynamic originalError;

  BookingException(
    this.message, {
    required this.type,
    this.canRetry = false,
    this.originalError,
  });

  /// Kiểm tra xem có phải lỗi race condition không
  bool get isRaceCondition => type == BookingErrorType.conflict;

  /// Kiểm tra xem có thể retry không
  bool get isRetryable => canRetry;

  /// Lấy user-friendly message
  String get userMessage {
    switch (type) {
      case BookingErrorType.conflict:
        return 'Ghế bạn chọn vừa được đặt bởi người khác. Vui lòng chọn ghế khác hoặc thử lại.';
      
      case BookingErrorType.validation:
        return message;
      
      case BookingErrorType.notFound:
        return 'Không tìm thấy lịch trình. Vui lòng kiểm tra lại.';
      
      case BookingErrorType.serverError:
        return 'Lỗi máy chủ. Vui lòng thử lại sau.';
      
      case BookingErrorType.timeout:
        return 'Kết nối timeout. Vui lòng kiểm tra mạng và thử lại.';
      
      case BookingErrorType.network:
        return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.';
      
      case BookingErrorType.parseError:
      case BookingErrorType.invalidResponse:
        return 'Lỗi xử lý dữ liệu. Vui lòng thử lại.';
      
      case BookingErrorType.apiError:
        return message;
      
      case BookingErrorType.unknown:
        return 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }
  }

  /// Lấy action message cho user
  String get actionMessage {
    if (isRaceCondition) {
      return 'Chọn ghế khác';
    }
    
    if (canRetry) {
      return 'Thử lại';
    }
    
    return 'Đóng';
  }

  @override
  String toString() {
    return 'BookingException: $message (type: $type, canRetry: $canRetry)';
  }
}

