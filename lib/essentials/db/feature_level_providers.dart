///***************************************************************** */
///* The entry point for dependency injection for the database layer.
///***************************************************************** */

import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db_import/application/debug_settings_provider.dart';

import 'infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'infrastructure/data_sources/local/working/working_database.dart';

part 'feature_level_providers.g.dart';

const _databaseDirectoryPath = '/Users/rob/sqlite_rmc/remember_every_text/';

Future<void> _ensureDatabaseDirectoryExists() async {
  final directory = Directory(_databaseDirectoryPath);
  if (!directory.existsSync()) {
    await directory.create(recursive: true);
  }
}

/// Provides access to the Sqflite-powered import ledger database.
@Riverpod(keepAlive: true)
Future<SqfliteImportDatabase> sqfliteImportDatabase(
  SqfliteImportDatabaseRef ref,
) async {
  await _ensureDatabaseDirectoryExists();
  final database = SqfliteImportDatabase(
    databaseDirectory: _databaseDirectoryPath,
    databaseName: 'macos_import.db',
    debugSettings: ref.watch(importDebugSettingsProvider),
  );

  // Ensure the database file is created immediately so dependent services can query schema metadata.
  await database.database;

  ref.onDispose(() async {
    await database.close();
  });

  return database;
}

/// Provides access to the Drift projection database used by the UI.
@Riverpod(keepAlive: true)
Future<WorkingDatabase> driftWorkingDatabase(
  DriftWorkingDatabaseRef ref,
) async {
  await _ensureDatabaseDirectoryExists();
  final dbPath = path.join(_databaseDirectoryPath, 'working.db');

  final database = WorkingDatabase(
    NativeDatabase.createInBackground(File(dbPath)),
  );

  await database.doWhenOpened((_) async {
    await database.customStatement('PRAGMA foreign_keys = ON');
  });

  ref.onDispose(() async {
    await database.close();
  });

  return database;
}
