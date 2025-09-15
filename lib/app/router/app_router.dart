import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/offline_banner.dart';
import '../../features/search/presentation/pages/home_search_page.dart';
import '../../features/search/presentation/pages/search_history_page.dart';
import '../../features/results/presentation/pages/results_page.dart';
import '../../features/trip_detail/presentation/pages/trip_detail_page.dart';
import '../../features/booking/presentation/pages/booking_page.dart';
import '../../features/booking/presentation/pages/manage_booking_page.dart';
import '../../features/manage/presentation/pages/manage_booking_page.dart'
    as manage;
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/tickets/presentation/pages/ticket_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/support/presentation/pages/faq_page.dart';
import '../../features/support/presentation/pages/contact_support_page.dart';
import '../../features/support/presentation/pages/terms_policy_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../core/providers/locale_provider.dart';

/// App router configuration using GoRouter
class AppRouter {
  AppRouter._();

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      // Bottom navigation shell
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          // Home/Search page
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeSearchPage(),
          ),

          // Results page
          GoRoute(
            path: '/results',
            name: 'results',
            builder: (context, state) => const ResultsPage(),
          ),

          // Profile page
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),

      // Trip detail page
      GoRoute(
        path: '/trip/:tripId',
        name: 'tripDetail',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          final extra = state.extra as Map<String, dynamic>?;
          return TripDetailPage(tripId: tripId, schedule: extra?['schedule']);
        },
      ),

      // Booking flow
      GoRoute(
        path: '/booking',
        name: 'booking',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return BookingPage(
            trip: extra?['trip'],
            selectedSeats: extra?['selectedSeats'],
            selectedSeatData: extra?['selectedSeatData'],
            selectedClass: extra?['selectedClass'],
          );
        },
      ),

      // Manage booking
      GoRoute(
        path: '/manage',
        name: 'manage',
        builder: (context, state) => const ManageBookingPage(),
      ),

      // Ticket page
      GoRoute(
        path: '/ticket/:bookingId',
        name: 'ticket',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return TicketPage(bookingId: bookingId);
        },
      ),

      // Search history
      GoRoute(
        path: '/search-history',
        name: 'searchHistory',
        builder: (context, state) => const SearchHistoryPage(),
      ),

      // Favorites
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) => const FavoritesPage(),
      ),

      // Notifications
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),

      // FAQ
      GoRoute(
        path: '/faq',
        name: 'faq',
        builder: (context, state) => const FAQPage(),
      ),

      // Contact Support
      GoRoute(
        path: '/contact-support',
        name: 'contactSupport',
        builder: (context, state) => const ContactSupportPage(),
      ),

      // Terms & Policy
      GoRoute(
        path: '/terms-policy',
        name: 'termsPolicy',
        builder: (context, state) => const TermsPolicyPage(),
      ),

      // Authentication routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => AppErrorPage(error: state.error),
  );

  static GoRouter get router => _router;
}

/// Main shell with bottom navigation
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Get bottom navigation index from current location
  int _getIndexFromLocation(String location) {
    switch (location) {
      case '/':
        return 0; // Home/Search
      case '/results':
        return 1; // Results
      case '/profile':
        return 2; // Profile
      default:
        return 0; // Default to Home
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final localizations = ref.watch(localizationsProvider(locale));

    // Sync bottom navigation with current route
    final currentLocation = GoRouterState.of(context).uri.path;
    final currentIndex = _getIndexFromLocation(currentLocation);
    if (_currentIndex != currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _currentIndex = currentIndex;
          });
        }
      });
    }

    return Scaffold(
      body: OfflineBanner(child: widget.child),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            if (_currentIndex != index) {
              // Haptic feedback
              HapticFeedback.lightImpact();

              _animationController.forward().then((_) {
                setState(() {
                  _currentIndex = index;
                });

                switch (index) {
                  case 0:
                    context.go('/');
                    break;
                  case 1:
                    context.go('/results');
                    break;
                  case 2:
                    context.go('/profile');
                    break;
                }

                _animationController.reverse();
              });
            }
          },
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          indicatorColor: theme.colorScheme.primaryContainer,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.search_outlined, size: 24),
              selectedIcon: Icon(
                Icons.search,
                size: 24,
                color: theme.colorScheme.primary,
              ),
              label: localizations.search,
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible:
                    false, // TODO: Show badge when there are results
                child: Icon(Icons.flight_outlined, size: 24),
              ),
              selectedIcon: Icon(
                Icons.flight,
                size: 24,
                color: theme.colorScheme.primary,
              ),
              label: locale.languageCode == 'vi' ? 'Chuyến bay' : 'Flights',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, size: 24),
              selectedIcon: Icon(
                Icons.person,
                size: 24,
                color: theme.colorScheme.primary,
              ),
              label: localizations.profile,
            ),
          ],
        ),
      ),
    );
  }
}

/// Error page
class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lỗi')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Đã xảy ra lỗi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Lỗi không xác định',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error page for routing errors
class AppErrorPage extends StatelessWidget {
  const AppErrorPage({super.key, this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lỗi')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Đã xảy ra lỗi',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Lỗi không xác định',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    );
  }
}
