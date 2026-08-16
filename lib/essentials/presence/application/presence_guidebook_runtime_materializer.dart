import '../domain/entities/presence_guidebook_catalog.dart';
import '../domain/entities/schedule_definition.dart';
import '../domain/entities/step.dart';
import '../domain/entities/trip.dart';
import '../domain/services/fda_settings_opening_authority.dart';
import '../domain/services/test_agent_resolver.dart';

/// Temporary bridge from pure guidebook data to today's executable definitions.
///
/// Installation and replacement do not exist yet, so current runtime still
/// submits this materialized definition to `installOrExtendDefinition`.
ScheduleDefinition materializePresenceGuidebookSchedule({
  required PresenceGuidebookSchedule schedule,
  required TestAgentResolver testAgentResolver,
  required FdaSettingsOpeningAuthority fdaSettingsOpeningAuthority,
}) {
  return ScheduleDefinition(
    id: schedule.id,
    name: schedule.name,
    trips: schedule.trips
        .map(
          (occurrence) => ScheduleTripDefinition(
            occurrenceId: occurrence.occurrenceId,
            position: occurrence.position,
            trip: TripDefinition(
              id: occurrence.trip.id,
              name: occurrence.trip.name,
              steps: occurrence.trip.steps
                  .map(
                    (step) => _materializeStep(
                      step,
                      testAgentResolver: testAgentResolver,
                      fdaSettingsOpeningAuthority: fdaSettingsOpeningAuthority,
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        )
        .toList(growable: false),
  );
}

Step _materializeStep(
  PresenceGuidebookStep step, {
  required TestAgentResolver testAgentResolver,
  required FdaSettingsOpeningAuthority fdaSettingsOpeningAuthority,
}) {
  return switch (step) {
    PresenceGuidebookTellStep() => TellStep(
      id: step.id,
      name: step.name,
      text: step.text,
    ),
    PresenceGuidebookFixedDestinationStep() => FixedDestinationStep(
      id: step.id,
      name: step.name,
      destinationTripDefinitionId: step.destinationTripDefinitionId,
    ),
    PresenceGuidebookTestStep() => TestStep(
      id: step.id,
      name: step.name,
      testAgentId: step.testAgentId,
      testAgent: testAgentResolver.resolve(step.testAgentId),
      trueDestinationTripDefinitionId: step.trueDestinationTripDefinitionId,
      falseDestinationTripDefinitionId: step.falseDestinationTripDefinitionId,
    ),
    PresenceGuidebookOpenFdaSettingsStep() => OpenFdaSettingsStep(
      id: step.id,
      name: step.name,
      settingsOpeningAuthority: fdaSettingsOpeningAuthority,
    ),
    PresenceGuidebookChoiceStep() => ChoiceStep(
      id: step.id,
      name: step.name,
      options: step.options,
    ),
  };
}
