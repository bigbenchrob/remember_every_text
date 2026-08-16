import '../entities/choice_value.dart';
import '../entities/presence_guidebook_catalog.dart';
import '../entities/trip_definition_id.dart';

/// Validates guidebook structure without resolving capabilities or using I/O.
final class PresenceGuidebookCatalogValidator {
  const PresenceGuidebookCatalogValidator();

  void validate(PresenceGuidebookCatalog catalog) {
    if (catalog.schedules.isEmpty) {
      throw ArgumentError('A Presence guidebook requires a Schedule.');
    }

    final scheduleIds = <int>{};
    final scheduleNames = <String>{};
    final occurrenceIds = <int>{};
    final tripsById = <TripDefinitionId, PresenceGuidebookTrip>{};
    final tripNames = <String>{};
    final stepsById = <int, PresenceGuidebookStep>{};
    final stepNames = <String>{};

    for (final schedule in catalog.schedules) {
      _requireNonEmpty(schedule.name, 'Schedule names');
      if (!scheduleIds.add(schedule.id)) {
        throw ArgumentError('Duplicate Schedule identity ${schedule.id}.');
      }
      if (!scheduleNames.add(schedule.name)) {
        throw ArgumentError('Duplicate Schedule name ${schedule.name}.');
      }
      if (schedule.trips.isEmpty) {
        throw ArgumentError('Schedule ${schedule.id} requires a Trip.');
      }

      final positions = <int>{};
      final scheduleTripIds = <TripDefinitionId>{};
      for (final occurrence in schedule.trips) {
        if (!occurrenceIds.add(occurrence.occurrenceId)) {
          throw ArgumentError(
            'Duplicate Schedule Trip occurrence identity '
            '${occurrence.occurrenceId}.',
          );
        }
        if (occurrence.position < 0) {
          throw ArgumentError('Schedule Trip positions must be non-negative.');
        }
        if (!positions.add(occurrence.position)) {
          throw ArgumentError(
            'Duplicate Schedule Trip position ${occurrence.position} in '
            'Schedule ${schedule.id}.',
          );
        }
        if (!scheduleTripIds.add(occurrence.trip.id)) {
          throw ArgumentError(
            'Trip ${occurrence.trip.id} appears more than once in Schedule '
            '${schedule.id}.',
          );
        }
        _validateCanonicalTrip(
          occurrence.trip,
          tripsById: tripsById,
          tripNames: tripNames,
          stepsById: stepsById,
          stepNames: stepNames,
        );
      }

      for (final occurrence in schedule.trips) {
        _validateRoutes(
          scheduleId: schedule.id,
          trip: occurrence.trip,
          scheduleTripIds: scheduleTripIds,
        );
      }
    }
  }

  void _validateCanonicalTrip(
    PresenceGuidebookTrip trip, {
    required Map<TripDefinitionId, PresenceGuidebookTrip> tripsById,
    required Set<String> tripNames,
    required Map<int, PresenceGuidebookStep> stepsById,
    required Set<String> stepNames,
  }) {
    _requireNonEmpty(trip.name, 'Trip names');
    final existingTrip = tripsById[trip.id];
    if (existingTrip != null && existingTrip != trip) {
      throw ArgumentError('Trip ${trip.id} has conflicting definitions.');
    }
    if (existingTrip == null) {
      tripsById[trip.id] = trip;
      if (!tripNames.add(trip.name)) {
        throw ArgumentError('Duplicate Trip name ${trip.name}.');
      }
    }
    if (trip.steps.isEmpty) {
      throw ArgumentError('Trip ${trip.id} requires a Step.');
    }

    for (final step in trip.steps) {
      _requireNonEmpty(step.name, 'Step names');
      final existingStep = stepsById[step.id];
      if (existingStep != null && existingStep != step) {
        throw ArgumentError('Step ${step.id} has conflicting definitions.');
      }
      if (existingStep == null) {
        stepsById[step.id] = step;
        if (!stepNames.add(step.name)) {
          throw ArgumentError('Duplicate Step name ${step.name}.');
        }
      }
      _validateStepPayload(step);
    }
  }

  void _validateStepPayload(PresenceGuidebookStep step) {
    switch (step) {
      case PresenceGuidebookTellStep():
        _requireNonEmpty(step.text, 'Tell Step text');
        return;
      case PresenceGuidebookTestStep():
        _requireNonEmpty(step.testAgentId.value, 'Test Agent IDs');
        return;
      case PresenceGuidebookChoiceStep():
        if (step.options.length < 2) {
          throw ArgumentError(
            'Choice Step ${step.id} requires at least two options.',
          );
        }
        final values = <ChoiceValue>{};
        for (final option in step.options) {
          if (!values.add(option.value)) {
            throw ArgumentError(
              'Choice Step ${step.id} contains duplicate value '
              '${option.value.value}.',
            );
          }
        }
        return;
      case PresenceGuidebookFixedDestinationStep() ||
          PresenceGuidebookOpenFdaSettingsStep():
        return;
    }
  }

  void _validateRoutes({
    required int scheduleId,
    required PresenceGuidebookTrip trip,
    required Set<TripDefinitionId> scheduleTripIds,
  }) {
    for (var index = 0; index < trip.steps.length; index += 1) {
      final step = trip.steps[index];
      switch (step) {
        case PresenceGuidebookTellStep():
          break;
        case PresenceGuidebookFixedDestinationStep():
          _requireDestination(
            stepId: step.id,
            scheduleId: scheduleId,
            destination: step.destinationTripDefinitionId,
            scheduleTripIds: scheduleTripIds,
          );
          _requireTerminal(step: step, index: index, trip: trip);
          break;
        case PresenceGuidebookTestStep():
          for (final destination in <TripDefinitionId?>[
            step.trueDestinationTripDefinitionId,
            step.falseDestinationTripDefinitionId,
          ]) {
            if (destination != null) {
              _requireDestination(
                stepId: step.id,
                scheduleId: scheduleId,
                destination: destination,
                scheduleTripIds: scheduleTripIds,
              );
            }
          }
          _requireTerminal(step: step, index: index, trip: trip);
          break;
        case PresenceGuidebookChoiceStep():
          for (final option in step.options) {
            _requireDestination(
              stepId: step.id,
              scheduleId: scheduleId,
              destination: option.destinationTripDefinitionId,
              scheduleTripIds: scheduleTripIds,
            );
          }
          _requireTerminal(step: step, index: index, trip: trip);
          break;
        case PresenceGuidebookOpenFdaSettingsStep():
          _requireTerminal(step: step, index: index, trip: trip);
          break;
      }
    }
  }

  void _requireDestination({
    required int stepId,
    required int scheduleId,
    required TripDefinitionId destination,
    required Set<TripDefinitionId> scheduleTripIds,
  }) {
    if (!scheduleTripIds.contains(destination)) {
      throw ArgumentError(
        'Step $stepId points to $destination, which is absent from Schedule '
        '$scheduleId.',
      );
    }
  }

  void _requireTerminal({
    required PresenceGuidebookStep step,
    required int index,
    required PresenceGuidebookTrip trip,
  }) {
    if (index != trip.steps.length - 1) {
      throw ArgumentError(
        '${step.runtimeType} ${step.id} must be terminal in Trip ${trip.id}.',
      );
    }
  }

  void _requireNonEmpty(String value, String label) {
    if (value.trim().isEmpty) {
      throw ArgumentError('$label must not be empty.');
    }
  }
}
