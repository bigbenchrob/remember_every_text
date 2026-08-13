import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/step.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/test_agent_id.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip_definition_id.dart';
import 'package:remember_this_text/essentials/presence/domain/services/presence_scheduler.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent_resolver.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/data_sources/local/presence_database.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/repositories/drift_presence_schedule_repository.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

void main() {
  group('Presence generic Test grammar', () {
    late PresenceDatabase database;

    setUp(() async {
      database = PresenceDatabase(NativeDatabase.memory());
      await database.customSelect('SELECT 1').get();
    });

    tearDown(() => database.close());

    test(
      'stores a declared opaque Agent and nullable Boolean routes',
      () async {
        final agentId = TestAgentId('sample.test-agent');
        await _insertTrip(database, 10, 'True destination');
        await _insertBaseTestStep(database, 20, 'Generic Test');
        await database
            .into(database.testAgentDefinitions)
            .insert(TestAgentDefinitionsCompanion.insert(id: agentId.value));
        await database
            .into(database.testStepDefinitions)
            .insert(
              TestStepDefinitionsCompanion.insert(
                stepDefinitionId: const Value<int>(20),
                testAgentId: agentId.value,
                trueDestinationTripDefinitionId: const Value<int?>(10),
                falseDestinationTripDefinitionId: const Value<int?>(null),
              ),
            );

        final stored = await database
            .select(database.testStepDefinitions)
            .getSingle();

        expect(TestAgentId(stored.testAgentId), agentId);
        expect(stored.trueDestinationTripDefinitionId, 10);
        expect(stored.falseDestinationTripDefinitionId, null);
      },
    );

    test('rejects an undeclared Agent identity', () async {
      final agentId = TestAgentId('sample.undeclared-agent');
      await _insertBaseTestStep(database, 20, 'Undeclared Agent Test');

      await expectLater(
        database
            .into(database.testStepDefinitions)
            .insert(
              TestStepDefinitionsCompanion.insert(
                stepDefinitionId: const Value<int>(20),
                testAgentId: agentId.value,
              ),
            ),
        throwsA(isA<sqlite3.SqliteException>()),
      );
    });

    test('rejects a nonexistent destination Trip', () async {
      final agentId = TestAgentId('sample.missing-destination-agent');
      await _insertBaseTestStep(database, 20, 'Missing Destination Test');
      await database
          .into(database.testAgentDefinitions)
          .insert(TestAgentDefinitionsCompanion.insert(id: agentId.value));

      await expectLater(
        database
            .into(database.testStepDefinitions)
            .insert(
              TestStepDefinitionsCompanion.insert(
                stepDefinitionId: const Value<int>(20),
                testAgentId: agentId.value,
                trueDestinationTripDefinitionId: const Value<int?>(999),
              ),
            ),
        throwsA(isA<sqlite3.SqliteException>()),
      );
    });

    test('rejects a duplicate Agent declaration', () async {
      final agentId = TestAgentId('sample.duplicate-agent');
      final row = TestAgentDefinitionsCompanion.insert(id: agentId.value);
      await database.into(database.testAgentDefinitions).insert(row);

      await expectLater(
        database.into(database.testAgentDefinitions).insert(row),
        throwsA(isA<sqlite3.SqliteException>()),
      );
    });

    test('rejects a duplicate Test subtype for one Step', () async {
      final agentId = TestAgentId('sample.duplicate-test-subtype');
      await _insertBaseTestStep(database, 20, 'Duplicate Test Subtype');
      await database
          .into(database.testAgentDefinitions)
          .insert(TestAgentDefinitionsCompanion.insert(id: agentId.value));
      final row = TestStepDefinitionsCompanion.insert(
        stepDefinitionId: const Value<int>(20),
        testAgentId: agentId.value,
      );
      await database.into(database.testStepDefinitions).insert(row);

      await expectLater(
        database.into(database.testStepDefinitions).insert(row),
        throwsA(isA<sqlite3.SqliteException>()),
      );
    });
  });

  test(
    'v6 migration preserves history and prepares identity-stable generic rows',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'presence_v7_generic_test_migration_',
      );
      final path = '${directory.path}/presence.db';
      _createVersionSixDatabase(path);

      final database = PresenceDatabase(NativeDatabase(File(path)));
      try {
        await database.customSelect('SELECT 1').get();

        final version = await database
            .customSelect('PRAGMA user_version')
            .getSingle();
        final scheduleIds = await _integerColumn(
          database,
          'SELECT id FROM schedule_definitions ORDER BY id',
          'id',
        );
        final tripIds = await _integerColumn(
          database,
          'SELECT id FROM trip_definitions ORDER BY id',
          'id',
        );
        final stepIds = await _integerColumn(
          database,
          'SELECT id FROM step_definitions ORDER BY id',
          'id',
        );
        final scheduleOccurrenceIds = await _integerColumn(
          database,
          'SELECT id FROM schedule_trip_occurrences ORDER BY id',
          'id',
        );
        final stepOccurrenceIds = await _integerColumn(
          database,
          'SELECT id FROM trip_step_occurrences ORDER BY id',
          'id',
        );
        final run = await database
            .customSelect(
              'SELECT id, current_trip_occurrence_id FROM schedule_runs',
            )
            .getSingle();
        final traceRows = await database
            .customSelect(
              'SELECT id, sequence FROM execution_trace_events ORDER BY id',
            )
            .get();
        final genericRows = await database.customSelect('''
              SELECT
                step_definition_id,
                test_agent_id,
                true_destination_trip_definition_id,
                false_destination_trip_definition_id
              FROM test_step_definitions
              ORDER BY step_definition_id
              ''').get();
        final agentIds = await database
            .customSelect('SELECT id FROM test_agent_definitions ORDER BY id')
            .get();
        final baseRows = await database
            .customSelect('SELECT id, type FROM step_definitions ORDER BY id')
            .get();

        expect(version.read<int>('user_version'), 8);
        expect(scheduleIds, <int>[900]);
        expect(tripIds, <int>[901, 902, 903, 904]);
        expect(stepIds, <int>[9101, 9102, 9103, 9104]);
        expect(scheduleOccurrenceIds, <int>[9301, 9302, 9303, 9304]);
        expect(stepOccurrenceIds, <int>[9201, 9202, 9203, 9204]);
        expect(run.read<int>('id'), 9401);
        expect(run.read<int>('current_trip_occurrence_id'), 9302);
        expect(
          traceRows
              .map((row) => (row.read<int>('id'), row.read<int>('sequence')))
              .toList(),
          <(int, int)>[(9501, 1), (9502, 2), (9503, 3)],
        );
        expect(agentIds.map((row) => row.read<String>('id')).toList(), <String>[
          'onboarding.contacts-source-readable',
          'onboarding.messages-source-readable',
        ]);
        expect(
          genericRows
              .map(
                (row) => (
                  row.read<int>('step_definition_id'),
                  row.read<String>('test_agent_id'),
                  row.readNullable<int>('true_destination_trip_definition_id'),
                  row.readNullable<int>('false_destination_trip_definition_id'),
                ),
              )
              .toList(),
          <(int, String, int?, int?)>[
            (9101, 'onboarding.messages-source-readable', 903, 904),
            (9102, 'onboarding.contacts-source-readable', 904, null),
          ],
        );
        expect(
          baseRows
              .map((row) => (row.read<int>('id'), row.read<String>('type')))
              .toList(),
          <(int, String)>[
            (9101, testStepType),
            (9102, testStepType),
            (9103, tellStepType),
            (9104, tellStepType),
          ],
          reason: 'The generic runtime discriminator is now active.',
        );
        expect(
          await database.select(database.fdaTestStepDefinitions).get(),
          hasLength(1),
        );
        expect(
          await database
              .select(database.contactsSourceReadinessStepDefinitions)
              .get(),
          hasLength(1),
        );

        final activeGenericRows = await database
            .customSelect(
              '''
              SELECT step_definitions.id
              FROM step_definitions
              INNER JOIN test_step_definitions
                ON test_step_definitions.step_definition_id =
                  step_definitions.id
              WHERE step_definitions.type = ?
              ORDER BY step_definitions.id
              ''',
              variables: const <Variable<Object>>[
                Variable<String>(testStepType),
              ],
            )
            .get();
        expect(
          activeGenericRows.map((row) => row.read<int>('id')).toList(),
          <int>[9101, 9102],
        );
        expect(
          await database.select(database.fdaTestStepDefinitions).get(),
          hasLength(1),
        );
        expect(
          await database
              .select(database.contactsSourceReadinessStepDefinitions)
              .get(),
          hasLength(1),
          reason: 'Legacy rows remain frozen migration evidence.',
        );

        final contactsAgent = _ConstantTestAgent(value: true);
        final repository = DriftPresenceScheduleRepository(
          database: database,
          testAgentResolver: ImmutableTestAgentResolver(<TestAgentBinding>[
            TestAgentBinding(
              id: TestAgentId('onboarding.messages-source-readable'),
              agent: _ConstantTestAgent(value: false),
            ),
            TestAgentBinding(
              id: TestAgentId('onboarding.contacts-source-readable'),
              agent: contactsAgent,
            ),
          ]),
        );
        final migrated = await repository.loadDefinition(900);
        expect(migrated.trips.first.trip.steps.single, isA<TestStep>());
        expect(migrated.trips[1].trip.steps.single, isA<TestStep>());

        final scheduler = PresenceScheduler(
          repository: repository,
          scheduleDefinitionId: 900,
        );
        await scheduler.initialize();
        expect(
          scheduler.currentTrip?.definition.id,
          const TripDefinitionId(902),
        );
        await scheduler.completeCurrentStep();
        expect(
          scheduler.currentTrip?.definition.id,
          const TripDefinitionId(904),
        );
        expect(contactsAgent.invocationCount, 1);
      } finally {
        await database.close();
        await directory.delete(recursive: true);
      }
    },
  );
}

Future<void> _insertTrip(PresenceDatabase database, int id, String name) async {
  await database
      .into(database.tripDefinitions)
      .insert(TripDefinitionsCompanion.insert(id: Value<int>(id), name: name));
}

Future<void> _insertBaseTestStep(
  PresenceDatabase database,
  int id,
  String name,
) async {
  await database
      .into(database.stepDefinitions)
      .insert(
        StepDefinitionsCompanion.insert(
          id: Value<int>(id),
          name: name,
          stepType: testStepType,
        ),
      );
}

Future<List<int>> _integerColumn(
  PresenceDatabase database,
  String query,
  String column,
) async {
  final rows = await database.customSelect(query).get();
  return rows.map((row) => row.read<int>(column)).toList();
}

void _createVersionSixDatabase(String path) {
  final database = sqlite3.sqlite3.open(path);
  try {
    database.execute('''
      PRAGMA foreign_keys = ON;
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
          type IN (
            'tell',
            'fixed_destination',
            'fda_test',
            'contacts_source_readiness',
            'open_fda_settings'
          )
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
      CREATE TABLE contacts_source_readiness_step_definitions (
        step_definition_id INTEGER NOT NULL PRIMARY KEY
          REFERENCES step_definitions (id),
        available_destination_trip_definition_id INTEGER
          REFERENCES trip_definitions (id),
        unavailable_destination_trip_definition_id INTEGER
          REFERENCES trip_definitions (id)
      );
      CREATE TABLE open_fda_settings_step_definitions (
        step_definition_id INTEGER NOT NULL PRIMARY KEY
          REFERENCES step_definitions (id)
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
      CREATE TABLE execution_trace_events (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        schedule_run_id INTEGER NOT NULL REFERENCES schedule_runs (id),
        sequence INTEGER NOT NULL CHECK (sequence > 0),
        event_type TEXT NOT NULL,
        trip_occurrence_id INTEGER REFERENCES schedule_trip_occurrences (id),
        step_occurrence_id INTEGER REFERENCES trip_step_occurrences (id),
        routing_result_trip_definition_id INTEGER
          REFERENCES trip_definitions (id),
        selected_destination_trip_occurrence_id INTEGER
          REFERENCES schedule_trip_occurrences (id),
        occurred_at_utc_us INTEGER NOT NULL CHECK (occurred_at_utc_us >= 0),
        UNIQUE (schedule_run_id, sequence)
      );

      INSERT INTO schedule_definitions (id, name)
        VALUES (900, 'preserved_schedule');
      INSERT INTO trip_definitions (id, name) VALUES
        (901, 'fda_test_trip'),
        (902, 'contacts_test_trip'),
        (903, 'true_destination_trip'),
        (904, 'false_destination_trip');
      INSERT INTO step_definitions (id, name, type) VALUES
        (9101, 'preserved_fda_test', 'fda_test'),
        (9102, 'preserved_contacts_test', 'contacts_source_readiness'),
        (9103, 'preserved_true_destination', 'tell'),
        (9104, 'preserved_false_destination', 'tell');
      INSERT INTO tell_step_definitions (step_definition_id, text) VALUES
        (9103, 'True destination'),
        (9104, 'False destination');
      INSERT INTO fda_test_step_definitions (
        step_definition_id,
        present_destination_trip_definition_id,
        absent_destination_trip_definition_id
      ) VALUES (9101, 903, 904);
      INSERT INTO contacts_source_readiness_step_definitions (
        step_definition_id,
        available_destination_trip_definition_id,
        unavailable_destination_trip_definition_id
      ) VALUES (9102, 904, NULL);
      INSERT INTO trip_step_occurrences
        (id, trip_definition_id, step_definition_id, position) VALUES
        (9201, 901, 9101, 0),
        (9202, 902, 9102, 0),
        (9203, 903, 9103, 0),
        (9204, 904, 9104, 0);
      INSERT INTO schedule_trip_occurrences
        (id, schedule_definition_id, trip_definition_id, position) VALUES
        (9301, 900, 901, 0),
        (9302, 900, 902, 1),
        (9303, 900, 903, 2),
        (9304, 900, 904, 3);
      INSERT INTO schedule_runs
        (id, schedule_definition_id, current_trip_occurrence_id)
        VALUES (9401, 900, 9302);
      INSERT INTO execution_trace_events (
        id,
        schedule_run_id,
        sequence,
        event_type,
        trip_occurrence_id,
        step_occurrence_id,
        occurred_at_utc_us
      ) VALUES
        (9501, 9401, 1, 'schedule_run_started', NULL, NULL, 1),
        (9502, 9401, 2, 'trip_started', 9302, NULL, 2),
        (9503, 9401, 3, 'step_started', 9302, 9202, 3);
      PRAGMA user_version = 6;
    ''');
  } finally {
    database.dispose();
  }
}

final class _ConstantTestAgent implements TestAgent {
  _ConstantTestAgent({required this.value});

  final bool value;
  int invocationCount = 0;

  @override
  Future<bool> evaluate() async {
    invocationCount += 1;
    return value;
  }
}
