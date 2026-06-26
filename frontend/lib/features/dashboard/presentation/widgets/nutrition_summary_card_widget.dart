import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_painters.dart';
import '../../../../core/widgets/skeleton.dart';

class NutritionSummaryCardWidget extends StatelessWidget {
  final double targetCalories;
  final String goalText;
  final double consumedCalories;
  final double consumedCarbs;
  final double consumedProtein;
  final double consumedFat;

  const NutritionSummaryCardWidget({
    super.key,
    required this.targetCalories,
    required this.goalText,
    required this.consumedCalories,
    required this.consumedCarbs,
    required this.consumedProtein,
    required this.consumedFat,
  });

  @override
  Widget build(BuildContext context) {
    final double totalGrams = consumedCarbs + consumedProtein + consumedFat;
    final double carbPct = totalGrams > 0 ? (consumedCarbs / totalGrams * 0.9) : 0.45;
    final double proteinPct = totalGrams > 0 ? (consumedProtein / totalGrams * 0.9) : 0.30;
    final double fatPct = totalGrams > 0 ? (consumedFat / totalGrams * 0.9) : 0.15;
    final double otherPct = 1.0 - (carbPct + proteinPct + fatPct);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan Nutrisi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.neutralColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tujuan: $goalText',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Hari Ini',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 136,
                      height: 136,
                      child: CustomPaint(
                        painter: DoughnutChartPainter(
                          calorieProgress: targetCalories > 0 ? (consumedCalories / targetCalories).clamp(0.0, 1.0) : 0.0,
                          carbPct: carbPct,
                          proteinPct: proteinPct,
                          fatPct: fatPct,
                          otherPct: otherPct,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          consumedCalories.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.neutralColor,
                          ),
                        ),
                        Text(
                          'kkal total',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Target: ${targetCalories.toInt()}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 28),
                Expanded(
                  child: Column(
                    children: [
                      _buildChartLegend(
                        const Color(0xFFFFA500),
                        'Karbohidrat',
                        '${consumedCarbs.toStringAsFixed(0)} g',
                        '(${(carbPct * 100).toStringAsFixed(0)}%)',
                      ),
                      const SizedBox(height: 10),
                      _buildChartLegend(
                        const Color(0xFF8B5CF6),
                        'Protein',
                        '${consumedProtein.toStringAsFixed(0)} g',
                        '(${(proteinPct * 100).toStringAsFixed(0)}%)',
                      ),
                      const SizedBox(height: 10),
                      _buildChartLegend(
                        Colors.redAccent,
                        'Lemak',
                        '${consumedFat.toStringAsFixed(0)} g',
                        '(${(fatPct * 100).toStringAsFixed(0)}%)',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend(Color color, String label, String value, String pct) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppTheme.neutralColor,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          pct,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}

class NutritionSummaryCardSkeleton extends StatelessWidget {
  const NutritionSummaryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
        ),
        padding: const EdgeInsets.all(20),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 120, height: 16),
                    SizedBox(height: 6),
                    Skeleton(width: 150, height: 10),
                  ],
                ),
                Skeleton(width: 70, height: 24, borderRadius: 8),
              ],
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Skeleton(width: 136, height: 136, borderRadius: 68),
                SizedBox(width: 28),
                Expanded(
                  child: Column(
                    children: [
                      Skeleton(width: double.infinity, height: 14),
                      SizedBox(height: 12),
                      Skeleton(width: double.infinity, height: 14),
                      SizedBox(height: 12),
                      Skeleton(width: double.infinity, height: 14),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
