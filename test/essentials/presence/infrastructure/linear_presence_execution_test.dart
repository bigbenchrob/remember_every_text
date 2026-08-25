import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/schedule_definition.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/step.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip_definition_id.dart';
import 'package:remember_this_text/essentials/presence/domain/services/presence_scheduler.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/data_sources/local/presence_database.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/repositories/drift_presence_schedule_repository.dart';
import 'package:sqlite3/sqlite3.dart' show SqliteException;

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
      'presence_linear_execution_',
    );
    databasePath = '${tempDirectory.path}/presence.db';
  });

  tearDown(() async {
    await closeDatabase();
    await tempDirectory.delete(recursive: true);
  });

  test(
    'uses a physically persistent database and deterministic order',
    () async {
      final firstDatabase = await openDatabase();
      final repository = DriftPresenceScheduleRepository(
        database: firstDatabase,
      );
      await repository.insertDefinition(_linearDefinition());

      expect(File(databasePath).existsSync(), isTrue);

      final scheduleOrder =
          await (firstDatabase.select(firstDatabase.scheduleTripOccurrences)
                ..orderBy(<OrderClauseGenerator<ScheduleTripOccurrences>>[
                  (table) => OrderingTerm.asc(table.position),
                ]))
              .get();
      expect(
        scheduleOrder.map((row) => row.tripDefinitionId),
        orderedEquals(<int>[10, 20, 30]),
      );

      await closeDatabase();
      final reopenedDatabase = await openDatabase();
      final reopenedRepository = DriftPresenceScheduleRepository(
        database: reopenedDatabase,
      );
      final scheduler = PresenceScheduler(
        repository: reopenedRepository,
        scheduleDefinitionId: 1,
      );
      await scheduler.initialize();

      expect(scheduler.currentTrip?.definition.id, const TripDefinitionId(10));
      expect(
        scheduler.currentStep,
        isA<TellStep>().having((step) => step.text, 'text', 'Trip 10 - Step 1'),
      );
    },
  );

  test('rejects one Trip definition appearing twice in a Schedule', () async {
    final opened = await openDatabase();
    final repository = DriftPresenceScheduleRepository(database: opened);
    await repository.insertDefinition(_linearDefinition());
    await opened
        .into(opened.scheduleDefinitions)
        .insert(
          ScheduleDefinitionsCompanion.insert(
            id: const Value<int>(2),
            name: 'invalid_duplicate_trip_schedule',
          ),
        );
    await opened
        .into(opened.scheduleTripOccurrences)
        .insert(
          ScheduleTripOccurrencesCompanion.insert(
            id: const Value<int>(2010),
            scheduleDefinitionId: 2,
            tripDefinitionId: 10,
            position: 0,
          ),
        );

    await expectLater(
      opened
          .into(opened.scheduleTripOccurrences)
          .insert(
            ScheduleTripOccurrencesCompanion.insert(
              id: const Value<int>(2020),
              scheduleDefinitionId: 2,
              tripDefinitionId: 10,
              position: 1,
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('superseding an incomplete run preserves prior run evidence', () async {
    final opened = await openDatabase();
    final repository = DriftPresenceScheduleRepository(database: opened);
    await repository.insertDefinition(_linearDefinition());
    final original = await repository.startOrLoadRun(1);

    final replacement = await repository.supersedeRunFromBeginning(1);
    final runs =
        await (opened.select(opened.scheduleRuns)
              ..orderBy(<OrderClauseGenerator<ScheduleRuns>>[
                (table) => OrderingTerm.asc(table.id),
              ]))
            .get();

    expect(replacement.id, isNot(original.id));
    expect(replacement.currentTripOccurrenceId, 1010);
    expect(runs.map((run) => run.id), <int>[original.id, replacement.id]);
    expect(
      (await repository.loadRun(original.id)).currentTripOccurrenceId,
      original.currentTripOccurrenceId,
    );
  });

  test('allows one canonical Trip in different Schedules', () async {
    final opened = await openDatabase();
    final repository = DriftPresenceScheduleRepository(database: opened);
    final first = _linearDefinition();
    await repository.insertDefinition(first);
    await repository.insertDefinition(
      ScheduleDefinition(
        id: 2,
        name: 'second_schedule',
        trips: <ScheduleTripDefinition>[
          ScheduleTripDefinition(
            occurrenceId: 2010,
            position: 0,
            trip: first.trips.first.trip,
          ),
        ],
      ),
    );

    final references = await (opened.select(
      opened.scheduleTripOccurrences,
    )..where((table) => table.tripDefinitionId.equals(10))).get();
    expect(
      references.map((row) => row.scheduleDefinitionId),
      orderedEquals(<int>[1, 2]),
    );
  });

  test('executes Tell Steps and Trips in linear order', () async {
    final opened = await openDatabase();
    final repository = DriftPresenceScheduleRepository(database: opened);
    await repository.insertDefinition(_linearDefinition());
    final scheduler = PresenceScheduler(
      repository: repository,
      scheduleDefinitionId: 1,
    );
    await scheduler.initialize();

    expect(_location(scheduler), (10, 1001));
    await scheduler.completeCurrentStep();
    expect(_location(scheduler), (10, 1002));
    await scheduler.completeCurrentStep();
    expect(_location(scheduler), (20, 2001));
    await scheduler.completeCurrentStep();
    expect(_location(scheduler), (20, 2002));
    await scheduler.completeCurrentStep();
    expect(_location(scheduler), (30, 3001));
    await scheduler.completeCurrentStep();

    expect(scheduler.isComplete, isTrue);
    expect(scheduler.currentTrip, isNull);
    expect(scheduler.currentStep, isNull);
    expect(scheduler.run?.currentTripOccurrenceId, isNull);
  });

  test('restart repeats the incomplete Trip but not completed Trips', () async {
    var opened = await openDatabase();
    var repository = DriftPresenceScheduleRepository(database: opened);
    await repository.insertDefinition(_linearDefinition());
    var scheduler = PresenceScheduler(
      repository: repository,
      scheduleDefinitionId: 1,
    );
    await scheduler.initialize();

    await scheduler.completeCurrentStep();
    await scheduler.completeCurrentStep();
    expect(_location(scheduler), (20, 2001));
    expect(scheduler.run?.currentTripOccurrenceId, 1020);

    await scheduler.completeCurrentStep();
    expect(_location(scheduler), (20, 2002));
    expect(scheduler.run?.currentTripOccurrenceId, 1020);

    await closeDatabase();
    opened = await openDatabase();
    repository = DriftPresenceScheduleRepository(database: opened);
    scheduler = PresenceScheduler(
      repository: repository,
      scheduleDefinitionId: 1,
    );
    await scheduler.initialize();

    expect(_location(scheduler), (20, 2001));
    expect(scheduler.run?.currentTripOccurrenceId, 1020);
  });

  test(
    'Trip-boundary checkpoint changes restart destination atomically',
    () async {
      var opened = await openDatabase();
      var repository = DriftPresenceScheduleRepository(database: opened);
      await repository.insertDefinition(_linearDefinition());
      var scheduler = PresenceScheduler(
        repository: repository,
        scheduleDefinitionId: 1,
      );
      await scheduler.initialize();
      await scheduler.completeCurrentStep();
      await scheduler.completeCurrentStep();
      await scheduler.completeCurrentStep();

      expect(_location(scheduler), (20, 2002));
      expect(scheduler.run?.currentTripOccurrenceId, 1020);

      await scheduler.completeCurrentStep();
      expect(_location(scheduler), (30, 3001));
      expect(scheduler.run?.currentTripOccurrenceId, 1030);

      await closeDatabase();
      opened = await openDatabase();
      repository = DriftPresenceScheduleRepository(database: opened);
      scheduler = PresenceScheduler(
        repository: repository,
        scheduleDefinitionId: 1,
      );
      await scheduler.initialize();

      expect(_location(scheduler), (30, 3001));
      expect(scheduler.run?.currentTripOccurrenceId, 1030);
    },
  );

  test('completed run remains complete until explicitly replaced', () async {
    var opened = await openDatabase();
    var repository = DriftPresenceScheduleRepository(database: opened);
    await repository.insertDefinition(_linearDefinition());
    var scheduler = PresenceScheduler(
      repository: repository,
      scheduleDefinitionId: 1,
    );
    await scheduler.initialize();

    while (!scheduler.isComplete) {
      await scheduler.completeCurrentStep();
    }
    final completedRunId = scheduler.run!.id;

    await closeDatabase();
    opened = await openDatabase();
    repository = DriftPresenceScheduleRepository(database: opened);
    scheduler = PresenceScheduler(
      repository: repository,
      scheduleDefinitionId: 1,
    );
    await scheduler.initialize();

    expect(scheduler.isComplete, isTrue);
    expect(scheduler.run?.id, completedRunId);

    await scheduler.replaceRunFromBeginning();

    expect(scheduler.isComplete, isFalse);
    expect(scheduler.run?.id, isNot(completedRunId));
    expect(scheduler.run?.currentTripOccurrenceId, 1010);
    expect(_location(scheduler), (10, 1001));

    final storedRuns = await opened.select(opened.scheduleRuns).get();
    expect(storedRuns, hasLength(2));
    expect(storedRuns.last.id, scheduler.run?.id);
    expect(storedRuns.last.currentTripOccurrenceId, 1010);
    expect(storedRuns.first.currentTripOccurrenceId, isNull);
  });
}

(int, int) _location(PresenceScheduler scheduler) {
  final trip = scheduler.currentTrip;
  final step = scheduler.currentStep;
  if (trip == null || step == null) {
    throw StateError('The Schedule is complete.');
  }
  return (trip.definition.id.value, step.id);
}

ScheduleDefinition _linearDefinition() {
  return ScheduleDefinition(
    id: 1,
    name: 'linear_presence_experiment',
    trips: <ScheduleTripDefinition>[
      ScheduleTripDefinition(
        occurrenceId: 1010,
        position: 0,
        trip: TripDefinition(
          id: const TripDefinitionId(10),
          name: 'Trip 10',
          steps: const <Step>[
            TellStep(
              id: 1001,
              name: 'trip_10_step_1',
              text: 'Trip 10 - Step 1',
            ),
            TellStep(
              id: 1002,
              name: 'trip_10_step_2',
              text: 'Trip 10 - Step 2',
            ),
          ],
        ),
      ),
      ScheduleTripDefinition(
        occurrenceId: 1020,
        position: 1,
        trip: TripDefinition(
          id: const TripDefinitionId(20),
          name: 'Trip 20',
          steps: const <Step>[
            TellStep(
              id: 2001,
              name: 'trip_20_step_1',
              text: 'Trip 20 - Step 1',
            ),
            TellStep(
              id: 2002,
              name: 'trip_20_step_2',
              text: 'Trip 20 - Step 2',
            ),
          ],
        ),
      ),
      ScheduleTripDefinition(
        occurrenceId: 1030,
        position: 2,
        trip: TripDefinition(
          id: const TripDefinitionId(30),
          name: 'Trip 30',
          steps: const <Step>[
            TellStep(
              id: 3001,
              name: 'trip_30_step_1',
              text: 'Trip 30 - Step 1',
            ),
          ],
        ),
      ),
    ],
  );
}
