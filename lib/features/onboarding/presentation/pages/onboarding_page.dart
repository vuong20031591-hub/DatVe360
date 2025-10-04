import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/models/onboarding_data.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_screen.dart';
import '../widgets/page_indicator.dart';

/// Main onboarding page with PageView
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<OnboardingData> _screens = OnboardingData.screens;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Skip button
              _buildTopBar(theme, isTablet),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    ref.read(onboardingProvider.notifier).updatePage(index);
                  },
                  itemCount: _screens.length,
                  itemBuilder: (context, index) {
                    return OnboardingScreen(
                      data: _screens[index],
                      isLastScreen: index == _screens.length - 1,
                    );
                  },
                ),
              ),

              // Bottom section with indicator and buttons
              _buildBottomSection(onboardingState, theme, isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme, bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/logo_datve360.svg',
                height: isTablet ? 32 : 28,
                width: isTablet ? 32 : 28,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF2563EB),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'DatVe360',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2563EB),
                  fontSize: isTablet ? 24 : 20,
                ),
              ),
            ],
          ),

          // Skip button
          TextButton(
            onPressed: _skipOnboarding,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6B7280),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 20 : 16,
                vertical: isTablet ? 12 : 8,
              ),
            ),
            child: Text(
              'Bỏ qua',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(
    OnboardingState state,
    ThemeData theme,
    bool isTablet,
  ) {
    final isLastScreen = state.currentPage == _screens.length - 1;

    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      child: Column(
        children: [
          // Page indicator
          PageIndicator(
            currentPage: state.currentPage,
            totalPages: _screens.length,
            activeColor: const Color(0xFF2563EB),
            size: isTablet ? 10 : 8,
            spacing: isTablet ? 12 : 8,
          ),

          SizedBox(height: isTablet ? 40 : 32),

          // Action buttons
          Row(
            children: [
              // Previous button (only show if not first screen)
              if (state.currentPage > 0) ...[
                Expanded(
                  child: AppButton(
                    text: 'Quay lại',
                    onPressed: _previousPage,
                    type: AppButtonType.outline,
                    isLoading: false,
                  ),
                ),
                SizedBox(width: isTablet ? 20 : 16),
              ],

              // Next/Done button
              Expanded(
                flex: state.currentPage > 0 ? 1 : 2,
                child: AppButton(
                  text: isLastScreen ? 'Bắt đầu ngay' : 'Tiếp theo',
                  onPressed: isLastScreen ? _completeOnboarding : _nextPage,
                  isLoading: state.isLoading,
                  icon: isLastScreen ? Icons.arrow_forward : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: AppConstants.mediumAnimation,
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_pageController.hasClients) {
      _pageController.previousPage(
        duration: AppConstants.mediumAnimation,
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() async {
    await ref.read(onboardingProvider.notifier).skipOnboarding();
    if (mounted) {
      context.go('/login');
    }
  }

  void _completeOnboarding() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go('/login');
    }
  }
}
