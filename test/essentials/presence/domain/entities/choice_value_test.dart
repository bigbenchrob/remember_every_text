import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/choice_value.dart';

void main() {
  group('ChoiceValue', () {
    test('preserves its exact opaque string', () {
      final value = ChoiceValue('  import_anyway  ');

      expect(value.value, '  import_anyway  ');
    });

    test('uses value equality and matching hash semantics', () {
      final first = ChoiceValue('pause');
      final second = ChoiceValue('pause');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('keeps distinct values distinct', () {
      expect(ChoiceValue('pause'), isNot(ChoiceValue('continue')));
    });

    test('rejects empty and whitespace-only values', () {
      expect(() => ChoiceValue(''), throwsArgumentError);
      expect(() => ChoiceValue('   '), throwsArgumentError);
    });
  });
}
