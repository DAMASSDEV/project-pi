import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/date_helper.dart';
import '../../../../core/widgets/meal_image.dart';

class MealDetailPage extends StatefulWidget {
  final Map<String, dynamic> meal;
  final VoidCallback? onDeleteSuccess;

  const MealDetailPage({super.key, required this.meal, this.onDeleteSuccess});

  @override
  State<MealDetailPage> createState() => _MealDetailPageState();
}

class _MealDetailPageState extends State<MealDetailPage> {
  final ApiService _apiService = ApiService();

  // Dynamic State variables loaded from the Postgres database entry
  late String _foodName;
  late double _calories;
  late double _protein;
  late double _carbs;
  late double _fat;
  late List<Map<String, dynamic>> _ingredientsList;

  double _portion = 1.0;
  bool _isSaving = false;
  bool _isDeleting = false;
  Timer? _portionSaveDebounce;

  // Preset database of ingredient details for premium breakdown mapping
  final Map<String, Map<String, num>> _ingredientDatabase = {
    'pita bread': {
      'calories': 318,
      'weight': 120,
      'protein': 8,
      'carbs': 55,
      'fat': 2,
    },
    'beef': {
      'calories': 426,
      'weight': 150,
      'protein': 38,
      'carbs': 0,
      'fat': 30,
    },
    'lettuce': {
      'calories': 6,
      'weight': 30,
      'protein': 0.5,
      'carbs': 1,
      'fat': 0.1,
    },
    'shredded carrots': {
      'calories': 11,
      'weight': 25,
      'protein': 0.3,
      'carbs': 2.5,
      'fat': 0.1,
    },
    'red cabbage': {
      'calories': 7,
      'weight': 25,
      'protein': 0.3,
      'carbs': 1.8,
      'fat': 0.1,
    },
    'corn': {
      'calories': 129,
      'weight': 150,
      'protein': 4,
      'carbs': 28,
      'fat': 1.5,
    },
    'asinan': {
      'calories': 180,
      'weight': 200,
      'protein': 3,
      'carbs': 35,
      'fat': 2,
    },
    'soto': {
      'calories': 250,
      'weight': 250,
      'protein': 18,
      'carbs': 10,
      'fat': 15,
    },
    'nasi goreng': {
      'calories': 450,
      'weight': 300,
      'protein': 14,
      'carbs': 70,
      'fat': 16,
    },
    'salad bowl': {
      'calories': 120,
      'weight': 150,
      'protein': 5,
      'carbs': 10,
      'fat': 8,
    },
    'chicken': {
      'calories': 220,
      'weight': 120,
      'protein': 26,
      'carbs': 0,
      'fat': 12,
    },
    'egg': {
      'calories': 70,
      'weight': 50,
      'protein': 6.5,
      'carbs': 0.6,
      'fat': 5.0,
    },
    'rice': {
      'calories': 200,
      'weight': 150,
      'protein': 4,
      'carbs': 44,
      'fat': 0.4,
    },
    'vegetables': {
      'calories': 45,
      'weight': 100,
      'protein': 2,
      'carbs': 9,
      'fat': 0.2,
    },
    'daging sapi': {
      'calories': 250,
      'weight': 100,
      'protein': 25,
      'carbs': 0,
      'fat': 17,
    },
    'daging': {
      'calories': 250,
      'weight': 100,
      'protein': 25,
      'carbs': 0,
      'fat': 17,
    },
    'saus': {
      'calories': 50,
      'weight': 30,
      'protein': 0.5,
      'carbs': 5,
      'fat': 3.5,
    },
    'bumbu': {
      'calories': 40,
      'weight': 20,
      'protein': 0.5,
      'carbs': 4,
      'fat': 2.5,
    },
    'kerupuk': {
      'calories': 80,
      'weight': 15,
      'protein': 1,
      'carbs': 12,
      'fat': 4,
    },
    'kol': {
      'calories': 10,
      'weight': 40,
      'protein': 0.5,
      'carbs': 2,
      'fat': 0.1,
    },
    'tahu': {'calories': 60, 'weight': 60, 'protein': 6, 'carbs': 2, 'fat': 4},
    'tempe': {'calories': 90, 'weight': 50, 'protein': 9, 'carbs': 8, 'fat': 5},
    'telur': {
      'calories': 75,
      'weight': 55,
      'protein': 7,
      'carbs': 0.7,
      'fat': 5.3,
    },
  };

  @override
  void initState() {
    super.initState();
    // Load initial values from the database entry
    _foodName = widget.meal['food_name'] ?? 'Makanan';
    _calories = (widget.meal['calories'] as num?)?.toDouble() ?? 0.0;
    _protein = (widget.meal['protein'] as num?)?.toDouble() ?? 0.0;
    _carbs = (widget.meal['carbs'] as num?)?.toDouble() ?? 0.0;
    _fat = (widget.meal['fat'] as num?)?.toDouble() ?? 0.0;
    _portion = (widget.meal['portion'] as num?)?.toDouble() ?? 1.0;
    _ingredientsList = _parseIngredients();
    _refineIngredientsFromDatabase();
  }

  Future<void> _refineIngredientsFromDatabase() async {
    for (int i = 0; i < _ingredientsList.length; i++) {
      final name = _ingredientsList[i]['name'] as String;
      final results = await _apiService.searchFoods(name);
      if (results.isEmpty) continue;

      final match = results.firstWhere(
        (r) => (r['food_name'] as String).toLowerCase() == name.toLowerCase(),
        orElse: () => results.first,
      );
      final servingSize = (match['serving_size_g'] as num).toDouble();
      if (servingSize <= 0) continue;

      final weight = (_ingredientsList[i]['weight'] as num).toDouble();
      final ratio = weight / servingSize;
      final cals = (match['calories'] as num).toDouble() * ratio;
      final prot = (match['protein'] as num).toDouble() * ratio;
      final carb = (match['carbs'] as num).toDouble() * ratio;
      final fatVal = (match['fat'] as num).toDouble() * ratio;

      if (!mounted) return;
      setState(() {
        _ingredientsList[i] = {
          'name': name,
          'calories': cals,
          'weight': weight,
          'protein': prot,
          'carbs': carb,
          'fat': fatVal,
        };
      });
    }
  }

  @override
  void dispose() {
    _portionSaveDebounce?.cancel();
    super.dispose();
  }

  void _adjustPortion(double delta) {
    setState(() {
      _portion = (_portion + delta).clamp(0.5, 5.0);
    });
    _portionSaveDebounce?.cancel();
    _portionSaveDebounce = Timer(const Duration(milliseconds: 700), () {
      _saveChangesToBackend();
    });
  }

  String _formatPortion(double portion) {
    if (portion == portion.toInt().toDouble()) {
      return portion.toInt().toString();
    }
    return portion.toStringAsFixed(1);
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
      num prot = 2.0;
      num carb = 8.0;
      num fatVal = 1.5;

      if (_ingredientDatabase.containsKey(key)) {
        cals = _ingredientDatabase[key]!['calories']!;
        weight = _ingredientDatabase[key]!['weight']!;
        prot = _ingredientDatabase[key]!['protein'] ?? (cals * 0.15 / 4);
        carb = _ingredientDatabase[key]!['carbs'] ?? (cals * 0.55 / 4);
        fatVal = _ingredientDatabase[key]!['fat'] ?? (cals * 0.30 / 9);
      } else {
        cals = 30 + (name.length * 4);
        weight = 40 + (name.length * 3);
        prot = cals * 0.15 / 4;
        carb = cals * 0.55 / 4;
        fatVal = cals * 0.30 / 9;
      }

      list.add({
        'name': name,
        'calories': cals.toDouble(),
        'weight': weight.toDouble(),
        'protein': prot.toDouble(),
        'carbs': carb.toDouble(),
        'fat': fatVal.toDouble(),
      });
    }

    return list;
  }

  // Recalculates total values based on ingredients
  void _recalculateTotals() {
    double totalCal = 0;
    double totalProt = 0;
    double totalCarb = 0;
    double totalFat = 0;

    for (var ing in _ingredientsList) {
      totalCal += (ing['calories'] as num).toDouble();
      totalProt += (ing['protein'] as num).toDouble();
      totalCarb += (ing['carbs'] as num).toDouble();
      totalFat += (ing['fat'] as num).toDouble();
    }

    setState(() {
      _calories = totalCal;
      _protein = totalProt;
      _carbs = totalCarb;
      _fat = totalFat;
    });
  }

  // Saves changes directly to the PostgreSQL database on the backend
  Future<void> _saveChangesToBackend() async {
    setState(() {
      _isSaving = true;
    });

    final mealId = widget.meal['id'] as int;
    final componentsStr = _ingredientsList.map((e) => e['name']).join(', ');

    final payload = {
      'food_name': _foodName,
      'calories': _calories,
      'protein': _protein,
      'carbs': _carbs,
      'fat': _fat,
      'components': componentsStr,
      'portion': _portion,
    };

    try {
      final res = await _apiService.updateMeal(mealId, payload);
      if (res['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Catatan makanan berhasil diperbarui.'),
              backgroundColor: AppTheme.primaryColor,
              duration: Duration(milliseconds: 800),
            ),
          );
        }

        setState(() {
          _calories = (res['meal']['calories'] as num).toDouble();
          _protein = (res['meal']['protein'] as num).toDouble();
          _carbs = (res['meal']['carbs'] as num).toDouble();
          _fat = (res['meal']['fat'] as num).toDouble();
          _portion = (res['meal']['portion'] as num?)?.toDouble() ?? _portion;
        });

        if (widget.onDeleteSuccess != null) {
          widget.onDeleteSuccess!(); // Trigger reload on parent screens
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan perubahan: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // Edit Food Name Dialog
  Future<void> _editFoodName() async {
    final controller = TextEditingController(text: _foodName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Ubah Nama Makanan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nama Makanan',
              hintText: 'Masukkan nama makanan...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isEmpty) return;
                Navigator.pop(context);
                setState(() {
                  _foodName = newName;
                });
                await _saveChangesToBackend();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // Edit Macro Card Dialog
  Future<void> _editMacro(String key, String label, double currentValue) async {
    final controller = TextEditingController(
      text: currentValue.toStringAsFixed(0),
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Ubah $label',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: label,
              suffixText: key == 'calories' ? 'kkal' : 'g',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final val = double.tryParse(controller.text.trim());
                if (val == null) return;
                Navigator.pop(context);
                setState(() {
                  // Divide by portion to set base value
                  if (key == 'calories') _calories = val / _portion;
                  if (key == 'protein') _protein = val / _portion;
                  if (key == 'carbs') _carbs = val / _portion;
                  if (key == 'fat') _fat = val / _portion;
                });
                await _saveChangesToBackend();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // Edit Total Weight Dialog (recalculates portion scale)
  Future<void> _editTotalWeight(double currentTotalWeight) async {
    final controller = TextEditingController(
      text: currentTotalWeight.toStringAsFixed(0),
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Edit Total Berat',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Total Berat Makanan',
              suffixText: 'g',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final targetWeight = double.tryParse(controller.text.trim());
                if (targetWeight == null || targetWeight <= 0) return;

                double baseWeight = 0.0;
                for (var ing in _ingredientsList) {
                  baseWeight += (ing['weight'] as num).toDouble();
                }
                if (baseWeight == 0) return;

                Navigator.pop(context);
                setState(() {
                  _portion = targetWeight / baseWeight;
                });
                await _saveChangesToBackend();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // Edit Individual Ingredient Dialog
  Future<void> _editIngredient(int index) async {
    final ing = _ingredientsList[index];

    String rawName = ing['name'] ?? 'Bahan';
    double initialQty = 1.0;
    String initialUnit = 'Potong';

    final regExp = RegExp(r'^(.+?)\s*\(\s*([\d\.]+)\s*(.+?)\s*\)$');
    if (regExp.hasMatch(rawName)) {
      final match = regExp.firstMatch(rawName)!;
      rawName = match.group(1)!.trim();
      initialQty = double.tryParse(match.group(2)!) ?? 1.0;
      initialUnit = match.group(3)!.trim();
    }

    final nameController = TextEditingController(text: rawName);
    final quantityController = TextEditingController(
      text: initialQty.toStringAsFixed(0),
    );
    String selectedUnit =
        [
          'Porsi',
          'Potong',
          'Iris',
          'Mangkok',
          'Gelas',
          'Sendok Makan',
          'Butir',
        ].contains(initialUnit)
        ? initialUnit
        : 'Potong';
    const List<String> units = [
      'Porsi',
      'Potong',
      'Iris',
      'Mangkok',
      'Gelas',
      'Sendok Makan',
      'Butir',
    ];
    Map<String, dynamic>? selectedFood;
    List<Map<String, dynamic>> suggestions = [];
    Timer? debounce;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Ubah Bahan Makanan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama Bahan'),
                    onChanged: (value) {
                      selectedFood = null;
                      debounce?.cancel();
                      debounce = Timer(
                        const Duration(milliseconds: 350),
                        () async {
                          final query = value.trim();
                          if (query.length < 2) {
                            setDialogState(() => suggestions = []);
                            return;
                          }
                          final results = await _apiService.searchFoods(query);
                          setDialogState(() => suggestions = results);
                        },
                      );
                    },
                  ),
                  if (suggestions.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 160),
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: suggestions.length,
                        itemBuilder: (context, i) {
                          final item = suggestions[i];
                          return ListTile(
                            dense: true,
                            title: Text(item['food_name'].toString()),
                            subtitle: Text(
                              '${(item['calories'] as num).toStringAsFixed(0)} kkal / ${(item['serving_size_g'] as num).toStringAsFixed(0)}g',
                            ),
                            onTap: () {
                              setDialogState(() {
                                nameController.text = item['food_name']
                                    .toString();
                                selectedFood = item;
                                suggestions = [];
                              });
                            },
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: quantityController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Jumlah',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedUnit,
                          decoration: const InputDecoration(
                            labelText: 'Satuan',
                          ),
                          items: units.map((unit) {
                            return DropdownMenuItem<String>(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedUnit = val;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newName = nameController.text.trim();
                    final qty =
                        double.tryParse(quantityController.text.trim()) ?? 1.0;
                    if (newName.isEmpty) return;

                    Navigator.pop(context);

                    double unitWeight = 100.0;
                    if (selectedUnit == 'Porsi') {
                      unitWeight = 150.0;
                    } else if (selectedUnit == 'Potong')
                      unitWeight = 80.0;
                    else if (selectedUnit == 'Iris')
                      unitWeight = 20.0;
                    else if (selectedUnit == 'Mangkok')
                      unitWeight = 200.0;
                    else if (selectedUnit == 'Gelas')
                      unitWeight = 200.0;
                    else if (selectedUnit == 'Sendok Makan')
                      unitWeight = 15.0;
                    else if (selectedUnit == 'Butir')
                      unitWeight = 50.0;

                    final totalWeight = qty * unitWeight;

                    double calsPerGram = 1.2;
                    double protPerGram = 1.2 * 0.15 / 4;
                    double carbPerGram = 1.2 * 0.55 / 4;
                    double fatPerGram = 1.2 * 0.30 / 9;

                    if (selectedFood != null) {
                      final servingSize =
                          (selectedFood!['serving_size_g'] as num).toDouble();
                      final dbCals = (selectedFood!['calories'] as num)
                          .toDouble();
                      final dbProt = (selectedFood!['protein'] as num)
                          .toDouble();
                      final dbCarb = (selectedFood!['carbs'] as num).toDouble();
                      final dbFat = (selectedFood!['fat'] as num).toDouble();

                      calsPerGram = dbCals / servingSize;
                      protPerGram = dbProt / servingSize;
                      carbPerGram = dbCarb / servingSize;
                      fatPerGram = dbFat / servingSize;
                    }

                    final newCals = calsPerGram * totalWeight;
                    final newProt = protPerGram * totalWeight;
                    final newCarb = carbPerGram * totalWeight;
                    final newFat = fatPerGram * totalWeight;

                    setState(() {
                      _ingredientsList[index] = {
                        'name': '$newName ($qty $selectedUnit)',
                        'calories': newCals,
                        'weight': totalWeight,
                        'protein': newProt,
                        'carbs': newCarb,
                        'fat': newFat,
                      };
                    });
                    _recalculateTotals();
                    await _saveChangesToBackend();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Add New Ingredient Dialog
  Future<void> _addIngredient() async {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    String selectedUnit = 'Potong';
    const List<String> units = [
      'Porsi',
      'Potong',
      'Iris',
      'Mangkok',
      'Gelas',
      'Sendok Makan',
      'Butir',
    ];
    Map<String, dynamic>? selectedFood;
    List<Map<String, dynamic>> suggestions = [];
    Timer? debounce;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Tambah Bahan Makanan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Nama Bahan'),
                    onChanged: (value) {
                      selectedFood = null;
                      debounce?.cancel();
                      debounce = Timer(
                        const Duration(milliseconds: 350),
                        () async {
                          final query = value.trim();
                          if (query.length < 2) {
                            setDialogState(() => suggestions = []);
                            return;
                          }
                          final results = await _apiService.searchFoods(query);
                          setDialogState(() => suggestions = results);
                        },
                      );
                    },
                  ),
                  if (suggestions.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 160),
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: suggestions.length,
                        itemBuilder: (context, i) {
                          final item = suggestions[i];
                          return ListTile(
                            dense: true,
                            title: Text(item['food_name'].toString()),
                            subtitle: Text(
                              '${(item['calories'] as num).toStringAsFixed(0)} kkal / ${(item['serving_size_g'] as num).toStringAsFixed(0)}g',
                            ),
                            onTap: () {
                              setDialogState(() {
                                nameController.text = item['food_name']
                                    .toString();
                                selectedFood = item;
                                suggestions = [];
                              });
                            },
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: quantityController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Jumlah',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedUnit,
                          decoration: const InputDecoration(
                            labelText: 'Satuan',
                          ),
                          items: units.map((unit) {
                            return DropdownMenuItem<String>(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedUnit = val;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newName = nameController.text.trim();
                    final qty =
                        double.tryParse(quantityController.text.trim()) ?? 1.0;
                    if (newName.isEmpty) return;

                    Navigator.pop(context);

                    double unitWeight = 100.0;
                    if (selectedUnit == 'Porsi') {
                      unitWeight = 150.0;
                    } else if (selectedUnit == 'Potong')
                      unitWeight = 80.0;
                    else if (selectedUnit == 'Iris')
                      unitWeight = 20.0;
                    else if (selectedUnit == 'Mangkok')
                      unitWeight = 200.0;
                    else if (selectedUnit == 'Gelas')
                      unitWeight = 200.0;
                    else if (selectedUnit == 'Sendok Makan')
                      unitWeight = 15.0;
                    else if (selectedUnit == 'Butir')
                      unitWeight = 50.0;

                    final totalWeight = qty * unitWeight;

                    double calsPerGram = 1.2;
                    double protPerGram = 1.2 * 0.15 / 4;
                    double carbPerGram = 1.2 * 0.55 / 4;
                    double fatPerGram = 1.2 * 0.30 / 9;

                    if (selectedFood != null) {
                      final servingSize =
                          (selectedFood!['serving_size_g'] as num).toDouble();
                      final dbCals = (selectedFood!['calories'] as num)
                          .toDouble();
                      final dbProt = (selectedFood!['protein'] as num)
                          .toDouble();
                      final dbCarb = (selectedFood!['carbs'] as num).toDouble();
                      final dbFat = (selectedFood!['fat'] as num).toDouble();

                      calsPerGram = dbCals / servingSize;
                      protPerGram = dbProt / servingSize;
                      carbPerGram = dbCarb / servingSize;
                      fatPerGram = dbFat / servingSize;
                    }

                    final newCals = calsPerGram * totalWeight;
                    final newProt = protPerGram * totalWeight;
                    final newCarb = carbPerGram * totalWeight;
                    final newFat = fatPerGram * totalWeight;

                    setState(() {
                      _ingredientsList.add({
                        'name': '$newName ($qty $selectedUnit)',
                        'calories': newCals,
                        'weight': totalWeight,
                        'protein': newProt,
                        'carbs': newCarb,
                        'fat': newFat,
                      });
                    });
                    _recalculateTotals();
                    await _saveChangesToBackend();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Hapus Catatan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.neutralColor,
            ),
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghapus catatan makanan ini dari jurnal harian?',
          ),
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
                          content: Text(
                            res['message'] ?? 'Gagal menghapus catatan.',
                          ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
    final rawTimestamp = widget.meal['timestamp'] ?? 'Hari Ini';
    final friendlyTime = formatFriendlyTimestamp(rawTimestamp);

    // Dynamic scaled display values
    final displayCalories = _calories * _portion;
    final displayProtein = _protein * _portion;
    final displayCarbs = _carbs * _portion;
    final displayFat = _fat * _portion;

    // Summing current ingredient weight
    double totalWeight = 0.0;
    for (var ing in _ingredientsList) {
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
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(32),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(32),
                        ),
                        child: MealImage(
                          imagePath: widget.meal['image_path'] ?? '',
                        ),
                      ),
                    ),
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
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(32),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Food title text with Edit Tap Action
                    Positioned(
                      bottom: 24,
                      left: 24,
                      right: 24,
                      child: GestureDetector(
                        onTap: _editFoodName,
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _foodName,
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
                            child: _buildTopActionButton(
                              Icons.arrow_back_ios_new_rounded,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _confirmDelete,
                            child: _buildTopActionButton(
                              Icons.delete_outline_rounded,
                              iconColor: Colors.redAccent,
                            ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
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
                      // Multiplier portion buttons (triggers Postgres save on adjustment)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Row(
                          children: [
                            _buildPortionButton(
                              icon: Icons.remove,
                              onTap: () {
                                if (_portion > 0.5) {
                                  _adjustPortion(-0.5);
                                }
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
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
                                  _adjustPortion(0.5);
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

                // 3. Macronutrients Cards (tappable to edit)
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
                      GestureDetector(
                        onTap: () =>
                            _editMacro('calories', 'Kalori', displayCalories),
                        child: _buildMacroCard(
                          icon: Icons.blur_on_rounded,
                          color: Colors.blue.shade50,
                          iconColor: Colors.blue.shade600,
                          value: '${displayCalories.toStringAsFixed(0)} kkal',
                          label: 'Kalori',
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            _editMacro('protein', 'Protein', displayProtein),
                        child: _buildMacroCard(
                          icon: Icons.workspace_premium_rounded,
                          color: Colors.red.shade50,
                          iconColor: Colors.red.shade600,
                          value: '${displayProtein.toStringAsFixed(0)}g',
                          label: 'Protein',
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            _editMacro('carbs', 'Karbohidrat', displayCarbs),
                        child: _buildMacroCard(
                          icon: Icons.layers_rounded,
                          color: Colors.orange.shade50,
                          iconColor: Colors.orange.shade600,
                          value: '${displayCarbs.toStringAsFixed(0)}g',
                          label: 'Karbohidrat',
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _editMacro('fat', 'Lemak', displayFat),
                        child: _buildMacroCard(
                          icon: Icons.eco_rounded,
                          color: Colors.green.shade50,
                          iconColor: Colors.green.shade600,
                          value: '${displayFat.toStringAsFixed(0)}g',
                          label: 'Lemak',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 4. Ingredient Breakdown Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rincian Bahan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.neutralColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _editTotalWeight(totalWeight),
                        child: Text(
                          'Ubah total',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Total ${totalWeight.toStringAsFixed(0)}g',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Ingredient List (Fully functional list with edit and delete)
                if (_ingredientsList.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Text(
                      'Rincian bahan tidak tersedia.',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _ingredientsList.length,
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      bottom: 100,
                    ),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final ing = _ingredientsList[index];
                      final name = ing['name'];
                      final ingCalories =
                          (ing['calories'] as num).toDouble() * _portion;
                      final ingWeight =
                          (ing['weight'] as num).toDouble() * _portion;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(
                          children: [
                            // Delete ingredient icon
                            GestureDetector(
                              onTap: () async {
                                setState(() {
                                  _ingredientsList.removeAt(index);
                                });
                                _recalculateTotals();
                                await _saveChangesToBackend();
                              },
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
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
                            // Edit ingredient icon
                            GestureDetector(
                              onTap: () => _editIngredient(index),
                              child: Icon(
                                Icons.edit_outlined,
                                color: Colors.grey.shade400,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),

          // 5. Floating Bottom "Add Ingredients" button (fully functional)
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).padding.bottom + 12,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _addIngredient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Tambah Bahan',
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

          if (_isDeleting || _isSaving)
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

  Widget _buildTopActionButton(
    IconData icon, {
    Color iconColor = Colors.black87,
  }) {
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

  Widget _buildPortionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
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
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
                    Icon(
                      Icons.edit_outlined,
                      color: Colors.grey.shade400,
                      size: 12,
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
}
