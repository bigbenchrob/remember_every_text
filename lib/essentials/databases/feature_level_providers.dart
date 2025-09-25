///***************************************************************** */
///* The entry point for dependency injection for the feature.
///***************************************************************** */

import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../import/application/debug_settings_provider.dart';
import 'infrastructure/data_sources/local/import/import_db.dart';
import 'infrastructure/data_sources/local/working/drift_db.dart';

part 'feature_level_providers.g.dart';

/// Provider for the working database that creates the actual instance
@Riverpod(keepAlive: true)
Future<DriftDb> workingDatabase(WorkingDatabaseRef ref) async {
  // Use the same directory as the import database
  const databaseDirectory = '/Users/rob/sqlite_rmc/messages/';
  final dbPath = path.join(databaseDirectory, 'working.db');

  // Ensure the database directory exists
  final dataDir = Directory(databaseDirectory);
  if (!dataDir.existsSync()) {
    await dataDir.create(recursive: true);
  }

  final database = DriftDb(NativeDatabase.createInBackground(File(dbPath)));

  // Ensure database is initialized
  await database.doWhenOpened((e) => null);

  // Properly dispose of database connection when provider is disposed
  ref.onDispose(() async {
    await database.close();
  });

  return database;
}

/// Provider for the import database - single source of truth for database name
@Riverpod(keepAlive: true)
ImportDatabase importDatabase(ImportDatabaseRef ref) {
  // Single source of truth for the import database name
  const importDatabaseName = 'macos_import.db';
  final database = ImportDatabase(
    databaseName: importDatabaseName,
    debugSettings: ref.watch(importDebugSettingsProvider),
  );

  // Properly dispose of database connection when provider is disposed
  ref.onDispose(() async {
    await database.close();
  });

  return database;
}

/// Provider that checks if databases are ready
@Riverpod(keepAlive: true)
Future<DatabaseReadiness> databaseReadiness(DatabaseReadinessRef ref) async {
  try {
    final workingDb = await ref.watch(workingDatabaseProvider.future);
    final importDb = ref.watch(importDatabaseProvider);

    // Check if import database has data
    final importDbInstance = await importDb.database;
    final importMessages = await importDbInstance.query(
      'import_messages',
      limit: 1,
    );
    final hasImportData = importMessages.isNotEmpty;

    // Check if working database has data
    final workingMessageCount = await workingDb.managers.messages.count();
    final hasWorkingData = workingMessageCount > 0;

    return DatabaseReadiness(
      workingDbReady: true,
      importDbReady: true,
      hasImportData: hasImportData,
      hasWorkingData: hasWorkingData,
    );
  } catch (e) {
    print('Error checking database readiness: $e');
    return DatabaseReadiness(
      workingDbReady: false,
      importDbReady: false,
      hasImportData: false,
      hasWorkingData: false,
      error: e.toString(),
    );
  }
}

/// Status of database readiness
class DatabaseReadiness {
  final bool workingDbReady;
  final bool importDbReady;
  final bool hasImportData;
  final bool hasWorkingData;
  final String? error;

  DatabaseReadiness({
    required this.workingDbReady,
    required this.importDbReady,
    required this.hasImportData,
    required this.hasWorkingData,
    this.error,
  });

  bool get allReady => workingDbReady && importDbReady;
  bool get needsMigration => hasImportData && !hasWorkingData;
  bool get isComplete => hasWorkingData;

  @override
  String toString() {
    if (error != null) {
      return 'Database Error: $error';
    }
    return 'Working: $workingDbReady, Import: $importDbReady, Import Data: $hasImportData, Working Data: $hasWorkingData';
  }
}
