import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/core/util/date_converter.dart';

void main() {
  group('DateConverter Apple timestamp normalization', () {
    test('converts donor 2012 Apple-epoch seconds', () {
      expect(
        DateConverter.appleToIsoString(364929382),
        '2012-07-25T17:16:22.000Z',
      );
    });

    test('converts donor 2017 Apple-epoch seconds', () {
      expect(
        DateConverter.appleToIsoString(518890287),
        '2017-06-11T16:11:27.000Z',
      );
    });

    test('preserves modern Apple nanoseconds before conversion', () {
      const modernAppleTimestamp = 808531200000000000;

      expect(
        DateConverter.normalizeAppleTimestamp(modernAppleTimestamp),
        modernAppleTimestamp,
      );
      expect(
        DateConverter.appleToIsoString(modernAppleTimestamp),
        '2026-08-16T00:00:00.000Z',
      );
    });

    test('normalizes old Apple seconds to canonical nanoseconds', () {
      expect(
        DateConverter.normalizeAppleTimestamp(364929382),
        364929382000000000,
      );
    });

    test('does not collapse old Apple seconds to the 2001 epoch', () {
      final converted = DateConverter.appleToDateTime(364929382);

      expect(converted, isNotNull);
      expect(converted!.toUtc().year, 2012);
      expect(converted.toUtc().year, isNot(2001));
    });
  });
}
