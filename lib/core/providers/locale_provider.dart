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
  return const [
    Locale('vi', 'VN'),
    Locale('en', 'US'),
  ];
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
  String get welcomeBack => isVietnamese ? 'Chào mừng trở lại!' : 'Welcome back!';
  String get loginToContinue => isVietnamese ? 'Đăng nhập để tiếp tục sử dụng DatVe360' : 'Login to continue using DatVe360';
  String get email => isVietnamese ? 'Email' : 'Email';
  String get password => isVietnamese ? 'Mật khẩu' : 'Password';
  String get forgotPassword => isVietnamese ? 'Quên mật khẩu?' : 'Forgot password?';
  String get rememberMe => isVietnamese ? 'Ghi nhớ đăng nhập' : 'Remember me';
  String get dontHaveAccount => isVietnamese ? 'Chưa có tài khoản?' : "Don't have an account?";
  String get registerNow => isVietnamese ? 'Đăng ký ngay' : 'Register now';
  
  // Settings strings
  String get appearance => isVietnamese ? 'Giao diện' : 'Appearance';
  String get languageAndRegion => isVietnamese ? 'Ngôn ngữ & Khu vực' : 'Language & Region';
  String get notifications => isVietnamese ? 'Thông báo' : 'Notifications';
  String get privacy => isVietnamese ? 'Quyền riêng tư' : 'Privacy';
  String get about => isVietnamese ? 'Về ứng dụng' : 'About';
}

final localizationsProvider = Provider.family<AppLocalizations, Locale>((ref, locale) {
  return AppLocalizations(locale);
});
