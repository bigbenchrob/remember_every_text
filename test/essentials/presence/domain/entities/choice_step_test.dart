import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/choice_option.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/choice_value.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/step.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip_definition_id.dart';

void main() {
  group('ChoiceStep', () {
    test('constructs with two ordered choices', () {
      final options = <ChoiceOption>[
        _option('blue', 'Blue', 12),
        _option('pink', 'Pink', 15),
      ];

      final step = _step(options);

      expect(step.options, orderedEquals(options));
    });

    test('constructs with three or more choices', () {
      final step = _step(<ChoiceOption>[
        _option('blue', 'Blue', 12),
        _option('pink', 'Pink', 15),
        _option('purple', 'Purple', 19),
      ]);

      expect(step.options, hasLength(3));
    });

    test('rejects zero choices', () {
      expect(() => _step(<ChoiceOption>[]), throwsArgumentError);
    });

    test('rejects one choice', () {
      expect(
        () => _step(<ChoiceOption>[_option('continue', 'Continue', 12)]),
        throwsArgumentError,
      );
    });

    test('defensively copies choices and exposes an immutable list', () {
      final options = <ChoiceOption>[
        _option('blue', 'Blue', 12),
        _option('pink', 'Pink', 15),
      ];
      final step = _step(options);

      options
        ..clear()
        ..add(_option('purple', 'Purple', 19));

      expect(
        step.options.map((option) => option.value.value),
        orderedEquals(<String>['blue', 'pink']),
      );
      expect(
        () => step.options.add(_option('purple', 'Purple', 19)),
        throwsUnsupportedError,
      );
    });

    test('rejects duplicate values within the Step', () {
      expect(
        () => _step(<ChoiceOption>[
          _option('review', 'Review now', 12),
          _option('review', 'Review later', 15),
        ]),
        throwsArgumentError,
      );
    });

    test('allows duplicate labels because labels are not identity', () {
      final step = _step(<ChoiceOption>[
        _option('choice_a', 'Continue', 12),
        _option('choice_b', 'Continue', 15),
      ]);

      expect(step.options.map((option) => option.label), <String>[
        'Continue',
        'Continue',
      ]);
    });

    test('allows distinct choices to share one destination', () {
      final step = _step(<ChoiceOption>[
        _option('choice_a', 'First path', 15),
        _option('choice_b', 'Second path', 15),
      ]);

      expect(
        step.destinationFor(ChoiceValue('choice_a')),
        const TripDefinitionId(15),
      );
      expect(
        step.destinationFor(ChoiceValue('choice_b')),
        const TripDefinitionId(15),
      );
    });

    test('resolves a known opaque value to its configured destination', () {
      final step = _step(<ChoiceOption>[
        _option('blue', 'Blue', 12),
        _option('pink', 'Pink', 15),
        _option('purple', 'Purple', 19),
      ]);

      expect(
        step.destinationFor(ChoiceValue('pink')),
        const TripDefinitionId(15),
      );
    });

    test('rejects an unknown selected value explicitly', () {
      final step = _step(<ChoiceOption>[
        _option('blue', 'Blue', 12),
        _option('pink', 'Pink', 15),
      ]);

      expect(
        () => step.destinationFor(ChoiceValue('not-present')),
        throwsArgumentError,
      );
    });

    test('never uses human-facing labels as lookup keys', () {
      final step = _step(<ChoiceOption>[
        _option('choice_a', 'Continue', 12),
        _option('choice_b', 'Pause', 15),
      ]);

      expect(
        () => step.destinationFor(ChoiceValue('Continue')),
        throwsArgumentError,
      );
    });

    test('label revisions preserve the same durable route', () {
      final original = _step(<ChoiceOption>[
        _option('pause', "That's good for now", 15),
        _option('continue', 'Continue', 19),
      ]);
      final revised = _step(<ChoiceOption>[
        _option('pause', 'Finish for now', 15),
        _option('continue', 'Continue', 19),
      ]);

      expect(
        original.destinationFor(ChoiceValue('pause')),
        const TripDefinitionId(15),
      );
      expect(
        revised.destinationFor(ChoiceValue('pause')),
        const TripDefinitionId(15),
      );
    });

    test('does not autonomously complete its terminal human decision', () {
      final step = _step(<ChoiceOption>[
        _option('pause', 'Pause', 12),
        _option('continue', 'Continue', 15),
      ]);

      expect(step.complete, throwsUnsupportedError);
    });
  });
}

ChoiceStep _step(List<ChoiceOption> options) {
  return ChoiceStep(id: 100, name: 'choose_route', options: options);
}

ChoiceOption _option(String value, String label, int destination) {
  return ChoiceOption(
    value: ChoiceValue(value),
    label: label,
    destinationTripDefinitionId: TripDefinitionId(destination),
  );
}
