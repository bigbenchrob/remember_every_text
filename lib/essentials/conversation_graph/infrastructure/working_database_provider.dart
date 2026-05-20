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
      version: 4,
      onCreate: (db, version) async {
        await _createSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createChatSchema(db);
          await _createChatToMessageSchema(db);
        }
        if (oldVersion < 3) {
          await db.execute('DROP TABLE IF EXISTS chats');
          await _createChatSchema(db);
        }
        if (oldVersion < 4) {
          await _createHandleSchema(db);
          await _createChatToHandleSchema(db);
        }
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
    await _createHandleSchema(db);
    await _createChatSchema(db);
    await _createChatToMessageSchema(db);
    await _createChatToHandleSchema(db);
  }

  static Future<void> _createHandleSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS handles (
        ss_id INTEGER PRIMARY KEY,
        id TEXT NOT NULL,
        service TEXT
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_working_handles_id ON handles(id)',
    );
  }

  static Future<void> _createChatSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chats (
        ss_id INTEGER PRIMARY KEY,
        guid TEXT,
        service TEXT,
        is_group INTEGER NOT NULL CHECK (is_group IN (0, 1)),
        last_read_message_at_utc TEXT
      )
    ''');
  }

  static Future<void> _createChatToMessageSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chat_to_message (
        chat_ss_id INTEGER NOT NULL,
        message_ss_id INTEGER NOT NULL,
        PRIMARY KEY (chat_ss_id, message_ss_id)
      )
    ''');
  }

  static Future<void> _createChatToHandleSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chat_to_handle (
        chat_ss_id INTEGER NOT NULL,
        handle_ss_id INTEGER NOT NULL,
        UNIQUE(chat_ss_id, handle_ss_id)
      )
    ''');
  }
}
