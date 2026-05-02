import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/core/util/date_converter.dart';

void main() {
  group('DateConverter — canonical timestamp helpers', () {
    group('appleToIsoString', () {
      test('returns null for null', () {
        expect(DateConverter.appleToIsoString(null), isNull);
      });

      test('returns null for zero (no silent epoch coercion)', () {
        expect(DateConverter.appleToIsoString(0), isNull);
        expect(DateConverter.appleToIsoString(0.0), isNull);
      });

      test('returns null for unparseable values', () {
        expect(DateConverter.appleToIsoString('not a number'), isNull);
        expect(DateConverter.appleToIsoString(<String>[]), isNull);
      });

      test('converts Apple nanoseconds variant correctly', () {
        // 2024-06-01T00:00:00Z in unix seconds = 1717200000
        // In Apple nanoseconds = (1717200000 - 978307200) * 1e9 = 738892800e9
        const appleNs = (1717200000 - 978307200) * 1000000000;
        expect(
          DateConverter.appleToIsoString(appleNs),
          '2024-06-01T00:00:00.000Z',
        );
      });

      test('converts Apple seconds variant correctly (old chat.db)', () {
        // 2010-01-01T00:00:00Z in unix seconds = 1262304000
        // In Apple seconds = 1262304000 - 978307200 = 283996800 (well below 1e12)
        const appleSeconds = 1262304000 - 978307200;
        expect(
          DateConverter.appleToIsoString(appleSeconds),
          '2010-01-01T00:00:00.000Z',
        );
      });

      test('does NOT collapse old seconds-format values to 2001-01-01', () {
        // Regression: previously seconds-format Apple values were treated as
        // nanoseconds, dividing by 1e9 and rounding to ~0, producing the
        // "Jan 2001" Unix-epoch-zero-equivalent symptom.
        const appleSeconds = 1262304000 - 978307200;
        final iso = DateConverter.appleToIsoString(appleSeconds);
        expect(iso, isNotNull);
        expect(iso!.startsWith('2010-'), isTrue, reason: 'got $iso');
      });
    });

    group('appleAnyToUnixSeconds', () {
      test('returns null for null and zero', () {
        expect(DateConverter.appleAnyToUnixSeconds(null), isNull);
        expect(DateConverter.appleAnyToUnixSeconds(0), isNull);
      });

      test('handles nanoseconds variant', () {
        const appleNs = (1717200000 - 978307200) * 1000000000;
        expect(DateConverter.appleAnyToUnixSeconds(appleNs), 1717200000);
      });

      test('handles seconds variant', () {
        const appleSeconds = 1262304000 - 978307200;
        expect(DateConverter.appleAnyToUnixSeconds(appleSeconds), 1262304000);
      });
    });

    group('isoStringToUnixSeconds', () {
      test('returns null for null, blank, and invalid', () {
        expect(DateConverter.isoStringToUnixSeconds(null), isNull);
        expect(DateConverter.isoStringToUnixSeconds(''), isNull);
        expect(DateConverter.isoStringToUnixSeconds('   '), isNull);
        expect(DateConverter.isoStringToUnixSeconds('not-a-date'), isNull);
      });

      test('parses ISO 8601 UTC strings', () {
        expect(
          DateConverter.isoStringToUnixSeconds('2024-06-01T00:00:00Z'),
          1717200000,
        );
      });
    });

    group('SQL expression helpers', () {
      test(
        'unixSecondsToIsoTextSqlExpression returns NULL for null and zero',
        () {
          final sql = DateConverter.unixSecondsToIsoTextSqlExpression('col');
          expect(sql.contains('col IS NULL'), isTrue);
          expect(sql.contains('col = 0'), isTrue);
          expect(
            sql.contains("strftime('%Y-%m-%dT%H:%M:%SZ', col, 'unixepoch')"),
            isTrue,
          );
        },
      );

      test('isoTextToUnixSecondsSqlExpression returns NULL for null/blank, '
          'passes through numeric, parses TEXT', () {
        final sql = DateConverter.isoTextToUnixSecondsSqlExpression('col');
        expect(sql.contains('col IS NULL'), isTrue);
        expect(sql.contains("typeof(col) IN ('integer','real')"), isTrue);
        expect(sql.contains("TRIM(CAST(col AS TEXT)) = ''"), isTrue);
        expect(sql.contains("CAST(strftime('%s', col) AS INTEGER)"), isTrue);
      });
    });
  });
}
