import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/skeleton.dart';

class NutrientsScrollWidget extends StatelessWidget {
  final double consumedCarbs;
  final double consumedProtein;
  final double consumedFat;
  final double targetCarbs;
  final double targetProtein;
  final double targetFat;

  const NutrientsScrollWidget({
    super.key,
    required this.consumedCarbs,
    required this.consumedProtein,
    required this.consumedFat,
    required this.targetCarbs,
    required this.targetProtein,
    required this.targetFat,
  });

  @override
  Widget build(BuildContext context) {
    final double carbProgress = targetCarbs > 0 ? (consumedCarbs / targetCarbs).clamp(0.0, 1.0) : 0.0;
    final double proteinProgress = targetProtein > 0 ? (consumedProtein / targetProtein).clamp(0.0, 1.0) : 0.0;
    final double fatProgress = targetFat > 0 ? (consumedFat / targetFat).clamp(0.0, 1.0) : 0.0;

    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildNutrientCard(
            'Karbohidrat',
            consumedCarbs.toStringAsFixed(0),
            'g',
            '${(carbProgress * 100).toStringAsFixed(0)}% dari target ${targetCarbs.toStringAsFixed(0)} g',
            carbProgress,
            const Color(0xFFFFA500),
          ),
          _buildNutrientCard(
            'Protein',
            consumedProtein.toStringAsFixed(0),
            'g',
            '${(proteinProgress * 100).toStringAsFixed(0)}% dari target ${targetProtein.toStringAsFixed(0)} g',
            proteinProgress,
            const Color(0xFF8B5CF6),
          ),
          _buildNutrientCard(
            'Lemak',
            consumedFat.toStringAsFixed(0),
            'g',
            '${(fatProgress * 100).toStringAsFixed(0)}% dari target ${targetFat.toStringAsFixed(0)} g',
            fatProgress,
            Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientCard(
    String label,
    String value,
    String unit,
    String desc,
    double progress,
    Color color,
  ) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.neutralColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            desc,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class NutrientsScrollSkeleton extends StatelessWidget {
  const NutrientsScrollSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 170,
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
            ),
            padding: const EdgeInsets.all(16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Skeleton(width: 28, height: 28, borderRadius: 14),
                    SizedBox(width: 8),
                    Skeleton(width: 70, height: 12),
                  ],
                ),
                SizedBox(height: 18),
                Skeleton(width: 90, height: 22),
                Spacer(),
                Skeleton(width: 100, height: 10),
                SizedBox(height: 8),
                Skeleton(width: 138, height: 4, borderRadius: 2),
              ],
            ),
          );
        },
      ),
    );
  }
}
