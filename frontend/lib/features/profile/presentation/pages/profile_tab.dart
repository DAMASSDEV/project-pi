import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/pages/sign_in_page.dart';

import '../widgets/profile_header_widget.dart';
import '../widgets/health_summary_section_widget.dart';
import '../widgets/settings_menu_section_widget.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String _name = '';
  String _email = '';
  Map<String, dynamic>? _personalizationData;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('logged_in_email');
    if (email == null) {
      setState(() => _isLoading = false);
      return;
    }
    
    setState(() {
      _email = email;
      _name = prefs.getString('logged_in_name') ?? '';
    });

    final res = await _apiService.getPersonalization(email);
    if (res['success'] == true && res['data'] != null) {
      setState(() {
        _personalizationData = res['data'];
        _name = _personalizationData!['name'] ?? _name;
      });
    }

    setState(() => _isLoading = false);
  }

  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in_email');
    await prefs.remove('logged_in_username');
    await prefs.remove('logged_in_name');
    await prefs.remove('has_completed_personalization');
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SignInPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            ProfileHeaderWidget(
              name: _name,
              email: _email,
            ),
            const SizedBox(height: 32),
            HealthSummarySectionWidget(
              weight: _personalizationData?['weight']?.toString() ?? '-',
              height: _personalizationData?['height']?.toString() ?? '-',
              goal: _personalizationData?['goal']?.toString() ?? '-',
              activity: _personalizationData?['activity']?.toString() ?? '-',
            ),
            const SizedBox(height: 28),
            SettingsMenuSectionWidget(
              personalizationData: _personalizationData,
            ),
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
