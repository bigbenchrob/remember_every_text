import 'package:drift/drift.dart'
    show OrderClauseGenerator, OrderingTerm, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_test_agent_bindings.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_test_agent_ids.dart';
import 'package:remember_this_text/essentials/onboarding/application/required_sources_readiness_schedule.dart';
import 'package:remember_this_text/essentials/presence/application/presence_step_presentation.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/choice_value.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/execution_trace_event.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/step.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip_definition_id.dart';
import 'package:remember_this_text/essentials/presence/domain/services/fda_settings_opening_authority.dart';
import 'package:remember_this_text/essentials/presence/domain/services/presence_scheduler.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent_resolver.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/data_sources/local/presence_database.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/repositories/drift_presence_schedule_repository.dart';
import 'package:remember_this_text/features/presence_iteration_simple/infrastructure/development/schedule_topology_projector.dart';

void main() {
  late PresenceDatabase database;
  late _MutableTestAgent messagesAgent;
  late _MutableTestAgent messagesAccessDeniedAgent;
  late _MutableTestAgent contactsAgent;
  late _MutableTestAgent historyAgent;
  late _RecordingSettingsAuthority settingsAuthority;
  late DriftPresenceScheduleRepository repository;

  setUp(() async {
    database = PresenceDatabase(NativeDatabase.memory());
    messagesAgent = _MutableTestAgent(result: true);
    messagesAccessDeniedAgent = _MutableTestAgent(result: false);
    contactsAgent = _MutableTestAgent(result: true);
    historyAgent = _MutableTestAgent(result: true);
    settingsAuthority = _RecordingSettingsAuthority();
    final testAgentResolver = ImmutableTestAgentResolver(
      buildOnboardingTestAgentBindings(
        messagesSourceReadinessTestAgent: messagesAgent,
        messagesSourceAccessDeniedTestAgent: messagesAccessDeniedAgent,
        contactsSourceReadinessTestAgent: contactsAgent,
        messagesSourceHistorySufficiencyTestAgent: historyAgent,
      ),
    );
    repository = DriftPresenceScheduleRepository(
      database: database,
      testAgentResolver: testAgentResolver,
      fdaSettingsOpeningAuthority: settingsAuthority,
    );
    await repository.insertDefinition(
      buildRequiredSourcesReadinessDefinition(
        testAgentResolver: testAgentResolver,
        fdaSettingsOpeningAuthority: settingsAuthority,
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('persists and reconstructs the Contacts generic TestStep', () async {
    final stored = await (database.select(
      database.testStepDefinitions,
    )..where((table) => table.stepDefinitionId.equals(6501))).getSingle();
    final definition = await repository.loadDefinition(
      requiredSourcesReadinessScheduleId,
    );
    final step = definition.trips[4].trip.steps.single;

    expect(stored.stepDefinitionId, 6501);
    expect(stored.testAgentId, contactsSourceReadableTestAgentId.value);
    expect(stored.trueDestinationTripDefinitionId, 308);
    expect(stored.falseDestinationTripDefinitionId, isNull);
    expect(step, isA<TestStep>());
    expect(
      await step.complete(),
      determineMessagesSourceHistorySufficiencyTripId,
    );
    expect(contactsAgent.invocationCount, 1);
  });

  test(
    'persists the real history TestStep and ordered Choice options',
    () async {
      final definition = await repository.loadDefinition(
        requiredSourcesReadinessScheduleId,
      );
      final historyStep = definition.trips[6].trip.steps.single;
      final choiceStep = definition.trips[7].trip.steps.last;
      final storedOptions =
          await (database.select(database.choiceStepOptions)
                ..where((table) => table.stepDefinitionId.equals(6903))
                ..orderBy(<OrderClauseGenerator<ChoiceStepOptions>>[
                  (table) => OrderingTerm.asc(table.position),
                ]))
              .get();

      expect(
        historyStep,
        isA<TestStep>()
            .having(
              (step) => step.testAgentId,
              'Agent ID',
              messagesSourceHistorySufficientTestAgentId,
            )
            .having(
              (step) => step.trueDestinationTripDefinitionId,
              'true destination',
              confirmRequiredSourcesReadableTripId,
            )
            .having(
              (step) => step.falseDestinationTripDefinitionId,
              'false destination',
              guideSparseMessagesSourceHistoryTripId,
            ),
      );
      expect(choiceStep, isA<ChoiceStep>());
      expect(
        storedOptions
            .map(
              (option) => (
                option.value,
                option.label,
                option.destinationTripDefinitionId,
              ),
            )
            .toList(growable: false),
        <(String, String, int)>[
          ('recheck', 'Re-check', 308),
          ('import_anyway', 'Import Anyway', 307),
        ],
      );
    },
  );

  test(
    'real Onboarding Choice uses generic destination-free projection',
    () async {
      final definition = await repository.loadDefinition(
        requiredSourcesReadinessScheduleId,
      );
      final choiceStep = definition.trips[7].trip.steps.last;
      ChoiceValue? submittedValue;

      final presentation = PresenceStepPresentationProjector.project(
        step: choiceStep,
        complete: () async {},
        issueChoiceSelection: () => (value) async {
          submittedValue = value;
        },
      );

      expect(
        presentation,
        isA<ChoiceStepPresentation>().having(
          (choice) => choice.items
              .map((item) => (item.value.value, item.label))
              .toList(growable: false),
          'destination-free items',
          <(String, String)>[
            ('recheck', 'Re-check'),
            ('import_anyway', 'Import Anyway'),
          ],
        ),
      );
      await (presentation as ChoiceStepPresentation).select(
        ChoiceValue('recheck'),
      );
      expect(submittedValue, ChoiceValue('recheck'));
    },
  );

  test('Schedule 6 coexists with legacy Schedule 5 definition names', () async {
    await database.close();
    database = PresenceDatabase(NativeDatabase.memory());
    final testAgentResolver = ImmutableTestAgentResolver(
      buildOnboardingTestAgentBindings(
        messagesSourceReadinessTestAgent: messagesAgent,
        messagesSourceAccessDeniedTestAgent: messagesAccessDeniedAgent,
        contactsSourceReadinessTestAgent: contactsAgent,
        messagesSourceHistorySufficiencyTestAgent: historyAgent,
      ),
    );
    final secondRepository = DriftPresenceScheduleRepository(
      database: database,
      testAgentResolver: testAgentResolver,
      fdaSettingsOpeningAuthority: settingsAuthority,
    );
    await _seedLegacyDefinitionNames(database);

    await secondRepository.insertDefinition(
      buildRequiredSourcesReadinessDefinition(
        testAgentResolver: testAgentResolver,
        fdaSettingsOpeningAuthority: settingsAuthority,
      ),
    );

    expect(
      await secondRepository.definitionExists(
        requiredSourcesReadinessScheduleId,
      ),
      isTrue,
    );
  });

  test('available Messages and Contacts reach combined confirmation', () async {
    final scheduler = await _startScheduler(repository);

    await _completeIntroduction(scheduler);
    expect(_tripId(scheduler), determineInitialMessagesSourceReadinessTripId);
    await scheduler.completeCurrentStep();
    expect(_tripId(scheduler), determineContactsSourceReadinessTripId);
    await scheduler.completeCurrentStep();
    expect(_tripId(scheduler), determineMessagesSourceHistorySufficiencyTripId);
    await scheduler.completeCurrentStep();
    expect(_tripId(scheduler), confirmRequiredSourcesReadableTripId);
    expect(
      scheduler.currentStep,
      isA<TellStep>().having(
        (step) => step.text,
        'combined source confirmation',
        'MessageLens can read the local Messages and Contacts information it '
            'needs.',
      ),
    );
    await scheduler.completeCurrentStep();

    expect(scheduler.isComplete, isTrue);
    expect(messagesAgent.invocationCount, 1);
    expect(contactsAgent.invocationCount, 1);
    expect(historyAgent.invocationCount, 1);
    expect(settingsAuthority.invocationCount, 0);
  });

  test('sparse history reaches persisted guidance and ChoiceStep', () async {
    historyAgent.result = false;
    final scheduler = await _startScheduler(repository);

    await _reachSparseHistoryChoice(scheduler);

    expect(
      scheduler.currentStep,
      isA<ChoiceStep>().having(
        (step) => step.options
            .map((option) => (option.value.value, option.label))
            .toList(growable: false),
        'durable values and labels',
        <(String, String)>[
          ('recheck', 'Re-check'),
          ('import_anyway', 'Import Anyway'),
        ],
      ),
    );
    expect(historyAgent.invocationCount, 1);
  });

  test('Re-check evaluates a fresh history fact and can escape', () async {
    historyAgent.result = false;
    final scheduler = await _startScheduler(repository);
    await _reachSparseHistoryChoice(scheduler);

    await scheduler.issueCurrentChoiceSelection()(ChoiceValue('recheck'));
    expect(_tripId(scheduler), determineMessagesSourceHistorySufficiencyTripId);
    expect(historyAgent.invocationCount, 1);

    historyAgent.result = true;
    await scheduler.completeCurrentStep();

    expect(_tripId(scheduler), confirmRequiredSourcesReadableTripId);
    expect(historyAgent.invocationCount, 2);
  });

  test('repeated sparse facts repeat the ordinary configured loop', () async {
    historyAgent.result = false;
    final scheduler = await _startScheduler(repository);
    await _reachSparseHistoryChoice(scheduler);

    await scheduler.issueCurrentChoiceSelection()(ChoiceValue('recheck'));
    await scheduler.completeCurrentStep();

    expect(_tripId(scheduler), guideSparseMessagesSourceHistoryTripId);
    expect(scheduler.currentTrip?.currentStepIndex, 0);
    expect(historyAgent.invocationCount, 2);
  });

  test('Import Anyway checkpoints the canonical confirmation', () async {
    historyAgent.result = false;
    final scheduler = await _startScheduler(repository);
    await _reachSparseHistoryChoice(scheduler);

    await scheduler.issueCurrentChoiceSelection()(ChoiceValue('import_anyway'));

    expect(_tripId(scheduler), confirmRequiredSourcesReadableTripId);
    expect(historyAgent.invocationCount, 1);
  });

  test('restart inside sparse guidance returns to its first Step', () async {
    historyAgent.result = false;
    var scheduler = await _startScheduler(repository);
    await _reachHistoryTest(scheduler);
    await scheduler.completeCurrentStep();
    expect(_tripId(scheduler), guideSparseMessagesSourceHistoryTripId);
    await scheduler.completeCurrentStep();
    expect(scheduler.currentTrip?.currentStepIndex, 1);

    scheduler = await _startScheduler(repository);

    expect(_tripId(scheduler), guideSparseMessagesSourceHistoryTripId);
    expect(scheduler.currentTrip?.currentStepIndex, 0);
  });

  test('restart after Re-check resumes at the history test', () async {
    historyAgent.result = false;
    var scheduler = await _startScheduler(repository);
    await _reachSparseHistoryChoice(scheduler);
    await scheduler.issueCurrentChoiceSelection()(ChoiceValue('recheck'));

    scheduler = await _startScheduler(repository);

    expect(_tripId(scheduler), determineMessagesSourceHistorySufficiencyTripId);
    expect(scheduler.currentTrip?.currentStepIndex, 0);
  });

  test('restart after Import Anyway resumes at confirmation', () async {
    historyAgent.result = false;
    var scheduler = await _startScheduler(repository);
    await _reachSparseHistoryChoice(scheduler);
    await scheduler.issueCurrentChoiceSelection()(ChoiceValue('import_anyway'));

    scheduler = await _startScheduler(repository);

    expect(_tripId(scheduler), confirmRequiredSourcesReadableTripId);
    expect(scheduler.currentTrip?.currentStepIndex, 0);
  });

  test('trace records Re-check and Import Anyway as ordinary routes', () async {
    historyAgent.result = false;
    final scheduler = await _startScheduler(repository);
    await _reachSparseHistoryChoice(scheduler);
    await scheduler.issueCurrentChoiceSelection()(ChoiceValue('recheck'));
    await scheduler.completeCurrentStep();
    await scheduler.completeCurrentStep();
    await scheduler.completeCurrentStep();
    await scheduler.issueCurrentChoiceSelection()(ChoiceValue('import_anyway'));

    final routes = (await repository.loadExecutionTrace(scheduler.run!.id))
        .where(
          (event) =>
              event.type == ExecutionTraceEventType.routeDecision &&
              (event.tripOccurrenceId == 6108 ||
                  event.tripOccurrenceId == 6109),
        )
        .map(
          (event) => (
            event.tripOccurrenceId,
            event.selectedDestinationTripOccurrenceId,
          ),
        )
        .toList(growable: false);

    expect(routes, <(int?, int?)>[
      (6108, 6109),
      (6109, 6108),
      (6108, 6109),
      (6109, 6107),
    ]);
  });

  test('unavailable Contacts guidance retries a fresh source read', () async {
    contactsAgent.result = false;
    final scheduler = await _startScheduler(repository);

    await _reachContactsTest(scheduler);
    await scheduler.completeCurrentStep();
    expect(_tripId(scheduler), guideUnavailableContactsSourceTripId);
    await scheduler.completeCurrentStep();
    await scheduler.completeCurrentStep();
    await scheduler.completeCurrentStep();
    expect(_tripId(scheduler), determineContactsSourceReadinessTripId);

    contactsAgent.result = true;
    await scheduler.completeCurrentStep();
    expect(_tripId(scheduler), determineMessagesSourceHistorySufficiencyTripId);
    await scheduler.completeCurrentStep();
    expect(_tripId(scheduler), confirmRequiredSourcesReadableTripId);
    expect(contactsAgent.invocationCount, 2);
    expect(settingsAuthority.invocationCount, 0);
  });

  test('remaining unavailable Contacts loops through ordinary Trips', () async {
    contactsAgent.result = false;
    final scheduler = await _startScheduler(repository);

    await _reachContactsTest(scheduler);
    for (var attempt = 0; attempt < 2; attempt += 1) {
      await scheduler.completeCurrentStep();
      expect(_tripId(scheduler), guideUnavailableContactsSourceTripId);
      await scheduler.completeCurrentStep();
      await scheduler.completeCurrentStep();
      await scheduler.completeCurrentStep();
      expect(_tripId(scheduler), determineContactsSourceReadinessTripId);
    }

    expect(contactsAgent.invocationCount, 2);
  });

  test('restart preserves Contacts guidance and test checkpoints', () async {
    contactsAgent.result = false;
    var scheduler = await _startScheduler(repository);

    await _reachContactsTest(scheduler);
    await scheduler.completeCurrentStep();
    expect(_tripId(scheduler), guideUnavailableContactsSourceTripId);

    scheduler = await _startScheduler(repository);
    expect(_tripId(scheduler), guideUnavailableContactsSourceTripId);
    expect(scheduler.currentTrip?.currentStepIndex, 0);
    await scheduler.completeCurrentStep();
    await scheduler.completeCurrentStep();
    await scheduler.completeCurrentStep();

    scheduler = await _startScheduler(repository);
    expect(_tripId(scheduler), determineContactsSourceReadinessTripId);
    expect(scheduler.currentTrip?.currentStepIndex, 0);
    await scheduler.completeCurrentStep();
    expect(contactsAgent.invocationCount, 2);
  });

  test('FDA remediation still checkpoints verification on restart', () async {
    messagesAgent.result = false;
    messagesAccessDeniedAgent.result = true;
    var scheduler = await _startScheduler(repository);

    await _completeIntroduction(scheduler);
    await scheduler.completeCurrentStep();
    expect(_tripId(scheduler), classifyMessagesSourceFailureTripId);
    await scheduler.completeCurrentStep();
    expect(_tripId(scheduler), guideUnreadableMessagesSourceTripId);
    await scheduler.completeCurrentStep();
    await scheduler.completeCurrentStep();
    await scheduler.completeCurrentStep();
    expect(_tripId(scheduler), verifyMessagesSourceReadinessTripId);

    scheduler = await _startScheduler(repository);
    expect(_tripId(scheduler), verifyMessagesSourceReadinessTripId);
    expect(scheduler.currentStep, isA<TellStep>());
    await scheduler.completeCurrentStep();
    messagesAgent.result = true;
    await scheduler.completeCurrentStep();
    expect(_tripId(scheduler), determineContactsSourceReadinessTripId);
    expect(settingsAuthority.invocationCount, 1);
  });

  test('Settings failure leaves the Step and checkpoint unchanged', () async {
    messagesAgent.result = false;
    messagesAccessDeniedAgent.result = true;
    settingsAuthority.fail = true;
    final scheduler = await _startScheduler(repository);

    await _completeIntroduction(scheduler);
    await scheduler.completeCurrentStep();
    await scheduler.completeCurrentStep();
    await scheduler.completeCurrentStep();
    await scheduler.completeCurrentStep();
    final occurrenceBefore = scheduler.run?.currentTripOccurrenceId;

    await expectLater(
      scheduler.completeCurrentStep(),
      throwsA(isA<StateError>()),
    );

    expect(_tripId(scheduler), guideUnreadableMessagesSourceTripId);
    expect(scheduler.currentTrip?.currentStepIndex, 2);
    expect(scheduler.run?.currentTripOccurrenceId, occurrenceBefore);
  });

  test('non-FDA source failure reaches source-unavailable guidance', () async {
    messagesAgent.result = false;
    messagesAccessDeniedAgent.result = false;
    final scheduler = await _startScheduler(repository);

    await _completeIntroduction(scheduler);
    await scheduler.completeCurrentStep();
    expect(_tripId(scheduler), classifyMessagesSourceFailureTripId);
    await scheduler.completeCurrentStep();

    expect(_tripId(scheduler), guideUnavailableMessagesSourceTripId);
    expect(
      scheduler.currentStep,
      isA<TellStep>()
          .having(
            (step) => step.text,
            'source-specific guidance',
            contains('can’t currently use your Messages data'),
          )
          .having(
            (step) => step.text,
            'no FDA remediation',
            isNot(contains('Full Disk Access')),
          ),
    );
    expect(settingsAuthority.invocationCount, 0);
  });

  test('source-unavailable retry evaluates a fresh readable fact', () async {
    messagesAgent.result = false;
    messagesAccessDeniedAgent.result = false;
    final scheduler = await _startScheduler(repository);

    await _completeIntroduction(scheduler);
    await scheduler.completeCurrentStep();
    await scheduler.completeCurrentStep();
    expect(_tripId(scheduler), guideUnavailableMessagesSourceTripId);
    await scheduler.completeCurrentStep();
    await scheduler.completeCurrentStep();
    expect(_tripId(scheduler), determineInitialMessagesSourceReadinessTripId);

    messagesAgent.result = true;
    await scheduler.completeCurrentStep();

    expect(_tripId(scheduler), determineContactsSourceReadinessTripId);
    expect(messagesAgent.invocationCount, 2);
    expect(messagesAccessDeniedAgent.invocationCount, 1);
  });

  test('topology contains the history branch and re-check loop', () async {
    final definition = await repository.loadDefinition(
      requiredSourcesReadinessScheduleId,
    );
    final topology = const ScheduleTopologyProjector().project(definition);

    expect(
      topology.trips.map((trip) => trip.tripDefinitionId),
      <TripDefinitionId>[
        introduceMessageLensTripId,
        determineInitialMessagesSourceReadinessTripId,
        guideUnreadableMessagesSourceTripId,
        verifyMessagesSourceReadinessTripId,
        determineContactsSourceReadinessTripId,
        guideUnavailableContactsSourceTripId,
        determineMessagesSourceHistorySufficiencyTripId,
        guideSparseMessagesSourceHistoryTripId,
        classifyMessagesSourceFailureTripId,
        guideUnavailableMessagesSourceTripId,
        confirmRequiredSourcesReadableTripId,
      ],
    );
    expect(
      definition.trips.map((trip) => trip.trip.name),
      isNot(contains('confirm_messages_source_readable')),
    );
    expect(topology.edges, hasLength(17));
    expect(topology.edges.where((edge) => edge.isBackward), hasLength(4));
    expect(messagesAgent.invocationCount, 0);
    expect(contactsAgent.invocationCount, 0);
    expect(historyAgent.invocationCount, 0);
    expect(settingsAuthority.invocationCount, 0);
  });

  test(
    'trace observes the combined route without supplying authority',
    () async {
      final scheduler = await _startScheduler(repository);

      await _completeIntroduction(scheduler);
      await scheduler.completeCurrentStep();
      await scheduler.completeCurrentStep();
      await scheduler.completeCurrentStep();
      final trace = await repository.loadExecutionTrace(scheduler.run!.id);
      final routes = trace
          .where((event) => event.type == ExecutionTraceEventType.routeDecision)
          .toList(growable: false);

      expect(routes, hasLength(4));
      expect(routes.last.tripOccurrenceId, 6108);
      expect(
        routes.last.routingResultTripDefinitionId,
        confirmRequiredSourcesReadableTripId,
      );
      expect(routes.last.selectedDestinationTripOccurrenceId, 6107);
      expect(messagesAgent.invocationCount, 1);
      expect(contactsAgent.invocationCount, 1);
      expect(historyAgent.invocationCount, 1);
    },
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
  expect(_tripId(scheduler), introduceMessageLensTripId);
  for (var index = 0; index < 2; index += 1) {
    await scheduler.completeCurrentStep();
  }
}

Future<void> _reachContactsTest(PresenceScheduler scheduler) async {
  await _completeIntroduction(scheduler);
  await scheduler.completeCurrentStep();
  expect(_tripId(scheduler), determineContactsSourceReadinessTripId);
}

Future<void> _reachHistoryTest(PresenceScheduler scheduler) async {
  await _reachContactsTest(scheduler);
  await scheduler.completeCurrentStep();
  expect(_tripId(scheduler), determineMessagesSourceHistorySufficiencyTripId);
}

Future<void> _reachSparseHistoryChoice(PresenceScheduler scheduler) async {
  await _reachHistoryTest(scheduler);
  await scheduler.completeCurrentStep();
  expect(_tripId(scheduler), guideSparseMessagesSourceHistoryTripId);
  await scheduler.completeCurrentStep();
  await scheduler.completeCurrentStep();
  expect(scheduler.currentStep, isA<ChoiceStep>());
}

TripDefinitionId _tripId(PresenceScheduler scheduler) {
  return scheduler.currentTrip!.definition.id;
}

Future<void> _seedLegacyDefinitionNames(PresenceDatabase database) async {
  await database.transaction(() async {
    for (final legacyTrip in <(int, String)>[
      (201, 'introduce_message_lens_source_readiness'),
      (202, 'determine_initial_messages_source_readiness'),
      (203, 'guide_unreadable_messages_source'),
      (204, 'verify_messages_source_readiness'),
    ]) {
      await database
          .into(database.tripDefinitions)
          .insert(
            TripDefinitionsCompanion.insert(
              id: Value<int>(legacyTrip.$1),
              name: legacyTrip.$2,
            ),
          );
    }
    for (final legacyStep in <(int, String)>[
      (5101, 'source_readiness_welcome'),
      (5102, 'explain_source_readiness_check'),
      (5201, 'test_initial_messages_source_readiness'),
      (5301, 'explain_required_messages_permission'),
      (5302, 'explain_full_disk_access_action'),
      (5303, 'open_full_disk_access_settings_for_source_readiness'),
      (5401, 'orient_source_readiness_verification'),
      (5402, 'verify_messages_source_readiness'),
    ]) {
      await database
          .into(database.stepDefinitions)
          .insert(
            StepDefinitionsCompanion.insert(
              id: Value<int>(legacyStep.$1),
              name: legacyStep.$2,
              stepType: tellStepType,
            ),
          );
    }
  });
}

final class _MutableTestAgent implements TestAgent {
  _MutableTestAgent({required this.result});

  bool result;
  int invocationCount = 0;

  @override
  Future<bool> evaluate() async {
    invocationCount += 1;
    return result;
  }
}

final class _RecordingSettingsAuthority implements FdaSettingsOpeningAuthority {
  bool fail = false;
  int invocationCount = 0;

  @override
  Future<void> openSettings() async {
    invocationCount += 1;
    if (fail) {
      throw StateError('System Settings could not be opened.');
    }
  }
}
