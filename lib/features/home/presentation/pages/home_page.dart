import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/l10n.dart';
import '../../../../core/providers/locale_provider.dart';
import '../widgets/home_header.dart';
import '../widgets/popular_destinations_section.dart';
import '../widgets/featured_services_section.dart';
import '../widgets/special_offers_section.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final localizations = ref.watch(localizationsProvider(locale));

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header với greeting và logo
            const SliverToBoxAdapter(
              child: HomeHeader(),
            ),

            // Popular Destinations Section
            const SliverToBoxAdapter(
              child: PopularDestinationsSection(),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),

            // Featured Services Section
            const SliverToBoxAdapter(
              child: FeaturedServicesSection(),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),

            // Special Offers Section
            const SliverToBoxAdapter(
              child: SpecialOffersSection(),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),

            // Popular Destinations
            SliverToBoxAdapter(
              child: _buildPopularDestinations(context, theme),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularDestinations(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Điểm đến phổ biến',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.go('/search');
                },
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _getPopularDestinations().length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final destination = _getPopularDestinations()[index];
              return _buildDestinationCard(destination, theme);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationCard(Map<String, String> destination, ThemeData theme) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(destination['image']!),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              destination['name']!,
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Từ ${destination['price']}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _getPopularDestinations() {
    return [
      {
        'name': 'Hồ Chí Minh',
        'price': '1.200.000đ',
        'image': 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=400&h=300&fit=crop',
      },
      {
        'name': 'Đà Nẵng',
        'price': '800.000đ',
        'image': 'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=400&h=300&fit=crop',
      },
      {
        'name': 'Nha Trang',
        'price': '900.000đ',
        'image': 'https://images.unsplash.com/photo-1539650116574-75c0c6d73f6e?w=400&h=300&fit=crop',
      },
      {
        'name': 'Phú Quốc',
        'price': '1.500.000đ',
        'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
      },
    ];
  }
}
