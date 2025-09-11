import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

enum AppButtonType { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.type = AppButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.size = AppButtonSize.medium,
  });

  final VoidCallback? onPressed;
  final String text;
  final AppButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget button;
    
    switch (type) {
      case AppButtonType.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: _getButtonStyle(theme),
          child: _buildContent(theme),
        );
        break;
      case AppButtonType.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: _getButtonStyle(theme).copyWith(
            backgroundColor: MaterialStateProperty.all(
              theme.colorScheme.secondary,
            ),
          ),
          child: _buildContent(theme),
        );
        break;
      case AppButtonType.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: _getOutlineButtonStyle(theme),
          child: _buildContent(theme),
        );
        break;
      case AppButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: _getTextButtonStyle(theme),
          child: _buildContent(theme),
        );
        break;
    }
    
    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    
    return button;
  }

  Widget _buildContent(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        height: _getContentHeight(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  type == AppButtonType.outline || type == AppButtonType.text
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('Đang xử lý...'),
          ],
        ),
      );
    }

    if (icon != null) {
      return SizedBox(
        height: _getContentHeight(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: _getIconSize()),
            const SizedBox(width: 8),
            Text(text),
          ],
        ),
      );
    }

    return SizedBox(
      height: _getContentHeight(),
      child: Center(child: Text(text)),
    );
  }

  ButtonStyle _getButtonStyle(ThemeData theme) {
    return ElevatedButton.styleFrom(
      padding: _getPadding(),
      textStyle: _getTextStyle(theme),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      minimumSize: Size(_getMinWidth(), _getMinHeight()),
    );
  }

  ButtonStyle _getOutlineButtonStyle(ThemeData theme) {
    return OutlinedButton.styleFrom(
      padding: _getPadding(),
      textStyle: _getTextStyle(theme),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      minimumSize: Size(_getMinWidth(), _getMinHeight()),
    );
  }

  ButtonStyle _getTextButtonStyle(ThemeData theme) {
    return TextButton.styleFrom(
      padding: _getPadding(),
      textStyle: _getTextStyle(theme),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      minimumSize: Size(_getMinWidth(), _getMinHeight()),
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  TextStyle _getTextStyle(ThemeData theme) {
    switch (size) {
      case AppButtonSize.small:
        return theme.textTheme.labelMedium!.copyWith(
          fontWeight: FontWeight.w600,
        );
      case AppButtonSize.medium:
        return theme.textTheme.labelLarge!.copyWith(
          fontWeight: FontWeight.w600,
        );
      case AppButtonSize.large:
        return theme.textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.w600,
        );
    }
  }

  double _getMinWidth() {
    switch (size) {
      case AppButtonSize.small:
        return 80;
      case AppButtonSize.medium:
        return 100;
      case AppButtonSize.large:
        return 120;
    }
  }

  double _getMinHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 36;
      case AppButtonSize.medium:
        return AppConstants.minTouchTarget;
      case AppButtonSize.large:
        return 52;
    }
  }

  double _getContentHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 20;
      case AppButtonSize.medium:
        return 24;
      case AppButtonSize.large:
        return 28;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }
}

enum AppButtonSize { small, medium, large }
