import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/schedule_definition.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/step.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip_definition_id.dart';
import 'package:remember_this_text/essentials/presence/domain/services/presence_scheduler.dart';
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
      'presence_fixed_destination_',
    );
    databasePath = '${tempDirectory.path}/presence.db';
  });

  tearDown(() async {
    await closeDatabase();
    await tempDirectory.delete(recursive: true);
  });

  test('persists and reloads a canonical Fixed Destination Step', () async {
    final opened = await openDatabase();
    final repository = DriftPresenceScheduleRepository(database: opened);
    await repository.insertDefinition(_forwardRouteDefinition());
    final scheduler = PresenceScheduler(
      repository: repository,
      scheduleDefinitionId: 1,
    );
    await scheduler.initialize();

    await scheduler.completeCurrentStep();

    expect(_location(scheduler), (20, 2001));
    expect(
      scheduler.currentStep,
      isA<FixedDestinationStep>().having(
        (step) => step.destinationTripDefinitionId,
        'canonical destination',
        const TripDefinitionId(40),
      ),
    );

    final stored = await opened
        .select(opened.fixedDestinationStepDefinitions)
        .getSingle();
    expect(stored.destinationTripDefinitionId, 40);
    expect(stored.destinationTripDefinitionId, isNot(1040));
  });

  test(
    'migrates an existing Tell-only schema without losing its run',
    () async {
      _createVersionOneDatabase(databasePath);

      final opened = await openDatabase();
      final schemaVersion = await opened
          .customSelect('PRAGMA user_version')
          .getSingle();
      final subtypeTable = await opened
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND "
            "name = 'fixed_destination_step_definitions'",
          )
          .getSingleOrNull();
      final repository = DriftPresenceScheduleRepository(database: opened);
      final run = await repository.loadRun(1);

      expect(schemaVersion.read<int>('user_version'), 8);
      expect(
        subtypeTable?.read<String>('name'),
        'fixed_destination_step_definitions',
      );
      expect(run.currentTripDefinition?.id, const TripDefinitionId(10));
      expect(run.currentTripDefinition?.steps.single, isA<TellStep>());
    },
  );

  test('routes forward by canonical Trip identity and skips Trip C', () async {
    final opened = await openDatabase();
    final repository = DriftPresenceScheduleRepository(database: opened);
    await repository.insertDefinition(_forwardRouteDefinition());
    final scheduler = PresenceScheduler(
      repository: repository,
      scheduleDefinitionId: 1,
    );
    await scheduler.initialize();

    expect(_location(scheduler), (10, 1001));
    await scheduler.completeCurrentStep();
    expect(_location(scheduler), (20, 2001));
    await scheduler.completeCurrentStep();
    expect(_location(scheduler), (40, 4001));
    expect(scheduler.run?.currentTripOccurrenceId, 1040);
    await scheduler.completeCurrentStep();

    expect(scheduler.isComplete, isTrue);
  });

  test(
    'routes backward repeatedly without a loop object or extra state',
    () async {
      final opened = await openDatabase();
      final repository = DriftPresenceScheduleRepository(database: opened);
      await repository.insertDefinition(_backwardRouteDefinition());
      final scheduler = PresenceScheduler(
        repository: repository,
        scheduleDefinitionId: 1,
      );
      await scheduler.initialize();

      expect(_location(scheduler), (10, 1001));
      await scheduler.completeCurrentStep();
      expect(_location(scheduler), (20, 2001));
      await scheduler.completeCurrentStep();
      expect(_location(scheduler), (40, 4001));
      await scheduler.completeCurrentStep();
      expect(_location(scheduler), (20, 2001));
      await scheduler.completeCurrentStep();
      expect(_location(scheduler), (40, 4001));

      expect(scheduler.run?.currentTripOccurrenceId, 1040);
    },
  );

  test('rejects a Schedule whose canonical destination is absent', () async {
    final opened = await openDatabase();
    final repository = DriftPresenceScheduleRepository(database: opened);
    final definition = ScheduleDefinition(
      id: 1,
      name: 'invalid_route_closure',
      trips: <ScheduleTripDefinition>[
        ScheduleTripDefinition(
          occurrenceId: 1020,
          position: 0,
          trip: TripDefinition(
            id: const TripDefinitionId(20),
            name: 'Trip B',
            steps: const <Step>[
              FixedDestinationStep(
                id: 2001,
                name: 'route_to_absent_d',
                destinationTripDefinitionId: TripDefinitionId(40),
              ),
            ],
          ),
        ),
      ],
    );

    await expectLater(
      repository.insertDefinition(definition),
      throwsA(isA<ArgumentError>()),
    );
    expect(await repository.definitionExists(1), isFalse);
  });

  test('rejects a nonterminal Fixed Destination Step', () async {
    final opened = await openDatabase();
    final repository = DriftPresenceScheduleRepository(database: opened);
    final definition = ScheduleDefinition(
      id: 1,
      name: 'invalid_nonterminal_route',
      trips: <ScheduleTripDefinition>[
        ScheduleTripDefinition(
          occurrenceId: 1010,
          position: 0,
          trip: TripDefinition(
            id: const TripDefinitionId(10),
            name: 'Trip A',
            steps: const <Step>[
              FixedDestinationStep(
                id: 1001,
                name: 'nonterminal_route',
                destinationTripDefinitionId: TripDefinitionId(20),
              ),
              TellStep(id: 1002, name: 'terminal_tell', text: 'Finish.'),
            ],
          ),
        ),
        ScheduleTripDefinition(
          occurrenceId: 1020,
          position: 1,
          trip: TripDefinition(
            id: const TripDefinitionId(20),
            name: 'Trip B',
            steps: const <Step>[
              TellStep(id: 2001, name: 'trip_b_tell', text: 'Trip B'),
            ],
          ),
        ),
      ],
    );

    await expectLater(
      repository.insertDefinition(definition),
      throwsA(isA<ArgumentError>()),
    );
    expect(await repository.definitionExists(1), isFalse);
  });

  test(
    'restart after explicit routing begins destination Trip at Step 1',
    () async {
      var opened = await openDatabase();
      var repository = DriftPresenceScheduleRepository(database: opened);
      await repository.insertDefinition(_forwardRouteDefinition());
      var scheduler = PresenceScheduler(
        repository: repository,
        scheduleDefinitionId: 1,
      );
      await scheduler.initialize();

      await scheduler.completeCurrentStep();
      await scheduler.completeCurrentStep();
      expect(_location(scheduler), (40, 4001));
      expect(scheduler.run?.currentTripOccurrenceId, 1040);

      await closeDatabase();
      opened = await openDatabase();
      repository = DriftPresenceScheduleRepository(database: opened);
      scheduler = PresenceScheduler(
        repository: repository,
        scheduleDefinitionId: 1,
      );
      await scheduler.initialize();

      expect(_location(scheduler), (40, 4001));
      expect(scheduler.currentTrip?.currentStepIndex, 0);
      expect(scheduler.run?.currentTripOccurrenceId, 1040);
    },
  );

  test('Trip discards a nonterminal routing result', () async {
    final trip = Trip(
      TripDefinition(
        id: const TripDefinitionId(10),
        name: 'boundary_probe',
        steps: const <Step>[
          FixedDestinationStep(
            id: 1001,
            name: 'nonterminal_route',
            destinationTripDefinitionId: TripDefinitionId(40),
          ),
          TellStep(id: 1002, name: 'terminal_tell', text: 'Finish.'),
        ],
      ),
    );

    final first = await trip.completeCurrentStep();
    final terminal = await trip.completeCurrentStep();

    expect(first.tripCompleted, isFalse);
    expect(first.routingResultTripDefinitionId, isNull);
    expect(terminal.tripCompleted, isTrue);
    expect(terminal.routingResultTripDefinitionId, isNull);
  });
}

void _createVersionOneDatabase(String path) {
  final database = sqlite3.sqlite3.open(path);
  try {
    database.execute('PRAGMA foreign_keys = ON');
    database.execute('''
      CREATE TABLE schedule_definitions (
        id INTEGER NOT NULL PRIMARY KEY,
        name TEXT NOT NULL UNIQUE
      )
    ''');
    database.execute('''
      CREATE TABLE trip_definitions (
        id INTEGER NOT NULL PRIMARY KEY,
        name TEXT NOT NULL UNIQUE
      )
    ''');
    database.execute('''
      CREATE TABLE step_definitions (
        id INTEGER NOT NULL PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL CHECK (type IN ('tell'))
      )
    ''');
    database.execute('''
      CREATE TABLE schedule_trip_occurrences (
        id INTEGER NOT NULL PRIMARY KEY,
        schedule_definition_id INTEGER NOT NULL
          REFERENCES schedule_definitions (id),
        trip_definition_id INTEGER NOT NULL
          REFERENCES trip_definitions (id),
        position INTEGER NOT NULL CHECK (position >= 0),
        UNIQUE (schedule_definition_id, position),
        UNIQUE (schedule_definition_id, trip_definition_id),
        UNIQUE (schedule_definition_id, id)
      )
    ''');
    database.execute('''
      CREATE TABLE trip_step_occurrences (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        trip_definition_id INTEGER NOT NULL
          REFERENCES trip_definitions (id),
        step_definition_id INTEGER NOT NULL
          REFERENCES step_definitions (id),
        position INTEGER NOT NULL CHECK (position >= 0),
        UNIQUE (trip_definition_id, position)
      )
    ''');
    database.execute('''
      CREATE TABLE tell_step_definitions (
        step_definition_id INTEGER NOT NULL PRIMARY KEY
          REFERENCES step_definitions (id),
        text TEXT NOT NULL
      )
    ''');
    database.execute('''
      CREATE TABLE schedule_runs (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        schedule_definition_id INTEGER NOT NULL
          REFERENCES schedule_definitions (id),
        current_trip_occurrence_id INTEGER,
        FOREIGN KEY (schedule_definition_id, current_trip_occurrence_id)
          REFERENCES schedule_trip_occurrences (schedule_definition_id, id)
          ON DELETE RESTRICT
      )
    ''');
    database.execute(
      "INSERT INTO schedule_definitions (id, name) VALUES (1, 'existing')",
    );
    database.execute(
      "INSERT INTO trip_definitions (id, name) VALUES (10, 'Trip A')",
    );
    database.execute('''
      INSERT INTO step_definitions (id, name, type)
      VALUES (1001, 'trip_a_tell', 'tell')''');
    database.execute('''
      INSERT INTO tell_step_definitions (step_definition_id, text)
      VALUES (1001, 'Existing Tell')''');
    database.execute(
      'INSERT INTO trip_step_occurrences '
      '(trip_definition_id, step_definition_id, position) '
      'VALUES (10, 1001, 0)',
    );
    database.execute(
      'INSERT INTO schedule_trip_occurrences '
      '(id, schedule_definition_id, trip_definition_id, position) '
      'VALUES (1010, 1, 10, 0)',
    );
    database.execute(
      'INSERT INTO schedule_runs '
      '(id, schedule_definition_id, current_trip_occurrence_id) '
      'VALUES (1, 1, 1010)',
    );
    database.execute('PRAGMA user_version = 1');
  } finally {
    database.dispose();
  }
}

(int, int) _location(PresenceScheduler scheduler) {
  final trip = scheduler.currentTrip;
  final step = scheduler.currentStep;
  if (trip == null || step == null) {
    throw StateError('The Schedule is complete.');
  }
  return (trip.definition.id.value, step.id);
}

ScheduleDefinition _forwardRouteDefinition() {
  return _routeDefinition(loopBackFromD: false);
}

ScheduleDefinition _backwardRouteDefinition() {
  return _routeDefinition(loopBackFromD: true);
}

ScheduleDefinition _routeDefinition({required bool loopBackFromD}) {
  return ScheduleDefinition(
    id: 1,
    name: loopBackFromD
        ? 'backward_route_experiment'
        : 'forward_route_experiment',
    trips: <ScheduleTripDefinition>[
      ScheduleTripDefinition(
        occurrenceId: 1010,
        position: 0,
        trip: TripDefinition(
          id: const TripDefinitionId(10),
          name: 'Trip A',
          steps: const <Step>[
            TellStep(id: 1001, name: 'trip_a_tell', text: 'Trip A'),
          ],
        ),
      ),
      ScheduleTripDefinition(
        occurrenceId: 1020,
        position: 1,
        trip: TripDefinition(
          id: const TripDefinitionId(20),
          name: 'Trip B',
          steps: const <Step>[
            FixedDestinationStep(
              id: 2001,
              name: 'trip_b_route_to_d',
              destinationTripDefinitionId: TripDefinitionId(40),
            ),
          ],
        ),
      ),
      ScheduleTripDefinition(
        occurrenceId: 1030,
        position: 2,
        trip: TripDefinition(
          id: const TripDefinitionId(30),
          name: 'Trip C',
          steps: const <Step>[
            TellStep(id: 3001, name: 'trip_c_tell', text: 'Trip C'),
          ],
        ),
      ),
      ScheduleTripDefinition(
        occurrenceId: 1040,
        position: 3,
        trip: TripDefinition(
          id: const TripDefinitionId(40),
          name: 'Trip D',
          steps: <Step>[
            if (loopBackFromD)
              const FixedDestinationStep(
                id: 4001,
                name: 'trip_d_route_to_b',
                destinationTripDefinitionId: TripDefinitionId(20),
              )
            else
              const TellStep(id: 4001, name: 'trip_d_tell', text: 'Trip D'),
          ],
        ),
      ),
    ],
  );
}
