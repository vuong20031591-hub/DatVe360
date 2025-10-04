import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/onboarding_data.dart';
import 'three_d_svg_container.dart';

/// Individual onboarding screen widget
class OnboardingScreen extends StatelessWidget {
  final OnboardingData data;
  final bool isLastScreen;

  const OnboardingScreen({
    super.key,
    required this.data,
    this.isLastScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet
            ? screenSize.width * 0.15
            : AppConstants.largePadding,
        vertical: AppConstants.largePadding,
      ),
      child: Column(
        children: [
          // Spacer to push content to center
          const Spacer(flex: 1),

          // Main illustration
          _buildIllustration(context, screenSize),

          SizedBox(height: isTablet ? 60 : 40),

          // Title
          _buildTitle(theme, isTablet),

          SizedBox(height: isTablet ? 24 : 16),

          // Subtitle
          _buildSubtitle(theme, isTablet),

          // Spacer to balance layout
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget _buildIllustration(BuildContext context, Size screenSize) {
    final illustrationSize = screenSize.width > 600
        ? screenSize.width * 0.5
        : screenSize.width * 0.7;

    return SizedBox(
      width: illustrationSize,
      height: illustrationSize,
      child: data.lottieAsset != null
          ? _buildLottieAnimation()
          : _buildRealIllustration(context),
    );
  }

  Widget _buildLottieAnimation() {
    return Lottie.asset(
      data.lottieAsset!,
      fit: BoxFit.contain,
      repeat: true,
      animate: true,
      errorBuilder: (context, error, stackTrace) {
        return _buildRealIllustration(context);
      },
    );
  }

  Widget _buildRealIllustration(BuildContext context) {
    // Get the appropriate SVG illustration based on the screen title
    String svgAsset;
    bool enableInteraction = false;
    double maxRotationX = 0.1;
    double maxRotationY = 0.05;

    switch (data.title) {
      case 'Đặt vé dễ dàng':
        svgAsset = 'assets/images/onboarding_booking.svg';
        enableInteraction = true;
        maxRotationX = 0.15;
        maxRotationY = 0.08;
        break;
      case 'Thanh toán an toàn':
        svgAsset = 'assets/images/onboarding_payment.svg';
        enableInteraction = true;
        maxRotationX = 0.12;
        maxRotationY = 0.06;
        break;
      case 'Vé điện tử tiện lợi':
        svgAsset = 'assets/images/onboarding_eticket.svg';
        enableInteraction = true;
        maxRotationX = 0.1;
        maxRotationY = 0.05;
        break;
      default:
        svgAsset = 'assets/images/onboarding_booking.svg';
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius * 2),
      ),
      child: ThreeDSvgContainer(
        svgAsset: svgAsset,
        enableFloating: true,
        enablePerspective: true,
        enableInteraction: enableInteraction,
        maxRotationX: maxRotationX,
        maxRotationY: maxRotationY,
        animationDuration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme, bool isTablet) {
    return Text(
      data.title,
      textAlign: TextAlign.center,
      style: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: isTablet ? 32 : 28,
        color: const Color(0xFF111827),
        height: 1.2,
      ),
    );
  }

  Widget _buildSubtitle(ThemeData theme, bool isTablet) {
    return Text(
      data.subtitle,
      textAlign: TextAlign.center,
      style: theme.textTheme.bodyLarge?.copyWith(
        fontSize: isTablet ? 18 : 16,
        color: const Color(0xFF6B7280),
        height: 1.5,
      ),
    );
  }
}
