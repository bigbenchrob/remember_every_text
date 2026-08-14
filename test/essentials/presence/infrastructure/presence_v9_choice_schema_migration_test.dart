import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/step.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/data_sources/local/presence_database.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/repositories/drift_presence_schedule_repository.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

void main() {
  test('v8 migrates additively to Choice schema v9', () async {
    final directory = await Directory.systemTemp.createTemp(
      'presence_v9_choice_migration_',
    );
    final path = '${directory.path}/presence.db';
    _createVersionEightDatabase(path);

    final database = PresenceDatabase(NativeDatabase(File(path)));
    try {
      await database.customSelect('SELECT 1').get();

      final version = await database
          .customSelect('PRAGMA user_version')
          .getSingle();
      final choiceMarkerTable = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
            variables: const <Variable<Object>>[
              Variable<String>('choice_step_definitions'),
            ],
          )
          .getSingleOrNull();
      final choiceOptionsTable = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
            variables: const <Variable<Object>>[
              Variable<String>('choice_step_options'),
            ],
          )
          .getSingleOrNull();
      final repository = DriftPresenceScheduleRepository(database: database);
      final definition = await repository.loadDefinition(800);
      final run = await repository.loadRun(8401);
      final trace = await repository.loadExecutionTrace(8401);

      expect(version.read<int>('user_version'), 9);
      expect(
        choiceMarkerTable?.read<String>('name'),
        'choice_step_definitions',
      );
      expect(choiceOptionsTable?.read<String>('name'), 'choice_step_options');
      expect(definition.name, 'preserved_schedule');
      expect(definition.trips.single.trip.name, 'preserved_trip');
      expect(definition.trips.single.trip.steps.single, isA<TellStep>());
      expect(run.currentTripOccurrenceId, 8301);
      expect(trace, hasLength(1));
      expect(trace.single.sequence, 1);

      await database
          .into(database.stepDefinitions)
          .insert(
            StepDefinitionsCompanion.insert(
              id: const Value<int>(8102),
              name: 'new_choice',
              stepType: choiceStepType,
            ),
          );
      await database
          .into(database.choiceStepDefinitions)
          .insert(
            ChoiceStepDefinitionsCompanion.insert(
              stepDefinitionId: const Value<int>(8102),
            ),
          );
      await database
          .into(database.choiceStepOptions)
          .insert(
            ChoiceStepOptionsCompanion.insert(
              stepDefinitionId: 8102,
              value: 'preserved',
              position: 0,
              label: 'Preserved',
              destinationTripDefinitionId: 801,
            ),
          );

      await expectLater(
        database
            .into(database.choiceStepOptions)
            .insert(
              ChoiceStepOptionsCompanion.insert(
                stepDefinitionId: 9999,
                value: 'orphan',
                position: 0,
                label: 'Orphan',
                destinationTripDefinitionId: 801,
              ),
            ),
        throwsA(isA<sqlite3.SqliteException>()),
      );
      await expectLater(
        database
            .into(database.choiceStepOptions)
            .insert(
              ChoiceStepOptionsCompanion.insert(
                stepDefinitionId: 8102,
                value: 'missing_destination',
                position: 1,
                label: 'Missing destination',
                destinationTripDefinitionId: 9999,
              ),
            ),
        throwsA(isA<sqlite3.SqliteException>()),
      );
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });
}

void _createVersionEightDatabase(String path) {
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
            'test',
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
      CREATE TABLE test_agent_definitions (
        id TEXT NOT NULL PRIMARY KEY
      );
      CREATE TABLE test_step_definitions (
        step_definition_id INTEGER NOT NULL PRIMARY KEY
          REFERENCES step_definitions (id),
        test_agent_id TEXT NOT NULL REFERENCES test_agent_definitions (id),
        true_destination_trip_definition_id INTEGER
          REFERENCES trip_definitions (id),
        false_destination_trip_definition_id INTEGER
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
        UNIQUE (schedule_run_id, sequence),
        CHECK (
          (event_type IN ('schedule_run_started', 'schedule_run_completed')
            AND trip_occurrence_id IS NULL AND step_occurrence_id IS NULL)
          OR
          (event_type IN ('trip_started', 'trip_completed', 'route_decision')
            AND trip_occurrence_id IS NOT NULL AND step_occurrence_id IS NULL)
          OR
          (event_type IN ('step_started', 'step_completed')
            AND trip_occurrence_id IS NOT NULL AND step_occurrence_id IS NOT NULL)
        ),
        CHECK (
          event_type = 'route_decision'
          OR (routing_result_trip_definition_id IS NULL
            AND selected_destination_trip_occurrence_id IS NULL)
        )
      );
      CREATE TRIGGER execution_trace_events_reject_update
      BEFORE UPDATE ON execution_trace_events
      BEGIN
        SELECT RAISE(ABORT, 'execution_trace_events is append-only');
      END;
      CREATE TRIGGER execution_trace_events_reject_delete
      BEFORE DELETE ON execution_trace_events
      BEGIN
        SELECT RAISE(ABORT, 'execution_trace_events is append-only');
      END;
      INSERT INTO schedule_definitions (id, name)
        VALUES (800, 'preserved_schedule');
      INSERT INTO trip_definitions (id, name)
        VALUES (801, 'preserved_trip');
      INSERT INTO step_definitions (id, name, type)
        VALUES (8101, 'preserved_tell', 'tell');
      INSERT INTO tell_step_definitions (step_definition_id, text)
        VALUES (8101, 'Preserved Tell');
      INSERT INTO trip_step_occurrences
        (id, trip_definition_id, step_definition_id, position)
        VALUES (8201, 801, 8101, 0);
      INSERT INTO schedule_trip_occurrences
        (id, schedule_definition_id, trip_definition_id, position)
        VALUES (8301, 800, 801, 0);
      INSERT INTO schedule_runs
        (id, schedule_definition_id, current_trip_occurrence_id)
        VALUES (8401, 800, 8301);
      INSERT INTO execution_trace_events (
        id,
        schedule_run_id,
        sequence,
        event_type,
        occurred_at_utc_us
      ) VALUES (8501, 8401, 1, 'schedule_run_started', 1);
      PRAGMA user_version = 8;
    ''');
  } finally {
    database.dispose();
  }
}
