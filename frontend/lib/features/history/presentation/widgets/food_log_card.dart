import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class FoodLogCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final String time;
  final String badgeText;
  final bool isManual;
  final String calories;
  final String protein;
  final String carbs;
  final String fat;

  const FoodLogCard({
    super.key,
    required this.imagePath,
    required this.name,
    required this.time,
    required this.badgeText,
    required this.isManual,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Widget _buildNutrientMetric({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppTheme.neutralColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 56,
                  height: 56,
                  color: const Color(0xFFF8F9FA),
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.neutralColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isManual ? const Color(0xFFF1F3F5) : const Color(0xFFE8F6F1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isManual ? Colors.grey.shade600 : AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F3F5)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutrientMetric(
                icon: Icons.local_fire_department_rounded,
                iconColor: const Color(0xFFFFA500),
                value: calories,
                label: 'kkal',
              ),
              _buildNutrientMetric(
                icon: Icons.spa_rounded,
                iconColor: const Color(0xFF108967),
                value: protein,
                label: 'g protein',
              ),
              _buildNutrientMetric(
                icon: Icons.grain_rounded,
                iconColor: const Color(0xFFD3A25D),
                value: carbs,
                label: 'g karbo',
              ),
              _buildNutrientMetric(
                icon: Icons.opacity_rounded,
                iconColor: const Color(0xFFF2994A),
                value: fat,
                label: 'g lemak',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
