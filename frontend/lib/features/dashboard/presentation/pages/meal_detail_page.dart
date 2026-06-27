import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/date_helper.dart';

class MealDetailPage extends StatefulWidget {
  final Map<String, dynamic> meal;
  final VoidCallback? onDeleteSuccess;

  const MealDetailPage({
    super.key,
    required this.meal,
    this.onDeleteSuccess,
  });

  @override
  State<MealDetailPage> createState() => _MealDetailPageState();
}

class _MealDetailPageState extends State<MealDetailPage> {
  final ApiService _apiService = ApiService();
  double _portion = 1.0;
  bool _isDeleting = false;
  bool _isBookmarked = false;

  // Preset database of ingredient details for premium breakdown mapping
  final Map<String, Map<String, num>> _ingredientDatabase = {
    'pita bread': {'calories': 318, 'weight': 120},
    'beef': {'calories': 426, 'weight': 150},
    'lettuce': {'calories': 6, 'weight': 30},
    'shredded carrots': {'calories': 11, 'weight': 25},
    'red cabbage': {'calories': 7, 'weight': 25},
    'corn': {'calories': 129, 'weight': 150},
    'asinan': {'calories': 180, 'weight': 200},
    'soto': {'calories': 250, 'weight': 250},
    'nasi goreng': {'calories': 450, 'weight': 300},
    'salad bowl': {'calories': 120, 'weight': 150},
    'chicken': {'calories': 220, 'weight': 120},
    'egg': {'calories': 70, 'weight': 50},
    'rice': {'calories': 200, 'weight': 150},
    'vegetables': {'calories': 45, 'weight': 100},
    'daging sapi': {'calories': 250, 'weight': 100},
    'daging': {'calories': 250, 'weight': 100},
    'saus': {'calories': 50, 'weight': 30},
    'bumbu': {'calories': 40, 'weight': 20},
    'kerupuk': {'calories': 80, 'weight': 15},
    'kol': {'calories': 10, 'weight': 40},
    'tahu': {'calories': 60, 'weight': 60},
    'tempe': {'calories': 90, 'weight': 50},
    'telur': {'calories': 75, 'weight': 55},
  };

  @override
  void initState() {
    super.initState();
    _loadBookmarkState();
  }

  Future<void> _loadBookmarkState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBookmarked = prefs.getBool('meal_bookmark_${widget.meal['id']}') ?? false;
    });
  }

  Future<void> _toggleBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    await prefs.setBool('meal_bookmark_${widget.meal['id']}', _isBookmarked);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isBookmarked ? 'Makanan disimpan ke Bookmark.' : 'Makanan dihapus dari Bookmark.'),
          backgroundColor: AppTheme.primaryColor,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  String _formatPortion(double portion) {
    if (portion == portion.toInt().toDouble()) {
      return portion.toInt().toString();
    }
    return portion.toStringAsFixed(1);
  }

  Widget _buildMealImage(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.restaurant_rounded, color: Colors.grey, size: 50),
        ),
      );
    } else if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.restaurant_rounded, color: Colors.grey, size: 50),
        ),
      );
    } else {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.restaurant_rounded, color: Colors.grey, size: 50),
        ),
      );
    }
  }

  List<Map<String, dynamic>> _parseIngredients() {
    final componentsStr = widget.meal['components'] as String? ?? '';
    if (componentsStr.trim().isEmpty) return [];

    final names = componentsStr.split(',');
    List<Map<String, dynamic>> list = [];

    for (var rawName in names) {
      final name = rawName.trim();
      if (name.isEmpty) continue;

      final key = name.toLowerCase();
      num cals = 50;
      num weight = 60;

      if (_ingredientDatabase.containsKey(key)) {
        cals = _ingredientDatabase[key]!['calories']!;
        weight = _ingredientDatabase[key]!['weight']!;
      } else {
        // Fallback generator based on length to make it consistent
        cals = 30 + (name.length * 4);
        weight = 40 + (name.length * 3);
      }

      list.add({
        'name': name,
        'calories': cals,
        'weight': weight,
      });
    }

    return list;
  }

  Future<void> _confirmDelete() async {
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
          content: const Text('Apakah Anda yakin ingin menghapus catatan makanan ini dari jurnal harian?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() {
                  _isDeleting = true;
                });
                try {
                  final mealId = widget.meal['id'] as int;
                  final res = await _apiService.deleteMeal(mealId);
                  if (res['success'] == true) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Catatan makanan berhasil dihapus.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      if (widget.onDeleteSuccess != null) {
                        widget.onDeleteSuccess!();
                      }
                      Navigator.pop(context);
                    }
                  } else {
                    setState(() {
                      _isDeleting = false;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(res['message'] ?? 'Gagal menghapus catatan.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  setState(() {
                    _isDeleting = false;
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
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
    final foodName = widget.meal['food_name'] ?? 'Makanan';
    final rawTimestamp = widget.meal['timestamp'] ?? 'Hari Ini';
    final friendlyTime = formatFriendlyTimestamp(rawTimestamp);

    // Baseline nutritional values
    final baseCalories = (widget.meal['calories'] as num?)?.toDouble() ?? 0.0;
    final baseProtein = (widget.meal['protein'] as num?)?.toDouble() ?? 0.0;
    final baseCarbs = (widget.meal['carbs'] as num?)?.toDouble() ?? 0.0;
    final baseFat = (widget.meal['fat'] as num?)?.toDouble() ?? 0.0;

    // Portioned nutritional values
    final calories = baseCalories * _portion;
    final protein = baseProtein * _portion;
    final carbs = baseCarbs * _portion;
    final fat = baseFat * _portion;

    // Parse and multiply ingredients
    final ingredients = _parseIngredients();
    double totalWeight = 0.0;
    for (var ing in ingredients) {
      totalWeight += (ing['weight'] as num).toDouble() * _portion;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Food Header Image
                Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.38,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                        child: _buildMealImage(widget.meal['image_path'] ?? ''),
                      ),
                    ),
                    // Gradient overlay at bottom of image for readability
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                          ),
                        ),
                      ),
                    ),
                    // Food title text on top of image
                    Positioned(
                      bottom: 24,
                      left: 24,
                      right: 24,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              foodName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.edit_outlined,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                    // Custom action buttons at top
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 10,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: _buildTopActionButton(Icons.arrow_back_ios_new_rounded),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {},
                            child: _buildTopActionButton(Icons.ios_share_rounded),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: _toggleBookmark,
                            child: _buildTopActionButton(
                              _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                              iconColor: _isBookmarked ? Colors.amber : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: _confirmDelete,
                            child: _buildTopActionButton(Icons.delete_outline_rounded, iconColor: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. Time & Portion Selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          friendlyTime,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Multiplier selector
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Row(
                          children: [
                            _buildPortionButton(
                              icon: Icons.remove,
                              onTap: () {
                                if (_portion > 0.5) {
                                  setState(() {
                                    _portion -= 0.5;
                                  });
                                }
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                _formatPortion(_portion),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.neutralColor,
                                ),
                              ),
                            ),
                            _buildPortionButton(
                              icon: Icons.add,
                              onTap: () {
                                if (_portion < 5.0) {
                                  setState(() {
                                    _portion += 0.5;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Macronutrients Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 2.1,
                    children: [
                      _buildMacroCard(
                        icon: Icons.blur_on_rounded,
                        color: Colors.blue.shade50,
                        iconColor: Colors.blue.shade600,
                        value: '${calories.toStringAsFixed(0)} kkal',
                        label: 'Calories',
                      ),
                      _buildMacroCard(
                        icon: Icons.workspace_premium_rounded,
                        color: Colors.red.shade50,
                        iconColor: Colors.red.shade600,
                        value: '${protein.toStringAsFixed(0)}g',
                        label: 'Protein',
                      ),
                      _buildMacroCard(
                        icon: Icons.layers_rounded,
                        color: Colors.orange.shade50,
                        iconColor: Colors.orange.shade600,
                        value: '${carbs.toStringAsFixed(0)}g',
                        label: 'Carbs',
                      ),
                      _buildMacroCard(
                        icon: Icons.eco_rounded,
                        color: Colors.green.shade50,
                        iconColor: Colors.green.shade600,
                        value: '${fat.toStringAsFixed(0)}g',
                        label: 'Fat',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 4. Ingredient Breakdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ingredient Breakdown',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.neutralColor,
                        ),
                      ),
                      Text(
                        'Edit total',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    '${totalWeight.toStringAsFixed(0)}g total',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Ingredient List
                if (ingredients.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text(
                      'Rincian bahan tidak tersedia.',
                      style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ingredients.length,
                    padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final ing = ingredients[index];
                      final name = ing['name'];
                      final ingCalories = (ing['calories'] as num).toDouble() * _portion;
                      final ingWeight = (ing['weight'] as num).toDouble() * _portion;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: Icon(Icons.close_rounded, color: Colors.grey.shade400, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.neutralColor,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${ingCalories.toStringAsFixed(0)} cal',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.neutralColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${ingWeight.toStringAsFixed(0)}g',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.edit_outlined, color: Colors.grey.shade400, size: 18),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),

          // 5. Floating Bottom "Add Ingredients" button
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).padding.bottom + 12,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Add Ingredients',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_isDeleting)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopActionButton(IconData icon, {Color iconColor = Colors.black87}) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }

  Widget _buildPortionButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTheme.neutralColor, size: 16),
      ),
    );
  }

  Widget _buildMacroCard({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutralColor,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.edit_outlined, color: Colors.grey.shade400, size: 12),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
