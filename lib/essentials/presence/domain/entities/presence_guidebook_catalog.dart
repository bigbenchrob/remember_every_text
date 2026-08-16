import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'choice_option.dart';
import 'test_agent_id.dart';
import 'trip_definition_id.dart';

const _listEquality = ListEquality<Object?>();

/// Complete, immutable guidebook content supplied by one MessageLens build.
///
/// This contract contains no database, runtime capability, or execution state.
@immutable
final class PresenceGuidebookCatalog {
  PresenceGuidebookCatalog({required List<PresenceGuidebookSchedule> schedules})
    : schedules = List<PresenceGuidebookSchedule>.unmodifiable(schedules);

  final List<PresenceGuidebookSchedule> schedules;

  PresenceGuidebookSchedule scheduleById(int id) {
    return schedules.singleWhere((schedule) => schedule.id == id);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PresenceGuidebookCatalog &&
            _listEquality.equals(other.schedules, schedules);
  }

  @override
  int get hashCode => _listEquality.hash(schedules);
}

@immutable
final class PresenceGuidebookSchedule {
  PresenceGuidebookSchedule({
    required this.id,
    required this.name,
    required List<PresenceGuidebookTripOccurrence> trips,
  }) : trips = List<PresenceGuidebookTripOccurrence>.unmodifiable(trips);

  final int id;
  final String name;
  final List<PresenceGuidebookTripOccurrence> trips;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PresenceGuidebookSchedule &&
            other.id == id &&
            other.name == name &&
            _listEquality.equals(other.trips, trips);
  }

  @override
  int get hashCode => Object.hash(id, name, _listEquality.hash(trips));
}

@immutable
final class PresenceGuidebookTripOccurrence {
  const PresenceGuidebookTripOccurrence({
    required this.occurrenceId,
    required this.position,
    required this.trip,
  });

  final int occurrenceId;
  final int position;
  final PresenceGuidebookTrip trip;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PresenceGuidebookTripOccurrence &&
            other.occurrenceId == occurrenceId &&
            other.position == position &&
            other.trip == trip;
  }

  @override
  int get hashCode => Object.hash(occurrenceId, position, trip);
}

@immutable
final class PresenceGuidebookTrip {
  PresenceGuidebookTrip({
    required this.id,
    required this.name,
    required List<PresenceGuidebookStep> steps,
  }) : steps = List<PresenceGuidebookStep>.unmodifiable(steps);

  final TripDefinitionId id;
  final String name;

  /// Ordered Step occurrences. A Step's position is its list index.
  final List<PresenceGuidebookStep> steps;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PresenceGuidebookTrip &&
            other.id == id &&
            other.name == name &&
            _listEquality.equals(other.steps, steps);
  }

  @override
  int get hashCode => Object.hash(id, name, _listEquality.hash(steps));
}

@immutable
sealed class PresenceGuidebookStep {
  const PresenceGuidebookStep({required this.id, required this.name});

  final int id;
  final String name;
}

final class PresenceGuidebookTellStep extends PresenceGuidebookStep {
  const PresenceGuidebookTellStep({
    required super.id,
    required super.name,
    required this.text,
  });

  final String text;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PresenceGuidebookTellStep &&
            other.id == id &&
            other.name == name &&
            other.text == text;
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, text);
}

final class PresenceGuidebookFixedDestinationStep
    extends PresenceGuidebookStep {
  const PresenceGuidebookFixedDestinationStep({
    required super.id,
    required super.name,
    required this.destinationTripDefinitionId,
  });

  final TripDefinitionId destinationTripDefinitionId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PresenceGuidebookFixedDestinationStep &&
            other.id == id &&
            other.name == name &&
            other.destinationTripDefinitionId == destinationTripDefinitionId;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, id, name, destinationTripDefinitionId);
  }
}

final class PresenceGuidebookTestStep extends PresenceGuidebookStep {
  const PresenceGuidebookTestStep({
    required super.id,
    required super.name,
    required this.testAgentId,
    required this.trueDestinationTripDefinitionId,
    required this.falseDestinationTripDefinitionId,
  });

  final TestAgentId testAgentId;
  final TripDefinitionId? trueDestinationTripDefinitionId;
  final TripDefinitionId? falseDestinationTripDefinitionId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PresenceGuidebookTestStep &&
            other.id == id &&
            other.name == name &&
            other.testAgentId == testAgentId &&
            other.trueDestinationTripDefinitionId ==
                trueDestinationTripDefinitionId &&
            other.falseDestinationTripDefinitionId ==
                falseDestinationTripDefinitionId;
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      id,
      name,
      testAgentId,
      trueDestinationTripDefinitionId,
      falseDestinationTripDefinitionId,
    );
  }
}

final class PresenceGuidebookOpenFdaSettingsStep extends PresenceGuidebookStep {
  const PresenceGuidebookOpenFdaSettingsStep({
    required super.id,
    required super.name,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PresenceGuidebookOpenFdaSettingsStep &&
            other.id == id &&
            other.name == name;
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name);
}

final class PresenceGuidebookChoiceStep extends PresenceGuidebookStep {
  PresenceGuidebookChoiceStep({
    required super.id,
    required super.name,
    required List<ChoiceOption> options,
  }) : options = List<ChoiceOption>.unmodifiable(options);

  final List<ChoiceOption> options;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PresenceGuidebookChoiceStep &&
            other.id == id &&
            other.name == name &&
            _listEquality.equals(other.options, options);
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, id, name, _listEquality.hash(options));
  }
}
