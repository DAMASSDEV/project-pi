import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../widgets/personalization_step_one.dart';
import '../widgets/personalization_step_two.dart';
import '../widgets/personalization_step_three.dart';

class PersonalizationPage extends StatefulWidget {
  final String email;

  const PersonalizationPage({super.key, required this.email});

  @override
  State<PersonalizationPage> createState() => _PersonalizationPageState();
}

class _PersonalizationPageState extends State<PersonalizationPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  int _currentStep = 0;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _dobController = TextEditingController(text: '04/12/2005');
  String _gender = 'Perempuan';
  final _heightController = TextEditingController(text: '160');
  final _weightController = TextEditingController(text: '55');
  String _activity = 'Sedang';

  @override
  void initState() {
    super.initState();
    _loadUserDisplayName();
  }

  Future<void> _loadUserDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('logged_in_name');
    if (name != null && name.isNotEmpty) {
      setState(() {
        _nameController.text = name;
      });
    }
  }

  final List<String> _availableConditions = [
    'Diabetes',
    'Hipertensi',
    'Kolesterol Tinggi',
    'Asam Urat',
    'Alergi Makanan',
    'Maag / GERD',
    'Tidak Ada'
  ];
  final Set<String> _selectedConditions = {'Tidak Ada'};
  final _otherConditionsController = TextEditingController();

  final List<String> _allergies = ['Udang'];
  final _newAllergyController = TextEditingController();

  final List<String> _restrictions = ['Santan', 'Gorengan', 'Daging Merah'];
  final _newRestrictionController = TextEditingController();

  String _goal = 'Menjaga Berat Badan';
  final List<String> _availablePreferences = [
    'Sayuran',
    'Buah',
    'Daging',
    'Ikan',
    'Telur',
    'Kacang-kacangan'
  ];
  final Set<String> _selectedPreferences = {
    'Sayuran',
    'Buah',
    'Ikan',
    'Kacang-kacangan'
  };
  final _notesController = TextEditingController();

  int _calculateAge(String dob) {
    try {
      final parts = dob.split('/');
      if (parts.length != 3) return 21;
      int month = int.parse(parts[0]);
      int day = int.parse(parts[1]);
      int year = int.parse(parts[2]);
      final birthDate = DateTime(year, month, day);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 21;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005, 4, 12),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        final monthStr = picked.month.toString().padLeft(2, '0');
        final dayStr = picked.day.toString().padLeft(2, '0');
        _dobController.text = "$monthStr/$dayStr/${picked.year}";
      });
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKey.currentState!.validate()) return;
    }
    setState(() {
      _currentStep++;
    });
  }

  void _prevStep() {
    setState(() {
      _currentStep--;
    });
  }

  void _resetForm() {
    setState(() {
      _currentStep = 0;
      _nameController.clear();
      _dobController.text = '04/12/2005';
      _gender = 'Perempuan';
      _heightController.text = '160';
      _weightController.text = '55';
      _activity = 'Sedang';
      _selectedConditions.clear();
      _selectedConditions.add('Tidak Ada');
      _otherConditionsController.clear();
      _allergies.clear();
      _allergies.add('Udang');
      _restrictions.clear();
      _restrictions.addAll(['Santan', 'Gorengan', 'Daging Merah']);
      _goal = 'Menjaga Berat Badan';
      _selectedPreferences.clear();
      _selectedPreferences.addAll(['Sayuran', 'Buah', 'Ikan', 'Kacang-kacangan']);
      _notesController.clear();
    });
  }

  Future<void> _saveData() async {
    setState(() {
      _isLoading = true;
    });

    final payload = {
      'email': widget.email,
      'name': _nameController.text.trim(),
      'dob': _dobController.text.trim(),
      'gender': _gender,
      'height': double.tryParse(_heightController.text) ?? 160.0,
      'weight': double.tryParse(_weightController.text) ?? 55.0,
      'activity': _activity,
      'conditions': _selectedConditions.toList(),
      'other_conditions': _otherConditionsController.text.trim(),
      'allergies': _allergies,
      'restrictions': _restrictions,
      'goal': _goal,
      'preferences': _selectedPreferences.toList(),
      'notes': _notesController.text.trim(),
    };

    final result = await _apiService.savePersonalization(payload);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (result['success'] == true) {
        _showTopNotification(true, 'Data personalisasi berhasil disimpan!');
        Future.delayed(const Duration(milliseconds: 1500), () async {
          if (mounted) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_goal', _goal);
            await prefs.setBool('has_completed_personalization', true);
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => DashboardPage(goal: _goal),
                ),
              );
            }
          }
        });
      } else {
        _showTopNotification(
          false,
          result['message'] ?? 'Gagal menyimpan data.',
        );
      }
    }
  }

  void _showTopNotification(bool isSuccess, String message) {
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: isSuccess ? AppTheme.primaryColor : Colors.redAccent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  isSuccess
                      ? Icons.check_circle_outline_rounded
                      : Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _otherConditionsController.dispose();
    _newAllergyController.dispose();
    _newRestrictionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppTheme.neutralColor,
                ),
                onPressed: _prevStep,
              )
            : null,
        title: const Text(
          'Nutrify',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentStepView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            children: List.generate(5, (index) {
              bool isCompleted = index < _currentStep;
              bool isActive = index == _currentStep;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  decoration: BoxDecoration(
                    color: isCompleted || isActive
                        ? AppTheme.primaryColor
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tahap ${_currentStep + 1} dari 5',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                _getStepName(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStepName() {
    switch (_currentStep) {
      case 0:
        return 'Data Diri';
      case 1:
        return 'Riwayat Kesehatan';
      case 2:
        return 'Alergi & Pantangan';
      case 3:
        return 'Preferensi & Tujuan';
      case 4:
        return 'Ringkasan';
      default:
        return '';
    }
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 0:
        return PersonalizationStepOne(
          formKey: _formKey,
          nameController: _nameController,
          dobController: _dobController,
          gender: _gender,
          heightController: _heightController,
          weightController: _weightController,
          activity: _activity,
          onNext: _nextStep,
          onSelectDate: () => _selectDate(context),
          onGenderChanged: (val) {
            if (val != null) {
              setState(() {
                _gender = val;
              });
            }
          },
          onActivityChanged: (val) {
            if (val != null) {
              setState(() {
                _activity = val;
              });
            }
          },
        );
      case 1:
        return PersonalizationStepTwo(
          availableConditions: _availableConditions,
          selectedConditions: _selectedConditions,
          otherConditionsController: _otherConditionsController,
          onConditionSelected: (cond, selected) {
            setState(() {
              if (cond == 'Tidak Ada') {
                if (selected) {
                  _selectedConditions.clear();
                  _selectedConditions.add('Tidak Ada');
                }
              } else {
                if (selected) {
                  _selectedConditions.remove('Tidak Ada');
                  _selectedConditions.add(cond);
                } else {
                  _selectedConditions.remove(cond);
                  if (_selectedConditions.isEmpty) {
                    _selectedConditions.add('Tidak Ada');
                  }
                }
              }
            });
          },
          onNext: _nextStep,
        );
      case 2:
        return PersonalizationStepThree(
          allergies: _allergies,
          newAllergyController: _newAllergyController,
          onAllergyDeleted: (allergy) {
            setState(() {
              _allergies.remove(allergy);
            });
          },
          onAllergyAdded: (allergy) {
            setState(() {
              _allergies.add(allergy);
              _newAllergyController.clear();
            });
          },
          restrictions: _restrictions,
          newRestrictionController: _newRestrictionController,
          onRestrictionDeleted: (rest) {
            setState(() {
              _restrictions.remove(rest);
            });
          },
          onRestrictionAdded: (rest) {
            setState(() {
              _restrictions.add(rest);
              _newRestrictionController.clear();
            });
          },
          onNext: _nextStep,
        );
      case 3:
        return PersonalizationStepFour(
          goal: _goal,
          availablePreferences: _availablePreferences,
          selectedPreferences: _selectedPreferences,
          notesController: _notesController,
          onGoalChanged: (val) {
            if (val != null) {
              setState(() {
                _goal = val;
              });
            }
          },
          onPreferenceSelected: (pref, selected) {
            setState(() {
              if (selected) {
                _selectedPreferences.add(pref);
              } else {
                _selectedPreferences.remove(pref);
              }
            });
          },
          onNext: _nextStep,
        );
      case 4:
        final int age = _calculateAge(_dobController.text);
        final String ageStr = "$age Tahun";
        final String heightStr = "${_heightController.text} cm";
        final String weightStr = "${_weightController.text} kg";
        final String hbStr = "$heightStr / $weightStr";
        return PersonalizationStepFive(
          ageStr: ageStr,
          gender: _gender,
          hbStr: hbStr,
          activity: _activity,
          conditions: _selectedConditions.join(', '),
          goal: _goal,
          isLoading: _isLoading,
          onSave: _saveData,
          onReset: _resetForm,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
