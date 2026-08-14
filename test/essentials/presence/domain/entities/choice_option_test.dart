import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/choice_option.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/choice_value.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip_definition_id.dart';

void main() {
  test(
    'ChoiceOption preserves its configured value, label, and destination',
    () {
      final option = ChoiceOption(
        value: ChoiceValue('pause'),
        label: "That's good for now",
        destinationTripDefinitionId: const TripDefinitionId(15),
      );

      expect(option.value, ChoiceValue('pause'));
      expect(option.label, "That's good for now");
      expect(option.destinationTripDefinitionId, const TripDefinitionId(15));
    },
  );

  test('label copy can change without changing durable routing identity', () {
    final original = ChoiceOption(
      value: ChoiceValue('pause'),
      label: "That's good for now",
      destinationTripDefinitionId: const TripDefinitionId(15),
    );
    final revised = ChoiceOption(
      value: ChoiceValue('pause'),
      label: 'Finish for now',
      destinationTripDefinitionId: const TripDefinitionId(15),
    );

    expect(revised.value, original.value);
    expect(
      revised.destinationTripDefinitionId,
      original.destinationTripDefinitionId,
    );
    expect(revised.label, isNot(original.label));
  });
}
