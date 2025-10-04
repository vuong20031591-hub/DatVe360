import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/enums/user_role.dart';
import '../../../auth/data/models/user.dart';
import '../../domain/enums/management_section.dart';

class AdminDrawer extends ConsumerWidget {
  final ManagementSection currentSection;
  final Function(ManagementSection) onSectionSelected;
  final User user;

  const AdminDrawer({
    super.key,
    required this.currentSection,
    required this.onSectionSelected,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final List<ManagementSection> sections = [
      ManagementSection.dashboard,
      ManagementSection.destinations,
      ManagementSection.categories,
      ManagementSection.tickets,
      ManagementSection.users,
      ManagementSection.bookings,
      ManagementSection.payments,
      ManagementSection.reports,
      ManagementSection.settings,
    ];

    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryColor,
                  theme.primaryColor.withOpacity(0.8),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage: user.avatar != null
                          ? NetworkImage(user.avatar!)
                          : null,
                      child: user.avatar == null
                          ? const Icon(
                              Icons.admin_panel_settings,
                              size: 20,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user.displayName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user.role.toUserRole.displayName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Admin sections
                ...sections.map((section) {
                  final isSelected = section == currentSection;
                  return ListTile(
                    leading: Icon(
                      _getIconForSection(section),
                      color: isSelected ? theme.primaryColor : null,
                    ),
                    title: Text(
                      section.vietnameseName,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? theme.primaryColor : null,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: theme.primaryColor.withOpacity(0.1),
                    onTap: () => onSectionSelected(section),
                  );
                }).toList(),
              ],
            ),
          ),

          // Footer
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text('Phiên bản ${AppConstants.appVersion}'),
            dense: true,
          ),

          // Back to User View
          ListTile(
            leading: const Icon(Icons.home, color: Colors.green),
            title: const Text(
              'Quay lại trang người dùng',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            dense: true,
            onTap: () {
              // Close drawer first
              Navigator.of(context).pop();
              // Then navigate to home
              Future.delayed(const Duration(milliseconds: 100), () {
                if (context.mounted) {
                  context.go('/');
                }
              });
            },
          ),
        ],
      ),
    );
  }

  IconData _getIconForSection(ManagementSection section) {
    switch (section) {
      case ManagementSection.dashboard:
        return Icons.dashboard;
      case ManagementSection.destinations:
        return Icons.location_on;
      case ManagementSection.categories:
        return Icons.category;
      case ManagementSection.tickets:
        return Icons.confirmation_number;
      case ManagementSection.users:
        return Icons.people;
      case ManagementSection.bookings:
        return Icons.book_online;
      case ManagementSection.payments:
        return Icons.payment;
      case ManagementSection.reports:
        return Icons.analytics;
      case ManagementSection.settings:
        return Icons.settings;
    }
  }
}

