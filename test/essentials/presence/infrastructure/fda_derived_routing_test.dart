import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
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
  final testAgentId = TestAgentId('test.source-readable');
  late Directory tempDirectory;
  late String databasePath;
  late _FakeTestAgent authority;
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

  DriftPresenceScheduleRepository repository(PresenceDatabase opened) {
    return DriftPresenceScheduleRepository(
      database: opened,
      testAgentResolver: ImmutableTestAgentResolver(<TestAgentBinding>[
        TestAgentBinding(id: testAgentId, agent: authority),
      ]),
    );
  }

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'presence_fda_routing_',
    );
    databasePath = '${tempDirectory.path}/presence.db';
    authority = _FakeTestAgent(isPresent: true);
  });

  tearDown(() async {
    await closeDatabase();
    await tempDirectory.delete(recursive: true);
  });

  test('TestStep keeps the Boolean local and returns only its arm', () async {
    final step = TestStep(
      id: 1,
      name: 'test_source',
      testAgentId: testAgentId,
      testAgent: authority,
      trueDestinationTripDefinitionId: null,
      falseDestinationTripDefinitionId: const TripDefinitionId(5),
    );

    expect(await step.complete(), isNull);
    authority.isPresent = false;
    expect(await step.complete(), const TripDefinitionId(5));
    expect(authority.invocationCount, 2);
  });

  test('persists and reloads both canonical nullable routing arms', () async {
    var opened = await openDatabase();
    var store = repository(opened);
    await store.insertDefinition(_fdaSchedule(authority));

    final storedByStep = <int, TestStepDefinitionRow>{
      for (final row in await opened.select(opened.testStepDefinitions).get())
        row.stepDefinitionId: row,
    };
    expect(storedByStep, hasLength(2));
    expect(storedByStep[3201]?.trueDestinationTripDefinitionId, isNull);
    expect(storedByStep[3201]?.falseDestinationTripDefinitionId, 5);
    expect(storedByStep[3701]?.trueDestinationTripDefinitionId, isNull);
    expect(storedByStep[3701]?.falseDestinationTripDefinitionId, 2);

    await closeDatabase();
    opened = await openDatabase();
    store = repository(opened);
    final scheduler = PresenceScheduler(
      repository: store,
      scheduleDefinitionId: 3,
    );
    await scheduler.initialize();
    await scheduler.completeCurrentStep();

    expect(
      scheduler.currentStep,
      isA<TestStep>()
          .having(
            (step) => step.trueDestinationTripDefinitionId,
            'true arm',
            isNull,
          )
          .having(
            (step) => step.falseDestinationTripDefinitionId,
            'false arm',
            const TripDefinitionId(5),
          ),
    );
  });

  test(
    'present path uses default-next routing through Trips 1 2 3 4 8',
    () async {
      final opened = await openDatabase();
      final store = repository(opened);
      await store.insertDefinition(_fdaSchedule(authority));
      final scheduler = PresenceScheduler(
        repository: store,
        scheduleDefinitionId: 3,
      );
      await scheduler.initialize();

      expect(_tripId(scheduler), 1);
      await scheduler.completeCurrentStep();
      expect(_tripId(scheduler), 2);
      await scheduler.completeCurrentStep();
      expect(_tripId(scheduler), 3);
      await scheduler.completeCurrentStep();
      expect(_tripId(scheduler), 4);
      await scheduler.completeCurrentStep();
      expect(_tripId(scheduler), 8);
      await scheduler.completeCurrentStep();

      expect(scheduler.isComplete, isTrue);
    },
  );

  test('absent then granted path routes through Trips 1 2 5 7 8', () async {
    authority.isPresent = false;
    final opened = await openDatabase();
    final store = repository(opened);
    await store.insertDefinition(_fdaSchedule(authority));
    final scheduler = PresenceScheduler(
      repository: store,
      scheduleDefinitionId: 3,
    );
    await scheduler.initialize();

    await scheduler.completeCurrentStep();
    expect(_tripId(scheduler), 2);
    await scheduler.completeCurrentStep();
    expect(_tripId(scheduler), 5);
    await scheduler.completeCurrentStep();
    expect(_tripId(scheduler), 7);
    authority.isPresent = true;
    await scheduler.completeCurrentStep();
    expect(_tripId(scheduler), 8);
    await scheduler.completeCurrentStep();

    expect(scheduler.isComplete, isTrue);
  });

  test('remaining absent loops 2 5 7 2 without durable loop state', () async {
    authority.isPresent = false;
    var opened = await openDatabase();
    var store = repository(opened);
    await store.insertDefinition(_fdaSchedule(authority));
    var scheduler = PresenceScheduler(
      repository: store,
      scheduleDefinitionId: 3,
    );
    await scheduler.initialize();

    await scheduler.completeCurrentStep();
    await scheduler.completeCurrentStep();
    await scheduler.completeCurrentStep();
    expect(_tripId(scheduler), 7);

    await closeDatabase();
    opened = await openDatabase();
    store = repository(opened);
    scheduler = PresenceScheduler(repository: store, scheduleDefinitionId: 3);
    await scheduler.initialize();

    expect(_tripId(scheduler), 7);
    expect(scheduler.currentTrip?.currentStepIndex, 0);
    await scheduler.completeCurrentStep();
    expect(_tripId(scheduler), 2);
    await scheduler.completeCurrentStep();
    expect(_tripId(scheduler), 5);
  });

  test(
    'changing the fake after one full loop escapes through Trip 8',
    () async {
      authority.isPresent = false;
      final opened = await openDatabase();
      final store = repository(opened);
      await store.insertDefinition(_fdaSchedule(authority));
      final scheduler = PresenceScheduler(
        repository: store,
        scheduleDefinitionId: 3,
      );
      await scheduler.initialize();

      await scheduler.completeCurrentStep(); // 1 -> 2
      await scheduler.completeCurrentStep(); // 2 -> 5
      await scheduler.completeCurrentStep(); // 5 -> 7
      await scheduler.completeCurrentStep(); // 7 -> 2
      await scheduler.completeCurrentStep(); // 2 -> 5
      await scheduler.completeCurrentStep(); // 5 -> 7
      expect(_tripId(scheduler), 7);

      authority.isPresent = true;
      await scheduler.completeCurrentStep();

      expect(_tripId(scheduler), 8);
    },
  );

  test('both nullable arms use default-next routing', () async {
    final opened = await openDatabase();
    final store = repository(opened);
    await store.insertDefinition(_bothArmsDefaultSchedule(authority));
    final scheduler = PresenceScheduler(
      repository: store,
      scheduleDefinitionId: 4,
    );
    await scheduler.initialize();

    authority.isPresent = true;
    await scheduler.completeCurrentStep();
    expect(_tripId(scheduler), 2);
  });

  test(
    'rejects each configured destination absent from the Schedule',
    () async {
      final opened = await openDatabase();
      final store = repository(opened);

      for (final presentArm in <bool>[true, false]) {
        const missing = TripDefinitionId(99);
        final definition = _singleFdaSchedule(
          scheduleId: presentArm ? 10 : 11,
          authority: authority,
          present: presentArm ? missing : null,
          absent: presentArm ? null : missing,
        );
        await expectLater(
          store.insertDefinition(definition),
          throwsA(isA<ArgumentError>()),
        );
      }
    },
  );

  test('rejects a nonterminal TestStep', () async {
    final opened = await openDatabase();
    final store = repository(opened);
    final definition = ScheduleDefinition(
      id: 12,
      name: 'nonterminal_fda',
      trips: <ScheduleTripDefinition>[
        ScheduleTripDefinition(
          occurrenceId: 1201,
          position: 0,
          trip: TripDefinition(
            id: const TripDefinitionId(1),
            name: 'Trip 1',
            steps: <Step>[
              TestStep(
                id: 12001,
                name: 'nonterminal_test',
                testAgentId: testAgentId,
                testAgent: authority,
                trueDestinationTripDefinitionId: null,
                falseDestinationTripDefinitionId: null,
              ),
              const TellStep(id: 12002, name: 'later', text: 'Later'),
            ],
          ),
        ),
      ],
    );

    await expectLater(
      store.insertDefinition(definition),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('migrates a file-backed v2 run and adds FDA subtype storage', () async {
    _createVersionTwoDatabase(databasePath);

    final opened = await openDatabase();
    final version = await opened
        .customSelect('PRAGMA user_version')
        .getSingle();
    final table = await opened
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND "
          "name = 'fda_test_step_definitions'",
        )
        .getSingleOrNull();
    final run = await repository(opened).loadRun(1);

    expect(version.read<int>('user_version'), 9);
    expect(table?.read<String>('name'), 'fda_test_step_definitions');
    expect(run.currentTripDefinition?.id, const TripDefinitionId(20));
    expect(
      run.currentTripDefinition?.steps.single,
      isA<FixedDestinationStep>().having(
        (step) => step.destinationTripDefinitionId,
        'preserved destination',
        const TripDefinitionId(10),
      ),
    );
  });
}

final class _FakeTestAgent implements TestAgent {
  _FakeTestAgent({required this.isPresent});

  bool isPresent;
  int invocationCount = 0;

  @override
  Future<bool> evaluate() async {
    invocationCount += 1;
    return isPresent;
  }
}

int _tripId(PresenceScheduler scheduler) {
  return scheduler.currentTrip!.definition.id.value;
}

ScheduleDefinition _fdaSchedule(TestAgent authority) {
  return ScheduleDefinition(
    id: 3,
    name: 'fda_routing',
    trips: <ScheduleTripDefinition>[
      _tellTrip(1, 3001, 0),
      _fdaTrip(2, 3002, 1, authority, absent: const TripDefinitionId(5)),
      _tellTrip(3, 3003, 2),
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
      _tellTrip(5, 3005, 4),
      _fdaTrip(7, 3007, 5, authority, absent: const TripDefinitionId(2)),
      _tellTrip(8, 3008, 6),
    ],
  );
}

ScheduleTripDefinition _tellTrip(int tripId, int occurrenceId, int position) {
  return ScheduleTripDefinition(
    occurrenceId: occurrenceId,
    position: position,
    trip: TripDefinition(
      id: TripDefinitionId(tripId),
      name: 'Trip $tripId',
      steps: <Step>[
        TellStep(
          id: 3000 + (tripId * 100) + 1,
          name: 'trip_${tripId}_tell',
          text: 'Trip $tripId',
        ),
      ],
    ),
  );
}

ScheduleTripDefinition _fdaTrip(
  int tripId,
  int occurrenceId,
  int position,
  TestAgent authority, {
  TripDefinitionId? present,
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
          name: 'trip_${tripId}_test',
          testAgentId: TestAgentId('test.source-readable'),
          testAgent: authority,
          trueDestinationTripDefinitionId: present,
          falseDestinationTripDefinitionId: absent,
        ),
      ],
    ),
  );
}

ScheduleDefinition _bothArmsDefaultSchedule(TestAgent authority) {
  return ScheduleDefinition(
    id: 4,
    name: 'both_arms_default',
    trips: <ScheduleTripDefinition>[
      _fdaTrip(1, 4001, 0, authority),
      _tellTrip(2, 4002, 1),
    ],
  );
}

ScheduleDefinition _singleFdaSchedule({
  required int scheduleId,
  required TestAgent authority,
  required TripDefinitionId? present,
  required TripDefinitionId? absent,
}) {
  return ScheduleDefinition(
    id: scheduleId,
    name: 'invalid_$scheduleId',
    trips: <ScheduleTripDefinition>[
      _fdaTrip(
        1,
        scheduleId * 100,
        0,
        authority,
        present: present,
        absent: absent,
      ),
    ],
  );
}

void _createVersionTwoDatabase(String path) {
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
        type TEXT NOT NULL CHECK (type IN ('tell', 'fixed_destination'))
      );
      CREATE TABLE schedule_trip_occurrences (
        id INTEGER NOT NULL PRIMARY KEY,
        schedule_definition_id INTEGER NOT NULL REFERENCES schedule_definitions (id),
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
        step_definition_id INTEGER NOT NULL PRIMARY KEY REFERENCES step_definitions (id),
        text TEXT NOT NULL
      );
      CREATE TABLE fixed_destination_step_definitions (
        step_definition_id INTEGER NOT NULL PRIMARY KEY REFERENCES step_definitions (id),
        destination_trip_definition_id INTEGER NOT NULL REFERENCES trip_definitions (id)
      );
      CREATE INDEX fixed_destination_step_destination_trip
        ON fixed_destination_step_definitions (destination_trip_definition_id);
      CREATE TABLE schedule_runs (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        schedule_definition_id INTEGER NOT NULL REFERENCES schedule_definitions (id),
        current_trip_occurrence_id INTEGER,
        FOREIGN KEY (schedule_definition_id, current_trip_occurrence_id)
          REFERENCES schedule_trip_occurrences (schedule_definition_id, id)
          ON DELETE RESTRICT
      );
      INSERT INTO schedule_definitions (id, name) VALUES (1, 'existing_v2');
      INSERT INTO trip_definitions (id, name) VALUES (10, 'Trip A');
      INSERT INTO trip_definitions (id, name) VALUES (20, 'Trip B');
      INSERT INTO step_definitions (id, name, type)
        VALUES (1001, 'trip_a_tell', 'tell');
      INSERT INTO tell_step_definitions (step_definition_id, text)
        VALUES (1001, 'Existing Tell');
      INSERT INTO step_definitions (id, name, type)
        VALUES (2001, 'trip_b_fixed', 'fixed_destination');
      INSERT INTO fixed_destination_step_definitions
        (step_definition_id, destination_trip_definition_id)
        VALUES (2001, 10);
      INSERT INTO trip_step_occurrences
        (trip_definition_id, step_definition_id, position)
        VALUES (10, 1001, 0);
      INSERT INTO trip_step_occurrences
        (trip_definition_id, step_definition_id, position)
        VALUES (20, 2001, 0);
      INSERT INTO schedule_trip_occurrences
        (id, schedule_definition_id, trip_definition_id, position)
        VALUES (1010, 1, 10, 0);
      INSERT INTO schedule_trip_occurrences
        (id, schedule_definition_id, trip_definition_id, position)
        VALUES (1020, 1, 20, 1);
      INSERT INTO schedule_runs
        (id, schedule_definition_id, current_trip_occurrence_id)
        VALUES (1, 1, 1020);
      PRAGMA user_version = 2;
    ''');
  } finally {
    database.dispose();
  }
}
