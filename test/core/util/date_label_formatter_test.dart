import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/core/util/date_label_formatter.dart';

void main() {
  group('DateLabelFormatter', () {
    test('formats full dates consistently', () {
      expect(DateLabelFormatter.fullDate(DateTime(2026, 7, 4)), 'Jul 4, 2026');
    });

    test('formats long month/year labels', () {
      expect(DateLabelFormatter.longMonthYear(DateTime(2026, 7)), 'July 2026');
    });

    test('formats compact month/year labels', () {
      expect(
        DateLabelFormatter.compactMonthYear(DateTime(2026, 7)),
        'Jul 2026',
      );
    });

    test('formats sortable dates', () {
      expect(
        DateLabelFormatter.sortableDate(DateTime(2026, 7, 4)),
        '2026-07-04',
      );
    });

    test('formats stable month keys', () {
      expect(DateLabelFormatter.monthKey(DateTime(2026, 7, 4)), '2026-07');
    });

    test('returns null for invalid ISO strings', () {
      expect(DateLabelFormatter.parseIso('not a date'), isNull);
      expect(DateLabelFormatter.fullDateFromIso('not a date'), isNull);
      expect(DateLabelFormatter.sortableDateFromIso('not a date'), isNull);
    });

    test('formats local time only when the parsed day matches today', () {
      final now = DateTime(2026, 7, 4, 12);

      expect(
        DateLabelFormatter.localTimeIfTodayFromIso(
          DateTime(2026, 7, 4, 9, 30).toIso8601String(),
          now: now,
        ),
        '9:30 AM',
      );
      expect(
        DateLabelFormatter.localTimeIfTodayFromIso(
          DateTime(2026, 7, 3, 9, 30).toIso8601String(),
          now: now,
        ),
        isNull,
      );
    });
  });
}
