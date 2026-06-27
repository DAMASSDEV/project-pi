import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PersonalizationStepOne extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController dobController;
  final String? gender;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final String? activity;
  final VoidCallback onNext;
  final VoidCallback onSelectDate;
  final ValueChanged<String?> onGenderChanged;
  final ValueChanged<String?> onActivityChanged;

  const PersonalizationStepOne({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.dobController,
    required this.gender,
    required this.heightController,
    required this.weightController,
    required this.activity,
    required this.onNext,
    required this.onSelectDate,
    required this.onGenderChanged,
    required this.onActivityChanged,
  });

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('step1'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: formKey,
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
                    controller: nameController,
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
                    controller: dobController,
                    readOnly: true,
                    onTap: onSelectDate,
                    decoration: _getInputDecoration('Pilih tanggal lahir').copyWith(
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
                    value: gender,
                    decoration: _getInputDecoration('Pilih jenis kelamin'),
                    hint: Text(
                      'Pilih jenis kelamin',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    ),
                    items: ['Laki-laki', 'Perempuan'].map((g) {
                      return DropdownMenuItem(
                        value: g,
                        child: Text(g),
                      );
                    }).toList(),
                    onChanged: onGenderChanged,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jenis kelamin wajib dipilih';
                      }
                      return null;
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
                              controller: heightController,
                              keyboardType: TextInputType.number,
                              decoration: _getInputDecoration('Tinggi').copyWith(
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
                              controller: weightController,
                              keyboardType: TextInputType.number,
                              decoration: _getInputDecoration('Berat').copyWith(
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
                    value: activity,
                    decoration: _getInputDecoration('Pilih tingkat aktivitas'),
                    hint: Text(
                      'Pilih tingkat aktivitas',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    ),
                    items: ['Sangat Jarang', 'Jarang', 'Sedang', 'Aktif', 'Sangat Aktif'].map((a) {
                      return DropdownMenuItem(
                        value: a,
                        child: Text(a),
                      );
                    }).toList(),
                    onChanged: onActivityChanged,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tingkat aktivitas wajib dipilih';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onNext,
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
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
