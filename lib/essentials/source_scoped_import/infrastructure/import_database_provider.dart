import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../../db/feature_level_providers.dart';
import '../domain/known_sources.dart';

part 'import_database_provider.g.dart';

const String importDatabaseFileName = 'macos_import_ss.db';

@Riverpod(keepAlive: true)
Future<ImportDatabase> importDatabase(ImportDatabaseRef ref) async {
  final directory = Directory(databaseDirectoryPath);
  if (!directory.existsSync()) {
    await directory.create(recursive: true);
  }

  final database = await ImportDatabase.open(
    databaseDirectory: databaseDirectoryPath,
    databaseName: importDatabaseFileName,
  );

  ref.onDispose(() async {
    await database.close();
  });

  return database;
}

class ImportDatabase {
  ImportDatabase._(this.database);

  final Database database;

  static Future<ImportDatabase> open({
    required String databaseDirectory,
    String databaseName = importDatabaseFileName,
  }) async {
    final directory = Directory(databaseDirectory);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }

    final db = await openDatabase(
      path.join(databaseDirectory, databaseName),
      version: 5,
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
          await db.execute('DROP TABLE IF EXISTS chats');
          await _createChatSchema(db);
        }
        if (oldVersion < 5) {
          await _createHandleSchema(db);
          await _createChatToHandleSchema(db);
        }
      },
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );

    await _ensureLiveSource(db);
    return ImportDatabase._(db);
  }

  Future<void> close() async {
    await database.close();
  }

  Future<int> insertImportBatch({
    required int sourceId,
    required String startedAtUtc,
  }) async {
    return database.insert('import_batches', <String, Object?>{
      'source_id': sourceId,
      'started_at_utc': startedAtUtc,
    });
  }

  Future<int?> maxMessageSourceRowIdForSource(int sourceId) async {
    final rows = await database.rawQuery(
      'SELECT MAX(source_rowid) AS max_source_rowid '
      'FROM messages WHERE source_id = ?',
      <Object?>[sourceId],
    );
    return rows.single['max_source_rowid'] as int?;
  }

  Future<int?> maxHandleSourceRowIdForSource(int sourceId) async {
    final rows = await database.rawQuery(
      'SELECT MAX(source_rowid) AS max_source_rowid '
      'FROM handles WHERE source_id = ?',
      <Object?>[sourceId],
    );
    return rows.single['max_source_rowid'] as int?;
  }

  static Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE source_registry (
        source_id INTEGER PRIMARY KEY,
        source_key TEXT NOT NULL UNIQUE,
        source_kind TEXT NOT NULL,
        source_label TEXT,
        created_at_utc TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE import_batches (
        batch_id INTEGER PRIMARY KEY AUTOINCREMENT,
        source_id INTEGER NOT NULL,
        started_at_utc TEXT NOT NULL,
        finished_at_utc TEXT,
        notes TEXT,
        FOREIGN KEY (source_id) REFERENCES source_registry(source_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        ss_id INTEGER PRIMARY KEY,
        source_id INTEGER NOT NULL,
        source_rowid INTEGER NOT NULL,
        guid TEXT NOT NULL,
        sender_handle_ss_id INTEGER,
        is_from_me INTEGER NOT NULL CHECK (is_from_me IN (0, 1)),
        date_utc TEXT,
        date_read_utc TEXT,
        date_delivered_utc TEXT,
        text TEXT,
        attributed_body_blob BLOB,
        associated_message_guid TEXT,
        batch_id INTEGER NOT NULL,
        UNIQUE(source_id, source_rowid),
        FOREIGN KEY (source_id) REFERENCES source_registry(source_id),
        FOREIGN KEY (batch_id) REFERENCES import_batches(batch_id)
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_messages_source_cursor '
      'ON messages(source_id, source_rowid)',
    );
    await db.execute('CREATE INDEX idx_messages_guid ON messages(guid)');
    await _createHandleSchema(db);
    await _createChatSchema(db);
    await _createChatToMessageSchema(db);
    await _createChatToHandleSchema(db);
  }

  static Future<void> _createHandleSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS handles (
        ss_id INTEGER PRIMARY KEY,
        source_id INTEGER NOT NULL,
        source_rowid INTEGER NOT NULL,
        id TEXT NOT NULL,
        service TEXT,
        batch_id INTEGER NOT NULL,
        UNIQUE(source_id, source_rowid),
        FOREIGN KEY (source_id) REFERENCES source_registry(source_id),
        FOREIGN KEY (batch_id) REFERENCES import_batches(batch_id)
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_handles_source_cursor '
      'ON handles(source_id, source_rowid)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_handles_id ON handles(id)',
    );
  }

  static Future<void> _createChatSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chats (
        ss_id INTEGER PRIMARY KEY,
        source_id INTEGER NOT NULL,
        source_rowid INTEGER NOT NULL,
        guid TEXT NOT NULL,
        service TEXT,
        group_id TEXT,
        original_group_id TEXT,
        last_read_message_at_utc TEXT,
        batch_id INTEGER NOT NULL,
        UNIQUE(source_id, source_rowid),
        FOREIGN KEY (source_id) REFERENCES source_registry(source_id),
        FOREIGN KEY (batch_id) REFERENCES import_batches(batch_id)
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_chats_source_cursor '
      'ON chats(source_id, source_rowid)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_chats_guid ON chats(guid)',
    );
  }

  static Future<void> _createChatToMessageSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chat_to_message (
        ss_id INTEGER PRIMARY KEY,
        source_id INTEGER NOT NULL,
        source_rowid INTEGER NOT NULL,
        source_chat_rowid INTEGER NOT NULL,
        source_message_rowid INTEGER NOT NULL,
        chat_ss_id INTEGER NOT NULL,
        message_ss_id INTEGER NOT NULL,
        UNIQUE(source_id, source_rowid)
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_chat_to_message_chat '
      'ON chat_to_message(chat_ss_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_chat_to_message_message '
      'ON chat_to_message(message_ss_id)',
    );
  }

  static Future<void> _createChatToHandleSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chat_to_handle (
        source_id INTEGER NOT NULL,
        source_chat_rowid INTEGER NOT NULL,
        source_handle_rowid INTEGER NOT NULL,
        chat_ss_id INTEGER NOT NULL,
        handle_ss_id INTEGER NOT NULL,
        batch_id INTEGER NOT NULL,
        UNIQUE(source_id, source_chat_rowid, source_handle_rowid),
        FOREIGN KEY (source_id) REFERENCES source_registry(source_id),
        FOREIGN KEY (batch_id) REFERENCES import_batches(batch_id)
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_chat_to_handle_chat '
      'ON chat_to_handle(chat_ss_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_chat_to_handle_handle '
      'ON chat_to_handle(handle_ss_id)',
    );
  }

  static Future<void> _ensureLiveSource(Database db) async {
    await db.insert('source_registry', <String, Object?>{
      'source_id': liveChatDbSourceId,
      'source_key': liveChatDbSourceKey,
      'source_kind': liveChatDbSourceKind,
      'source_label': 'Live chat.db',
      'created_at_utc': DateTime.now().toUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }
}
