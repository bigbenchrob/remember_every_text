import 'package:meta/meta.dart';

import 'choice_value.dart';
import 'trip_definition_id.dart';

/// One configured value, label, and destination within a ChoiceStep.
@immutable
final class ChoiceOption {
  const ChoiceOption({
    required this.value,
    required this.label,
    required this.destinationTripDefinitionId,
  });

  final ChoiceValue value;
  final String label;
  final TripDefinitionId destinationTripDefinitionId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ChoiceOption &&
            other.value == value &&
            other.label == label &&
            other.destinationTripDefinitionId == destinationTripDefinitionId;
  }

  @override
  int get hashCode => Object.hash(value, label, destinationTripDefinitionId);

  @override
  String toString() {
    return 'ChoiceOption('
        'value: $value, '
        'label: $label, '
        'destinationTripDefinitionId: $destinationTripDefinitionId'
        ')';
  }
}
