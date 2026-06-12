import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DashboardPage extends StatefulWidget {
  final String? goal;
  const DashboardPage({super.key, this.goal});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  late double targetCalories;
  late String goalText;
  int _selectedCalendarDay = 11;
  int _waterIntakeCups = 0;

  @override
  void initState() {
    super.initState();
    final userGoal = widget.goal ?? 'Menjaga Berat Badan';
    goalText = userGoal;
    if (userGoal == 'Menurunkan Berat Badan') {
      targetCalories = 1500;
    } else if (userGoal == 'Menaikkan Berat Badan') {
      targetCalories = 2500;
    } else if (userGoal == 'Meningkatkan Massa Otot') {
      targetCalories = 2300;
    } else {
      targetCalories = 2000;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  _buildHomeTab(),
                  _buildPlaceholderTab('Layar Chatbot'),
                  _buildPlaceholderTab('Layar Pindai Kamera'),
                  _buildPlaceholderTab('Layar Riwayat Log'),
                  _buildPlaceholderTab('Layar Profil Akun'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF0FAF7),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: AppTheme.primaryColor,
              size: 22,
            ),
          ),
          const Text(
            'Nutrify',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: Colors.grey.shade700,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNutrientsScroll(),
          const SizedBox(height: 24),
          _buildNutritionSummaryCard(),
          const SizedBox(height: 24),
          _buildCalendarCard(),
          const SizedBox(height: 24),
          _buildWaterTrackerCard(),
          const SizedBox(height: 24),
          _buildFoodHistorySection(),
          const SizedBox(height: 24),
          _buildInsightSection(),
        ],
      ),
    );
  }

  Widget _buildNutrientsScroll() {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildNutrientCard(
            'Karbohidrat',
            '210',
            'g',
            '70% dari target 300 g',
            0.70,
            const Color(0xFFFFA500),
          ),
          _buildNutrientCard(
            'Protein',
            '85',
            'g',
            '65% dari target 130 g',
            0.65,
            const Color(0xFF8B5CF6),
          ),
          _buildNutrientCard(
            'Lemak',
            '45',
            'g',
            '50% dari target 90 g',
            0.50,
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

  Widget _buildNutritionSummaryCard() {
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
                      width: 120,
                      height: 120,
                      child: CustomPaint(
                        painter: DoughnutChartPainter(
                          calorieProgress: 1652 / targetCalories,
                          carbPct: 0.45,
                          proteinPct: 0.30,
                          fatPct: 0.15,
                          otherPct: 0.10,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '1.652',
                          style: TextStyle(
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
                        const SizedBox(height: 2),
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
                        '210 g',
                        '(45%)',
                      ),
                      const SizedBox(height: 10),
                      _buildChartLegend(
                        const Color(0xFF8B5CF6),
                        'Protein',
                        '85 g',
                        '(30%)',
                      ),
                      const SizedBox(height: 10),
                      _buildChartLegend(
                        Colors.redAccent,
                        'Lemak',
                        '45 g',
                        '(15%)',
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

  Widget _buildFoodHistorySection() {
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
                onTap: () {},
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

  Widget _buildInsightSection() {
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
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Insight & Rekomendasi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutralColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Asupan protein anda masih dibawah target. Coba tambahkan sumber protein seperti telur, ayam, atau kacang-kacangan dimenu berikutnya.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Lihat Rekomendasi Takaran',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    final List<String> weekdays = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];
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
            const Text(
              'Kalender',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.neutralColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Hari Ini',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neutralColor,
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Juni 2026',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.neutralColor,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.chevron_left_rounded, color: AppTheme.primaryColor, size: 20),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.chevron_right_rounded, color: AppTheme.primaryColor, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekdays.map((day) {
                return SizedBox(
                  width: 32,
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade400,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            _buildCalendarGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    List<Widget> rows = [];
    List<int> rowData = [];
    for (int day = 1; day <= 30; day++) {
      rowData.add(day);
      if (rowData.length == 7) {
        rows.add(_buildCalendarRow(rowData, false));
        rowData = [];
      }
    }
    if (rowData.isNotEmpty) {
      int nextMonthDay = 1;
      while (rowData.length < 7) {
        rowData.add(-nextMonthDay);
        nextMonthDay++;
      }
      rows.add(_buildCalendarRow(rowData, true));
    }
    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: row,
        );
      }).toList(),
    );
  }

  Widget _buildCalendarRow(List<int> days, bool isLastRow) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((day) {
        bool isFaded = day < 0;
        int displayDay = day.abs();
        bool isSelected = !isFaded && displayDay == _selectedCalendarDay;
        return GestureDetector(
          onTap: isFaded ? null : () {
            setState(() {
              _selectedCalendarDay = displayDay;
            });
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$displayDay',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isFaded ? Colors.grey.shade300 : AppTheme.neutralColor),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWaterTrackerCard() {
    double progress = _waterIntakeCups / 5.0;
    double liters = _waterIntakeCups * 0.4;
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
                    bool isFilled = index < _waterIntakeCups;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_waterIntakeCups == index + 1) {
                            _waterIntakeCups = index;
                          } else {
                            _waterIntakeCups = index + 1;
                          }
                        });
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

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_filled, 'Beranda'),
              _buildNavItem(1, Icons.chat_bubble_outline_rounded, 'Chatbot'),
              _buildCenterScanButton(),
              _buildNavItem(3, Icons.history_rounded, 'Riwayat'),
              _buildNavItem(4, Icons.person_outline_rounded, 'Akun'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppTheme.primaryColor : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isActive ? AppTheme.primaryColor : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterScanButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = 2;
        });
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: AppTheme.primaryColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.camera_alt_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildPlaceholderTab(String label) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction_rounded,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

class DoughnutChartPainter extends CustomPainter {
  final double calorieProgress;
  final double carbPct;
  final double proteinPct;
  final double fatPct;
  final double otherPct;

  DoughnutChartPainter({
    required this.calorieProgress,
    required this.carbPct,
    required this.proteinPct,
    required this.fatPct,
    required this.otherPct,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);

    Paint outerTrackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..color = const Color(0xFFF1F5F9);
    canvas.drawCircle(center, 58, outerTrackPaint);

    Paint outerProgressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    outerProgressPaint.color = const Color(0xFF108967);
    double outerStartAngle = -3.141592653589793 / 2;
    double outerSweepAngle = (calorieProgress.clamp(0.0, 1.0)) * 2 * 3.141592653589793;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 58),
      outerStartAngle,
      outerSweepAngle,
      false,
      outerProgressPaint,
    );

    double innerRadius = 44;
    double innerStrokeWidth = 11;
    Rect innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    Paint innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = innerStrokeWidth
      ..strokeCap = StrokeCap.butt;

    double innerStartAngle = -3.141592653589793 / 2;
    double gap = 0.05;

    innerPaint.color = const Color(0xFFFFA500);
    double sweepAngleCarb = carbPct * 2 * 3.141592653589793;
    if (sweepAngleCarb > gap) {
      canvas.drawArc(innerRect, innerStartAngle + gap / 2, sweepAngleCarb - gap, false, innerPaint);
    } else {
      canvas.drawArc(innerRect, innerStartAngle, sweepAngleCarb, false, innerPaint);
    }
    innerStartAngle += sweepAngleCarb;

    innerPaint.color = const Color(0xFF8B5CF6);
    double sweepAngleProtein = proteinPct * 2 * 3.141592653589793;
    if (sweepAngleProtein > gap) {
      canvas.drawArc(innerRect, innerStartAngle + gap / 2, sweepAngleProtein - gap, false, innerPaint);
    } else {
      canvas.drawArc(innerRect, innerStartAngle, sweepAngleProtein, false, innerPaint);
    }
    innerStartAngle += sweepAngleProtein;

    innerPaint.color = Colors.redAccent;
    double sweepAngleFat = fatPct * 2 * 3.141592653589793;
    if (sweepAngleFat > gap) {
      canvas.drawArc(innerRect, innerStartAngle + gap / 2, sweepAngleFat - gap, false, innerPaint);
    } else {
      canvas.drawArc(innerRect, innerStartAngle, sweepAngleFat, false, innerPaint);
    }
    innerStartAngle += sweepAngleFat;

    innerPaint.color = const Color(0xFFE2E8F0);
    double sweepAngleOther = otherPct * 2 * 3.141592653589793;
    if (sweepAngleOther > gap) {
      canvas.drawArc(innerRect, innerStartAngle + gap / 2, sweepAngleOther - gap, false, innerPaint);
    } else {
      canvas.drawArc(innerRect, innerStartAngle, sweepAngleOther, false, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
