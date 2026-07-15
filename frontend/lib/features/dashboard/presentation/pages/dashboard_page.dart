import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../../../recommendations/presentation/pages/recommendations_tab.dart';
import '../../../history/presentation/pages/history_tab.dart';
import '../../../profile/presentation/pages/profile_tab.dart';
import '../../../scanner/presentation/pages/scanner_tab.dart';
import '../widgets/nutrients_scroll_widget.dart';
import '../widgets/nutrition_summary_card_widget.dart';
import '../widgets/calendar_card_widget.dart';
import '../widgets/water_tracker_card_widget.dart';
import '../widgets/food_history_section_widget.dart';
import '../widgets/insight_section_widget.dart';
import '../../../../core/widgets/custom_painters.dart';

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
  int _selectedCalendarDay = DateTime.now().day;
  int _waterIntakeCups = 0;
  bool _isLoading = true;

  List<dynamic> _allMeals = [];
  List<dynamic> _meals = [];
  double _consumedCalories = 0.0;
  double _consumedCarbs = 0.0;
  double _consumedProtein = 0.0;
  double _consumedFat = 0.0;

  @override
  void initState() {
    super.initState();
    final userGoal = widget.goal ?? 'Menjaga Berat Badan';
    goalText = userGoal;
    targetCalories = 2000.0;
    _loadWaterIntake();
    _fetchMeals();
    _fetchPersonalization();
  }

  void _setTargetCalories(Map<String, dynamic> data) {
    final String goal = data['goal'] ?? 'Menjaga Berat Badan';
    final double weight = double.tryParse(data['weight']?.toString() ?? '') ?? 70.0;
    final double height = double.tryParse(data['height']?.toString() ?? '') ?? 170.0;
    final String gender = (data['gender'] ?? 'Laki-laki').toString();
    final String activity = (data['activity'] ?? 'Jarang').toString().toLowerCase();
    
    int age = 25;
    if (data['dob'] != null && data['dob'].toString().isNotEmpty) {
      try {
        final dob = DateTime.parse(data['dob']);
        age = DateTime.now().year - dob.year;
      } catch (_) {}
    }

    double bmr = 0;
    if (gender == 'Perempuan' || gender.toLowerCase().contains('wanita') || gender.toLowerCase().contains('female')) {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    } else {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    }

    double multiplier = 1.2;
    if (activity.contains('sangat aktif') || activity.contains('6-7')) {
      multiplier = 1.725;
    } else if (activity.contains('cukup aktif') || activity.contains('3-5') || activity.contains('sedang')) {
      multiplier = 1.55;
    } else if (activity.contains('jarang') || activity.contains('1-3')) {
      multiplier = 1.375;
    }

    double tdee = bmr * multiplier;

    if (goal == 'Menurunkan Berat Badan') {
      tdee -= 500;
    } else if (goal == 'Menaikkan Berat Badan') {
      tdee += 500;
    } else if (goal == 'Meningkatkan Massa Otot') {
      tdee += 300;
    }

    setState(() {
      targetCalories = tdee.roundToDouble().clamp(1200, 3500);
    });
  }

  Future<void> _fetchPersonalization() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('logged_in_email');
      if (email != null) {
        final apiService = ApiService();
        final res = await apiService.getPersonalization(email);
        if (res['success'] == true && res['data'] != null) {
          final data = res['data'];
          if (mounted) {
            setState(() {
              goalText = data['goal'] ?? 'Menjaga Berat Badan';
              _setTargetCalories(data);
            });
          }
          return;
        }
      }

      if (mounted) {
        final savedGoal = prefs.getString('user_goal') ?? 'Menjaga Berat Badan';
        setState(() {
          goalText = savedGoal;
          _setTargetCalories({
            'goal': savedGoal,
            'weight': prefs.getDouble('user_weight') ?? 70.0,
            'height': prefs.getDouble('user_height') ?? 170.0,
            'gender': prefs.getString('user_gender') ?? 'Laki-laki',
            'activity': prefs.getString('user_activity') ?? 'Jarang',
            'dob': prefs.getString('user_dob') ?? '2001-01-01',
          });
        });
      }
    } catch (_) {}
  }

  bool _isMealOnSelectedDay(Map<String, dynamic> meal, int selectedDay) {
    final timestamp = meal['timestamp'] as String? ?? '';
    
    final now = DateTime.now();
    final datePrefix = "${now.year}-${now.month.toString().padLeft(2, '0')}-${selectedDay.toString().padLeft(2, '0')}";
    if (timestamp.startsWith(datePrefix)) {
      return true;
    }
    
    if (timestamp.contains("Hari Ini") && selectedDay == now.day) {
      return true;
    }
    
    return false;
  }

  void _filterMealsForSelectedDay() {
    final filtered = _allMeals.where((m) {
      final mealMap = m as Map<String, dynamic>;
      return _isMealOnSelectedDay(mealMap, _selectedCalendarDay);
    }).toList();

    double cal = 0.0;
    double carb = 0.0;
    double prot = 0.0;
    double fat = 0.0;

    for (var m in filtered) {
      cal += (m['calories'] as num?)?.toDouble() ?? 0.0;
      carb += (m['carbs'] as num?)?.toDouble() ?? 0.0;
      prot += (m['protein'] as num?)?.toDouble() ?? 0.0;
      fat += (m['fat'] as num?)?.toDouble() ?? 0.0;
    }

    setState(() {
      _meals = filtered;
      _consumedCalories = cal;
      _consumedCarbs = carb;
      _consumedProtein = prot;
      _consumedFat = fat;
    });
  }

  Future<void> _loadWaterIntake() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final key = 'water_intake_${now.year}_${now.month.toString().padLeft(2, '0')}_$_selectedCalendarDay';
    if (mounted) {
      setState(() {
        _waterIntakeCups = prefs.getInt(key) ?? 0;
      });
    }
  }

  Future<void> _saveWaterIntake(int cups) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final key = 'water_intake_${now.year}_${now.month.toString().padLeft(2, '0')}_$_selectedCalendarDay';
    await prefs.setInt(key, cups);
    if (mounted) {
      setState(() {
        _waterIntakeCups = cups;
      });
    }
  }

  Future<void> _fetchMeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('logged_in_email') ?? 'guest@nutrify.com';
      final apiService = ApiService();
      final meals = await apiService.getMeals(email);

      if (mounted) {
        setState(() {
          _allMeals = meals;
          _isLoading = false;
        });
        _filterMealsForSelectedDay();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                  const RecommendationsTab(),
                  const HistoryTab(),
                  const ProfileTab(),
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
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/hero-bot.png',
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Text(
              'Nutrify',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    if (_isLoading) {
      return const SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NutrientsScrollSkeleton(),
            SizedBox(height: 24),
            NutritionSummaryCardSkeleton(),
            SizedBox(height: 24),
            CalendarCardSkeleton(),
            SizedBox(height: 24),
            WaterTrackerCardSkeleton(),
            SizedBox(height: 24),
            FoodHistorySectionSkeleton(),
            SizedBox(height: 24),
            InsightSectionSkeleton(),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchMeals,
      color: AppTheme.primaryColor,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NutrientsScrollWidget(
              consumedCarbs: _consumedCarbs,
              consumedProtein: _consumedProtein,
              consumedFat: _consumedFat,
              targetCarbs: 300.0,
              targetProtein: 130.0,
              targetFat: 90.0,
            ),
            const SizedBox(height: 24),
            NutritionSummaryCardWidget(
              targetCalories: targetCalories,
              goalText: goalText,
              consumedCalories: _consumedCalories,
              consumedCarbs: _consumedCarbs,
              consumedProtein: _consumedProtein,
              consumedFat: _consumedFat,
            ),
            const SizedBox(height: 24),
            CalendarCardWidget(
              selectedDay: _selectedCalendarDay,
              onDaySelected: (day) {
                setState(() {
                  _selectedCalendarDay = day;
                });
                _loadWaterIntake();
                _filterMealsForSelectedDay();
              },
            ),
            const SizedBox(height: 24),
            WaterTrackerCardWidget(
              waterIntakeCups: _waterIntakeCups,
              onCupsChanged: (cups) {
                _saveWaterIntake(cups);
              },
            ),
            const SizedBox(height: 24),
            FoodHistorySectionWidget(
              meals: _meals,
              onMealDeleted: _fetchMeals,
              onViewAll: () {
                setState(() {
                  _currentIndex = 2;
                });
              },
            ),
            const SizedBox(height: 24),
            const InsightSectionWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    if (isKeyboardVisible) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding > 0 ? bottomPadding : 12.0),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 18),
            child: CustomPaint(
              painter: FloatingNotchedPainter(),
              child: SizedBox(
                height: 64,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.home_filled, 'Beranda'),
                    _buildNavItem(1, Icons.menu_book_rounded, 'Rekomendasi'),
                    const SizedBox(width: 60),
                    _buildNavItem(2, Icons.history_rounded, 'Riwayat'),
                    _buildNavItem(3, Icons.person_outline_rounded, 'Akun'),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -6,
            child: _buildCenterScanButton(),
          ),
        ],
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
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2DD4BF),
            AppTheme.primaryColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2DD4BF).withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(2),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScannerTab(
                  onScanSaved: () {
                    _fetchMeals();
                  },
                ),
              ),
            );
          },
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  Color(0xFF0F766E),
                ],
              ),
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
