import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';

class FeaturedServicesSection extends StatelessWidget {
  const FeaturedServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Dịch vụ nổi bật',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: _getFeaturedServices().map((service) {
              return _buildServiceCard(context, service);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(BuildContext context, Map<String, dynamic> service) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        final route = service['route'] as String?;
        if (route != null) {
          context.go(route);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (service['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                service['icon'] as IconData,
                color: service['color'] as Color,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              service['title'] as String,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              service['subtitle'] as String,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFeaturedServices() {
    return [
      {
        'title': 'Quản lý đặt vé',
        'subtitle': 'Xem và quản lý các chuyến đi',
        'icon': Icons.book_online,
        'color': AppColors.flightColor,
        'route': '/manage',
      },
      {
        'title': 'Lịch sử tìm kiếm',
        'subtitle': 'Xem lại các tìm kiếm gần đây',
        'icon': Icons.history,
        'color': AppColors.trainColor,
        'route': '/search-history',
      },
      {
        'title': 'Yêu thích',
        'subtitle': 'Lưu các chuyến đi ưa thích',
        'icon': Icons.favorite,
        'color': Colors.red,
        'route': '/favorites',
      },
      {
        'title': 'Hỗ trợ',
        'subtitle': 'Liên hệ khi cần hỗ trợ',
        'icon': Icons.support_agent,
        'color': AppColors.busColor,
        'route': '/support',
      },
    ];
  }
}
