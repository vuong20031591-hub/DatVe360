import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

/// Page indicator widget for onboarding screens
class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Color? activeColor;
  final Color? inactiveColor;
  final double size;
  final double spacing;

  const PageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.activeColor,
    this.inactiveColor,
    this.size = 8.0,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeIndicatorColor = activeColor ?? theme.colorScheme.primary;
    final inactiveIndicatorColor = inactiveColor ?? theme.colorScheme.primary.withValues(alpha: 0.3);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: AppConstants.shortAnimation,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: currentPage == index ? size * 2.5 : size,
          height: size,
          decoration: BoxDecoration(
            color: currentPage == index ? activeIndicatorColor : inactiveIndicatorColor,
            borderRadius: BorderRadius.circular(size / 2),
          ),
        ),
      ),
    );
  }
}
