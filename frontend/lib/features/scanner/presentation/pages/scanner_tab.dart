import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/widgets/meal_image.dart';
import '../../../../core/widgets/top_toast.dart';
import 'package:image_picker/image_picker.dart';

class ScannerTab extends StatefulWidget {
  final VoidCallback? onScanSaved;
  final DateTime? selectedDate;
  const ScannerTab({super.key, this.onScanSaved, this.selectedDate});

  @override
  State<ScannerTab> createState() => _ScannerTabState();
}

class _ScannerTabState extends State<ScannerTab> with WidgetsBindingObserver {
  final ApiService _apiService = ApiService();
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraReady = false;
  bool _isFlashOn = false;
  bool _showGrid = true;
  bool _isScanning = false;
  int _currentZoomIndex = 0;
  bool _isDemoMode = false;
  double _demoZoomScale = 1.0;

  final List<String> _demoImages = [
    'assets/image1.png',
    'assets/image2.png',
    'assets/image3.png',
  ];
  int _demoImageIndex = 0;

  final List<Map<String, dynamic>> _zoomLevels = [
    {'label': '0.5', 'value': 0.5},
    {'label': '1x', 'value': 1.0},
    {'label': '2x', 'value': 2.0},
    {'label': '3x', 'value': 3.0},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentZoomIndex = 1;
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isDemoMode = true;
        });
        return;
      }

      final backCamera = _cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      if (!mounted) return;

      setState(() {
        _isCameraReady = true;
        _isDemoMode = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDemoMode = true;
        _isCameraReady = false;
      });
    }
  }

  Future<void> _setZoom(int index) async {
    setState(() {
      _currentZoomIndex = index;
      _demoZoomScale = (_zoomLevels[index]['value'] as double);
    });

    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final double maxZoom = await _cameraController!.getMaxZoomLevel();
        final double minZoom = await _cameraController!.getMinZoomLevel();
        final double targetZoom = (_zoomLevels[index]['value'] as double).clamp(
          minZoom,
          maxZoom,
        );
        await _cameraController!.setZoomLevel(targetZoom);
      } catch (_) {}
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    setState(() {
      _isFlashOn = !_isFlashOn;
    });

    try {
      await _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (_) {}
  }

  void _showInstructionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Container(
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
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 24),
                _buildInstructionItem(
                  Icons.wb_sunny_rounded,
                  Colors.amber,
                  'Pencahayaan yang Cukup',
                  'Pastikan makanan diterangi cahaya terang.',
                ),
                const SizedBox(height: 16),
                _buildInstructionItem(
                  Icons.center_focus_strong_rounded,
                  AppTheme.primaryColor,
                  'Fokus pada Satu Piring',
                  'Posisikan makanan tepat di tengah frame.',
                ),
                const SizedBox(height: 16),
                _buildInstructionItem(
                  Icons.photo_camera_back_rounded,
                  Colors.blue,
                  'Sudut Foto 45 Derajat',
                  'Ambil foto dari kemiringan 45 derajat atau tegak lurus dari atas.',
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
            color: color.withValues(alpha: 0.1),
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

  void _showFoodSelectorSheet() {
    final textController = TextEditingController();
    String? selectedPreset;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pindai Makanan Cerdas AI',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neutralColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pilih makanan yang terdeteksi di kamera atau ketikkan namanya secara manual.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'PILIHAN CEPAT (PRESET)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        [
                          'Soto Kuning Bogor',
                          'Asinan Bogor',
                          'Nasi Goreng Spesial',
                          'Chicken Salad Bowl',
                        ].map((food) {
                          final isSel = selectedPreset == food;
                          return ChoiceChip(
                            label: Text(food),
                            selected: isSel,
                            selectedColor: const Color(0xFFF0FAF7),
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSel
                                  ? AppTheme.primaryColor
                                  : Colors.grey.shade700,
                              fontWeight: isSel
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isSel
                                    ? AppTheme.primaryColor
                                    : Colors.grey.shade300,
                              ),
                            ),
                            showCheckmark: false,
                            onSelected: (selected) {
                              setSheetState(() {
                                if (selected) {
                                  selectedPreset = food;
                                  textController.clear();
                                } else {
                                  selectedPreset = null;
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'ATAU KETIK NAMA MAKANAN LAIN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Sate Ayam, Gado-gado, dll.',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      fillColor: const Color(0xFFF8F9FA),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (val) {
                      if (val.trim().isNotEmpty && selectedPreset != null) {
                        setSheetState(() {
                          selectedPreset = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        final String foodName =
                            selectedPreset ?? textController.text.trim();
                        if (foodName.isEmpty) {
                          showTopToast(
                            context,
                            'Silakan pilih atau ketik nama makanan.',
                            isError: true,
                          );
                          return;
                        }
                        Navigator.pop(context);
                        _startAnalysisFlow(foodName: foodName);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Mulai Analisis AI',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _captureAndAnalyze() async {
    if (_isScanning) return;
    if (_isDemoMode) {
      String foodName = 'Soto Kuning Bogor';
      if (_demoImageIndex == 0) {
        foodName = 'Doclang';
      } else if (_demoImageIndex == 1) {
        foodName = 'Asinan Bogor';
      } else if (_demoImageIndex == 2) {
        foodName = 'Soto Kuning Bogor';
      }
      _startAnalysisFlow(foodName: foodName);
    } else {
      if (_cameraController == null || !_cameraController!.value.isInitialized)
        return;
      try {
        final file = await _cameraController!.takePicture();
        _startAnalysisFlow(filePath: file.path);
      } catch (e) {
        if (!mounted) return;
        showTopToast(context, 'Gagal mengambil gambar dari kamera', isError: true);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isScanning) return;
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _startAnalysisFlow(filePath: pickedFile.path);
      }
    } catch (e) {
      if (!mounted) return;
      showTopToast(context, 'Gagal memilih gambar dari galeri', isError: true);
    }
  }

  Future<void> _startAnalysisFlow({String? foodName, String? filePath}) async {
    setState(() {
      _isScanning = true;
    });

    try {
      if (_isFlashOn &&
          _cameraController != null &&
          _cameraController!.value.isInitialized) {
        await _cameraController!.setFlashMode(FlashMode.off);
      }

      final Map<String, dynamic> result;
      if (filePath != null) {
        result = await _apiService.scanFoodImage(filePath);
      } else if (foodName != null) {
        result = await _apiService.scanFood(foodName);
      } else {
        result = {'success': false, 'message': 'Parameter tidak valid'};
      }

      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;

      setState(() {
        _isScanning = false;
      });

      if (result['success'] == true) {
        final isBogorFood = result['is_bogor_food'] ?? true;
        if (isBogorFood == false) {
          _showNotBogorAlert(
            result['alert_message'] ??
                'Makanan tidak terdeteksi sebagai makanan khas Bogor.',
          );
        } else {
          _showResultSheet(result);
        }
      } else {
        showTopToast(
          context,
          result['message'] ?? 'Gagal memindai makanan',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
      });
      showTopToast(context, 'Terjadi kesalahan saat memproses foto', isError: true);
    }
  }

  void _showNotBogorAlert(String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Colors.orange.shade700,
                size: 28,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Bukan Makanan Khas Bogor',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Tutup',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        );
      },
    );
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
        final confidence = (data['confidence'] as num?)?.toDouble();

        Color confidenceColor = Colors.green;
        if (confidence != null) {
          if (confidence < 0.5) {
            confidenceColor = Colors.orange;
          } else if (confidence < 0.85) {
            confidenceColor = Colors.blue;
          }
        }

        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.6,
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
                        if (confidence != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: confidenceColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Akurasi: ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: confidenceColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${(confidence * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: confidenceColor,
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
                            child: MealImage(
                              imagePath: imgPath,
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
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
                    _buildMacroProgress(
                      'Karbohidrat',
                      carbs,
                      'g',
                      Colors.orange,
                      100,
                    ),
                    const SizedBox(height: 12),
                    _buildMacroProgress(
                      'Protein',
                      protein,
                      'g',
                      AppTheme.primaryColor,
                      80,
                    ),
                    const SizedBox(height: 12),
                    _buildMacroProgress(
                      'Lemak',
                      fat,
                      'g',
                      Colors.redAccent,
                      60,
                    ),
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
                        color: AppTheme.primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        ),
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
                          final now = DateTime.now();
                          final targetDate = widget.selectedDate ?? now;
                          final timeString =
                              "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
                          final timestamp =
                              "${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')} $timeString";

                          final prefs = await SharedPreferences.getInstance();
                          final email =
                              prefs.getString('logged_in_email') ??
                              'guest@nutrify.com';

                          final mealData = {
                            'email': email,
                            'food_name': foodName,
                            'calories': calories,
                            'protein': protein,
                            'carbs': carbs,
                            'fat': fat,
                            'health_score': score,
                            'components': components,
                            'timestamp': timestamp,
                            'image_path': imgPath,
                            'is_manual': false,
                          };

                          final res = await _apiService.saveMeal(mealData);
                          if (!mounted) return;

                          if (res['success'] == true) {
                            showTopToast(
                              context,
                              'Makanan berhasil disimpan ke jurnal harian.',
                            );
                            navigator.pop();
                            if (widget.onScanSaved != null) {
                              widget.onScanSaved!();
                            }
                          } else {
                            showTopToast(
                              context,
                              res['message'] ?? 'Gagal menyimpan makanan',
                              isError: true,
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
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMacroProgress(
    String label,
    double val,
    String unit,
    Color color,
    double maxVal,
  ) {
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
                  child: Container(color: color),
                ),
                Expanded(flex: ((1 - pct) * 100).toInt(), child: Container()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraPreview() {
    if (_isDemoMode) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _demoImageIndex = (_demoImageIndex + 1) % _demoImages.length;
          });
        },
        child: Container(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Transform.scale(
                scale: _demoZoomScale,
                child: Image.asset(
                  _demoImages[_demoImageIndex],
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'MODE DEMO',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isCameraReady || _cameraController == null) {
      return Container(
        color: const Color(0xFF1A1A1A),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    final previewSize = _cameraController!.value.previewSize!;
    final previewRatio = previewSize.height / previewSize.width;

    double scale = 1.0;
    if (deviceRatio > previewRatio) {
      scale = deviceRatio / previewRatio;
    } else {
      scale = previewRatio / deviceRatio;
    }

    return Transform.scale(
      scale: scale,
      child: Center(child: CameraPreview(_cameraController!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildCameraPreview(),
                  if (_showGrid) CustomPaint(painter: CameraGridPainter()),
                  if (_isScanning)
                    Container(
                      color: Colors.black.withValues(alpha: 0.7),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(
                                color: AppTheme.primaryColor,
                                strokeWidth: 3,
                                backgroundColor: AppTheme.primaryColor
                                    .withValues(alpha: 0.15),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Menganalisis...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'AI sedang mengidentifikasi makanan',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            top: topPadding + 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildTopControl(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    _buildTopControl(
                      icon: _isFlashOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      isActive: _isFlashOn,
                      onTap: _toggleFlash,
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildTopControl(
                      icon: _showGrid
                          ? Icons.grid_on_rounded
                          : Icons.grid_off_rounded,
                      isActive: _showGrid,
                      onTap: () {
                        setState(() {
                          _showGrid = !_showGrid;
                        });
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildTopControl(
                      icon: Icons.help_outline_rounded,
                      onTap: _showInstructionSheet,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding + 136,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_zoomLevels.length, (index) {
                    return _buildZoomChip(index);
                  }),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding + 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _isScanning ? null : _pickFromGallery,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _isScanning ? null : _captureAndAnalyze,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        shape: _isScanning
                            ? BoxShape.rectangle
                            : BoxShape.circle,
                        borderRadius: _isScanning
                            ? BorderRadius.circular(8)
                            : null,
                        color: _isScanning ? Colors.red : Colors.white,
                      ),
                      width: _isScanning ? 30 : double.infinity,
                      height: _isScanning ? 30 : double.infinity,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    if (_cameras.length > 1 && _cameraController != null) {
                      final currentDir =
                          _cameraController!.description.lensDirection;
                      final newCamera = _cameras.firstWhere(
                        (cam) => cam.lensDirection != currentDir,
                        orElse: () => _cameras.first,
                      );
                      _cameraController?.dispose();
                      _cameraController = CameraController(
                        newCamera,
                        ResolutionPreset.high,
                        enableAudio: false,
                        imageFormatGroup: ImageFormatGroup.jpeg,
                      );
                      _cameraController!.initialize().then((_) {
                        if (mounted) setState(() {});
                      });
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.flip_camera_ios_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopControl({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryColor.withValues(alpha: 0.85)
              : Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive
                ? AppTheme.primaryColor.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildZoomChip(int index) {
    final isActive = _currentZoomIndex == index;
    final label = _zoomLevels[index]['label'] as String;

    return GestureDetector(
      onTap: () => _setZoom(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: isActive ? 38 : 34,
        height: isActive ? 38 : 34,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? AppTheme.primaryColor : Colors.transparent,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.65),
              fontSize: isActive ? 12 : 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
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
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 2 / 3, 0),
      Offset(size.width * 2 / 3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 2 / 3),
      Offset(size.width, size.height * 2 / 3),
      paint,
    );

    final cornerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    const double cornerLen = 24.0;
    const double pad = 24.0;

    final path1 = Path()
      ..moveTo(pad, pad + cornerLen)
      ..lineTo(pad, pad)
      ..lineTo(pad + cornerLen, pad);
    canvas.drawPath(path1, cornerPaint);

    final path2 = Path()
      ..moveTo(size.width - pad - cornerLen, pad)
      ..lineTo(size.width - pad, pad)
      ..lineTo(size.width - pad, pad + cornerLen);
    canvas.drawPath(path2, cornerPaint);

    final path3 = Path()
      ..moveTo(pad, size.height - pad - cornerLen)
      ..lineTo(pad, size.height - pad)
      ..lineTo(pad + cornerLen, size.height - pad);
    canvas.drawPath(path3, cornerPaint);

    final path4 = Path()
      ..moveTo(size.width - pad - cornerLen, size.height - pad)
      ..lineTo(size.width - pad, size.height - pad)
      ..lineTo(size.width - pad, size.height - pad - cornerLen);
    canvas.drawPath(path4, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
