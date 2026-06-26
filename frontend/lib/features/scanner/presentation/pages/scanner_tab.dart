import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';

class ScannerTab extends StatefulWidget {
  final VoidCallback? onScanSaved;
  const ScannerTab({super.key, this.onScanSaved});

  @override
  State<ScannerTab> createState() => _ScannerTabState();
}

class _ScannerTabState extends State<ScannerTab> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late AnimationController _animationController;
  double _zoomScale = 1.0;
  int _selectedPresetIndex = 0;
  bool _isFlashOn = false;
  bool _showGrid = true;
  bool _isScanning = false;

  final List<Map<String, String>> _presets = [
    {
      'name': 'Soto Kuning Bogor',
      'image': 'assets/image3.png',
      'desc': 'Soto hangat gurih bersantan khas Bogor'
    },
    {
      'name': 'Asinan Bogor',
      'image': 'assets/image2.png',
      'desc': 'Campuran buah dan sayur segar kuah pedas manis cuka'
    },
    {
      'name': 'Nasi Goreng Spesial',
      'image': 'assets/image1.png',
      'desc': 'Nasi goreng lezat dengan telur mata sapi'
    },
    {
      'name': 'Chicken Salad Bowl',
      'image': 'assets/image2.png',
      'desc': 'Salad dada ayam kaya protein dan serat tinggi'
    }
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showInstructionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const Text(
                'Cara Foto Makanan agar AI Akurat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neutralColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Patuhi petunjuk di bawah ini agar pemindaian nutrisi makanan Anda tepat.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 24),
              _buildInstructionItem(
                Icons.wb_sunny_rounded,
                Colors.amber,
                'Pencahayaan yang Cukup',
                'Pastikan makanan diterangi cahaya terang. Hindari memotret di ruangan yang gelap atau terdapat bayangan besar.',
              ),
              const SizedBox(height: 16),
              _buildInstructionItem(
                Icons.center_focus_strong_rounded,
                AppTheme.primaryColor,
                'Fokus pada Satu Piring',
                'Dekatkan kamera dan posisikan makanan tepat di tengah kotak panduan. Hindari objek lain masuk ke frame.',
              ),
              const SizedBox(height: 16),
              _buildInstructionItem(
                Icons.photo_camera_back_rounded,
                Colors.blue,
                'Sudut Foto 45 Derajat',
                'Ambil foto dari kemiringan 45 derajat atau tegak lurus dari atas agar AI dapat mendeteksi kedalaman porsi makanan.',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Saya Mengerti',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInstructionItem(
    IconData icon,
    Color color,
    String title,
    String desc,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neutralColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _startScanProcess() async {
    setState(() {
      _isScanning = true;
    });

    final targetFood = _presets[_selectedPresetIndex]['name']!;
    final result = await _apiService.scanFood(targetFood);

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    setState(() {
      _isScanning = false;
    });

    if (result['success'] == true) {
      _showResultSheet(result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal memindai makanan'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showResultSheet(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final calories = data['calories'] as double;
        final protein = data['protein'] as double;
        final carbs = data['carbs'] as double;
        final fat = data['fat'] as double;
        final foodName = data['food_name'] as String;
        final score = data['health_score'] as int;
        final description = data['description'] as String;
        final components = data['components'] as String;
        final imgPath = data['image_path'] as String;

        String grade = 'A';
        Color gradeColor = Colors.green;
        if (score < 70) {
          grade = 'C';
          gradeColor = Colors.orange;
        } else if (score < 85) {
          grade = 'B';
          gradeColor = Colors.blue;
        }

        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.6,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              foodName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.neutralColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hasil Analisis AI Nutrify',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: gradeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Skor: ',
                              style: TextStyle(
                                fontSize: 12,
                                color: gradeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              grade,
                              style: TextStyle(
                                fontSize: 18,
                                color: gradeColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            imgPath,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Estimasi Kalori Porsi',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    calories.toStringAsFixed(0),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.neutralColor,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'kkal',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Kandungan Makronutrisi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neutralColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMacroProgress('Karbohidrat', carbs, 'g', Colors.orange, 100),
                  const SizedBox(height: 12),
                  _buildMacroProgress('Protein', protein, 'g', AppTheme.primaryColor, 80),
                  const SizedBox(height: 12),
                  _buildMacroProgress('Lemak', fat, 'g', Colors.redAccent, 60),
                  const SizedBox(height: 24),
                  const Text(
                    'Komponen Terdeteksi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neutralColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    components,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Catatan Ahli Gizi AI',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neutralColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
                    ),
                    child: Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.neutralColor,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        final timeString = TimeOfDay.now().format(context);

                        final prefs = await SharedPreferences.getInstance();
                        final email = prefs.getString('logged_in_email') ?? 'guest@nutrify.com';
                        
                        final mealData = {
                          'email': email,
                          'food_name': foodName,
                          'calories': calories,
                          'protein': protein,
                          'carbs': carbs,
                          'fat': fat,
                          'health_score': score,
                          'components': components,
                          'timestamp': 'Hari Ini, $timeString',
                          'image_path': imgPath,
                          'is_manual': false,
                        };

                        final res = await _apiService.saveMeal(mealData);
                        if (!mounted) return;
                        
                        if (res['success'] == true) {
                          navigator.pop();
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Makanan berhasil disimpan ke jurnal harian.'),
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          );
                          if (widget.onScanSaved != null) {
                            widget.onScanSaved!();
                          }
                        } else {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(res['message'] ?? 'Gagal menyimpan makanan'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Simpan ke Jurnal Makanan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMacroProgress(String label, double val, String unit, Color color, double maxVal) {
    final double pct = (val / maxVal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.neutralColor,
              ),
            ),
            Text(
              '${val.toStringAsFixed(0)} $unit',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 8,
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(
                  flex: (pct * 100).toInt(),
                  child: Container(
                    color: color,
                  ),
                ),
                Expanded(
                  flex: ((1 - pct) * 100).toInt(),
                  child: Container(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double cameraHeight = size.height * 0.42;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Scanner',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.neutralColor,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Pindai makanan Anda secara instan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _showInstructionSheet,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Icon(
                      Icons.help_outline_rounded,
                      size: 20,
                      color: AppTheme.neutralColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Container(
                height: cameraHeight,
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(
                      scale: _zoomScale,
                      child: Center(
                        child: Opacity(
                          opacity: 0.85,
                          child: Image.asset(
                            _presets[_selectedPresetIndex]['image']!,
                            height: cameraHeight,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    if (_showGrid)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: CameraGridPainter(),
                        ),
                      ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.lens, color: Colors.red, size: 8),
                            SizedBox(width: 6),
                            Text(
                              'MOCK REC',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isFlashOn = !_isFlashOn;
                              });
                            },
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showGrid = !_showGrid;
                              });
                            },
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _showGrid ? Icons.grid_on_rounded : Icons.grid_off_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        final double verticalOffset = _animationController.value * cameraHeight;
                        return Positioned(
                          top: verticalOffset,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryColor.withOpacity(0.1),
                                  AppTheme.primaryColor,
                                  AppTheme.primaryColor.withOpacity(0.1),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    if (_isScanning)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.6),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  color: AppTheme.primaryColor,
                                  strokeWidth: 5,
                                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Menganalisis Gizi...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Mengidentifikasi makanan melalui AI model',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildZoomBtn(1.0, '1x'),
                            _buildZoomBtn(1.8, '2x'),
                            _buildZoomBtn(3.0, '3x'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Preset Makanan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutralColor,
                  ),
                ),
                Text(
                  'Geser untuk simulasi',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _presets.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final isSelected = _selectedPresetIndex == index;
                final item = _presets[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPresetIndex = index;
                    });
                  },
                  child: Container(
                    width: 140,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF0FAF7) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              color: const Color(0xFFF8F9FA),
                              width: double.infinity,
                              child: Image.asset(
                                item['image']!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['name']!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.neutralColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['desc']!,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey.shade400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isScanning ? null : _startScanProcess,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Ambil Foto & Analisis AI',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildZoomBtn(double val, String label) {
    final active = _zoomScale == val;
    return GestureDetector(
      onTap: () {
        setState(() {
          _zoomScale = val;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.grey,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class CameraGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(size.width / 3, 0), Offset(size.width / 3, size.height), paint);
    canvas.drawLine(Offset(size.width * 2 / 3, 0), Offset(size.width * 2 / 3, size.height), paint);

    canvas.drawLine(Offset(0, size.height / 3), Offset(size.width, size.height / 3), paint);
    canvas.drawLine(Offset(0, size.height * 2 / 3), Offset(size.width, size.height * 2 / 3), paint);

    final cornerPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    const double cornerLen = 20.0;
    const double padding = 20.0;

    final path1 = Path()
      ..moveTo(padding, padding + cornerLen)
      ..lineTo(padding, padding)
      ..lineTo(padding + cornerLen, padding);
    canvas.drawPath(path1, cornerPaint);

    final path2 = Path()
      ..moveTo(size.width - padding - cornerLen, padding)
      ..lineTo(size.width - padding, padding)
      ..lineTo(size.width - padding, padding + cornerLen);
    canvas.drawPath(path2, cornerPaint);

    final path3 = Path()
      ..moveTo(padding, size.height - padding - cornerLen)
      ..lineTo(padding, size.height - padding)
      ..lineTo(padding + cornerLen, size.height - padding);
    canvas.drawPath(path3, cornerPaint);

    final path4 = Path()
      ..moveTo(size.width - padding - cornerLen, size.height - padding)
      ..lineTo(size.width - padding, size.height - padding)
      ..lineTo(size.width - padding, size.height - padding - cornerLen);
    canvas.drawPath(path4, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
