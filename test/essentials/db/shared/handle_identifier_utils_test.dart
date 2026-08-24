import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/shared/handle_identifier_utils.dart';

void main() {
  group('interpretHandleIdentifier', () {
    test('preserves established phone normalization', () {
      final interpretation = interpretHandleIdentifier('+1 (604) 685-8506');

      expect(
        interpretation,
        isA<NormalizedHandleIdentifier>().having(
          (value) => value.normalizedIdentifier,
          'normalized identifier',
          '6046858506',
        ),
      );
    });

    test('preserves established email normalization', () {
      final interpretation = interpretHandleIdentifier(' Person@Example.COM ');

      expect(
        interpretation,
        isA<NormalizedHandleIdentifier>().having(
          (value) => value.normalizedIdentifier,
          'normalized identifier',
          'person@example.com',
        ),
      );
    });

    test('does not invent semantics for punctuation-heavy text', () {
      expect(
        interpretHandleIdentifier('*city*'),
        isA<PreservedUnnormalizedHandleIdentifier>(),
      );
      expect(
        interpretHandleIdentifier('urn:business:42'),
        isA<PreservedUnnormalizedHandleIdentifier>(),
      );
    });

    test('normal path does not require exception control flow', () {
      const values = <String>[
        '+16046858506',
        '6046858506',
        'person@example.com',
        '74720',
      ];

      for (var iteration = 0; iteration < 2500; iteration++) {
        for (final value in values) {
          expect(
            interpretHandleIdentifier(value),
            isA<NormalizedHandleIdentifier>(),
          );
        }
      }
    });
  });
}
