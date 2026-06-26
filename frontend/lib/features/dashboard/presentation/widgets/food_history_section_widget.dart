import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/skeleton.dart';

class FoodHistorySectionWidget extends StatelessWidget {
  final VoidCallback onViewAll;

  const FoodHistorySectionWidget({
    super.key,
    required this.onViewAll,
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
          _buildFoodHistoryCard(
            'assets/image3.png',
            'Nasi Goreng Spesial',
            'Hari Ini, 13.00',
            '450 kkal',
            '4 Komponen',
            'Karbo Tinggi',
            const Color(0xFFFFA500),
          ),
          const SizedBox(height: 14),
          _buildFoodHistoryCard(
            'assets/image2.png',
            'Avocado Chicken Salad',
            'Hari Ini, 08.00',
            '320 kkal',
            '3 Komponen',
            'Protein Tinggi',
            const Color(0xFF8B5CF6),
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
                      child: const Text(
                        '4 Komponen',
                        style: TextStyle(
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
