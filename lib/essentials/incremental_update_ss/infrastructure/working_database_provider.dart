import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../../db/feature_level_providers.dart';

part 'working_database_provider.g.dart';

const String workingDatabaseFileName = 'working_ss.db';

@Riverpod(keepAlive: true)
Future<WorkingDatabase> workingDatabase(WorkingDatabaseRef ref) async {
  final directory = Directory(databaseDirectoryPath);
  if (!directory.existsSync()) {
    await directory.create(recursive: true);
  }

  final database = await WorkingDatabase.open(
    databaseDirectory: databaseDirectoryPath,
    databaseName: workingDatabaseFileName,
  );

  ref.onDispose(() async {
    await database.close();
  });

  return database;
}

class WorkingDatabase {
  WorkingDatabase._(this.database);

  final Database database;

  static Future<WorkingDatabase> open({
    required String databaseDirectory,
    String databaseName = workingDatabaseFileName,
  }) async {
    final directory = Directory(databaseDirectory);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }

    final db = await openDatabase(
      path.join(databaseDirectory, databaseName),
      version: 1,
      onCreate: (db, version) async {
        await _createSchema(db);
      },
    );

    return WorkingDatabase._(db);
  }

  Future<void> close() async {
    await database.close();
  }

  static Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE messages (
        ss_id INTEGER PRIMARY KEY,
        guid TEXT,
        sender_handle_ss_id INTEGER,
        is_from_me INTEGER NOT NULL CHECK (is_from_me IN (0, 1)),
        date_utc TEXT,
        text TEXT,
        associated_message_ss_id INTEGER
      )
    ''');
  }
}
