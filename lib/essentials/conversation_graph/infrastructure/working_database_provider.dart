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
      version: 9,
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
        if (oldVersion < 5) {
          await _createContactSchema(db);
          await _createContactToHandleSchema(db);
        }
        if (oldVersion < 6) {
          await db.execute('DROP TABLE IF EXISTS contact_to_handle');
          await db.execute('DROP TABLE IF EXISTS contacts');
          await _createContactSchema(db);
          await _createContactToHandleSchema(db);
        }
        if (oldVersion < 7) {
          await _createHandleAliasSchema(db);
        }
        if (oldVersion < 8) {
          await _addMessageSemanticColumns(db);
        }
        if (oldVersion < 9) {
          await _createAttachmentSchema(db);
          await _createMessageToAttachmentSchema(db);
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
        associated_message_ss_id INTEGER,
        sender_canonical_handle_ss_id INTEGER,
        semantic_kind TEXT,
        item_kind TEXT,
        is_system_message INTEGER NOT NULL DEFAULT 0 CHECK (is_system_message IN (0, 1)),
        is_sparse_artifact INTEGER NOT NULL DEFAULT 0 CHECK (is_sparse_artifact IN (0, 1)),
        has_attributed_body_source INTEGER NOT NULL DEFAULT 0 CHECK (has_attributed_body_source IN (0, 1)),
        has_message_summary_info INTEGER NOT NULL DEFAULT 0 CHECK (has_message_summary_info IN (0, 1)),
        has_payload_data_source INTEGER NOT NULL DEFAULT 0 CHECK (has_payload_data_source IN (0, 1)),
        error_code INTEGER
      )
    ''');
    await _createHandleSchema(db);
    await _createHandleAliasSchema(db);
    await _createChatSchema(db);
    await _createChatToMessageSchema(db);
    await _createChatToHandleSchema(db);
    await _createContactSchema(db);
    await _createContactToHandleSchema(db);
    await _createAttachmentSchema(db);
    await _createMessageToAttachmentSchema(db);
  }

  static Future<void> _addMessageSemanticColumns(Database db) async {
    await _addColumnIfMissing(
      db,
      'messages',
      'sender_canonical_handle_ss_id INTEGER',
    );
    await _addColumnIfMissing(db, 'messages', 'semantic_kind TEXT');
    await _addColumnIfMissing(db, 'messages', 'item_kind TEXT');
    await _addColumnIfMissing(
      db,
      'messages',
      'is_system_message INTEGER NOT NULL DEFAULT 0 '
          'CHECK (is_system_message IN (0, 1))',
    );
    await _addColumnIfMissing(
      db,
      'messages',
      'is_sparse_artifact INTEGER NOT NULL DEFAULT 0 '
          'CHECK (is_sparse_artifact IN (0, 1))',
    );
    await _addColumnIfMissing(
      db,
      'messages',
      'has_attributed_body_source INTEGER NOT NULL DEFAULT 0 '
          'CHECK (has_attributed_body_source IN (0, 1))',
    );
    await _addColumnIfMissing(
      db,
      'messages',
      'has_message_summary_info INTEGER NOT NULL DEFAULT 0 '
          'CHECK (has_message_summary_info IN (0, 1))',
    );
    await _addColumnIfMissing(
      db,
      'messages',
      'has_payload_data_source INTEGER NOT NULL DEFAULT 0 '
          'CHECK (has_payload_data_source IN (0, 1))',
    );
    await _addColumnIfMissing(db, 'messages', 'error_code INTEGER');
  }

  static Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String columnDefinition,
  ) async {
    final columnName = columnDefinition.split(' ').first;
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final columnNames = columns.map((row) => row['name']).toSet();
    if (columnNames.contains(columnName)) {
      return;
    }
    await db.execute('ALTER TABLE $table ADD COLUMN $columnDefinition');
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

  static Future<void> _createHandleAliasSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS canonical_handles (
        canonical_handle_ss_id INTEGER PRIMARY KEY,
        display_handle TEXT NOT NULL,
        normalized_identifier TEXT NOT NULL,
        service TEXT,
        alias_count INTEGER NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_canonical_handles_normalized '
      'ON canonical_handles(normalized_identifier)',
    );
    await db.execute('''
      CREATE TABLE IF NOT EXISTS handle_aliases (
        handle_ss_id INTEGER PRIMARY KEY,
        canonical_handle_ss_id INTEGER NOT NULL,
        raw_identifier TEXT NOT NULL,
        normalized_identifier TEXT NOT NULL,
        alias_kind TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_handle_aliases_canonical '
      'ON handle_aliases(canonical_handle_ss_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_handle_aliases_normalized '
      'ON handle_aliases(normalized_identifier)',
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

  static Future<void> _createContactSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS contacts (
        contact_id INTEGER PRIMARY KEY,
        display_name TEXT NOT NULL,
        short_name TEXT,
        given_name TEXT,
        family_name TEXT,
        organization TEXT
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_working_contacts_display_name '
      'ON contacts(display_name)',
    );
  }

  static Future<void> _createContactToHandleSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS contact_to_handle (
        contact_id INTEGER NOT NULL,
        handle_ss_id INTEGER NOT NULL,
        handle_value TEXT NOT NULL,
        UNIQUE(contact_id, handle_ss_id)
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_contact_to_handle_handle '
      'ON contact_to_handle(handle_ss_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_contact_to_handle_contact '
      'ON contact_to_handle(contact_id)',
    );
  }

  static Future<void> _createAttachmentSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS attachments (
        ss_id INTEGER PRIMARY KEY,
        guid TEXT,
        filename TEXT,
        transfer_name TEXT,
        uti TEXT,
        mime_type TEXT,
        total_bytes INTEGER,
        created_at_utc TEXT
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_working_attachments_guid '
      'ON attachments(guid)',
    );
  }

  static Future<void> _createMessageToAttachmentSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS message_to_attachment (
        message_ss_id INTEGER NOT NULL,
        attachment_ss_id INTEGER NOT NULL,
        UNIQUE(message_ss_id, attachment_ss_id)
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_working_message_to_attachment_message '
      'ON message_to_attachment(message_ss_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_working_message_to_attachment_attachment '
      'ON message_to_attachment(attachment_ss_id)',
    );
  }
}
