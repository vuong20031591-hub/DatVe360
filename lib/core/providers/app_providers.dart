import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../../features/search/data/repositories/search_repository.dart';
import '../../features/results/data/repositories/trip_repository.dart';
import '../../features/booking/data/repositories/booking_repository.dart';
import '../../features/tickets/data/repositories/ticket_repository.dart';

// Core providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient.instance;
});

// Repository providers
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return SearchRepository(dioClient);
});

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return TripRepository(dioClient);
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return BookingRepository(dioClient);
});

final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return TicketRepository(dioClient);
});

// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;
  static const String _key = 'theme_mode';

  ThemeNotifier(this._prefs) : super(_loadTheme(_prefs));

  static ThemeMode _loadTheme(SharedPreferences prefs) {
    final themeIndex = prefs.getInt(_key) ?? 0;
    return ThemeMode.values[themeIndex];
  }

  void setTheme(ThemeMode theme) {
    state = theme;
    _prefs.setInt(_key, theme.index);
  }

  void toggleTheme() {
    switch (state) {
      case ThemeMode.light:
        setTheme(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        setTheme(ThemeMode.system);
        break;
      case ThemeMode.system:
        setTheme(ThemeMode.light);
        break;
    }
  }
}

// Locale provider
final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

class LocaleNotifier extends StateNotifier<String> {
  final SharedPreferences _prefs;
  static const String _key = 'locale';

  LocaleNotifier(this._prefs) : super(_loadLocale(_prefs));

  static String _loadLocale(SharedPreferences prefs) {
    return prefs.getString(_key) ?? 'vi';
  }

  void setLocale(String locale) {
    state = locale;
    _prefs.setString(_key, locale);
  }
}

// Loading state provider
final loadingProvider = StateProvider<bool>((ref) => false);

// Error provider
final errorProvider = StateProvider<String?>((ref) => null);

// Network connectivity provider
final connectivityProvider = StateProvider<bool>((ref) => true);

// Search history provider
final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SearchHistoryNotifier(prefs);
});

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  final SharedPreferences _prefs;
  static const String _key = 'search_history';
  static const int _maxHistory = 10;

  SearchHistoryNotifier(this._prefs) : super(_loadHistory(_prefs));

  static List<String> _loadHistory(SharedPreferences prefs) {
    return prefs.getStringList(_key) ?? [];
  }

  void addSearch(String query) {
    final history = List<String>.from(state);
    
    // Remove if already exists
    history.remove(query);
    
    // Add to beginning
    history.insert(0, query);
    
    // Limit size
    if (history.length > _maxHistory) {
      history.removeRange(_maxHistory, history.length);
    }
    
    state = history;
    _prefs.setStringList(_key, history);
  }

  void removeSearch(String query) {
    final history = List<String>.from(state);
    history.remove(query);
    state = history;
    _prefs.setStringList(_key, history);
  }

  void clearHistory() {
    state = [];
    _prefs.remove(_key);
  }
}
