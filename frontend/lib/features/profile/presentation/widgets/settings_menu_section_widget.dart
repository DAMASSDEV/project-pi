import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/top_toast.dart';
import '../pages/notifications_page.dart';
import '../pages/privacy_security_page.dart';
import '../pages/help_center_page.dart';
import '../pages/connected_devices_page.dart';
import '../pages/about_nutrify_page.dart';

class SettingsMenuSectionWidget extends StatelessWidget {
  final Map<String, dynamic>? personalizationData;

  const SettingsMenuSectionWidget({
    super.key,
    this.personalizationData,
  });

  void _showPersonalInfo(BuildContext context) {
    final data = personalizationData;
    if (data == null) {
      showTopToast(context, 'Data personal belum tersedia. Silakan lengkapi personalisasi.', isError: true);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
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
                'Informasi Personal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neutralColor,
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoRow('Nama', data['name'] ?? '-'),
              _buildInfoRow('Email', data['email'] ?? '-'),
              _buildInfoRow('Tanggal Lahir', data['dob'] ?? '-'),
              _buildInfoRow('Jenis Kelamin', data['gender'] ?? '-'),
              _buildInfoRow('Tinggi Badan', '${data['height'] ?? '-'} cm'),
              _buildInfoRow('Berat Badan', '${data['weight'] ?? '-'} kg'),
              _buildInfoRow('Tingkat Aktivitas', data['activity'] ?? '-'),
              _buildInfoRow('Tujuan', data['goal'] ?? '-'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.neutralColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHealthHistory(BuildContext context) {
    final data = personalizationData;
    if (data == null) {
      showTopToast(context, 'Data kesehatan belum tersedia.', isError: true);
      return;
    }

    final conditions = data['conditions'] as List<dynamic>? ?? [];
    final allergies = data['allergies'] as List<dynamic>? ?? [];
    final restrictions = data['restrictions'] as List<dynamic>? ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
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
                'Riwayat Kesehatan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neutralColor,
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoRow('Kondisi Kesehatan', conditions.isNotEmpty ? conditions.join(', ') : 'Tidak Ada'),
              if (data['other_conditions'] != null && data['other_conditions'].toString().isNotEmpty)
                _buildInfoRow('Kondisi Lainnya', data['other_conditions']),
              _buildInfoRow('Alergi', allergies.isNotEmpty ? allergies.join(', ') : 'Tidak Ada'),
              _buildInfoRow('Pantangan', restrictions.isNotEmpty ? restrictions.join(', ') : 'Tidak Ada'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showDietaryPreferences(BuildContext context) {
    final data = personalizationData;
    if (data == null) {
      showTopToast(context, 'Data preferensi belum tersedia.', isError: true);
      return;
    }

    final preferences = data['preferences'] as List<dynamic>? ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
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
                'Preferensi Makanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neutralColor,
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoRow('Makanan Favorit', preferences.isNotEmpty ? preferences.join(', ') : '-'),
              _buildInfoRow('Tujuan Diet', data['goal'] ?? '-'),
              if (data['notes'] != null && data['notes'].toString().isNotEmpty)
                _buildInfoRow('Catatan', data['notes']),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconBgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.neutralColor,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Colors.grey.shade400,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PENGATURAN AKUN',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Informasi Pribadi',
                    iconColor: AppTheme.primaryColor,
                    iconBgColor: AppTheme.secondaryColor,
                    onTap: () => _showPersonalInfo(context),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF8F9FA)),
                  _buildMenuTile(
                    icon: Icons.assignment_turned_in_outlined,
                    title: 'Riwayat Kesehatan',
                    iconColor: AppTheme.primaryColor,
                    iconBgColor: AppTheme.secondaryColor,
                    onTap: () => _showHealthHistory(context),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF8F9FA)),
                  _buildMenuTile(
                    icon: Icons.restaurant_rounded,
                    title: 'Preferensi Pola Makan',
                    iconColor: AppTheme.primaryColor,
                    iconBgColor: AppTheme.secondaryColor,
                    onTap: () => _showDietaryPreferences(context),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PENGATURAN APLIKASI',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Tentang Nutrify',
                    iconColor: Colors.grey.shade700,
                    iconBgColor: const Color(0xFFF1F3F5),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AboutNutrifyPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
