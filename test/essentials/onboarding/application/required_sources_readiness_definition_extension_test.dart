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
        messagesSourceAccessDeniedTestAgent: messagesAgent,
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
      messagesAgent: messagesAgent,
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

  test('preserves an active checkpoint in the historical FDA Trip', () async {
    messagesAgent.result = false;
    var scheduler = await _startScheduler(repository);
    await _completeIntroduction(scheduler);
    await scheduler.completeCurrentStep();
    expect(scheduler.run?.currentTripOccurrenceId, 6103);
    expect(
      scheduler.currentTrip?.definition.id,
      guideUnreadableMessagesSourceTripId,
    );
    final runId = scheduler.run!.id;

    await repository.installOrExtendDefinition(targetDefinition);
    scheduler = await _startScheduler(repository);

    expect(scheduler.run?.id, runId);
    expect(scheduler.run?.currentTripOccurrenceId, 6103);
    expect(
      (_stepById(targetDefinition, 6302) as TellStep).text,
      contains('Development'),
    );
    await scheduler.completeCurrentStep();
    await scheduler.completeCurrentStep();
    await scheduler.completeCurrentStep();
    expect(scheduler.run?.currentTripOccurrenceId, 6104);
    expect(
      scheduler.currentTrip?.definition.id,
      verifyMessagesSourceReadinessTripId,
    );
  });

  test(
    'extends the exact pre-Slice-55 definition without redefining Step 6302',
    () async {
      final before = await repository.loadDefinition(
        requiredSourcesReadinessScheduleId,
      );
      final historicalStep = _stepById(before, 6302) as TellStep;
      expect(
        historicalStep.text,
        'In Full Disk Access, add or enable MessageLens Development. '
        'macOS may ask you to quit and reopen the app after you make the '
        'change.',
      );

      await repository.installOrExtendDefinition(targetDefinition);

      final extended = await repository.loadDefinition(
        requiredSourcesReadinessScheduleId,
      );
      final preservedStep = _stepById(extended, 6302) as TellStep;
      expect(preservedStep.text, historicalStep.text);
      expect(
        extended.trips.map((scheduledTrip) => scheduledTrip.trip.id),
        containsAll(<TripDefinitionId>[
          classifyMessagesSourceFailureTripId,
          guideUnavailableMessagesSourceTripId,
        ]),
      );
      expect(_stepById(extended, 7001), isA<TestStep>());
      expect(_stepById(extended, 7101), isA<TellStep>());
    },
  );

  test('still rejects a genuine semantic redefinition of Step 6302', () async {
    await repository.installOrExtendDefinition(targetDefinition);
    final redefined = _replaceStep(
      definition: targetDefinition,
      tripId: guideUnreadableMessagesSourceTripId,
      replacement: const TellStep(
        id: 6302,
        name: 'explain_required_sources_full_disk_access_action',
        text: 'A different instruction under the same canonical identity.',
      ),
    );

    await expectLater(
      repository.installOrExtendDefinition(redefined),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('Existing Step 6302'),
        ),
      ),
    );

    final preserved = await repository.loadDefinition(
      requiredSourcesReadinessScheduleId,
    );
    expect(
      (_stepById(preserved, 6302) as TellStep).text,
      contains('Development'),
    );
  });

  test('accepts an identical current definition after extension', () async {
    await repository.installOrExtendDefinition(targetDefinition);

    await expectLater(
      repository.installOrExtendDefinition(targetDefinition),
      completes,
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
    expect(confirmationOccurrence.position, 10);
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
          position: 10,
          trip: TripDefinition(
            id: const TripDefinitionId(999),
            name: 'invalid_replacement_trip',
            steps: const <Step>[
              TellStep(id: 9991, name: 'invalid_replacement', text: 'Invalid.'),
            ],
          ),
        ),
        ScheduleTripDefinition(
          occurrenceId: 6199,
          position: 11,
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
  required TestAgent messagesAgent,
  required TestAgent contactsAgent,
}) {
  final trips = <ScheduleTripDefinition>[];
  for (final scheduledTrip in target.trips) {
    if (scheduledTrip.trip.id ==
            determineMessagesSourceHistorySufficiencyTripId ||
        scheduledTrip.trip.id == guideSparseMessagesSourceHistoryTripId ||
        scheduledTrip.trip.id == classifyMessagesSourceFailureTripId ||
        scheduledTrip.trip.id == guideUnavailableMessagesSourceTripId) {
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
    if (scheduledTrip.trip.id ==
        determineInitialMessagesSourceReadinessTripId) {
      trips.add(
        ScheduleTripDefinition(
          occurrenceId: scheduledTrip.occurrenceId,
          position: scheduledTrip.position,
          trip: TripDefinition(
            id: scheduledTrip.trip.id,
            name: scheduledTrip.trip.name,
            steps: <Step>[
              TestStep(
                id: 6201,
                name: 'test_required_sources_initial_messages_readiness',
                testAgentId: messagesSourceReadableTestAgentId,
                testAgent: messagesAgent,
                trueDestinationTripDefinitionId:
                    determineContactsSourceReadinessTripId,
                falseDestinationTripDefinitionId:
                    guideUnreadableMessagesSourceTripId,
              ),
            ],
          ),
        ),
      );
      continue;
    }
    if (scheduledTrip.trip.id == verifyMessagesSourceReadinessTripId) {
      trips.add(
        ScheduleTripDefinition(
          occurrenceId: scheduledTrip.occurrenceId,
          position: scheduledTrip.position,
          trip: TripDefinition(
            id: scheduledTrip.trip.id,
            name: scheduledTrip.trip.name,
            steps: <Step>[
              scheduledTrip.trip.steps.first,
              TestStep(
                id: 6402,
                name: 'test_required_sources_messages_verification',
                testAgentId: messagesSourceReadableTestAgentId,
                testAgent: messagesAgent,
                trueDestinationTripDefinitionId: null,
                falseDestinationTripDefinitionId:
                    guideUnreadableMessagesSourceTripId,
              ),
            ],
          ),
        ),
      );
      continue;
    }
    if (scheduledTrip.trip.id == guideUnreadableMessagesSourceTripId) {
      trips.add(
        ScheduleTripDefinition(
          occurrenceId: scheduledTrip.occurrenceId,
          position: scheduledTrip.position,
          trip: TripDefinition(
            id: scheduledTrip.trip.id,
            name: scheduledTrip.trip.name,
            steps: <Step>[
              scheduledTrip.trip.steps.first,
              const TellStep(
                id: 6302,
                name: 'explain_required_sources_full_disk_access_action',
                text:
                    'In Full Disk Access, add or enable '
                    'MessageLens Development. macOS may ask you to quit and '
                    'reopen the app after you make the change.',
              ),
              scheduledTrip.trip.steps.last,
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

Step _stepById(ScheduleDefinition definition, int stepId) {
  return definition.trips
      .expand((scheduledTrip) => scheduledTrip.trip.steps)
      .singleWhere((step) => step.id == stepId);
}

ScheduleDefinition _replaceStep({
  required ScheduleDefinition definition,
  required TripDefinitionId tripId,
  required Step replacement,
}) {
  return ScheduleDefinition(
    id: definition.id,
    name: definition.name,
    trips: definition.trips
        .map((scheduledTrip) {
          if (scheduledTrip.trip.id != tripId) {
            return scheduledTrip;
          }
          return ScheduleTripDefinition(
            occurrenceId: scheduledTrip.occurrenceId,
            position: scheduledTrip.position,
            trip: TripDefinition(
              id: scheduledTrip.trip.id,
              name: scheduledTrip.trip.name,
              steps: scheduledTrip.trip.steps
                  .map((step) => step.id == replacement.id ? replacement : step)
                  .toList(growable: false),
            ),
          );
        })
        .toList(growable: false),
  );
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
