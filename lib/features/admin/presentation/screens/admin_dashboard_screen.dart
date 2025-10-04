import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/enums/user_role.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../../auth/data/models/auth_state.dart';
import '../../domain/enums/management_section.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/dashboard_card.dart';
import 'destinations_management_screen.dart';
import 'users_management_screen.dart';
import 'categories_management_screen.dart';
import 'tickets_management_screen.dart';
import 'bookings_simple_screen.dart';
import 'payments_management_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  ManagementSection _currentSection = ManagementSection.dashboard;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    // Check if user is authenticated and has admin role
    if (authState.status != AuthStatus.authenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = authState.user!;
    
    // Check if user has admin or operator role
    if (!user.role.isOperatorOrAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Truy cập bị từ chối'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Bạn không có quyền truy cập trang này',
                style: TextStyle(fontSize: 18),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentSection.vietnameseName),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: _showProfile,
          ),
        ],
      ),
      drawer: AdminDrawer(
        currentSection: _currentSection,
        onSectionSelected: (section) {
          setState(() {
            _currentSection = section;
          });
          Navigator.of(context).pop();
        },
        user: user,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_currentSection) {
      case ManagementSection.dashboard:
        return _buildDashboard();
      case ManagementSection.destinations:
        return const DestinationsManagementScreen();
      case ManagementSection.categories:
        return const CategoriesManagementScreen();
      case ManagementSection.tickets:
        return const TicketsManagementScreen();
      case ManagementSection.users:
        return const UsersManagementScreen();
      case ManagementSection.bookings:
        return const BookingsSimpleScreen();
      case ManagementSection.payments:
        return const PaymentsManagementScreen();
      case ManagementSection.reports:
        return const ReportsScreen();
      case ManagementSection.settings:
        return const SettingsScreen();
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng quan hệ thống',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              DashboardCard(
                title: 'Tổng người dùng',
                value: '1,234',
                icon: Icons.people,
                color: Colors.blue,
                onTap: () {
                  setState(() {
                    _currentSection = ManagementSection.users;
                  });
                },
              ),
              DashboardCard(
                title: 'Tổng vé',
                value: '5,678',
                icon: Icons.confirmation_number,
                color: Colors.green,
                onTap: () {
                  setState(() {
                    _currentSection = ManagementSection.tickets;
                  });
                },
              ),
              DashboardCard(
                title: 'Đặt vé hôm nay',
                value: '89',
                icon: Icons.today,
                color: Colors.orange,
                onTap: () {
                  setState(() {
                    _currentSection = ManagementSection.bookings;
                  });
                },
              ),
              DashboardCard(
                title: 'Doanh thu',
                value: '₫12.5M',
                icon: Icons.attach_money,
                color: Colors.purple,
                onTap: () {
                  setState(() {
                    _currentSection = ManagementSection.payments;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Tính năng đang được phát triển',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _showProfile() {
    final user = ref.read(authProvider).user!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông tin tài khoản'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tên: ${user.displayName}'),
            Text('Email: ${user.email}'),
            Text('Vai trò: ${user.role.toUserRole.displayName}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showLogoutConfirmation();
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).logout();
              context.go('/');
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}

