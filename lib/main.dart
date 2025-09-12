import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/router/app_router.dart';
import 'core/providers/app_providers.dart';
import 'core/providers/theme_provider.dart' as theme_providers;
import 'core/providers/locale_provider.dart' as locale_providers;
import 'core/services/settings_service.dart';
import 'core/services/cache_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/storage/storage_service.dart';
import 'core/constants/app_constants.dart';
import 'core/i18n/l10n.dart' as app_l10n;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Open Hive boxes
  await Hive.openBox(AppConstants.bookingsBox);
  await Hive.openBox(AppConstants.ticketsBox);

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize Settings Service
  final settingsService = SettingsService();
  await settingsService.init();

  // Initialize Cache Service
  final cacheService = CacheService.instance;
  await cacheService.init();

  // Initialize Connectivity Service
  final connectivityService = ConnectivityService.instance;
  await connectivityService.init();

  // Initialize Storage Service
  final storageService = StorageService.instance;
  await storageService.init();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        theme_providers.settingsServiceProvider.overrideWithValue(
          settingsService,
        ),
      ],
      child: const DatVe360App(),
    ),
  );
}

class DatVe360App extends ConsumerWidget {
  const DatVe360App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(theme_providers.themeProvider);
    final locale = ref.watch(locale_providers.localeProvider);
    final lightTheme = ref.watch(theme_providers.lightThemeProvider);
    final darkTheme = ref.watch(theme_providers.darkThemeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Theme
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,

      // Localization
      locale: locale,
      supportedLocales: const [
        Locale('vi', 'VN'), // Vietnamese
        Locale('en', 'US'), // English
      ],
      localizationsDelegates: [
        app_l10n.AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Router
      routerConfig: AppRouter.router,
    );
  }
}
