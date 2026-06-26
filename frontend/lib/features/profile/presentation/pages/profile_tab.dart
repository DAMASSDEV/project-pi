import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/pages/sign_in_page.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  void _handleLogout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SignInPage()),
      (route) => false,
    );
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
            _buildProfileHeader(),
            const SizedBox(height: 32),
            _buildHealthSummarySection(),
            const SizedBox(height: 28),
            _buildAccountSettingsSection(),
            const SizedBox(height: 28),
            _buildAppSettingsSection(),
            const SizedBox(height: 32),
            _buildLogoutButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE8F6F1),
                    Color(0xFFF0FAF7),
                  ],
                ),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 56,
                color: AppTheme.primaryColor,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'John Doe',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.neutralColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.check_circle_rounded,
                size: 14,
                color: AppTheme.primaryColor,
              ),
              SizedBox(width: 6),
              Text(
                'Nutrition Enthusiast',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HEALTH SUMMARY',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Colors.grey,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryItemCard(
                icon: Icons.scale_rounded,
                title: 'Weight',
                value: '65',
                unit: 'kg',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryItemCard(
                icon: Icons.straighten_rounded,
                title: 'Height',
                value: '170',
                unit: 'cm',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSummaryItemRowCard(
          icon: Icons.track_changes_rounded,
          title: 'Goal',
          value: 'Maintain Weight',
        ),
        const SizedBox(height: 12),
        _buildSummaryItemRowCard(
          icon: Icons.directions_run_rounded,
          title: 'Activity Level',
          value: 'Moderate',
        ),
      ],
    );
  }

  Widget _buildSummaryItemCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: AppTheme.neutralColor),
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItemRowCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
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
      ),
    );
  }

  Widget _buildAccountSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACCOUNT SETTINGS',
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
                title: 'Personal Information',
                iconColor: AppTheme.primaryColor,
                iconBgColor: AppTheme.secondaryColor,
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF8F9FA)),
              _buildMenuTile(
                icon: Icons.assignment_turned_in_outlined,
                title: 'Health History',
                iconColor: AppTheme.primaryColor,
                iconBgColor: AppTheme.secondaryColor,
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF8F9FA)),
              _buildMenuTile(
                icon: Icons.restaurant_rounded,
                title: 'Dietary Preferences',
                iconColor: AppTheme.primaryColor,
                iconBgColor: AppTheme.secondaryColor,
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF8F9FA)),
              _buildMenuTile(
                icon: Icons.devices_rounded,
                title: 'Connected Devices',
                iconColor: AppTheme.primaryColor,
                iconBgColor: AppTheme.secondaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'APP SETTINGS',
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
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                iconColor: Colors.grey.shade700,
                iconBgColor: const Color(0xFFF1F3F5),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF8F9FA)),
              _buildMenuTile(
                icon: Icons.lock_outline_rounded,
                title: 'Privacy & Security',
                iconColor: Colors.grey.shade700,
                iconBgColor: const Color(0xFFF1F3F5),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF8F9FA)),
              _buildMenuTile(
                icon: Icons.help_outline_rounded,
                title: 'Help Center',
                iconColor: Colors.grey.shade700,
                iconBgColor: const Color(0xFFF1F3F5),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF8F9FA)),
              _buildMenuTile(
                icon: Icons.info_outline_rounded,
                title: 'About Nutrify',
                iconColor: Colors.grey.shade700,
                iconBgColor: const Color(0xFFF1F3F5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required Color iconColor,
    required Color iconBgColor,
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
      onTap: () {},
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
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
