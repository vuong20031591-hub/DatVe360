import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

/// A container that applies 3D transforms to SVG illustrations
/// with smooth animations and performance optimizations
class ThreeDSvgContainer extends StatefulWidget {
  final String svgAsset;
  final Duration animationDuration;
  final bool enableFloating;
  final bool enablePerspective;
  final bool enableInteraction;
  final double maxRotationX;
  final double maxRotationY;
  final double perspectiveValue;

  const ThreeDSvgContainer({
    super.key,
    required this.svgAsset,
    this.animationDuration = const Duration(seconds: 3),
    this.enableFloating = true,
    this.enablePerspective = true,
    this.enableInteraction = false,
    this.maxRotationX = 0.1,
    this.maxRotationY = 0.05,
    this.perspectiveValue = 0.001,
  });

  @override
  State<ThreeDSvgContainer> createState() => _ThreeDSvgContainerState();
}

class _ThreeDSvgContainerState extends State<ThreeDSvgContainer>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _perspectiveController;
  late AnimationController _interactionController;

  late Animation<double> _floatingAnimation;
  late Animation<double> _rotationXAnimation;
  late Animation<double> _rotationYAnimation;
  late Animation<double> _scaleAnimation;

  // Interaction state
  double _interactionRotationX = 0.0;
  double _interactionRotationY = 0.0;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Floating animation controller
    _floatingController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Perspective animation controller
    _perspectiveController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Interaction animation controller
    _interactionController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Floating animation (subtle up-down movement)
    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    // Rotation animations for perspective effect
    _rotationXAnimation = Tween<double>(
      begin: -widget.maxRotationX,
      end: widget.maxRotationX,
    ).animate(CurvedAnimation(
      parent: _perspectiveController,
      curve: Curves.easeInOut,
    ));

    _rotationYAnimation = Tween<double>(
      begin: -widget.maxRotationY,
      end: widget.maxRotationY,
    ).animate(CurvedAnimation(
      parent: _perspectiveController,
      curve: Curves.easeInOut,
    ));

    // Scale animation for interaction
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _interactionController,
      curve: Curves.easeOut,
    ));

    // Start animations
    if (widget.enableFloating) {
      _floatingController.repeat(reverse: true);
    }

    if (widget.enablePerspective) {
      _perspectiveController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _perspectiveController.dispose();
    _interactionController.dispose();
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!widget.enableInteraction) return;

    setState(() {
      // Convert pan delta to rotation values
      _interactionRotationY += details.delta.dx * 0.01;
      _interactionRotationX -= details.delta.dy * 0.01;

      // Clamp rotation values
      _interactionRotationX = _interactionRotationX.clamp(-0.3, 0.3);
      _interactionRotationY = _interactionRotationY.clamp(-0.3, 0.3);
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!widget.enableInteraction) return;

    // Animate back to neutral position
    setState(() {
      _interactionRotationX = 0.0;
      _interactionRotationY = 0.0;
    });
  }

  void _handleHover(bool isHovered) {
    if (!widget.enableInteraction) return;

    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _interactionController.forward();
    } else {
      _interactionController.reverse();
    }
  }

  Matrix4 _buildTransformMatrix() {
    final matrix = Matrix4.identity();

    // Apply perspective
    if (widget.enablePerspective) {
      matrix.setEntry(3, 2, widget.perspectiveValue);
    }

    // Apply floating translation
    if (widget.enableFloating) {
      matrix.translate(0.0, -_floatingAnimation.value, 0.0);
    }

    // Apply perspective rotations
    if (widget.enablePerspective) {
      matrix.rotateX(_rotationXAnimation.value + _interactionRotationX);
      matrix.rotateY(_rotationYAnimation.value + _interactionRotationY);
    }

    // Apply interaction scale
    if (widget.enableInteraction && _isHovered) {
      final scale = _scaleAnimation.value;
      matrix.scale(scale, scale, scale);
    }

    return matrix;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _floatingController,
        _perspectiveController,
        _interactionController,
      ]),
      builder: (context, child) {
        return GestureDetector(
          onPanUpdate: _handlePanUpdate,
          onPanEnd: _handlePanEnd,
          child: MouseRegion(
            onEnter: (_) => _handleHover(true),
            onExit: (_) => _handleHover(false),
            child: Transform(
              alignment: Alignment.center,
              transform: _buildTransformMatrix(),
              child: SvgPicture.asset(
                widget.svgAsset,
                fit: BoxFit.contain,
                placeholderBuilder: (context) => Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Performance-optimized version for mobile devices
class LightweightThreeDSvgContainer extends StatefulWidget {
  final String svgAsset;
  final bool enableFloating;

  const LightweightThreeDSvgContainer({
    super.key,
    required this.svgAsset,
    this.enableFloating = true,
  });

  @override
  State<LightweightThreeDSvgContainer> createState() =>
      _LightweightThreeDSvgContainerState();
}

class _LightweightThreeDSvgContainerState
    extends State<LightweightThreeDSvgContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.enableFloating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableFloating) {
      return SvgPicture.asset(
        widget.svgAsset,
        fit: BoxFit.contain,
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_animation.value),
          child: SvgPicture.asset(
            widget.svgAsset,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }
}
