import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/skeleton.dart';

class WaterTrackerCardWidget extends StatelessWidget {
  final int waterIntakeCups;
  final ValueChanged<int> onCupsChanged;

  const WaterTrackerCardWidget({
    super.key,
    required this.waterIntakeCups,
    required this.onCupsChanged,
  });

  @override
  Widget build(BuildContext context) {
    double progress = waterIntakeCups / 5.0;
    double liters = waterIntakeCups * 0.4;
    int percentage = (progress * 100).toInt();
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
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F2FE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.opacity_rounded,
                    color: Color(0xFF0EA5E9),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Minum Air',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutralColor,
                  ),
                ),
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    width: 100,
                    height: 8,
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0EA5E9)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      textBaseline: TextBaseline.alphabetic,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      children: [
                        Text(
                          liters == 0.0 ? '0' : liters.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.neutralColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/ 2 Liter',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$percentage% dari target harian',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: List.generate(5, (index) {
                    bool isFilled = index < waterIntakeCups;
                    return GestureDetector(
                      onTap: () {
                        if (waterIntakeCups == index + 1) {
                          onCupsChanged(index);
                        } else {
                          onCupsChanged(index + 1);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          isFilled ? Icons.local_drink_rounded : Icons.local_drink_outlined,
                          color: isFilled ? const Color(0xFF0EA5E9) : Colors.grey.shade300,
                          size: 28,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WaterTrackerCardSkeleton extends StatelessWidget {
  const WaterTrackerCardSkeleton({super.key});

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
              children: [
                Skeleton(width: 36, height: 36, borderRadius: 18),
                SizedBox(width: 12),
                Skeleton(width: 80, height: 16),
                Spacer(),
                Skeleton(width: 100, height: 8, borderRadius: 4),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 80, height: 20),
                    SizedBox(height: 6),
                    Skeleton(width: 130, height: 10),
                  ],
                ),
                Row(
                  children: [
                    Skeleton(width: 24, height: 24, borderRadius: 12),
                    SizedBox(width: 4),
                    Skeleton(width: 24, height: 24, borderRadius: 12),
                    SizedBox(width: 4),
                    Skeleton(width: 24, height: 24, borderRadius: 12),
                    SizedBox(width: 4),
                    Skeleton(width: 24, height: 24, borderRadius: 12),
                    SizedBox(width: 4),
                    Skeleton(width: 24, height: 24, borderRadius: 12),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
