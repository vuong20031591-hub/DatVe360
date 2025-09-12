/// App-wide constants
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'DatVe360';
  static const String appVersion = '1.0.0';

  // API
  static const String baseUrl = 'http://localhost:5000/api/v1';
  static const String prodBaseUrl = 'https://api.datve360.com/v1';
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration cacheTimeout = Duration(minutes: 5);

  // Storage keys
  static const String themeKey = 'theme_mode';
  static const String localeKey = 'locale';
  static const String searchHistoryKey = 'search_history';
  static const String lastUsedPaymentKey = 'last_used_payment';

  // Hive boxes
  static const String bookingsBox = 'bookings';
  static const String ticketsBox = 'tickets';
  static const String cacheBox = 'cache';
  static const String searchCacheBox = 'search_cache';
  static const String destinationsCacheBox = 'destinations_cache';
  static const String airportsCacheBox = 'airports_cache';

  // Cache settings
  static const Duration searchCacheExpiry = Duration(hours: 2);
  static const Duration destinationsCacheExpiry = Duration(days: 7);
  static const Duration airportsCacheExpiry = Duration(days: 30);
  static const int maxCacheSize = 100; // Maximum cached items per type

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxSearchHistory = 10;

  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  static const double minTouchTarget = 44.0;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Seat map
  static const int seatMapRows = 10;
  static const int seatMapCols = 8;
  static const double seatSize = 32.0;
  static const double seatSpacing = 4.0;

  // Payment
  static const String sandboxPaymentUrl = 'https://sandbox.payment.com/pay';

  // Firebase
  static const String fcmTopic = 'datve360_notifications';

  // Validation
  static const int minPassengerAge = 0;
  static const int maxPassengerAge = 120;
  static const int maxPassengers = 9;
  static const int minBookingIdLength = 6;
  static const int maxBookingIdLength = 10;

  // File paths
  static const String ticketPdfPath = '/tickets/';
  static const String qrCodePath = '/qr_codes/';
}

/// Transport mode enum
enum TransportMode {
  flight('flight', 'Máy bay'),
  train('train', 'Tàu hỏa'),
  bus('bus', 'Xe khách'),
  ferry('ferry', 'Phà');

  const TransportMode(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// Passenger type enum
enum PassengerType {
  adult('adult', 'Người lớn'),
  child('child', 'Trẻ em'),
  infant('infant', 'Em bé');

  const PassengerType(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// Booking status enum
enum BookingStatus {
  pending('pending', 'Đang xử lý'),
  confirmed('confirmed', 'Đã xác nhận'),
  cancelled('cancelled', 'Đã hủy'),
  completed('completed', 'Hoàn thành');

  const BookingStatus(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// Seat status enum
enum SeatStatus {
  available('available', 'Trống'),
  booked('booked', 'Đã đặt'),
  selected('selected', 'Đang chọn'),
  held('held', 'Đang giữ');

  const SeatStatus(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// Payment method enum
enum PaymentMethod {
  vnpay('vnpay', 'VNPay'),
  momo('momo', 'MoMo'),
  stripe('stripe', 'Thẻ tín dụng');

  const PaymentMethod(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// Payment status enum
enum PaymentStatus {
  pending('pending', 'Đang xử lý'),
  completed('completed', 'Thành công'),
  failed('failed', 'Thất bại'),
  cancelled('cancelled', 'Đã hủy');

  const PaymentStatus(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// Seat type enum
enum SeatType {
  standard('standard', 'Ghế thường'),
  premium('premium', 'Ghế cao cấp'),
  exit('exit', 'Ghế lối thoát'),
  window('window', 'Ghế cửa sổ'),
  aisle('aisle', 'Ghế lối đi');

  const SeatType(this.value, this.displayName);
  final String value;
  final String displayName;
}
