
String formatFriendlyTimestamp(String timestamp) {
  try {
    // Standard format: "YYYY-MM-DD HH:mm"
    final regExp = RegExp(r'^(\d{4})-(\d{2})-(\d{2})\s+(\d{2}):(\d{2})$');
    if (regExp.hasMatch(timestamp)) {
      final match = regExp.firstMatch(timestamp)!;
      final y = int.parse(match.group(1)!);
      final m = int.parse(match.group(2)!);
      final d = int.parse(match.group(3)!);
      final hr = match.group(4)!;
      final mn = match.group(5)!;
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final mealDate = DateTime(y, m, d);
      
      // Calculate difference in days safely
      final diff = today.difference(mealDate).inDays;
      
      if (diff == 0) {
        return "Hari Ini, $hr:$mn";
      } else if (diff == 1) {
        return "Kemarin, $hr:$mn";
      } else {
        const months = [
          'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
          'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
        ];
        final monthName = m >= 1 && m <= 12 ? months[m - 1] : '';
        return "$d $monthName $y, $hr:$mn";
      }
    }
  } catch (_) {}
  return timestamp;
}
