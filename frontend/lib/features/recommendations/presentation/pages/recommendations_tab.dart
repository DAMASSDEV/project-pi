import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';

class RecommendationsTab extends StatefulWidget {
  const RecommendationsTab({super.key});

  @override
  State<RecommendationsTab> createState() => _RecommendationsTabState();
}

class _RecommendationsTabState extends State<RecommendationsTab> {
  final ApiService _apiService = ApiService();
  String _userName = 'Pengguna';
  String _goal = 'Menjaga Berat Badan';
  List<String> _conditions = [];
  double _targetCalories = 2000;
  double _targetCarbs = 300.0;
  double _targetProtein = 130.0;
  double _targetFat = 90.0;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _bogorFoods = [
    {
      'name': 'Asinan Bogor',
      'calories': 105.0,
      'protein': 2.5,
      'carbs': 18.0,
      'fat': 3.0,
      'fiber': 2.8,
      'sodium': 540.0,
      'desc':
          'Asinan buah dan sayur segar dengan kuah cuka merah asam pedas yang menggugah selera.',
      'tip':
          'Sangat sehat! Vitamin C tinggi dan kaya serat. Namun, kurangi asupan kerupuk mi kuning pelengkapnya jika ingin membatasi kalori kosong.',
      'image': 'assets/image2.png',
      'color': Color(0xFF108967),
    },
    {
      'name': 'Soto Kuning',
      'calories': 380.0,
      'protein': 22.0,
      'carbs': 15.0,
      'fat': 25.0,
      'fiber': 0.8,
      'sodium': 620.0,
      'desc':
          'Soto kuning bersantan khas Bogor yang kaya akan rempah, disajikan dengan irisan daging sapi.',
      'tip':
          'Tinggi protein hewani. Batasi konsumsi kuah santan berlebih untuk meminimalkan asupan lemak jenuh harian Anda.',
      'image': 'assets/image3.png',
      'color': Color(0xFFFFA500),
    },
    {
      'name': 'Doclang',
      'calories': 215.0,
      'protein': 7.5,
      'carbs': 26.0,
      'fat': 9.5,
      'fiber': 2.5,
      'sodium': 520.0,
      'desc':
          'Makanan tradisional dengan isian kupat, tahu kuning, kentang rebus, telur, dan siraman bumbu kacang tebal.',
      'tip':
          'Sumber energi karbohidrat dan protein nabati yang baik. Mintalah saus bumbu kacang dipisah agar Anda bisa mengontrol porsi kalori bumbunya.',
      'image': 'assets/image1.png',
      'color': Color(0xFF0F766E),
    },
    {
      'name': 'Laksa Bogor',
      'calories': 280.0,
      'protein': 9.5,
      'carbs': 32.0,
      'fat': 13.0,
      'fiber': 2.0,
      'sodium': 650.0,
      'desc':
          'Ketupat, bihun, tauge, kemangi, oncom merah, disiram kuah santan laksa kuning khas yang gurih.',
      'tip':
          'Oncom merah di dalamnya merupakan fermentasi bergizi tinggi protein. Disarankan konsumsi dengan tambahan protein seperti telur rebus.',
      'image': 'assets/image2.png',
      'color': Color(0xFFE11D48),
    },
    {
      'name': 'Toge Goreng',
      'calories': 88.0,
      'protein': 3.2,
      'carbs': 14.0,
      'fat': 2.1,
      'fiber': 2.5,
      'sodium': 480.0,
      'desc':
          'Tauge segar, mi kuning, tahu kuning rebus yang disiram dengan saus tauco khas yang gurih manis.',
      'tip':
          'Relatif rendah kalori dan lemak karena tauge tidak digoreng dengan minyak (direbus di air wadah datar). Bagus untuk program diet kalori rendah.',
      'image': 'assets/image1.png',
      'color': Color(0xFF2563EB),
    },
  ];

  Map<String, dynamic>? _selectedCalculatorFood;
  final double _calculatorPortionGrams = 100.0;

  @override
  void initState() {
    super.initState();
    _selectedCalculatorFood = _bogorFoods[0];
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('logged_in_email') ?? '';
    final name = prefs.getString('logged_in_name') ?? 'Pengguna';

    if (email.isNotEmpty) {
      final res = await _apiService.getPersonalization(email);
      if (res['success'] == true && res['data'] != null) {
        final data = res['data'];
        setState(() {
          _userName = data['name'] ?? name;
          _goal = data['goal'] ?? 'Menjaga Berat Badan';
          _conditions = List<String>.from(data['conditions'] ?? []);
          _setTargetValues(data);
          _isLoading = false;
        });
        return;
      }
    }

    setState(() {
      _userName = name;
      _goal = prefs.getString('user_goal') ?? 'Menjaga Berat Badan';
      _conditions = List<String>.from(
        prefs.getStringList('user_conditions') ?? [],
      );
      _setTargetValues({
        'goal': _goal,
        'weight': prefs.getDouble('user_weight') ?? 70.0,
        'height': prefs.getDouble('user_height') ?? 170.0,
        'gender': prefs.getString('user_gender') ?? 'Laki-laki',
        'activity': prefs.getString('user_activity') ?? 'Jarang',
        'dob': prefs.getString('user_dob') ?? '2001-01-01',
      });
      _isLoading = false;
    });
  }

  void _setTargetValues(Map<String, dynamic> data) {
    final String goal = data['goal'] ?? 'Menjaga Berat Badan';
    final double weight =
        double.tryParse(data['weight']?.toString() ?? '') ?? 70.0;
    final double height =
        double.tryParse(data['height']?.toString() ?? '') ?? 170.0;
    final String gender = (data['gender'] ?? 'Laki-laki').toString();
    final String activity = (data['activity'] ?? 'Jarang')
        .toString()
        .toLowerCase();

    int age = 25;
    if (data['dob'] != null && data['dob'].toString().isNotEmpty) {
      try {
        final dob = DateTime.parse(data['dob']);
        age = DateTime.now().year - dob.year;
      } catch (_) {}
    }

    double bmr = 0;
    if (gender == 'Perempuan' ||
        gender.toLowerCase().contains('wanita') ||
        gender.toLowerCase().contains('female')) {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    } else {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    }

    double multiplier = 1.2;
    if (activity.contains('sangat aktif') || activity.contains('6-7')) {
      multiplier = 1.725;
    } else if (activity.contains('cukup aktif') ||
        activity.contains('3-5') ||
        activity.contains('sedang')) {
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

    _targetCalories = tdee.roundToDouble().clamp(1200, 3500);

    if (goal == 'Menurunkan Berat Badan') {
      _targetProtein = (_targetCalories * 0.30) / 4;
      _targetFat = (_targetCalories * 0.30) / 9;
      _targetCarbs = (_targetCalories * 0.40) / 4;
    } else if (goal == 'Menaikkan Berat Badan') {
      _targetProtein = (_targetCalories * 0.20) / 4;
      _targetFat = (_targetCalories * 0.25) / 9;
      _targetCarbs = (_targetCalories * 0.55) / 4;
    } else if (goal == 'Meningkatkan Massa Otot') {
      _targetProtein = (_targetCalories * 0.30) / 4;
      _targetFat = (_targetCalories * 0.25) / 9;
      _targetCarbs = (_targetCalories * 0.45) / 4;
    } else {
      _targetProtein = (_targetCalories * 0.20) / 4;
      _targetFat = (_targetCalories * 0.30) / 9;
      _targetCarbs = (_targetCalories * 0.50) / 4;
    }

    if (_conditions.contains('Diabetes')) {
      _targetCarbs = (_targetCalories * 0.35) / 4;
      _targetProtein = (_targetCalories * 0.35) / 4;
      _targetFat = (_targetCalories * 0.30) / 9;
    }
    if (_conditions.contains('Kolesterol Tinggi')) {
      _targetFat = (_targetCalories * 0.20) / 9;
      _targetCarbs = (_targetCalories * 0.60) / 4;
      _targetProtein = (_targetCalories * 0.20) / 4;
    }
  }

  List<String> _getGoalTips() {
    if (_goal == 'Menurunkan Berat Badan') {
      return [
        'Fokus pada makanan padat nutrisi yang rendah kalori tetapi tinggi serat.',
        'Pilih camilan segar seperti buah potong atau Asinan Bogor tanpa kerupuk berlebih.',
        'Usahakan minum air mineral minimal 8-10 gelas sehari untuk membantu rasa kenyang.',
        'Batasi penggunaan saus manis, santan, and gorengan bertepung tinggi minyak.',
      ];
    } else if (_goal == 'Menaikkan Berat Badan') {
      return [
        'Konsumsilah makanan dengan kepadatan kalori sehat seperti kacang-kacangan, alpukat, dan keju.',
        'Doclang dan Soto Kuning Bogor adalah pilihan bagus untuk asupan energi padat.',
        'Makan lebih sering dengan porsi sedang (misal 5-6 kali sehari termasuk camilan).',
        'Sertakan minuman berkalori sehat seperti jus buah murni, susu, atau yogurt plain.',
      ];
    } else if (_goal == 'Meningkatkan Massa Otot') {
      return [
        'Prioritaskan asupan protein berkualitas tinggi seperti daging tanpa lemak, telur, tahu, dan tempe.',
        'Cungkring dan Soto Kuning merupakan sumber protein hewani khas yang kaya gizi.',
        'Konsumsi protein sekitar 20-30 gram dalam setiap sesi makan utama Anda.',
        'Cukupi kebutuhan karbohidrat kompleks sebelum dan sesudah latihan untuk energi optimal.',
      ];
    } else {
      return [
        'Konsumsi makanan bergizi seimbang dengan porsi piring makan sehat.',
        'Lakukan pemantauan kalori harian agar stabil mendekati target 2000 kkal.',
        'Variasikan asupan buah-buahan, sayuran hijau, karbohidrat kompleks, and protein nabati.',
        'Perhatikan kandungan natrium (garam) agar tidak melebihi 2000 mg per hari.',
      ];
    }
  }

  void _showFoodDetailsBottomSheet(Map<String, dynamic> food) {
    final List<String> healthWarnings = [];
    final String foodName = (food['name'] as String).toLowerCase();
    final double carbs = (food['carbs'] as num).toDouble();
    final double fat = (food['fat'] as num).toDouble();
    final double sodium = (food['sodium'] as num).toDouble();

    for (var condition in _conditions) {
      if (condition == 'Diabetes' && carbs > 15.0) {
        healthWarnings.add(
          'Perhatian untuk penderita Diabetes: Makanan ini memiliki kadar karbohidrat/gula yang cukup tinggi ($carbs g per 100g). Batasi porsi konsumsi.',
        );
      }
      if (condition == 'Hipertensi' && sodium > 150.0) {
        healthWarnings.add(
          'Perhatian untuk penderita Hipertensi: Kandungan natrium/garam makanan ini cukup tinggi ($sodium mg). Harap batasi penggunaan kuah/saus asin.',
        );
      }
      if (condition == 'Kolesterol Tinggi' &&
          (fat > 10.0 ||
              foodName.contains('soto') ||
              foodName.contains('cungkring'))) {
        healthWarnings.add(
          'Perhatian untuk penderita Kolesterol Tinggi: Hindari mengonsumsi bagian jeroan atau kuah santan berlebih pada hidangan ini.',
        );
      }
      if (condition == 'Asam Urat' &&
          (foodName.contains('cungkring') || foodName.contains('soto'))) {
        healthWarnings.add(
          'Perhatian untuk penderita Asam Urat: Hidangan ini mengandung jeroan/kaki sapi yang tinggi purin. Batasi atau hindari untuk mencegah kekambuhan.',
        );
      }
      if (condition == 'Maag / GERD' &&
          (foodName.contains('asinan') || foodName.contains('pedas'))) {
        healthWarnings.add(
          'Perhatian untuk penderita Maag / GERD: Makanan ini cenderung asam dan pedas, yang dapat memicu kenaikan asam lambung Anda.',
        );
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SafeArea(
              top: false,
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: (food['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.restaurant_menu_rounded,
                            color: food['color'] as Color,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food['name'] as String,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.neutralColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Takaran saji standar: 100 gram',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      food['desc'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Kandungan Nutrisi (Per 100g)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.neutralColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNutritionFactItem(
                          'Energi',
                          '${food['calories']} kkal',
                          Colors.amber,
                        ),
                        _buildNutritionFactItem(
                          'Protein',
                          '${food['protein']} g',
                          Colors.blue,
                        ),
                        _buildNutritionFactItem(
                          'Karbo',
                          '${food['carbs']} g',
                          Colors.green,
                        ),
                        _buildNutritionFactItem(
                          'Lemak',
                          '${food['fat']} g',
                          Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNutritionFactItem(
                          'Serat',
                          '${food['fiber']} g',
                          Colors.teal,
                        ),
                        _buildNutritionFactItem(
                          'Natrium',
                          '${food['sodium']} mg',
                          Colors.orange,
                        ),
                        const SizedBox(width: 72),
                        const SizedBox(width: 72),
                      ],
                    ),
                    if (healthWarnings.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.red.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Catatan Kesehatan Khusus',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: healthWarnings.map((warn) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '• ',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          warn,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            color: Colors.red.shade900,
                                            height: 1.4,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FAF7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.lightbulb_outline_rounded,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Saran Penyajian Sehat',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            food['tip'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF0F766E),
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNutritionFactItem(String label, String value, Color color) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppTheme.neutralColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    final calculatedCalories =
        ((_selectedCalculatorFood?['calories'] as double) *
                _calculatorPortionGrams /
                100.0)
            .toStringAsFixed(1);
    final calculatedProtein =
        ((_selectedCalculatorFood?['protein'] as double) *
                _calculatorPortionGrams /
                100.0)
            .toStringAsFixed(1);
    final calculatedCarbs =
        ((_selectedCalculatorFood?['carbs'] as double) *
                _calculatorPortionGrams /
                100.0)
            .toStringAsFixed(1);
    final calculatedFat =
        ((_selectedCalculatorFood?['fat'] as double) *
                _calculatorPortionGrams /
                100.0)
            .toStringAsFixed(1);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFF0F766E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, $_userName 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Target Anda: $_goal',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.white.withOpacity(0.2), thickness: 1),
                  const SizedBox(height: 12),
                  const Text(
                    'Rekomendasi Batas Asupan Harian Anda:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTargetMetric(
                        'Kalori',
                        '${_targetCalories.toInt()}',
                        'kkal',
                      ),
                      _buildTargetMetric(
                        'Karbo',
                        '${_targetCarbs.toInt()}',
                        'g',
                      ),
                      _buildTargetMetric(
                        'Protein',
                        '${_targetProtein.toInt()}',
                        'g',
                      ),
                      _buildTargetMetric('Lemak', '${_targetFat.toInt()}', 'g'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Panduan Gizi Kuliner Bogor 🍲',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.neutralColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ketuk makanan untuk melihat detail kalori, nutrisi, dan tips sehatnya.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 124,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _bogorFoods.length,
                separatorBuilder: (context, index) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final food = _bogorFoods[index];
                  return GestureDetector(
                    onTap: () => _showFoodDetailsBottomSheet(food),
                    child: Container(
                      width: 140,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: (food['color'] as Color).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.restaurant_menu_rounded,
                              color: food['color'] as Color,
                              size: 18,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            food['name'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.neutralColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${food['calories']} kkal / 100g',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tips Pola Makan Anda 💡',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.neutralColor,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _getGoalTips().length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final tip = _getGoalTips()[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0FAF7),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_rounded,
                          color: AppTheme.primaryColor,
                          size: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetMetric(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 1),
            Text(
              unit,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSimulatedMetric(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.neutralColor,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 1),
            Text(
              unit,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
