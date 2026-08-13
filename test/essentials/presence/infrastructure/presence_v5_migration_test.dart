import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/step.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/data_sources/local/presence_database.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/repositories/drift_presence_schedule_repository.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

void main() {
  test('v4 to v8 preserves definitions, active run, and trace', () async {
    final directory = await Directory.systemTemp.createTemp(
      'presence_v5_migration_',
    );
    final path = '${directory.path}/presence.db';
    _createVersionFourDatabase(path);

    final database = PresenceDatabase(NativeDatabase(File(path)));
    try {
      await database.customSelect('SELECT 1').get();
      final version = await database
          .customSelect('PRAGMA user_version')
          .getSingle();
      final openSettingsSubtypeTable = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND "
            "name = 'open_fda_settings_step_definitions'",
          )
          .getSingleOrNull();
      final contactsSubtypeTable = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND "
            "name = 'contacts_source_readiness_step_definitions'",
          )
          .getSingleOrNull();
      final repository = DriftPresenceScheduleRepository(database: database);
      final definition = await repository.loadDefinition(90);
      final run = await repository.loadRun(1);
      final trace = await repository.loadExecutionTrace(1);

      expect(version.read<int>('user_version'), 8);
      expect(
        openSettingsSubtypeTable?.read<String>('name'),
        'open_fda_settings_step_definitions',
      );
      expect(
        contactsSubtypeTable?.read<String>('name'),
        'contacts_source_readiness_step_definitions',
      );
      expect(definition.trips.single.trip.steps.single, isA<TellStep>());
      expect(run.currentTripOccurrenceId, 9001);
      expect(trace, hasLength(1));
      expect(trace.single.sequence, 1);
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });
}

void _createVersionFourDatabase(String path) {
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
        VALUES (90, 'preserved_schedule');
      INSERT INTO trip_definitions (id, name)
        VALUES (90, 'preserved_trip');
      INSERT INTO step_definitions (id, name, type)
        VALUES (9001, 'preserved_tell', 'tell');
      INSERT INTO tell_step_definitions (step_definition_id, text)
        VALUES (9001, 'Preserved Tell');
      INSERT INTO trip_step_occurrences
        (id, trip_definition_id, step_definition_id, position)
        VALUES (9001, 90, 9001, 0);
      INSERT INTO schedule_trip_occurrences
        (id, schedule_definition_id, trip_definition_id, position)
        VALUES (9001, 90, 90, 0);
      INSERT INTO schedule_runs
        (id, schedule_definition_id, current_trip_occurrence_id)
        VALUES (1, 90, 9001);
      INSERT INTO execution_trace_events (
        id,
        schedule_run_id,
        sequence,
        event_type,
        occurred_at_utc_us
      ) VALUES (1, 1, 1, 'schedule_run_started', 1);
      PRAGMA user_version = 4;
    ''');
  } finally {
    database.dispose();
  }
}
