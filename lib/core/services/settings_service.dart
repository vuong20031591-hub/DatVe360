import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsService {
  static const String _boxName = 'settings';
  static const String _themeKey = 'theme_mode';
  static const String _localeKey = 'locale';
  
  late Box _box;
  
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }
  
  // Theme Mode
  ThemeMode get themeMode {
    final themeString = _box.get(_themeKey, defaultValue: 'system');
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    String themeString;
    switch (mode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      default:
        themeString = 'system';
        break;
    }
    await _box.put(_themeKey, themeString);
  }
  
  // Locale
  Locale get locale {
    final localeString = _box.get(_localeKey, defaultValue: 'vi');
    switch (localeString) {
      case 'en':
        return const Locale('en', 'US');
      default:
        return const Locale('vi', 'VN');
    }
  }
  
  Future<void> setLocale(Locale locale) async {
    await _box.put(_localeKey, locale.languageCode);
  }
  
  // Helper methods
  bool get isDarkMode => themeMode == ThemeMode.dark;
  bool get isLightMode => themeMode == ThemeMode.light;
  bool get isSystemMode => themeMode == ThemeMode.system;
  
  bool get isVietnamese => locale.languageCode == 'vi';
  bool get isEnglish => locale.languageCode == 'en';
  
  // Clear all settings
  Future<void> clearAll() async {
    await _box.clear();
  }
}
