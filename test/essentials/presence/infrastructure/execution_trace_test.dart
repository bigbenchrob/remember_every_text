import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/execution_trace_event.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/schedule_definition.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/step.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/test_agent_id.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip_definition_id.dart';
import 'package:remember_this_text/essentials/presence/domain/services/presence_scheduler.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent_resolver.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/data_sources/local/presence_database.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/repositories/drift_presence_schedule_repository.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

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

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'presence_execution_trace_',
    );
    databasePath = '${tempDirectory.path}/presence.db';
  });

  tearDown(() async {
    await closeDatabase();
    await tempDirectory.delete(recursive: true);
  });

  test(
    'migrates v3 state and mechanically enforces append-only rows',
    () async {
      _createVersionThreeDatabase(databasePath);
      final opened = await openDatabase();
      final repository = DriftPresenceScheduleRepository(database: opened);

      final version = await opened
          .customSelect('PRAGMA user_version')
          .getSingle();
      final run = await repository.loadRun(1);
      expect(version.read<int>('user_version'), 8);
      expect(run.currentTripOccurrenceId, 1010);
      expect(run.currentTripDefinition?.id, const TripDefinitionId(10));
      final traceColumns = await opened
          .customSelect('PRAGMA table_info(execution_trace_events)')
          .get();
      expect(
        traceColumns.map((row) => row.read<String>('name')),
        isNot(contains('boolean_result')),
      );

      await repository.recordTripStarted(
        scheduleRunId: 1,
        expectedCurrentTripOccurrenceId: 1010,
      );
      final event = await opened
          .select(opened.executionTraceEvents)
          .getSingle();
      await expectLater(
        (opened.update(
          opened.executionTraceEvents,
        )..where((table) => table.id.equals(event.id))).write(
          const ExecutionTraceEventsCompanion(sequence: Value<int>(99)),
        ),
        throwsA(isA<sqlite3.SqliteException>()),
      );
      await expectLater(
        (opened.delete(
          opened.executionTraceEvents,
        )..where((table) => table.id.equals(event.id))).go(),
        throwsA(isA<sqlite3.SqliteException>()),
      );
      await expectLater(
        opened
            .into(opened.executionTraceEvents)
            .insert(
              ExecutionTraceEventsCompanion.insert(
                scheduleRunId: 1,
                sequence: 1,
                eventType: scheduleRunStartedTraceEvent,
                occurredAtUtcUs: 1,
              ),
            ),
        throwsA(isA<sqlite3.SqliteException>()),
      );
    },
  );

  test('linear execution records the universal lifecycle in order', () async {
    final opened = await openDatabase();
    final repository = DriftPresenceScheduleRepository(database: opened);
    await repository.insertDefinition(_linearDefinition());
    final scheduler = PresenceScheduler(
      repository: repository,
      scheduleDefinitionId: 1,
    );
    await scheduler.initialize();
    while (!scheduler.isComplete) {
      await scheduler.completeCurrentStep();
    }

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
        ExecutionTraceEventType.stepStarted,
        ExecutionTraceEventType.stepCompleted,
        ExecutionTraceEventType.tripCompleted,
        ExecutionTraceEventType.routeDecision,
        ExecutionTraceEventType.tripStarted,
        ExecutionTraceEventType.stepStarted,
        ExecutionTraceEventType.stepCompleted,
        ExecutionTraceEventType.tripCompleted,
        ExecutionTraceEventType.routeDecision,
        ExecutionTraceEventType.scheduleRunCompleted,
      ]),
    );
    expect(
      trace.map((event) => event.sequence),
      orderedEquals(List<int>.generate(trace.length, (index) => index + 1)),
    );
    final routes = trace
        .where((event) => event.type == ExecutionTraceEventType.routeDecision)
        .toList(growable: false);
    expect(routes[0].routingResultTripDefinitionId, isNull);
    expect(routes[0].selectedDestinationTripOccurrenceId, 1020);
    expect(routes[2].selectedDestinationTripOccurrenceId, isNull);
  });

  test(
    'fixed routing records both the canonical result and occurrence',
    () async {
      final opened = await openDatabase();
      final repository = DriftPresenceScheduleRepository(database: opened);
      await repository.insertDefinition(_fixedDefinition());
      final scheduler = PresenceScheduler(
        repository: repository,
        scheduleDefinitionId: 2,
      );
      await scheduler.initialize();
      await scheduler.completeCurrentStep();
      await scheduler.completeCurrentStep();

      final trace = await repository.loadExecutionTrace(scheduler.run!.id);
      final route = trace
          .where((event) => event.type == ExecutionTraceEventType.routeDecision)
          .last;
      expect(route.tripOccurrenceId, 2020);
      expect(route.routingResultTripDefinitionId, const TripDefinitionId(40));
      expect(route.selectedDestinationTripOccurrenceId, 2040);
    },
  );

  for (final scenario in <({String name, List<bool> answers, List<int> path})>[
    (name: 'FDA present', answers: <bool>[true], path: <int>[1, 2, 3, 4, 8]),
    (
      name: 'FDA absent then granted',
      answers: <bool>[false, true],
      path: <int>[1, 2, 5, 7, 8],
    ),
    (
      name: 'FDA repeated failure then escape',
      answers: <bool>[false, false, false, true],
      path: <int>[1, 2, 5, 7, 2, 5, 7, 8],
    ),
  ]) {
    test('${scenario.name} records only ordinary universal events', () async {
      final opened = await openDatabase();
      final authority = _AnswerSequenceFdaAuthority(scenario.answers);
      final repository = DriftPresenceScheduleRepository(
        database: opened,
        testAgentResolver: ImmutableTestAgentResolver(<TestAgentBinding>[
          TestAgentBinding(
            id: TestAgentId('test.source-readable'),
            agent: authority,
          ),
        ]),
      );
      await repository.insertDefinition(_fdaDefinition(authority));
      final scheduler = PresenceScheduler(
        repository: repository,
        scheduleDefinitionId: 3,
      );
      await scheduler.initialize();
      while (!scheduler.isComplete) {
        await scheduler.completeCurrentStep();
      }

      final trace = await repository.loadExecutionTrace(scheduler.run!.id);
      expect(_tripPath(trace), scenario.path);
      final storedTypes = await opened
          .customSelect(
            'SELECT DISTINCT event_type FROM execution_trace_events',
          )
          .get();
      expect(
        storedTypes.map((row) => row.read<String>('event_type')),
        isNot(contains(anyOf('boolean_result', 'loop', 'retry'))),
      );
      expect(authority.remainingAnswers, 0);
    });
  }

  test('restart records a repeated Trip and begins again at Step 1', () async {
    var opened = await openDatabase();
    var repository = DriftPresenceScheduleRepository(database: opened);
    await repository.insertDefinition(_restartDefinition());
    var scheduler = PresenceScheduler(
      repository: repository,
      scheduleDefinitionId: 4,
    );
    await scheduler.initialize();
    await scheduler.completeCurrentStep();
    final runId = scheduler.run!.id;
    expect(scheduler.currentStep?.id, 4102);

    await closeDatabase();
    opened = await openDatabase();
    repository = DriftPresenceScheduleRepository(database: opened);
    scheduler = PresenceScheduler(
      repository: repository,
      scheduleDefinitionId: 4,
    );
    await scheduler.initialize();
    expect(scheduler.currentStep?.id, 4101);
    await scheduler.completeCurrentStep();

    final trace = await repository.loadExecutionTrace(runId);
    expect(
      trace
          .where((event) => event.type == ExecutionTraceEventType.tripStarted)
          .map((event) => event.tripOccurrenceId),
      orderedEquals(<int>[4010, 4010]),
    );
    final firstStepOccurrence = trace
        .firstWhere(
          (event) => event.type == ExecutionTraceEventType.stepStarted,
        )
        .stepOccurrenceId;
    expect(
      trace
          .where((event) => event.type == ExecutionTraceEventType.stepStarted)
          .map((event) => event.stepOccurrenceId),
      orderedEquals(<int?>[firstStepOccurrence, firstStepOccurrence]),
    );
  });

  test(
    'execution remains authoritative when earlier trace history is absent',
    () async {
      final opened = await openDatabase();
      final repository = DriftPresenceScheduleRepository(database: opened);
      await repository.insertDefinition(_linearDefinition());
      final scheduler = PresenceScheduler(
        repository: repository,
        scheduleDefinitionId: 1,
      );
      await scheduler.initialize();

      await opened.customStatement(
        'DROP TRIGGER execution_trace_events_reject_delete',
      );
      await opened.delete(opened.executionTraceEvents).go();
      await scheduler.completeCurrentStep();

      expect(scheduler.currentTrip?.definition.id, const TripDefinitionId(20));
      expect(scheduler.run?.currentTripOccurrenceId, 1020);
    },
  );
}

final class _AnswerSequenceFdaAuthority implements TestAgent {
  _AnswerSequenceFdaAuthority(List<bool> answers)
    : _answers = List<bool>.of(answers);

  final List<bool> _answers;

  int get remainingAnswers => _answers.length;

  @override
  Future<bool> evaluate() async {
    if (_answers.isEmpty) {
      throw StateError('No FDA answer remains.');
    }
    return _answers.removeAt(0);
  }
}

List<int> _tripPath(List<ExecutionTraceEvent> trace) {
  const tripByOccurrence = <int, int>{
    3001: 1,
    3002: 2,
    3003: 3,
    3004: 4,
    3005: 5,
    3007: 7,
    3008: 8,
  };
  return trace
      .where((event) => event.type == ExecutionTraceEventType.tripStarted)
      .map((event) => tripByOccurrence[event.tripOccurrenceId]!)
      .toList(growable: false);
}

ScheduleDefinition _linearDefinition() {
  return ScheduleDefinition(
    id: 1,
    name: 'trace_linear',
    trips: <ScheduleTripDefinition>[
      _tellTrip(10, 1010, 0, stepId: 1101),
      _tellTrip(20, 1020, 1, stepId: 1201),
      _tellTrip(30, 1030, 2, stepId: 1301),
    ],
  );
}

ScheduleDefinition _fixedDefinition() {
  return ScheduleDefinition(
    id: 2,
    name: 'trace_fixed',
    trips: <ScheduleTripDefinition>[
      _tellTrip(10, 2010, 0, stepId: 2101),
      ScheduleTripDefinition(
        occurrenceId: 2020,
        position: 1,
        trip: TripDefinition(
          id: const TripDefinitionId(20),
          name: 'Trip 20',
          steps: const <Step>[
            FixedDestinationStep(
              id: 2201,
              name: 'route_to_40',
              destinationTripDefinitionId: TripDefinitionId(40),
            ),
          ],
        ),
      ),
      _tellTrip(30, 2030, 2, stepId: 2301),
      _tellTrip(40, 2040, 3, stepId: 2401),
    ],
  );
}

ScheduleDefinition _restartDefinition() {
  return ScheduleDefinition(
    id: 4,
    name: 'trace_restart',
    trips: <ScheduleTripDefinition>[
      ScheduleTripDefinition(
        occurrenceId: 4010,
        position: 0,
        trip: TripDefinition(
          id: const TripDefinitionId(10),
          name: 'Trip 10',
          steps: const <Step>[
            TellStep(id: 4101, name: 'first', text: 'First'),
            TellStep(id: 4102, name: 'second', text: 'Second'),
          ],
        ),
      ),
    ],
  );
}

ScheduleDefinition _fdaDefinition(TestAgent authority) {
  return ScheduleDefinition(
    id: 3,
    name: 'trace_fda',
    trips: <ScheduleTripDefinition>[
      _tellTrip(1, 3001, 0, stepId: 3101),
      _fdaTrip(2, 3002, 1, authority, absent: const TripDefinitionId(5)),
      _tellTrip(3, 3003, 2, stepId: 3301),
      ScheduleTripDefinition(
        occurrenceId: 3004,
        position: 3,
        trip: TripDefinition(
          id: const TripDefinitionId(4),
          name: 'Trip 4',
          steps: const <Step>[
            FixedDestinationStep(
              id: 3401,
              name: 'route_to_8',
              destinationTripDefinitionId: TripDefinitionId(8),
            ),
          ],
        ),
      ),
      _tellTrip(5, 3005, 4, stepId: 3501),
      _fdaTrip(7, 3007, 5, authority, absent: const TripDefinitionId(2)),
      _tellTrip(8, 3008, 6, stepId: 3801),
    ],
  );
}

ScheduleTripDefinition _tellTrip(
  int tripId,
  int occurrenceId,
  int position, {
  required int stepId,
}) {
  return ScheduleTripDefinition(
    occurrenceId: occurrenceId,
    position: position,
    trip: TripDefinition(
      id: TripDefinitionId(tripId),
      name: 'Trip $tripId',
      steps: <Step>[
        TellStep(id: stepId, name: 'tell_$stepId', text: 'Trip $tripId'),
      ],
    ),
  );
}

ScheduleTripDefinition _fdaTrip(
  int tripId,
  int occurrenceId,
  int position,
  TestAgent authority, {
  TripDefinitionId? absent,
}) {
  return ScheduleTripDefinition(
    occurrenceId: occurrenceId,
    position: position,
    trip: TripDefinition(
      id: TripDefinitionId(tripId),
      name: 'Trip $tripId',
      steps: <Step>[
        TestStep(
          id: 3000 + (tripId * 100) + 1,
          name: 'test_$tripId',
          testAgentId: TestAgentId('test.source-readable'),
          testAgent: authority,
          trueDestinationTripDefinitionId: null,
          falseDestinationTripDefinitionId: absent,
        ),
      ],
    ),
  );
}

void _createVersionThreeDatabase(String path) {
  final database = sqlite3.sqlite3.open(path);
  try {
    database.execute('PRAGMA foreign_keys = ON');
    database.execute('''
      CREATE TABLE schedule_definitions (
        id INTEGER NOT NULL PRIMARY KEY,
        name TEXT NOT NULL UNIQUE
      );
      CREATE TABLE trip_definitions (
        id INTEGER NOT NULL PRIMARY KEY,
        name TEXT NOT NULL UNIQUE
      );
      CREATE TABLE step_definitions (
        id INTEGER NOT NULL PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL CHECK (
          type IN ('tell', 'fixed_destination', 'fda_test')
        )
      );
      CREATE TABLE schedule_trip_occurrences (
        id INTEGER NOT NULL PRIMARY KEY,
        schedule_definition_id INTEGER NOT NULL
          REFERENCES schedule_definitions (id),
        trip_definition_id INTEGER NOT NULL REFERENCES trip_definitions (id),
        position INTEGER NOT NULL CHECK (position >= 0),
        UNIQUE (schedule_definition_id, position),
        UNIQUE (schedule_definition_id, trip_definition_id),
        UNIQUE (schedule_definition_id, id)
      );
      CREATE TABLE trip_step_occurrences (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        trip_definition_id INTEGER NOT NULL REFERENCES trip_definitions (id),
        step_definition_id INTEGER NOT NULL REFERENCES step_definitions (id),
        position INTEGER NOT NULL CHECK (position >= 0),
        UNIQUE (trip_definition_id, position)
      );
      CREATE TABLE tell_step_definitions (
        step_definition_id INTEGER NOT NULL PRIMARY KEY
          REFERENCES step_definitions (id),
        text TEXT NOT NULL
      );
      CREATE TABLE fixed_destination_step_definitions (
        step_definition_id INTEGER NOT NULL PRIMARY KEY
          REFERENCES step_definitions (id),
        destination_trip_definition_id INTEGER NOT NULL
          REFERENCES trip_definitions (id)
      );
      CREATE TABLE fda_test_step_definitions (
        step_definition_id INTEGER NOT NULL PRIMARY KEY
          REFERENCES step_definitions (id),
        present_destination_trip_definition_id INTEGER
          REFERENCES trip_definitions (id),
        absent_destination_trip_definition_id INTEGER
          REFERENCES trip_definitions (id)
      );
      CREATE TABLE schedule_runs (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        schedule_definition_id INTEGER NOT NULL
          REFERENCES schedule_definitions (id),
        current_trip_occurrence_id INTEGER,
        FOREIGN KEY (schedule_definition_id, current_trip_occurrence_id)
          REFERENCES schedule_trip_occurrences (schedule_definition_id, id)
          ON DELETE RESTRICT
      );
      INSERT INTO schedule_definitions (id, name) VALUES (1, 'existing_v3');
      INSERT INTO trip_definitions (id, name) VALUES (10, 'Trip 10');
      INSERT INTO step_definitions (id, name, type)
        VALUES (1001, 'tell', 'tell');
      INSERT INTO tell_step_definitions (step_definition_id, text)
        VALUES (1001, 'Existing Tell');
      INSERT INTO trip_step_occurrences
        (id, trip_definition_id, step_definition_id, position)
        VALUES (10001, 10, 1001, 0);
      INSERT INTO schedule_trip_occurrences
        (id, schedule_definition_id, trip_definition_id, position)
        VALUES (1010, 1, 10, 0);
      INSERT INTO schedule_runs
        (id, schedule_definition_id, current_trip_occurrence_id)
        VALUES (1, 1, 1010);
      PRAGMA user_version = 3;
    ''');
  } finally {
    database.dispose();
  }
}
