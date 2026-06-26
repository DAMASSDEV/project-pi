import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsMenuSectionWidget extends StatelessWidget {
  const SettingsMenuSectionWidget({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
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
        ),
        const SizedBox(height: 28),
        Column(
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
        ),
      ],
    );
  }
}
