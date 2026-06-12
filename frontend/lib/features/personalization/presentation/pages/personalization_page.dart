import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';

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

  final _nameController = TextEditingController(text: 'Danar');
  final _dobController = TextEditingController(text: '04/12/2005');
  String _gender = 'Perempuan';
  final _heightController = TextEditingController(text: '160');
  final _weightController = TextEditingController(text: '55');
  String _activity = 'Sedang';

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
      _nameController.text = 'Danar';
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
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => DashboardPage(goal: _goal),
              ),
            );
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
        return _buildStep1DataDiri();
      case 1:
        return _buildStep2RiwayatKesehatan();
      case 2:
        return _buildStep3AlergiPantangan();
      case 3:
        return _buildStep4PreferensiTujuan();
      case 4:
        return _buildStep5Ringkasan();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1DataDiri() {
    return SingleChildScrollView(
      key: const ValueKey('step1'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personalisasi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppTheme.neutralColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lengkapi informasi dirimu agar kami dapat memberikan rekomendasi gizi yang lebih akurat dan sesuai kebutuhanmu.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0FAF7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.15),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Data kamu aman dan hanya digunakan untuk memberikan rekomendasi gizi personal.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.teal.shade800,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        color: Colors.teal.shade800,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '1. Data Diri',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.neutralColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('NAMA LENGKAP'),
                  TextFormField(
                    controller: _nameController,
                    decoration: _getInputDecoration('Masukkan nama lengkap'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama lengkap wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('TANGGAL LAHIR'),
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: _getInputDecoration('mm/dd/yyyy').copyWith(
                      suffixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tanggal lahir wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('JENIS KELAMIN'),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: _getInputDecoration(''),
                    items: ['Laki-laki', 'Perempuan'].map((g) {
                      return DropdownMenuItem(
                        value: g,
                        child: Text(g),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _gender = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('TINGGI BADAN'),
                            TextFormField(
                              controller: _heightController,
                              keyboardType: TextInputType.number,
                              decoration: _getInputDecoration('').copyWith(
                                suffixText: 'cm',
                                suffixStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Wajib diisi';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Harus angka';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('BERAT BADAN'),
                            TextFormField(
                              controller: _weightController,
                              keyboardType: TextInputType.number,
                              decoration: _getInputDecoration('').copyWith(
                                suffixText: 'kg',
                                suffixStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Wajib diisi';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Harus angka';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('TINGKAT AKTIVITAS'),
                  DropdownButtonFormField<String>(
                    value: _activity,
                    decoration: _getInputDecoration(''),
                    items: ['Sangat Jarang', 'Jarang', 'Sedang', 'Aktif', 'Sangat Aktif'].map((a) {
                      return DropdownMenuItem(
                        value: a,
                        child: Text(a),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _activity = val;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildNextButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2RiwayatKesehatan() {
    return SingleChildScrollView(
      key: const ValueKey('step2'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.favorite_border_rounded,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '2. Riwayat Kesehatan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.neutralColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildLabel('PENYAKIT / KONDISI'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableConditions.map((cond) {
                    final bool isSelected = _selectedConditions.contains(cond);
                    return ChoiceChip(
                      label: Text(cond),
                      selected: isSelected,
                      selectedColor: const Color(0xFFF0FAF7),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                        ),
                      ),
                      showCheckmark: false,
                      avatar: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              size: 16,
                              color: AppTheme.primaryColor,
                            )
                          : null,
                      onSelected: (selected) {
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
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                _buildLabel('RIWAYAT PENYAKIT LAIN (OPSIONAL)'),
                TextFormField(
                  controller: _otherConditionsController,
                  maxLines: 3,
                  decoration: _getInputDecoration('Contoh: pernah operasi usus buntu tahun 2022, dll.'),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tips Pengisian',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Semakin lengkap data yang kamu berikan, semakin akurat rekomendasi yang kami berikan untukmu.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildNextButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStep3AlergiPantangan() {
    return SingleChildScrollView(
      key: const ValueKey('step3'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.no_food_outlined,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '3. Alergi & Pantangan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.neutralColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildLabel('ALERGI'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._allergies.map((allergy) {
                      return Chip(
                        label: Text(allergy),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () {
                          setState(() {
                            _allergies.remove(allergy);
                          });
                        },
                        backgroundColor: const Color(0xFFF0FAF7),
                        labelStyle: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide.none,
                        ),
                      );
                    }),
                    if (_allergies.isEmpty)
                      Text(
                        'Tidak ada alergi yang terdaftar.',
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newAllergyController,
                        decoration: _getInputDecoration('Tambahkan alergi baru...'),
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty) {
                            setState(() {
                              _allergies.add(val.trim());
                              _newAllergyController.clear();
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor, size: 36),
                      onPressed: () {
                        if (_newAllergyController.text.trim().isNotEmpty) {
                          setState(() {
                            _allergies.add(_newAllergyController.text.trim());
                            _newAllergyController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildLabel('PANTANGAN MAKANAN / BAHAN'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._restrictions.map((rest) {
                      return Chip(
                        label: Text(rest),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () {
                          setState(() {
                            _restrictions.remove(rest);
                          });
                        },
                        backgroundColor: const Color(0xFFF0FAF7),
                        labelStyle: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide.none,
                        ),
                      );
                    }),
                    if (_restrictions.isEmpty)
                      Text(
                        'Tidak ada pantangan.',
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newRestrictionController,
                        decoration: _getInputDecoration('Tambahkan pantangan baru...'),
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty) {
                            setState(() {
                              _restrictions.add(val.trim());
                              _newRestrictionController.clear();
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor, size: 36),
                      onPressed: () {
                        if (_newRestrictionController.text.trim().isNotEmpty) {
                          setState(() {
                            _restrictions.add(_newRestrictionController.text.trim());
                            _newRestrictionController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildNextButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStep4PreferensiTujuan() {
    return SingleChildScrollView(
      key: const ValueKey('step4'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.track_changes_rounded,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '4. Preferensi & Tujuan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.neutralColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildLabel('TUJUAN UTAMA'),
                DropdownButtonFormField<String>(
                  value: _goal,
                  decoration: _getInputDecoration(''),
                  items: [
                    'Menjaga Berat Badan',
                    'Menurunkan Berat Badan',
                    'Menaikkan Berat Badan',
                    'Meningkatkan Massa Otot'
                  ].map((g) {
                    return DropdownMenuItem(
                      value: g,
                      child: Text(g),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _goal = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                _buildLabel('PREFERENSI MAKANAN'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availablePreferences.map((pref) {
                    final bool isSelected = _selectedPreferences.contains(pref);
                    return FilterChip(
                      label: Text(pref),
                      selected: isSelected,
                      selectedColor: const Color(0xFFF0FAF7),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                        ),
                      ),
                      showCheckmark: false,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedPreferences.add(pref);
                          } else {
                            _selectedPreferences.remove(pref);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                _buildLabel('CATATAN TAMBAHAN (OPSIONAL)'),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: _getInputDecoration('Tuliskan catatan lain terkait kondisi atau preferensi makananmu...'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildNextButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStep5Ringkasan() {
    final int age = _calculateAge(_dobController.text);
    final String ageStr = "$age Tahun";
    final String heightStr = "${_heightController.text} cm";
    final String weightStr = "${_weightController.text} kg";
    final String hbStr = "$heightStr / $weightStr";

    return SingleChildScrollView(
      key: const ValueKey('step5'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Profil Kesehatanmu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppTheme.neutralColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
              children: [
                _buildSummaryRow(Icons.calendar_today_outlined, 'Usia', ageStr),
                const Divider(height: 24, thickness: 0.8),
                _buildSummaryRow(Icons.person_outline_rounded, 'Jenis Kelamin', _gender),
                const Divider(height: 24, thickness: 0.8),
                _buildSummaryRow(Icons.straighten_rounded, 'Tinggi / Berat', hbStr),
                const Divider(height: 24, thickness: 0.8),
                _buildSummaryRow(Icons.directions_run_rounded, 'Aktivitas', _activity),
                const Divider(height: 24, thickness: 0.8),
                _buildSummaryRow(
                  Icons.favorite_border_rounded,
                  'Kondisi',
                  _selectedConditions.join(', '),
                ),
                const Divider(height: 24, thickness: 0.8),
                _buildSummaryRow(Icons.track_changes_rounded, 'Tujuan', _goal),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text(
                      'Simpan Perubahan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: _resetForm,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Reset',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF0FAF7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.neutralColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Colors.grey.shade400,
          letterSpacing: 0.8,
        ),
      ),
    );
  }


  InputDecoration _getInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      fillColor: const Color(0xFFF8F9FA),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Lanjut',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
