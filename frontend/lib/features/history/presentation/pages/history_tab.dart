import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/history_summary_card.dart';
import '../widgets/food_log_card.dart';
import '../widgets/history_insight_card.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final String _selectedRange = '7 Mei - 13 Mei 2024';
  final String _selectedTime = 'Semua Waktu';
  final String _selectedSort = 'Terbaru';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                children: [
                  _buildFilterDropdown(
                    icon: Icons.calendar_today_rounded,
                    label: _selectedRange,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildFilterDropdown(
                    icon: Icons.access_time_rounded,
                    label: _selectedTime,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: HistorySummaryCard(
                backgroundColor: Color(0xFFF0FAF7),
                icon: Icons.local_fire_department_rounded,
                iconColor: AppTheme.primaryColor,
                iconBgColor: Colors.white,
                title: 'Total Kalori Hari Ini',
                value: '1.652',
                unit: 'kkal',
                targetDesc: '85% dari target 2.000 kkal',
                progress: 0.85,
                progressColor: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: HistorySummaryCard(
                backgroundColor: Color(0xFFEBF3FF),
                icon: Icons.water_drop_rounded,
                iconColor: Color(0xFF2F80ED),
                iconBgColor: Colors.white,
                title: 'Total Protein Hari Ini',
                value: '62',
                unit: 'g',
                targetDesc: '75% dari target 80 g',
                progress: 0.75,
                progressColor: Color(0xFF2F80ED),
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Riwayat Makanan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neutralColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedSort,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: Colors.grey.shade700,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  FoodLogCard(
                    imagePath: 'assets/image3.png',
                    name: 'Nasi Goreng',
                    time: 'Hari ini, 13.00',
                    badgeText: '4 komponen terdeteksi',
                    isManual: false,
                    calories: '520',
                    protein: '14',
                    carbs: '72',
                    fat: '18',
                  ),
                  SizedBox(height: 16),
                  FoodLogCard(
                    imagePath: 'assets/image2.png',
                    name: 'Chicken Salad',
                    time: 'Kemarin, 19.30',
                    badgeText: '3 komponen terdeteksi',
                    isManual: false,
                    calories: '340',
                    protein: '28',
                    carbs: '12',
                    fat: '15',
                  ),
                  SizedBox(height: 16),
                  FoodLogCard(
                    imagePath: 'assets/image1.png',
                    name: 'Oatmeal with Berries',
                    time: 'Kemarin, 08.00',
                    badgeText: 'Manual Entry',
                    isManual: true,
                    calories: '280',
                    protein: '8',
                    carbs: '45',
                    fat: '5',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: HistoryInsightCard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }
}
