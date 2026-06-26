import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class HealthSummarySectionWidget extends StatelessWidget {
  const HealthSummarySectionWidget({super.key});

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

  @override
  Widget build(BuildContext context) {
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
}
