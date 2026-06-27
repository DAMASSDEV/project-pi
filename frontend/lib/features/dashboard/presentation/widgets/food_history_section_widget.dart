import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/services/date_helper.dart';

class FoodHistorySectionWidget extends StatelessWidget {
  final VoidCallback onViewAll;
  final List<dynamic> meals;

  const FoodHistorySectionWidget({
    super.key,
    required this.onViewAll,
    required this.meals,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Riwayat Makanan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neutralColor,
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (meals.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.restaurant_menu_rounded, color: Colors.grey.shade300, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada makanan hari ini',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: meals.length > 2 ? 2 : meals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final meal = meals[index];
                final foodName = meal['food_name'] ?? 'Makanan';
                final calories = meal['calories']?.toStringAsFixed(0) ?? '0';
                final rawTimestamp = meal['timestamp'] ?? 'Hari Ini';
                final timestamp = formatFriendlyTimestamp(rawTimestamp);
                final components = meal['components'] ?? '';
                final isManual = meal['is_manual'] ?? false;
                final imagePath = meal['image_path'] ?? 'assets/image3.png';
                final healthScore = meal['health_score'] as int? ?? 80;

                Color badgeColor = Colors.orange;
                String typeBadge = 'Karbo Tinggi';
                if (healthScore >= 85) {
                  badgeColor = const Color(0xFF8B5CF6);
                  typeBadge = 'Sangat Sehat';
                } else if (healthScore >= 70) {
                  badgeColor = AppTheme.primaryColor;
                  typeBadge = 'Seimbang';
                }

                int componentCount = components.split(',').length;

                return _buildFoodHistoryCard(
                  imagePath,
                  foodName,
                  timestamp,
                  '$calories kkal',
                  isManual ? 'Manual Entry' : '$componentCount Komponen',
                  typeBadge,
                  badgeColor,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFoodHistoryCard(
    String imgPath,
    String title,
    String time,
    String calories,
    String compBadge,
    String typeBadge,
    Color badgeColor,
  ) {
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
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 72,
              height: 72,
              color: const Color(0xFFF8F9FA),
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                imgPath,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      calories,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.neutralColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutralColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F6F1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        compBadge,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        typeBadge,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FoodHistorySectionSkeleton extends StatelessWidget {
  const FoodHistorySectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Skeleton(width: 130, height: 18),
              Skeleton(width: 80, height: 14),
            ],
          ),
          const SizedBox(height: 16),
          _buildFoodHistoryCardSkeleton(),
          const SizedBox(height: 14),
          _buildFoodHistoryCardSkeleton(),
        ],
      ),
    );
  }

  Widget _buildFoodHistoryCardSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      padding: const EdgeInsets.all(12),
      child: const Row(
        children: [
          Skeleton(width: 72, height: 72, borderRadius: 14),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Skeleton(width: 80, height: 10),
                    Skeleton(width: 60, height: 14),
                  ],
                ),
                SizedBox(height: 8),
                Skeleton(width: 140, height: 14),
                SizedBox(height: 10),
                Row(
                  children: [
                    Skeleton(width: 80, height: 18, borderRadius: 6),
                    SizedBox(width: 8),
                    Skeleton(width: 80, height: 18, borderRadius: 6),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
