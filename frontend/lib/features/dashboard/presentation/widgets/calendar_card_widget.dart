import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/skeleton.dart';

class CalendarCardWidget extends StatelessWidget {
  final int selectedDay;
  final ValueChanged<int> onDaySelected;

  const CalendarCardWidget({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> weekdays = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kalender',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.neutralColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Hari Ini',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neutralColor,
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Juni 2026',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.neutralColor,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.chevron_left_rounded, color: AppTheme.primaryColor, size: 20),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.chevron_right_rounded, color: AppTheme.primaryColor, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekdays.map((day) {
                return SizedBox(
                  width: 32,
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade400,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            _buildCalendarGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    List<Widget> rows = [];
    List<int> rowData = [];
    for (int day = 1; day <= 30; day++) {
      rowData.add(day);
      if (rowData.length == 7) {
        rows.add(_buildCalendarRow(rowData, false));
        rowData = [];
      }
    }
    if (rowData.isNotEmpty) {
      int nextMonthDay = 1;
      while (rowData.length < 7) {
        rowData.add(-nextMonthDay);
        nextMonthDay++;
      }
      rows.add(_buildCalendarRow(rowData, true));
    }
    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: row,
        );
      }).toList(),
    );
  }

  Widget _buildCalendarRow(List<int> days, bool isLastRow) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((day) {
        bool isFaded = day < 0;
        int displayDay = day.abs();
        bool isSelected = !isFaded && displayDay == selectedDay;
        return GestureDetector(
          onTap: isFaded ? null : () => onDaySelected(displayDay),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$displayDay',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isFaded ? Colors.grey.shade300 : AppTheme.neutralColor),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class CalendarCardSkeleton extends StatelessWidget {
  const CalendarCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
        ),
        padding: const EdgeInsets.all(20),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Skeleton(width: 100, height: 18),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Skeleton(width: 80, height: 24, borderRadius: 8),
                Skeleton(width: 110, height: 16),
              ],
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Skeleton(width: 24, height: 24, borderRadius: 12),
                Skeleton(width: 24, height: 24, borderRadius: 12),
                Skeleton(width: 24, height: 24, borderRadius: 12),
                Skeleton(width: 24, height: 24, borderRadius: 12),
                Skeleton(width: 24, height: 24, borderRadius: 12),
                Skeleton(width: 24, height: 24, borderRadius: 12),
                Skeleton(width: 24, height: 24, borderRadius: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
