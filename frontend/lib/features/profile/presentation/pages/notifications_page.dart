import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _mealReminder = true;
  bool _healthTips = true;
  bool _appUpdates = false;
  bool _weeklyReport = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _mealReminder = prefs.getBool('notif_meal_reminder') ?? true;
      _healthTips = prefs.getBool('notif_health_tips') ?? true;
      _appUpdates = prefs.getBool('notif_app_updates') ?? false;
      _weeklyReport = prefs.getBool('notif_weekly_report') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
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
        activeThumbColor: AppTheme.primaryColor,
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
          'Notifications',
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
                    'PENGATURAN NOTIFIKASI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSwitchTile(
                    title: 'Pengingat Makan',
                    subtitle: 'Ingatkan saya untuk mencatat makanan saat jam sarapan, makan siang, dan makan malam.',
                    value: _mealReminder,
                    onChanged: (val) {
                      setState(() => _mealReminder = val);
                      _saveSetting('notif_meal_reminder', val);
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Tips Kesehatan Harian',
                    subtitle: 'Terima rekomendasi makanan sehat dan tips nutrisi harian berbasis AI.',
                    value: _healthTips,
                    onChanged: (val) {
                      setState(() => _healthTips = val);
                      _saveSetting('notif_health_tips', val);
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Laporan Gizi Mingguan',
                    subtitle: 'Dapatkan rangkuman analisis asupan nutrisi Anda setiap akhir pekan.',
                    value: _weeklyReport,
                    onChanged: (val) {
                      setState(() => _weeklyReport = val);
                      _saveSetting('notif_weekly_report', val);
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Pembaruan Aplikasi',
                    subtitle: 'Beri tahu saya saat ada fitur gizi baru atau perbaikan di aplikasi.',
                    value: _appUpdates,
                    onChanged: (val) {
                      setState(() => _appUpdates = val);
                      _saveSetting('notif_app_updates', val);
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
