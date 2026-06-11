import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class OnboardingIndicator extends StatelessWidget {
  final int itemCount;
  final int currentPage;

  const OnboardingIndicator({
    super.key,
    required this.itemCount,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => _buildDotIndicator(index),
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    final bool isActive = index == currentPage;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 6,
      width: isActive ? 24 : 6,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
