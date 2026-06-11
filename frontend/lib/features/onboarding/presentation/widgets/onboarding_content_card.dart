import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/onboarding_item.dart';

class OnboardingContentCard extends StatelessWidget {
  final OnboardingItem item;
  final Size screenSize;
  final int currentPage;

  const OnboardingContentCard({
    super.key,
    required this.item,
    required this.screenSize,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    final double topAreaHeight = screenSize.height * 0.61;
    final double bottomAreaHeight = screenSize.height * 0.39;
    final double cardSize = screenSize.width * 0.64;

    return Column(
      children: [
        SizedBox(
          height: topAreaHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: cardSize * 1.5,
                height: cardSize * 1.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.08),
                      AppTheme.primaryColor.withOpacity(0.0),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              Container(
                width: cardSize,
                height: cardSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.04),
                      blurRadius: 36,
                      spreadRadius: 2,
                      offset: const Offset(0, 16),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.015),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Image.asset(
                  item.imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: bottomAreaHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.neutralColor,
                    height: 1.3,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    color: Colors.grey.shade600,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
