import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  String _selectedRange = '7 Mei - 13 Mei 2024';
  String _selectedTime = 'Semua Waktu';
  String _selectedSort = 'Terbaru';

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildSummaryCard(
                backgroundColor: const Color(0xFFF0FAF7),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildSummaryCard(
                backgroundColor: const Color(0xFFEBF3FF),
                icon: Icons.water_drop_rounded,
                iconColor: const Color(0xFF2F80ED),
                iconBgColor: Colors.white,
                title: 'Total Protein Hari Ini',
                value: '62',
                unit: 'g',
                targetDesc: '75% dari target 80 g',
                progress: 0.75,
                progressColor: const Color(0xFF2F80ED),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildFoodLogCard(
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
                  const SizedBox(height: 16),
                  _buildFoodLogCard(
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
                  const SizedBox(height: 16),
                  _buildFoodLogCard(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildInsightCard(),
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

  Widget _buildSummaryCard({
    required Color backgroundColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
    required String unit,
    required String targetDesc,
    required double progress,
    required Color progressColor,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: AppTheme.neutralColor),
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            targetDesc,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              color: progressColor,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodLogCard({
    required String imagePath,
    required String name,
    required String time,
    required String badgeText,
    required bool isManual,
    required String calories,
    required String protein,
    required String carbs,
    required String fat,
  }) {
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

  Widget _buildInsightCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0FAF7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.15),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'INSIGHT HARI INI',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppTheme.primaryColor,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.spa_rounded,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Kalori kamu sudah mendekati target!',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.neutralColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba tambahkan serat dari sayur dan buah untuk keseimbangan nutrisi.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
