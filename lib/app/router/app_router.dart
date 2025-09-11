import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/search/presentation/pages/home_search_page.dart';
import '../../features/results/presentation/pages/results_page.dart';
import '../../features/trip_detail/presentation/pages/trip_detail_page.dart';
import '../../features/booking/presentation/pages/booking_page.dart';
import '../../features/manage/presentation/pages/manage_booking_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/tickets/presentation/pages/ticket_page.dart';

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
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return ResultsPage(
                searchQuery: extra?['searchQuery'],
              );
            },
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
          return TripDetailPage(tripId: tripId);
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
    ],
    errorBuilder: (context, state) => ErrorPage(error: state.error),
  );

  static GoRouter get router => _router;
}

/// Main shell with bottom navigation
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.child});
  
  final Widget child;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
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
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Tìm kiếm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Kết quả',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
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
      appBar: AppBar(
        title: const Text('Lỗi'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
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
