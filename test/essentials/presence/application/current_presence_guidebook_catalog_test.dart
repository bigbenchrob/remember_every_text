import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/presence/application/current_presence_guidebook_catalog.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/choice_value.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/presence_guidebook_catalog.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip_definition_id.dart';

void main() {
  test('builds and validates without runtime infrastructure', () {
    final catalog = currentPresenceGuidebookCatalog();

    expect(catalog.schedules, hasLength(1));
    expect(
      catalog.scheduleById(requiredSourcesReadinessScheduleId).trips,
      hasLength(11),
    );
  });

  test('constructs the same complete catalog deterministically', () {
    expect(
      currentPresenceGuidebookCatalog(),
      currentPresenceGuidebookCatalog(),
    );
  });

  test('preserves current production topology and content', () {
    final schedule = currentPresenceGuidebookCatalog().scheduleById(
      requiredSourcesReadinessScheduleId,
    );
    final tripsById = <int, PresenceGuidebookTrip>{
      for (final occurrence in schedule.trips)
        occurrence.trip.id.value: occurrence.trip,
    };

    expect(
      schedule.trips.map((occurrence) => occurrence.position).toSet(),
      <int>{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10},
    );
    expect(tripsById.keys, <int>{
      301,
      302,
      303,
      304,
      305,
      306,
      307,
      308,
      309,
      310,
      311,
    });

    final initialMessagesTest =
        tripsById[determineInitialMessagesSourceReadinessTripId.value]!
                .steps
                .single
            as PresenceGuidebookTestStep;
    expect(initialMessagesTest.testAgentId, messagesSourceReadableTestAgentId);
    expect(
      initialMessagesTest.trueDestinationTripDefinitionId,
      determineContactsSourceReadinessTripId,
    );
    expect(
      initialMessagesTest.falseDestinationTripDefinitionId,
      classifyMessagesSourceFailureTripId,
    );

    final sparseChoice =
        tripsById[guideSparseMessagesSourceHistoryTripId.value]!.steps.last
            as PresenceGuidebookChoiceStep;
    expect(
      sparseChoice.options
          .map(
            (option) => (
              option.value,
              option.label,
              option.destinationTripDefinitionId,
            ),
          )
          .toList(growable: false),
      <(ChoiceValue, String, TripDefinitionId)>[
        (
          ChoiceValue('recheck'),
          'Re-check',
          determineMessagesSourceHistorySufficiencyTripId,
        ),
        (
          ChoiceValue('import_anyway'),
          'Import Anyway',
          confirmRequiredSourcesReadableTripId,
        ),
      ],
    );

    final fdaInstruction = tripsById[guideUnreadableMessagesSourceTripId.value]!
        .steps
        .whereType<PresenceGuidebookTellStep>()
        .singleWhere((step) => step.id == 6302);
    expect(fdaInstruction.text, contains('MessageLens Development'));
  });

  test('declares opaque Agent IDs without executable Agents', () {
    final steps = currentPresenceGuidebookCatalog()
        .scheduleById(requiredSourcesReadinessScheduleId)
        .trips
        .expand((occurrence) => occurrence.trip.steps)
        .whereType<PresenceGuidebookTestStep>();

    expect(steps.map((step) => step.testAgentId).toSet(), <Object>{
      messagesSourceReadableTestAgentId,
      messagesSourceAccessDeniedTestAgentId,
      contactsSourceReadableTestAgentId,
      messagesSourceHistorySufficientTestAgentId,
    });
  });
}
