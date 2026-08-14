import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/choice_option.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/choice_value.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/execution_trace_event.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/schedule_definition.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/step.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip_definition_id.dart';
import 'package:remember_this_text/essentials/presence/domain/services/presence_scheduler.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/data_sources/local/presence_database.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/repositories/drift_presence_schedule_repository.dart';

void main() {
  late Directory tempDirectory;
  late String databasePath;
  PresenceDatabase? database;

  Future<PresenceDatabase> openDatabase() async {
    final opened = PresenceDatabase(NativeDatabase(File(databasePath)));
    await opened.customSelect('SELECT 1').get();
    database = opened;
    return opened;
  }

  Future<void> closeDatabase() async {
    final opened = database;
    database = null;
    await opened?.close();
  }

  Future<
    ({DriftPresenceScheduleRepository repository, PresenceScheduler scheduler})
  >
  start(ScheduleDefinition definition) async {
    final opened = await openDatabase();
    final repository = DriftPresenceScheduleRepository(database: opened);
    if (!await repository.definitionExists(definition.id)) {
      await repository.insertDefinition(definition);
    }
    final scheduler = PresenceScheduler(
      repository: repository,
      scheduleDefinitionId: definition.id,
    );
    await scheduler.initialize();
    return (repository: repository, scheduler: scheduler);
  }

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'presence_choice_runtime_',
    );
    databasePath = '${tempDirectory.path}/presence.db';
  });

  tearDown(() async {
    await closeDatabase();
    await tempDirectory.delete(recursive: true);
  });

  test('valid selection checkpoints its configured Trip occurrence', () async {
    final (:scheduler, :repository) = await start(_colorSchedule());
    final select = scheduler.issueCurrentChoiceSelection();

    await select(ChoiceValue('pink'));

    expect(scheduler.currentTrip?.definition.id, const TripDefinitionId(15));
    expect(scheduler.run?.currentTripOccurrenceId, 103);
    final stored = await repository.loadRun(scheduler.run!.id);
    expect(stored.currentTripOccurrenceId, 103);
  });

  test('unknown value fails without changing checkpoint or trace', () async {
    final (:scheduler, :repository) = await start(_colorSchedule());
    final occurrenceBefore = scheduler.run!.currentTripOccurrenceId;
    final traceBefore = await repository.loadExecutionTrace(scheduler.run!.id);

    await expectLater(
      scheduler.issueCurrentChoiceSelection()(ChoiceValue('orange')),
      throwsA(isA<ArgumentError>()),
    );

    expect(scheduler.run?.currentTripOccurrenceId, occurrenceBefore);
    expect(scheduler.currentStep, isA<ChoiceStep>());
    expect(
      _traceShape(await repository.loadExecutionTrace(scheduler.run!.id)),
      _traceShape(traceBefore),
    );
  });

  test('stale interaction cannot act after its ChoiceStep advances', () async {
    final (:scheduler, repository: _) = await start(_colorSchedule());
    final staleSelection = scheduler.issueCurrentChoiceSelection();
    await staleSelection(ChoiceValue('pink'));

    await expectLater(
      staleSelection(ChoiceValue('blue')),
      throwsA(isA<StateError>()),
    );

    expect(scheduler.currentTrip?.definition.id, const TripDefinitionId(15));
    expect(scheduler.run?.currentTripOccurrenceId, 103);
  });

  test(
    'old callback cannot select the same value on a later ChoiceStep',
    () async {
      final (:scheduler, repository: _) = await start(_repeatedValueSchedule());
      final firstSelection = scheduler.issueCurrentChoiceSelection();
      await firstSelection(ChoiceValue('continue'));

      expect(scheduler.currentStep, isA<ChoiceStep>());
      expect(scheduler.run?.currentTripOccurrenceId, 202);
      await expectLater(
        firstSelection(ChoiceValue('continue')),
        throwsA(isA<StateError>()),
      );

      expect(scheduler.run?.currentTripOccurrenceId, 202);
    },
  );

  test('rapid repeated selection advances exactly once', () async {
    final (:scheduler, :repository) = await start(_colorSchedule());
    final select = scheduler.issueCurrentChoiceSelection();

    final outcomes = await Future.wait(<Future<String>>[
      select(
        ChoiceValue('pink'),
      ).then((_) => 'accepted').catchError((_) => 'rejected'),
      select(
        ChoiceValue('pink'),
      ).then((_) => 'accepted').catchError((_) => 'rejected'),
    ]);

    expect(outcomes.where((outcome) => outcome == 'accepted'), hasLength(1));
    expect(outcomes.where((outcome) => outcome == 'rejected'), hasLength(1));
    expect(scheduler.run?.currentTripOccurrenceId, 103);
    final trace = await repository.loadExecutionTrace(scheduler.run!.id);
    expect(
      trace.where(
        (event) => event.type == ExecutionTraceEventType.routeDecision,
      ),
      hasLength(1),
    );
  });

  for (final value in <String>['first', 'second']) {
    test('shared destination accepts $value independently', () async {
      final (:scheduler, repository: _) = await start(
        _sharedDestinationSchedule(),
      );

      await scheduler.issueCurrentChoiceSelection()(ChoiceValue(value));

      expect(scheduler.currentTrip?.definition.id, const TripDefinitionId(12));
      expect(scheduler.run?.currentTripOccurrenceId, 302);
    });
  }

  test('restart before selection returns to current Trip Step 1', () async {
    var result = await start(_restartSchedule());
    final runId = result.scheduler.run!.id;
    result.scheduler.issueCurrentChoiceSelection();
    await closeDatabase();

    result = await start(_restartSchedule());

    expect(result.scheduler.run?.id, runId);
    expect(result.scheduler.run?.currentTripOccurrenceId, 401);
    expect(result.scheduler.currentTrip?.currentStepIndex, 0);
    expect(result.scheduler.currentStep, isA<ChoiceStep>());
  });

  test('restart after selection begins at destination Trip Step 1', () async {
    var result = await start(_restartSchedule());
    final runId = result.scheduler.run!.id;
    await result.scheduler.issueCurrentChoiceSelection()(
      ChoiceValue('continue'),
    );
    await closeDatabase();

    result = await start(_restartSchedule());

    expect(result.scheduler.run?.id, runId);
    expect(result.scheduler.run?.currentTripOccurrenceId, 402);
    expect(result.scheduler.currentTrip?.currentStepIndex, 0);
    expect(result.scheduler.currentStep?.id, 4201);
  });

  test('selection uses the ordinary universal trace sequence', () async {
    final (:scheduler, :repository) = await start(_colorSchedule());

    await scheduler.issueCurrentChoiceSelection()(ChoiceValue('pink'));

    final trace = await repository.loadExecutionTrace(scheduler.run!.id);
    expect(
      trace.map((event) => event.type),
      orderedEquals(<ExecutionTraceEventType>[
        ExecutionTraceEventType.scheduleRunStarted,
        ExecutionTraceEventType.tripStarted,
        ExecutionTraceEventType.stepStarted,
        ExecutionTraceEventType.stepCompleted,
        ExecutionTraceEventType.tripCompleted,
        ExecutionTraceEventType.routeDecision,
        ExecutionTraceEventType.tripStarted,
      ]),
    );
    final route = trace.firstWhere(
      (event) => event.type == ExecutionTraceEventType.routeDecision,
    );
    expect(route.routingResultTripDefinitionId, const TripDefinitionId(15));
    expect(route.selectedDestinationTripOccurrenceId, 103);
  });

  test('autonomous completion fails closed at a ChoiceStep', () async {
    final (:scheduler, :repository) = await start(_colorSchedule());
    final traceBefore = await repository.loadExecutionTrace(scheduler.run!.id);

    await expectLater(
      scheduler.completeCurrentStep(),
      throwsA(isA<StateError>()),
    );

    expect(scheduler.run?.currentTripOccurrenceId, 101);
    expect(
      _traceShape(await repository.loadExecutionTrace(scheduler.run!.id)),
      _traceShape(traceBefore),
    );
  });

  test('Trip rejects a nonterminal ChoiceStep at runtime', () async {
    final trip = Trip(
      TripDefinition(
        id: const TripDefinitionId(90),
        name: 'invalid_runtime_trip',
        steps: <Step>[
          ChoiceStep(
            id: 9001,
            name: 'invalid_choice',
            options: <ChoiceOption>[
              _option('one', 'One', 91),
              _option('two', 'Two', 92),
            ],
          ),
          const TellStep(id: 9002, name: 'later', text: 'Later'),
        ],
      ),
    );

    await expectLater(
      trip.completeCurrentChoice(ChoiceValue('one')),
      throwsA(isA<StateError>()),
    );

    expect(trip.currentStepIndex, 0);
    expect(trip.isComplete, isFalse);
  });
}

ScheduleDefinition _colorSchedule() {
  return _schedule(
    id: 100,
    name: 'color_choice_schedule',
    choiceTripId: 10,
    choiceOccurrenceId: 101,
    choiceStepId: 1001,
    options: <ChoiceOption>[
      _option('blue', 'Blue', 12),
      _option('pink', 'Pink', 15),
      _option('purple', 'Purple', 19),
    ],
    destinations: const <({int id, int occurrenceId})>[
      (id: 12, occurrenceId: 102),
      (id: 15, occurrenceId: 103),
      (id: 19, occurrenceId: 104),
    ],
  );
}

ScheduleDefinition _sharedDestinationSchedule() {
  return _schedule(
    id: 300,
    name: 'shared_destination_schedule',
    choiceTripId: 30,
    choiceOccurrenceId: 301,
    choiceStepId: 3001,
    options: <ChoiceOption>[
      _option('first', 'First', 12),
      _option('second', 'Second', 12),
    ],
    destinations: const <({int id, int occurrenceId})>[
      (id: 12, occurrenceId: 302),
    ],
  );
}

ScheduleDefinition _restartSchedule() {
  return _schedule(
    id: 400,
    name: 'choice_restart_schedule',
    choiceTripId: 40,
    choiceOccurrenceId: 401,
    choiceStepId: 4001,
    options: <ChoiceOption>[
      _option('continue', 'Continue', 42),
      _option('finish', 'Finish', 42),
    ],
    destinations: const <({int id, int occurrenceId})>[
      (id: 42, occurrenceId: 402),
    ],
  );
}

ScheduleDefinition _repeatedValueSchedule() {
  return ScheduleDefinition(
    id: 200,
    name: 'repeated_value_schedule',
    trips: <ScheduleTripDefinition>[
      ScheduleTripDefinition(
        occurrenceId: 201,
        position: 0,
        trip: TripDefinition(
          id: const TripDefinitionId(20),
          name: 'first_choice_trip',
          steps: <Step>[
            ChoiceStep(
              id: 2001,
              name: 'first_choice',
              options: <ChoiceOption>[
                _option('continue', 'Continue', 22),
                _option('finish', 'Finish', 24),
              ],
            ),
          ],
        ),
      ),
      ScheduleTripDefinition(
        occurrenceId: 202,
        position: 1,
        trip: TripDefinition(
          id: const TripDefinitionId(22),
          name: 'second_choice_trip',
          steps: <Step>[
            ChoiceStep(
              id: 2201,
              name: 'second_choice',
              options: <ChoiceOption>[
                _option('continue', 'Continue', 24),
                _option('finish', 'Finish', 24),
              ],
            ),
          ],
        ),
      ),
      _destination(occurrenceId: 203, position: 2, id: 24),
    ],
  );
}

ScheduleDefinition _schedule({
  required int id,
  required String name,
  required int choiceTripId,
  required int choiceOccurrenceId,
  required int choiceStepId,
  required List<ChoiceOption> options,
  required List<({int id, int occurrenceId})> destinations,
}) {
  return ScheduleDefinition(
    id: id,
    name: name,
    trips: <ScheduleTripDefinition>[
      ScheduleTripDefinition(
        occurrenceId: choiceOccurrenceId,
        position: 0,
        trip: TripDefinition(
          id: TripDefinitionId(choiceTripId),
          name: '${name}_choice_trip',
          steps: <Step>[
            ChoiceStep(
              id: choiceStepId,
              name: '${name}_choice',
              options: options,
            ),
          ],
        ),
      ),
      for (var index = 0; index < destinations.length; index += 1)
        _destination(
          occurrenceId: destinations[index].occurrenceId,
          position: index + 1,
          id: destinations[index].id,
        ),
    ],
  );
}

ScheduleTripDefinition _destination({
  required int occurrenceId,
  required int position,
  required int id,
}) {
  return ScheduleTripDefinition(
    occurrenceId: occurrenceId,
    position: position,
    trip: TripDefinition(
      id: TripDefinitionId(id),
      name: 'destination_$id',
      steps: <Step>[
        TellStep(id: id * 100 + 1, name: 'tell_$id', text: 'Trip $id'),
      ],
    ),
  );
}

ChoiceOption _option(String value, String label, int destination) {
  return ChoiceOption(
    value: ChoiceValue(value),
    label: label,
    destinationTripDefinitionId: TripDefinitionId(destination),
  );
}

List<
  ({
    int id,
    int sequence,
    ExecutionTraceEventType type,
    int? tripOccurrenceId,
    int? stepOccurrenceId,
  })
>
_traceShape(List<ExecutionTraceEvent> trace) {
  return trace
      .map(
        (event) => (
          id: event.id,
          sequence: event.sequence,
          type: event.type,
          tripOccurrenceId: event.tripOccurrenceId,
          stepOccurrenceId: event.stepOccurrenceId,
        ),
      )
      .toList(growable: false);
}
