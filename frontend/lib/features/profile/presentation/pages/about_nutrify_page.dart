import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/top_toast.dart';

class AboutNutrifyPage extends StatelessWidget {
  const AboutNutrifyPage({super.key});

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Colors.grey,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildLinkTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor, size: 20),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.neutralColor,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.grey.shade400,
          size: 14,
        ),
        onTap: onTap,
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
          'Tentang Nutrify',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: AppTheme.primaryColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nutrify',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.neutralColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Versi 1.0.0 (Build 100)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nutrify adalah aplikasi asisten nutrisi pribadi cerdas bertenaga AI yang membantu mengukur nilai kalori, mengidentifikasi kandungan bahan, serta mencatat asupan makanan harian Anda hanya dengan memotret hidangan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '© 2026 Damassdev. Seluruh Hak Cipta Dilindungi.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
