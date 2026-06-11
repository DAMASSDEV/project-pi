import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class OnboardingBackgroundOrb extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;
  final double opacity;
  final double scale;

  const OnboardingBackgroundOrb({
    super.key,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.opacity,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(opacity),
                AppTheme.primaryColor.withOpacity(0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
