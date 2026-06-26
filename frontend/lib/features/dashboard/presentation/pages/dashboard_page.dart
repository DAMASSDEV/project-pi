import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../../../chatbot/presentation/pages/chatbot_tab.dart';
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
  int _selectedCalendarDay = 11;
  int _waterIntakeCups = 0;
  bool _isLoading = true;

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
    _setTargetCalories(userGoal);
    _fetchMeals();
  }

  void _setTargetCalories(String goal) {
    if (goal == 'Menurunkan Berat Badan') {
      targetCalories = 1500;
    } else if (goal == 'Menaikkan Berat Badan') {
      targetCalories = 2500;
    } else if (goal == 'Meningkatkan Massa Otot') {
      targetCalories = 2300;
    } else {
      targetCalories = 2000;
    }
  }

  Future<void> _fetchMeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (widget.goal == null) {
        final savedGoal = prefs.getString('user_goal');
        if (savedGoal != null && mounted) {
          setState(() {
            goalText = savedGoal;
            _setTargetCalories(savedGoal);
          });
        }
      }

      final email = prefs.getString('logged_in_email') ?? 'guest@nutrify.com';
      final apiService = ApiService();
      final meals = await apiService.getMeals(email);

      double cal = 0.0;
      double carb = 0.0;
      double prot = 0.0;
      double fat = 0.0;

      for (var m in meals) {
        cal += (m['calories'] as num?)?.toDouble() ?? 0.0;
        carb += (m['carbs'] as num?)?.toDouble() ?? 0.0;
        prot += (m['protein'] as num?)?.toDouble() ?? 0.0;
        fat += (m['fat'] as num?)?.toDouble() ?? 0.0;
      }

      if (mounted) {
        setState(() {
          _meals = meals;
          _consumedCalories = cal;
          _consumedCarbs = carb;
          _consumedProtein = prot;
          _consumedFat = fat;
          _isLoading = false;
        });
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
                  const ChatbotTab(),
                  ScannerTab(
                    onScanSaved: () {
                      _fetchMeals();
                      setState(() {
                        _currentIndex = 0;
                      });
                    },
                  ),
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
          Row(
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
    if (_isLoading) {
      return const SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
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
              },
            ),
            const SizedBox(height: 24),
            WaterTrackerCardWidget(
              waterIntakeCups: _waterIntakeCups,
              onCupsChanged: (cups) {
                setState(() {
                  _waterIntakeCups = cups;
                });
              },
            ),
            const SizedBox(height: 24),
            FoodHistorySectionWidget(
              meals: _meals,
              onViewAll: () {
                setState(() {
                  _currentIndex = 3;
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
      padding: EdgeInsets.only(bottom: bottomPadding > 0 ? 6.0 : 0.0),
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
                    _buildNavItem(1, Icons.chat_bubble_outline_rounded, 'Chatbot'),
                    const SizedBox(width: 60),
                    _buildNavItem(3, Icons.history_rounded, 'Riwayat'),
                    _buildNavItem(4, Icons.person_outline_rounded, 'Akun'),
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
            setState(() {
              _currentIndex = 2;
            });
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
