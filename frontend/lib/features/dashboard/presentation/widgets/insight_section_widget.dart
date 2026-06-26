import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/skeleton.dart';

class InsightSectionWidget extends StatelessWidget {
  const InsightSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0FAF7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.12),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TIPS NUTRISI HARI INI',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppTheme.primaryColor,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Asupan protein anda masih dibawah target. Coba tambahkan sumber protein seperti telur, ayam, atau kacang-kacangan dimenu berikutnya.',
              style: TextStyle(
                fontSize: 13.5,
                color: Colors.grey.shade800,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InsightSectionSkeleton extends StatelessWidget {
  const InsightSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0FAF7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.08),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Skeleton(width: 120, height: 10),
            SizedBox(height: 12),
            Skeleton(width: double.infinity, height: 14),
            SizedBox(height: 8),
            Skeleton(width: 200, height: 14),
          ],
        ),
      ),
    );
  }
}
