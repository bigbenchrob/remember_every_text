import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_test_agent_bindings.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_test_agent_ids.dart';
import 'package:remember_this_text/essentials/onboarding/application/required_sources_readiness_schedule.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/schedule_definition.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/step.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip_definition_id.dart';
import 'package:remember_this_text/essentials/presence/domain/services/fda_settings_opening_authority.dart';
import 'package:remember_this_text/essentials/presence/domain/services/presence_scheduler.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent_resolver.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/data_sources/local/presence_database.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/repositories/drift_presence_schedule_repository.dart';

void main() {
  late PresenceDatabase database;
  late _MutableTestAgent messagesAgent;
  late _MutableTestAgent contactsAgent;
  late _MutableTestAgent historyAgent;
  late TestAgentResolver resolver;
  late DriftPresenceScheduleRepository repository;
  late ScheduleDefinition previousDefinition;
  late ScheduleDefinition targetDefinition;

  setUp(() async {
    database = PresenceDatabase(NativeDatabase.memory());
    messagesAgent = _MutableTestAgent(result: true);
    contactsAgent = _MutableTestAgent(result: true);
    historyAgent = _MutableTestAgent(result: true);
    resolver = ImmutableTestAgentResolver(
      buildOnboardingTestAgentBindings(
        messagesSourceReadinessTestAgent: messagesAgent,
        contactsSourceReadinessTestAgent: contactsAgent,
        messagesSourceHistorySufficiencyTestAgent: historyAgent,
      ),
    );
    repository = DriftPresenceScheduleRepository(
      database: database,
      testAgentResolver: resolver,
      fdaSettingsOpeningAuthority: const _NoOpSettingsAuthority(),
    );
    targetDefinition = buildRequiredSourcesReadinessDefinition(
      testAgentResolver: resolver,
      fdaSettingsOpeningAuthority: const _NoOpSettingsAuthority(),
    );
    previousDefinition = _buildPreviousDefinition(
      target: targetDefinition,
      contactsAgent: contactsAgent,
    );
    await repository.insertDefinition(previousDefinition);
  });

  tearDown(() async {
    await database.close();
  });

  test('extends an active old run without resetting its checkpoint', () async {
    var scheduler = await _startScheduler(repository);
    await _completeIntroduction(scheduler);
    await scheduler.completeCurrentStep();
    expect(
      scheduler.currentTrip?.definition.id,
      determineContactsSourceReadinessTripId,
    );
    final runId = scheduler.run!.id;
    final occurrenceId = scheduler.run!.currentTripOccurrenceId;
    final traceBefore = await repository.loadExecutionTrace(runId);

    await repository.installOrExtendDefinition(targetDefinition);
    scheduler = await _startScheduler(repository);

    expect(scheduler.run?.id, runId);
    expect(scheduler.run?.currentTripOccurrenceId, occurrenceId);
    expect(
      scheduler.currentTrip?.definition.id,
      determineContactsSourceReadinessTripId,
    );
    await scheduler.completeCurrentStep();
    expect(
      scheduler.currentTrip?.definition.id,
      determineMessagesSourceHistorySufficiencyTripId,
    );
    expect(
      (await repository.loadExecutionTrace(
        runId,
      )).take(traceBefore.length).map((event) => event.id),
      traceBefore.map((event) => event.id),
    );
  });

  test('preserves the old confirmation occurrence and its meaning', () async {
    var scheduler = await _startScheduler(repository);
    await _completeIntroduction(scheduler);
    await scheduler.completeCurrentStep();
    await scheduler.completeCurrentStep();
    expect(scheduler.run?.currentTripOccurrenceId, 6107);
    expect(
      scheduler.currentTrip?.definition.id,
      confirmRequiredSourcesReadableTripId,
    );
    final runId = scheduler.run!.id;

    await repository.installOrExtendDefinition(targetDefinition);
    scheduler = await _startScheduler(repository);
    final confirmationOccurrence = await (database.select(
      database.scheduleTripOccurrences,
    )..where((table) => table.id.equals(6107))).getSingle();

    expect(scheduler.run?.id, runId);
    expect(scheduler.run?.currentTripOccurrenceId, 6107);
    expect(
      scheduler.currentTrip?.definition.id,
      confirmRequiredSourcesReadableTripId,
    );
    expect(confirmationOccurrence.position, 8);
  });

  test('does not reopen a completed old run', () async {
    var scheduler = await _startScheduler(repository);
    await _completeIntroduction(scheduler);
    await scheduler.completeCurrentStep();
    await scheduler.completeCurrentStep();
    await scheduler.completeCurrentStep();
    expect(scheduler.isComplete, isTrue);
    final runId = scheduler.run!.id;

    await repository.installOrExtendDefinition(targetDefinition);
    scheduler = await _startScheduler(repository);

    expect(scheduler.run?.id, runId);
    expect(scheduler.isComplete, isTrue);
  });

  test(
    'rejects occurrence remapping and leaves the old definition intact',
    () async {
      final confirmation = targetDefinition.trips.singleWhere(
        (scheduledTrip) =>
            scheduledTrip.trip.id == confirmRequiredSourcesReadableTripId,
      );
      final remappedTrips = <ScheduleTripDefinition>[
        ...targetDefinition.trips.where(
          (scheduledTrip) => scheduledTrip.occurrenceId != 6107,
        ),
        ScheduleTripDefinition(
          occurrenceId: 6107,
          position: 8,
          trip: TripDefinition(
            id: const TripDefinitionId(310),
            name: 'invalid_replacement_trip',
            steps: const <Step>[
              TellStep(id: 7001, name: 'invalid_replacement', text: 'Invalid.'),
            ],
          ),
        ),
        ScheduleTripDefinition(
          occurrenceId: 6110,
          position: 9,
          trip: confirmation.trip,
        ),
      ];
      final remapped = ScheduleDefinition(
        id: targetDefinition.id,
        name: targetDefinition.name,
        trips: remappedTrips,
      );

      await expectLater(
        repository.installOrExtendDefinition(remapped),
        throwsA(isA<StateError>()),
      );

      final loaded = await repository.loadDefinition(
        requiredSourcesReadinessScheduleId,
      );
      expect(loaded.trips, hasLength(7));
      expect(loaded.trips.last.occurrenceId, 6107);
      expect(loaded.trips.last.trip.id, confirmRequiredSourcesReadableTripId);
    },
  );
}

ScheduleDefinition _buildPreviousDefinition({
  required ScheduleDefinition target,
  required TestAgent contactsAgent,
}) {
  final trips = <ScheduleTripDefinition>[];
  for (final scheduledTrip in target.trips) {
    if (scheduledTrip.trip.id ==
            determineMessagesSourceHistorySufficiencyTripId ||
        scheduledTrip.trip.id == guideSparseMessagesSourceHistoryTripId) {
      continue;
    }
    if (scheduledTrip.trip.id == determineContactsSourceReadinessTripId) {
      trips.add(
        ScheduleTripDefinition(
          occurrenceId: scheduledTrip.occurrenceId,
          position: scheduledTrip.position,
          trip: TripDefinition(
            id: scheduledTrip.trip.id,
            name: scheduledTrip.trip.name,
            steps: <Step>[
              TestStep(
                id: 6501,
                name: 'test_required_sources_contacts_readiness',
                testAgentId: contactsSourceReadableTestAgentId,
                testAgent: contactsAgent,
                trueDestinationTripDefinitionId:
                    confirmRequiredSourcesReadableTripId,
                falseDestinationTripDefinitionId: null,
              ),
            ],
          ),
        ),
      );
      continue;
    }
    trips.add(
      scheduledTrip.trip.id == confirmRequiredSourcesReadableTripId
          ? ScheduleTripDefinition(
              occurrenceId: scheduledTrip.occurrenceId,
              position: 6,
              trip: scheduledTrip.trip,
            )
          : scheduledTrip,
    );
  }
  return ScheduleDefinition(id: target.id, name: target.name, trips: trips);
}

Future<PresenceScheduler> _startScheduler(
  DriftPresenceScheduleRepository repository,
) async {
  final scheduler = PresenceScheduler(
    repository: repository,
    scheduleDefinitionId: requiredSourcesReadinessScheduleId,
  );
  await scheduler.initialize();
  return scheduler;
}

Future<void> _completeIntroduction(PresenceScheduler scheduler) async {
  await scheduler.completeCurrentStep();
  await scheduler.completeCurrentStep();
}

final class _MutableTestAgent implements TestAgent {
  _MutableTestAgent({required this.result});

  bool result;

  @override
  Future<bool> evaluate() async => result;
}

final class _NoOpSettingsAuthority implements FdaSettingsOpeningAuthority {
  const _NoOpSettingsAuthority();

  @override
  Future<void> openSettings() async {}
}
