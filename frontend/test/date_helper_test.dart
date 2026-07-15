import 'package:flutter_test/flutter_test.dart';
import 'package:nutrify/core/services/date_helper.dart';

String _fmt(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day 14:30';
}

void main() {
  group('formatFriendlyTimestamp', () {
    test('returns "Hari Ini" for a timestamp from today', () {
      final today = DateTime.now();
      expect(formatFriendlyTimestamp(_fmt(today)), 'Hari Ini, 14:30');
    });

    test('returns "Kemarin" for a timestamp from yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(formatFriendlyTimestamp(_fmt(yesterday)), 'Kemarin, 14:30');
    });

    test('returns full date with Indonesian month name for older dates', () {
      expect(
        formatFriendlyTimestamp('2020-03-15 09:05'),
        '15 Maret 2020, 09:05',
      );
    });

    test('returns the original string when the format does not match', () {
      expect(formatFriendlyTimestamp('not-a-date'), 'not-a-date');
    });

    test('returns the original string for the "Hari Ini" literal fallback', () {
      expect(formatFriendlyTimestamp('Hari Ini'), 'Hari Ini');
    });
  });
}
