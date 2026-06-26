import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PersonalizationStepTwo extends StatelessWidget {
  final List<String> availableConditions;
  final Set<String> selectedConditions;
  final TextEditingController otherConditionsController;
  final void Function(String, bool) onConditionSelected;
  final VoidCallback onNext;

  const PersonalizationStepTwo({
    super.key,
    required this.availableConditions,
    required this.selectedConditions,
    required this.otherConditionsController,
    required this.onConditionSelected,
    required this.onNext,
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
                const Row(
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
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
                  children: availableConditions.map((cond) {
                    final bool isSelected = selectedConditions.contains(cond);
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
                      onSelected: (selected) => onConditionSelected(cond, selected),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                _buildLabel('RIWAYAT PENYAKIT LAIN (OPSIONAL)'),
                TextFormField(
                  controller: otherConditionsController,
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
    );
  }
}

class PersonalizationStepThree extends StatelessWidget {
  final List<String> allergies;
  final TextEditingController newAllergyController;
  final void Function(String) onAllergyDeleted;
  final void Function(String) onAllergyAdded;
  final List<String> restrictions;
  final TextEditingController newRestrictionController;
  final void Function(String) onRestrictionDeleted;
  final void Function(String) onRestrictionAdded;
  final VoidCallback onNext;

  const PersonalizationStepThree({
    super.key,
    required this.allergies,
    required this.newAllergyController,
    required this.onAllergyDeleted,
    required this.onAllergyAdded,
    required this.restrictions,
    required this.newRestrictionController,
    required this.onRestrictionDeleted,
    required this.onRestrictionAdded,
    required this.onNext,
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
                const Row(
                  children: [
                    Icon(
                      Icons.no_food_outlined,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
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
                    ...allergies.map((allergy) {
                      return Chip(
                        label: Text(allergy),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => onAllergyDeleted(allergy),
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
                    if (allergies.isEmpty)
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
                        controller: newAllergyController,
                        decoration: _getInputDecoration('Tambahkan alergi baru...'),
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty) {
                            onAllergyAdded(val.trim());
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor, size: 36),
                      onPressed: () {
                        if (newAllergyController.text.trim().isNotEmpty) {
                          onAllergyAdded(newAllergyController.text.trim());
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
                    ...restrictions.map((rest) {
                      return Chip(
                        label: Text(rest),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => onRestrictionDeleted(rest),
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
                    if (restrictions.isEmpty)
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
                        controller: newRestrictionController,
                        decoration: _getInputDecoration('Tambahkan pantangan baru...'),
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty) {
                            onRestrictionAdded(val.trim());
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor, size: 36),
                      onPressed: () {
                        if (newRestrictionController.text.trim().isNotEmpty) {
                          onRestrictionAdded(newRestrictionController.text.trim());
                        }
                      },
                    ),
                  ],
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
    );
  }
}
