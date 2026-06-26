import 'package:flutter/material.dart';
import '../../../auth/presentation/pages/sign_in_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/profile_header_widget.dart';
import '../widgets/health_summary_section_widget.dart';
import '../widgets/settings_menu_section_widget.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in_email');
    await prefs.remove('logged_in_username');
    await prefs.remove('logged_in_name');
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SignInPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const ProfileHeaderWidget(),
            const SizedBox(height: 32),
            const HealthSummarySectionWidget(),
            const SizedBox(height: 28),
            const SettingsMenuSectionWidget(),
            const SizedBox(height: 32),
            _buildLogoutButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _handleLogout,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFFFECEB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: Color(0xFFEB5757),
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFFEB5757),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
