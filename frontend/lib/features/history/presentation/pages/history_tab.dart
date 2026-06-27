import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../widgets/history_summary_card.dart';
import '../widgets/food_log_card.dart';
import '../widgets/history_insight_card.dart';
import '../../../../core/services/date_helper.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final ApiService _apiService = ApiService();
  String _selectedRange = 'Hari Ini';
  String _selectedSort = 'Terbaru';
  bool _isLoading = true;
  List<dynamic> _allMeals = [];
  List<dynamic> _meals = [];
  double _totalCalories = 0.0;
  double _totalProtein = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchMeals();
  }

  Future<void> _fetchMeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('logged_in_email') ?? 'guest@nutrify.com';
      final meals = await _apiService.getMeals(email);

      if (mounted) {
        setState(() {
          _allMeals = meals;
          _applyFilters();
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

  void _applyFilters() {
    List<dynamic> filtered = List.from(_allMeals);
    
    // Simulate simple filtering for the demo based on the dropdown
    // In a real app we would parse the ISO timestamps
    
    if (_selectedSort == 'Terbaru') {
      filtered.sort((a, b) => (b['id'] ?? 0).compareTo(a['id'] ?? 0));
    } else {
      filtered.sort((a, b) => (a['id'] ?? 0).compareTo(b['id'] ?? 0));
    }

    double cal = 0.0;
    double prot = 0.0;
    for (var m in filtered) {
      cal += (m['calories'] as num?)?.toDouble() ?? 0.0;
      prot += (m['protein'] as num?)?.toDouble() ?? 0.0;
    }

    _meals = filtered;
    _totalCalories = cal;
    _totalProtein = prot;
  }

  Future<void> _confirmDelete(int mealId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Hapus Catatan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.neutralColor,
            ),
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghapus catatan makanan ini dari jurnal harian Anda?',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final res = await _apiService.deleteMeal(mealId);
                if (res['success'] == true) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Catatan makanan berhasil dihapus.'),
                        backgroundColor: AppTheme.primaryColor,
                      ),
                    );
                  }
                  _fetchMeals();
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(res['message'] ?? 'Gagal menghapus makanan'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Hapus',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double calProgress = (_totalCalories / 2000.0).clamp(0.0, 1.0);
    final double protProgress = (_totalProtein / 80.0).clamp(0.0, 1.0);

    return Container(
      color: Colors.white,
      child: RefreshIndicator(
        onRefresh: _fetchMeals,
        color: AppTheme.primaryColor,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: PopupMenuButton<String>(
                  onSelected: (String result) {
                    setState(() {
                      _selectedRange = result;
                      _applyFilters();
                    });
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'Hari Ini',
                      child: Text('Hari Ini'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Minggu Ini',
                      child: Text('Minggu Ini'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Bulan Ini',
                      child: Text('Bulan Ini'),
                    ),
                  ],
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
                        const Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedRange,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  ),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: HistorySummaryCard(
                    backgroundColor: const Color(0xFFF0FAF7),
                    icon: Icons.local_fire_department_rounded,
                    iconColor: AppTheme.primaryColor,
                    iconBgColor: Colors.white,
                    title: 'Total Kalori $_selectedRange',
                    value: _totalCalories.toStringAsFixed(0),
                    unit: 'kkal',
                    targetDesc: '${(calProgress * 100).toStringAsFixed(0)}% dari target 2.000 kkal',
                    progress: calProgress,
                    progressColor: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: HistorySummaryCard(
                    backgroundColor: const Color(0xFFEBF3FF),
                    icon: Icons.water_drop_rounded,
                    iconColor: const Color(0xFF2F80ED),
                    iconBgColor: Colors.white,
                    title: 'Total Protein $_selectedRange',
                    value: _totalProtein.toStringAsFixed(0),
                    unit: 'g',
                    targetDesc: '${(protProgress * 100).toStringAsFixed(0)}% dari target 80 g',
                    progress: protProgress,
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
                      PopupMenuButton<String>(
                        onSelected: (String result) {
                          setState(() {
                            _selectedSort = result;
                            _applyFilters();
                          });
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'Terbaru',
                            child: Text('Terbaru'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'Terlama',
                            child: Text('Terlama'),
                          ),
                        ],
                        child: Container(
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
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _meals.isEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.restaurant_menu_rounded, color: Colors.grey.shade300, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'Jurnal makanan Anda masih kosong',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _meals.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final meal = _meals[index];
                            final mealId = meal['id'] as int;
                            final foodName = meal['food_name'] ?? 'Makanan';
                            final calories = meal['calories']?.toStringAsFixed(0) ?? '0';
                            final protein = meal['protein']?.toStringAsFixed(0) ?? '0';
                            final carbs = meal['carbs']?.toStringAsFixed(0) ?? '0';
                            final fat = meal['fat']?.toStringAsFixed(0) ?? '0';
                            final rawTimestamp = meal['timestamp'] ?? 'Hari Ini';
                            final timestamp = formatFriendlyTimestamp(rawTimestamp);
                            final components = meal['components'] ?? '';
                            final isManual = meal['is_manual'] ?? false;
                            final imagePath = meal['image_path'] ?? 'assets/image3.png';

                            int componentCount = components.split(',').length;

                            return Stack(
                              children: [
                                FoodLogCard(
                                  imagePath: imagePath,
                                  name: foodName,
                                  time: timestamp,
                                  badgeText: isManual ? 'Manual Entry' : '$componentCount komponen terdeteksi',
                                  isManual: isManual,
                                  calories: calories,
                                  protein: protein,
                                  carbs: carbs,
                                  fat: fat,
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: GestureDetector(
                                    onTap: () => _confirmDelete(mealId),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withOpacity(0.08),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.redAccent,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
                const SizedBox(height: 28),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: HistoryInsightCard(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
