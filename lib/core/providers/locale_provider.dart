import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/settings_service.dart';
import 'theme_provider.dart';

class LocaleNotifier extends Notifier<Locale> {
  late SettingsService _settingsService;

  @override
  Locale build() {
    _settingsService = ref.read(settingsServiceProvider);
    return _settingsService.locale;
  }

  Future<void> setLocale(Locale locale) async {
    await _settingsService.setLocale(locale);
    state = locale;
  }

  Future<void> toggleLanguage() async {
    final newLocale = state.languageCode == 'vi'
        ? const Locale('en', 'US')
        : const Locale('vi', 'VN');
    await setLocale(newLocale);
  }

  bool get isVietnamese => state.languageCode == 'vi';
  bool get isEnglish => state.languageCode == 'en';

  String get currentLanguageName => isVietnamese ? 'Tiếng Việt' : 'English';
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(() {
  return LocaleNotifier();
});

// Supported locales
final supportedLocalesProvider = Provider<List<Locale>>((ref) {
  return const [Locale('vi', 'VN'), Locale('en', 'US')];
});

// Localization strings (simple implementation)
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  bool get isVietnamese => locale.languageCode == 'vi';

  // Common strings
  String get appName => 'DatVe360';
  String get welcome => isVietnamese ? 'Chào mừng' : 'Welcome';
  String get login => isVietnamese ? 'Đăng nhập' : 'Login';
  String get register => isVietnamese ? 'Đăng ký' : 'Register';
  String get logout => isVietnamese ? 'Đăng xuất' : 'Logout';
  String get cancel => isVietnamese ? 'Hủy' : 'Cancel';
  String get confirm => isVietnamese ? 'Xác nhận' : 'Confirm';
  String get save => isVietnamese ? 'Lưu' : 'Save';
  String get settings => isVietnamese ? 'Cài đặt' : 'Settings';

  // Theme strings
  String get theme => isVietnamese ? 'Giao diện' : 'Theme';
  String get lightMode => isVietnamese ? 'Sáng' : 'Light';
  String get darkMode => isVietnamese ? 'Tối' : 'Dark';
  String get systemMode => isVietnamese ? 'Theo hệ thống' : 'System';

  // Language strings
  String get language => isVietnamese ? 'Ngôn ngữ' : 'Language';
  String get vietnamese => isVietnamese ? 'Tiếng Việt' : 'Vietnamese';
  String get english => isVietnamese ? 'Tiếng Anh' : 'English';

  // Navigation strings
  String get home => isVietnamese ? 'Trang chủ' : 'Home';
  String get search => isVietnamese ? 'Tìm kiếm' : 'Search';
  String get bookings => isVietnamese ? 'Đặt chỗ' : 'Bookings';
  String get tickets => isVietnamese ? 'Vé' : 'Tickets';
  String get profile => isVietnamese ? 'Tài khoản' : 'Profile';

  // Auth strings
  String get welcomeBack =>
      isVietnamese ? 'Chào mừng trở lại!' : 'Welcome back!';
  String get loginToContinue => isVietnamese
      ? 'Đăng nhập để tiếp tục sử dụng DatVe360'
      : 'Login to continue using DatVe360';
  String get email => isVietnamese ? 'Email' : 'Email';
  String get password => isVietnamese ? 'Mật khẩu' : 'Password';
  String get forgotPassword =>
      isVietnamese ? 'Quên mật khẩu?' : 'Forgot password?';
  String get rememberMe => isVietnamese ? 'Ghi nhớ đăng nhập' : 'Remember me';
  String get dontHaveAccount =>
      isVietnamese ? 'Chưa có tài khoản?' : "Don't have an account?";
  String get registerNow => isVietnamese ? 'Đăng ký ngay' : 'Register now';
  String get createAccount =>
      isVietnamese ? 'Tạo tài khoản mới' : 'Create new account';
  String get joinDatVe360 => isVietnamese
      ? 'Tham gia DatVe360 để đặt vé dễ dàng'
      : 'Join DatVe360 for easy ticket booking';
  String get fullName => isVietnamese ? 'Họ và tên' : 'Full name';
  String get phoneNumber => isVietnamese ? 'Số điện thoại' : 'Phone number';
  String get confirmPassword =>
      isVietnamese ? 'Xác nhận mật khẩu' : 'Confirm password';
  String get agreeToTerms => isVietnamese
      ? 'Tôi đồng ý với điều khoản sử dụng'
      : 'I agree to the terms of service';
  String get alreadyHaveAccount =>
      isVietnamese ? 'Đã có tài khoản?' : 'Already have an account?';
  String get loginNow => isVietnamese ? 'Đăng nhập ngay' : 'Login now';
  String get resetPassword =>
      isVietnamese ? 'Đặt lại mật khẩu' : 'Reset password';
  String get enterEmailToReset => isVietnamese
      ? 'Nhập email của bạn để nhận hướng dẫn đặt lại mật khẩu'
      : 'Enter your email to receive password reset instructions';
  String get sendInstructions =>
      isVietnamese ? 'Gửi hướng dẫn' : 'Send instructions';
  String get emailSent => isVietnamese ? 'Email đã được gửi!' : 'Email sent!';
  String get checkEmailForInstructions => isVietnamese
      ? 'Kiểm tra hộp thư của bạn và làm theo hướng dẫn để đặt lại mật khẩu.'
      : 'Check your inbox and follow the instructions to reset your password.';
  String get resendEmail => isVietnamese ? 'Gửi lại email' : 'Resend email';
  String get rememberPassword =>
      isVietnamese ? 'Nhớ mật khẩu?' : 'Remember password?';

  // Settings strings
  String get appearance => isVietnamese ? 'Giao diện' : 'Appearance';
  String get languageAndRegion =>
      isVietnamese ? 'Ngôn ngữ & Khu vực' : 'Language & Region';
  String get notifications => isVietnamese ? 'Thông báo' : 'Notifications';
  String get privacy => isVietnamese ? 'Quyền riêng tư' : 'Privacy';
  String get about => isVietnamese ? 'Về ứng dụng' : 'About';

  // Profile strings
  String get guest => isVietnamese ? 'Khách hàng' : 'Guest';
  String get bookingAndManagement =>
      isVietnamese ? 'Đặt vé & Quản lý' : 'Booking & Management';
  String get searchHistory =>
      isVietnamese ? 'Lịch sử tìm kiếm' : 'Search History';
  String get viewRecentSearches =>
      isVietnamese ? 'Xem các tìm kiếm gần đây' : 'View recent searches';
  String get myBookings => isVietnamese ? 'Đặt chỗ của tôi' : 'My Bookings';
  String get manageBookings =>
      isVietnamese ? 'Quản lý đặt chỗ và vé' : 'Manage bookings and tickets';
  String get myTickets => isVietnamese ? 'Vé của tôi' : 'My Tickets';
  String get viewDownloadTickets =>
      isVietnamese ? 'Xem và tải vé' : 'View and download tickets';
  String get support => isVietnamese ? 'Hỗ trợ' : 'Support';
  String get faq => isVietnamese ? 'Câu hỏi thường gặp' : 'FAQ';
  String get faqAndGuide =>
      isVietnamese ? 'FAQ và hướng dẫn sử dụng' : 'FAQ and user guide';
  String get contactSupport =>
      isVietnamese ? 'Liên hệ hỗ trợ' : 'Contact Support';
  String get chatOrCallSupport =>
      isVietnamese ? 'Chat hoặc gọi điện hỗ trợ' : 'Chat or call support';
  String get termsAndPolicy =>
      isVietnamese ? 'Điều khoản & Chính sách' : 'Terms & Policy';
  String get serviceUsagePolicy =>
      isVietnamese ? 'Quy định sử dụng dịch vụ' : 'Service usage policy';
  String get aboutDatVe360 => isVietnamese ? 'Về DatVe360' : 'About DatVe360';
  String get version => isVietnamese ? 'Phiên bản' : 'Version';
  String get confirmLogout =>
      isVietnamese ? 'Xác nhận đăng xuất' : 'Confirm Logout';
  String get areYouSureLogout => isVietnamese
      ? 'Bạn có chắc chắn muốn đăng xuất?'
      : 'Are you sure you want to logout?';

  // Additional strings for remaining pages
  String get clearAll => isVietnamese ? 'Xóa tất cả' : 'Clear all';
  String get noRecentSearches =>
      isVietnamese ? 'Chưa có tìm kiếm nào' : 'No recent searches';
  String get recentSearches =>
      isVietnamese ? 'Tìm kiếm gần đây' : 'Recent Searches';
  String get favorites => isVietnamese ? 'Yêu thích' : 'Favorites';
  String get trips => isVietnamese ? 'Chuyến đi' : 'Trips';
  String get destinations => isVietnamese ? 'Điểm đến' : 'Destinations';

  // Home page strings
  String get popularDestinations =>
      isVietnamese ? 'Điểm đến phổ biến' : 'Popular Destinations';
  String get specialOffers =>
      isVietnamese ? 'Ưu đãi đặc biệt' : 'Special Offers';
  String get featuredServices =>
      isVietnamese ? 'Dịch vụ nổi bật' : 'Featured Services';
  String get firstTripDiscount => isVietnamese
      ? 'Giảm 20% cho chuyến đi đầu tiên'
      : '20% off your first trip';
  String get useCode =>
      isVietnamese ? 'Sử dụng mã: DATVE360' : 'Use code: DATVE360';

  // Service strings
  String get quickBooking => isVietnamese ? 'Đặt vé nhanh' : 'Quick Booking';
  String get quickBookingDesc =>
      isVietnamese ? 'Chỉ 3 bước đơn giản' : 'Just 3 simple steps';
  String get support247 => isVietnamese ? 'Hỗ trợ 24/7' : '24/7 Support';
  String get support247Desc =>
      isVietnamese ? 'Luôn sẵn sàng hỗ trợ' : 'Always ready to help';
  String get securePayment =>
      isVietnamese ? 'Thanh toán an toàn' : 'Secure Payment';
  String get securePaymentDesc =>
      isVietnamese ? 'Bảo mật tuyệt đối' : 'Absolute security';
  String get easyRefund => isVietnamese ? 'Hoàn tiền dễ dàng' : 'Easy Refund';
  String get easyRefundDesc =>
      isVietnamese ? 'Chính sách linh hoạt' : 'Flexible policy';

  // Search history strings
  String get noSearchHistory =>
      isVietnamese ? 'Chưa có lịch sử tìm kiếm' : 'No search history';
  String get searchHistoryDesc => isVietnamese
      ? 'Các tìm kiếm của bạn sẽ xuất hiện ở đây'
      : 'Your searches will appear here';
  String get startSearching =>
      isVietnamese ? 'Bắt đầu tìm kiếm' : 'Start searching';
}

final localizationsProvider = Provider.family<AppLocalizations, Locale>((
  ref,
  locale,
) {
  return AppLocalizations(locale);
});
