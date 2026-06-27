import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/top_toast.dart';
import '../../../splash/presentation/pages/splash_screen.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  bool _shareDataWithAI = true;
  bool _localEncryption = true;
  bool _biometricLock = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _shareDataWithAI = prefs.getBool('privacy_share_data') ?? true;
      _localEncryption = prefs.getBool('privacy_local_encrypt') ?? true;
      _biometricLock = prefs.getBool('privacy_biometric_lock') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _resetPersonalizationData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
            SizedBox(width: 8),
            Text(
              'Hapus Data Personalisasi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus seluruh data personalisasi Anda? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('has_completed_personalization');
      await prefs.remove('user_goal');
      if (mounted) {
        showTopToast(context, 'Data personalisasi berhasil dihapus.');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SplashScreen()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.neutralColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
        activeTrackColor: AppTheme.primaryColor.withOpacity(0.15),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.neutralColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy & Security',
          style: TextStyle(
            color: AppTheme.neutralColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PENGATURAN PRIVASI & DATA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSwitchTile(
                    title: 'Bagikan Data ke AI',
                    subtitle: 'Izinkan AI memproses data makanan harian untuk rekomendasi nutrisi yang lebih spesifik.',
                    value: _shareDataWithAI,
                    onChanged: (val) {
                      setState(() => _shareDataWithAI = val);
                      _saveSetting('privacy_share_data', val);
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Enkripsi Data Lokal',
                    subtitle: 'Simpan data riwayat makanan secara terenkripsi di penyimpanan perangkat Anda.',
                    value: _localEncryption,
                    onChanged: (val) {
                      setState(() => _localEncryption = val);
                      _saveSetting('privacy_local_encrypt', val);
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Kunci Sidik Jari / Face ID',
                    subtitle: 'Minta autentikasi biometrik setiap kali membuka aplikasi Nutrify.',
                    value: _biometricLock,
                    onChanged: (val) {
                      setState(() => _biometricLock = val);
                      _saveSetting('privacy_biometric_lock', val);
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'PENGELOLAAN AKUN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hapus Data Personalisasi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Menghapus data personalisasi akan mereset berat badan, tinggi badan, alergi, dan preferensi makanan Anda. Anda harus mengisi ulang dari awal.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _resetPersonalizationData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Hapus Sekarang',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
