import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/skeleton.dart';

class InsightSectionWidget extends StatelessWidget {
  final double consumedCalories;
  final double targetCalories;
  final double consumedProtein;
  final double targetProtein;
  final double consumedCarbs;
  final double targetCarbs;
  final double consumedFat;
  final double targetFat;

  const InsightSectionWidget({
    super.key,
    required this.consumedCalories,
    required this.targetCalories,
    required this.consumedProtein,
    required this.targetProtein,
    required this.consumedCarbs,
    required this.targetCarbs,
    required this.consumedFat,
    required this.targetFat,
  });

  String _buildTip() {
    if (targetCalories > 0 && consumedCalories >= targetCalories) {
      return 'Kerja bagus! Anda sudah mencapai target kalori hari ini. Jaga porsi makan agar tidak berlebihan untuk sisa hari ini.';
    }
    if (targetProtein > 0 && consumedProtein < targetProtein * 0.8) {
      return 'Asupan protein Anda masih dibawah target. Coba tambahkan sumber protein seperti telur, ayam, atau kacang-kacangan dimenu berikutnya.';
    }
    if (targetFat > 0 && consumedFat > targetFat) {
      return 'Asupan lemak Anda sudah melebihi target hari ini. Kurangi makanan bersantan atau gorengan untuk sisa hari ini.';
    }
    if (targetCarbs > 0 && consumedCarbs > targetCarbs) {
      return 'Asupan karbohidrat Anda sudah melebihi target hari ini. Pertimbangkan menu rendah karbo untuk makan berikutnya.';
    }
    final remainingCalories = (targetCalories - consumedCalories).clamp(
      0,
      targetCalories,
    );
    return 'Anda masih punya ${remainingCalories.toStringAsFixed(0)} kkal tersisa hari ini. Pilih makanan bergizi seimbang untuk melengkapi kebutuhan harian Anda.';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0FAF7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.12)),
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
              _buildTip(),
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
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.08)),
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
