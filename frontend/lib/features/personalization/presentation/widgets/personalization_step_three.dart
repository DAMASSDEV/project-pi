import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PersonalizationStepFour extends StatelessWidget {
  final String? goal;
  final List<String> availablePreferences;
  final Set<String> selectedPreferences;
  final TextEditingController notesController;
  final ValueChanged<String?> onGoalChanged;
  final void Function(String pref, bool selected) onPreferenceSelected;
  final VoidCallback onNext;

  const PersonalizationStepFour({
    super.key,
    required this.goal,
    required this.availablePreferences,
    required this.selectedPreferences,
    required this.notesController,
    required this.onGoalChanged,
    required this.onPreferenceSelected,
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
                const Row(
                  children: [
                    Icon(
                      Icons.track_changes_rounded,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
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
                  initialValue: goal,
                  decoration: _getInputDecoration('Pilih tujuan utama'),
                  hint: Text(
                    'Pilih tujuan utama',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
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
                  onChanged: onGoalChanged,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tujuan utama wajib dipilih';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildLabel('PREFERENSI MAKANAN'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availablePreferences.map((pref) {
                    final bool isSelected = selectedPreferences.contains(pref);
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
                      onSelected: (selected) => onPreferenceSelected(pref, selected),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                _buildLabel('CATATAN TAMBAHAN (OPSIONAL)'),
                TextFormField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: _getInputDecoration('Tuliskan catatan lain terkait kondisi atau preferensi makananmu...'),
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

class PersonalizationStepFive extends StatelessWidget {
  final String ageStr;
  final String gender;
  final String hbStr;
  final String activity;
  final String conditions;
  final String goal;
  final bool isLoading;
  final VoidCallback onSave;
  final VoidCallback onReset;

  const PersonalizationStepFive({
    super.key,
    required this.ageStr,
    required this.gender,
    required this.hbStr,
    required this.activity,
    required this.conditions,
    required this.goal,
    required this.isLoading,
    required this.onSave,
    required this.onReset,
  });

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

  @override
  Widget build(BuildContext context) {
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
                _buildSummaryRow(Icons.person_outline_rounded, 'Jenis Kelamin', gender),
                const Divider(height: 24, thickness: 0.8),
                _buildSummaryRow(Icons.straighten_rounded, 'Tinggi / Berat', hbStr),
                const Divider(height: 24, thickness: 0.8),
                _buildSummaryRow(Icons.directions_run_rounded, 'Aktivitas', activity),
                const Divider(height: 24, thickness: 0.8),
                _buildSummaryRow(
                  Icons.favorite_border_rounded,
                  'Kondisi',
                  conditions,
                ),
                const Divider(height: 24, thickness: 0.8),
                _buildSummaryRow(Icons.track_changes_rounded, 'Tujuan', goal),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isLoading
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
              onPressed: onReset,
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
}
