import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class HistoryInsightCard extends StatelessWidget {
  final double calProgress;
  final double totalCalories;
  final String rangeLabel;

  const HistoryInsightCard({
    super.key,
    required this.calProgress,
    required this.totalCalories,
    required this.rangeLabel,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    IconData badgeIcon;
    Color accentColor;
    String headline;
    String tip;

    if (totalCalories <= 0) {
      icon = Icons.info_outline_rounded;
      badgeIcon = Icons.remove_rounded;
      accentColor = Colors.grey.shade500;
      headline = 'Belum ada catatan makanan untuk periode ini.';
      tip = 'Yuk mulai catat makanan kamu agar insight-nya muncul di sini.';
    } else if (calProgress >= 1.0) {
      icon = Icons.spa_rounded;
      badgeIcon = Icons.check_rounded;
      accentColor = AppTheme.primaryColor;
      headline = 'Kalori kamu sudah mencapai target!';
      tip = 'Kerja bagus! Pertahankan pola makan sehat ini ya.';
    } else if (calProgress >= 0.7) {
      icon = Icons.spa_rounded;
      badgeIcon = Icons.trending_up_rounded;
      accentColor = AppTheme.primaryColor;
      headline = 'Kalori kamu sudah mendekati target!';
      tip = 'Coba tambahkan serat dari sayur dan buah untuk keseimbangan nutrisi.';
    } else {
      icon = Icons.restaurant_rounded;
      badgeIcon = Icons.priority_high_rounded;
      accentColor = Colors.orange.shade700;
      headline = 'Kalori kamu masih jauh dari target.';
      tip = 'Yuk lengkapi asupan makananmu supaya kebutuhan gizi harian tetap terpenuhi.';
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0FAF7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accentColor.withOpacity(0.15),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'INSIGHT ${rangeLabel.toUpperCase()}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: accentColor,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 32,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    badgeIcon,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.neutralColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tip,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
