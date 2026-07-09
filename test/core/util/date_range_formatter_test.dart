import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/core/util/date_range_formatter.dart';

void main() {
  group('DateRangeFormatter', () {
    test('keeps both years for cross-year ranges', () {
      expect(
        DateRangeFormatter.formatMessageEvidenceRange(
          start: DateTime(2014),
          end: DateTime(2026, 7, 4),
        ),
        'Jan 1, 2014 to Jul 4, 2026',
      );
    });

    test('omits the repeated year for same-year cross-month ranges', () {
      expect(
        DateRangeFormatter.formatMessageEvidenceRange(
          start: DateTime(2019, 1, 18),
          end: DateTime(2019, 4),
        ),
        'Jan 18 to Apr 1, 2019',
      );
    });

    test('keeps the full date for a single-message range', () {
      expect(
        DateRangeFormatter.formatMessageEvidenceRange(
          start: DateTime(2018, 3, 12),
          end: DateTime(2018, 3, 12),
          itemCount: 1,
        ),
        'Mar 12, 2018',
      );
    });

    test('summarizes same-month multi-message ranges by month and year', () {
      expect(
        DateRangeFormatter.formatMessageEvidenceRange(
          start: DateTime(2019, 5, 15),
          end: DateTime(2019, 5, 21),
          itemCount: 9,
        ),
        'May 2019',
      );
    });

    test('summarizes same-month multi-day ranges by month and year', () {
      expect(
        DateRangeFormatter.formatMessageEvidenceRange(
          start: DateTime(2018, 3, 12),
          end: DateTime(2018, 3, 13),
          itemCount: 2,
        ),
        'Mar 2018',
      );
    });

    test('sorts reversed inputs before formatting', () {
      expect(
        DateRangeFormatter.formatMessageEvidenceRange(
          start: DateTime(2026, 7, 4),
          end: DateTime(2014),
        ),
        'Jan 1, 2014 to Jul 4, 2026',
      );
    });

    test('uses the configured empty label when no dates exist', () {
      expect(
        DateRangeFormatter.formatMessageEvidenceRange(
          start: null,
          end: null,
          emptyLabel: 'No dated messages',
        ),
        'No dated messages',
      );
    });
  });
}
