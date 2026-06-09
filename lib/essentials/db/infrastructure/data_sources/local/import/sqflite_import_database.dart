// ignore_for_file: prefer_single_quotes

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../../../../db_importers/application/debug_settings_provider.dart';

final class HistoricalArchiveSourceRecord {
  const HistoricalArchiveSourceRecord({
    required this.sourceChatDb,
    required this.folderPath,
    required this.sourceLabel,
    required this.chatDbStatusLabel,
    required this.attachmentsStatusLabel,
    required this.preflightStatusLabel,
    required this.preflightDetail,
    required this.updatedAtUtc,
    this.totalMessages,
    this.totalChats,
    this.totalHandles,
    this.missingGuids,
    this.earliestMessageUtc,
    this.latestMessageUtc,
    this.dryRunNewMessages,
    this.dryRunDuplicateMessages,
    this.lastImportFinishedAtUtc,
    this.lastImportSuccess,
    this.lastImportError,
    this.lastImportedMessageCount,
  });

  final String sourceChatDb;
  final String folderPath;
  final String sourceLabel;
  final String chatDbStatusLabel;
  final String attachmentsStatusLabel;
  final String preflightStatusLabel;
  final String preflightDetail;
  final int? totalMessages;
  final int? totalChats;
  final int? totalHandles;
  final int? missingGuids;
  final String? earliestMessageUtc;
  final String? latestMessageUtc;
  final int? dryRunNewMessages;
  final int? dryRunDuplicateMessages;
  final String? lastImportFinishedAtUtc;
  final bool? lastImportSuccess;
  final String? lastImportError;
  final int? lastImportedMessageCount;
  final String updatedAtUtc;
}

class SqfliteImportDatabase {
  SqfliteImportDatabase({
    required String databaseDirectory,
    required String databaseName,
    required ImportDebugSettingsState debugSettings,
  }) : _databaseDirectory = databaseDirectory,
       _databaseName = databaseName,
       _debugSettings = debugSettings;

  static const int _schemaVersion = 10;

  final String _databaseDirectory;
  final String _databaseName;
  final ImportDebugSettingsState _debugSettings;

  Database? _database;

  String get _dbPath => p.join(_databaseDirectory, _databaseName);

  Future<Database> get database async {
    final dbPath = _dbPath;

    if (_database != null) {
      final fileExists = File(dbPath).existsSync();
      if (!fileExists) {
        _debugSettings.logDatabase(
          'SqfliteImportDatabase.database: detected missing database file at $dbPath, reopening',
        );
        await _database!.close();
        _database = null;
      } else {
        _debugSettings.logDatabase(
          'SqfliteImportDatabase.database: returning existing instance for $_databaseName',
        );
        return _database!;
      }
    }

    _debugSettings.logDatabase(
      'SqfliteImportDatabase.database: opening database $_databaseName at $dbPath',
    );
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final directory = Directory(_databaseDirectory);
    if (!directory.existsSync()) {
      _debugSettings.logDatabase(
        'SqfliteImportDatabase._openDatabase: creating directory $_databaseDirectory',
      );
      await directory.create(recursive: true);
    }

    final dbPath = _dbPath;

    return openDatabase(
      dbPath,
      version: _schemaVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    _debugSettings.logDatabase(
      'SqfliteImportDatabase._onCreate: creating schema version $version',
    );

    try {
      final batch = db.batch();

      _debugSettings.logDatabase(
        'SqfliteImportDatabase._onCreate: adding ${_schemaStatements.length} schema statements',
      );
      _schemaStatements.forEach(batch.execute);

      if (_indexStatements.isNotEmpty) {
        _debugSettings.logDatabase(
          'SqfliteImportDatabase._onCreate: adding ${_indexStatements.length} index statements',
        );
        _indexStatements.forEach(batch.execute);
      }

      _debugSettings.logDatabase(
        'SqfliteImportDatabase._onCreate: committing batch',
      );
      await batch.commit(noResult: true);

      _debugSettings.logDatabase(
        'SqfliteImportDatabase._onCreate: inserting schema migration record',
      );
      await db.insert('schema_migrations', <String, Object?>{
        'version': version,
        'applied_at_utc': DateTime.now().toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      _debugSettings.logDatabase(
        'SqfliteImportDatabase._onCreate: schema creation completed successfully',
      );
    } catch (e, stackTrace) {
      _debugSettings.logDatabase(
        'SqfliteImportDatabase._onCreate: ERROR creating schema: $e',
      );
      _debugSettings.logDatabase(
        'SqfliteImportDatabase._onCreate: Stack trace: $stackTrace',
      );
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final batch = db.batch();
      _v2SchemaStatements.forEach(batch.execute);
      _v2IndexStatements.forEach(batch.execute);
      await batch.commit(noResult: true);

      await db.insert('schema_migrations', <String, Object?>{
        'version': 2,
        'applied_at_utc': DateTime.now().toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    if (oldVersion < 3) {
      final batch = db.batch();
      _v3SchemaStatements.forEach(batch.execute);
      await batch.commit(noResult: true);

      await db.insert('schema_migrations', <String, Object?>{
        'version': 3,
        'applied_at_utc': DateTime.now().toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    if (oldVersion < 4) {
      await _upgradeHandlesTableToPreserveSourceRows(db);

      await db.insert('schema_migrations', <String, Object?>{
        'version': 4,
        'applied_at_utc': DateTime.now().toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    if (oldVersion < 5) {
      final batch = db.batch();
      _v5SchemaStatements.forEach(batch.execute);
      await batch.commit(noResult: true);

      await db.insert('schema_migrations', <String, Object?>{
        'version': 5,
        'applied_at_utc': DateTime.now().toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    if (oldVersion < 6) {
      final batch = db.batch();
      _v6SchemaStatements.forEach(batch.execute);
      await batch.commit(noResult: true);

      await db.insert('schema_migrations', <String, Object?>{
        'version': 6,
        'applied_at_utc': DateTime.now().toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    if (oldVersion < 7) {
      final batch = db.batch();
      _v7SchemaStatements.forEach(batch.execute);
      await batch.commit(noResult: true);

      await db.insert('schema_migrations', <String, Object?>{
        'version': 7,
        'applied_at_utc': DateTime.now().toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    if (oldVersion < 8) {
      await _addColumnIfMissing(
        db,
        table: 'handles',
        column: 'source_id',
        columnDefinition: 'TEXT',
      );
      await _addColumnIfMissing(
        db,
        table: 'handles',
        column: 'source_kind',
        columnDefinition: 'TEXT',
      );

      await db.insert('schema_migrations', <String, Object?>{
        'version': 8,
        'applied_at_utc': DateTime.now().toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    if (oldVersion < 9) {
      await _addColumnIfMissing(
        db,
        table: 'chats',
        column: 'source_id',
        columnDefinition: 'TEXT',
      );
      await _addColumnIfMissing(
        db,
        table: 'chats',
        column: 'source_kind',
        columnDefinition: 'TEXT',
      );

      await db.insert('schema_migrations', <String, Object?>{
        'version': 9,
        'applied_at_utc': DateTime.now().toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    if (oldVersion < 10) {
      final batch = db.batch();
      batch.execute(_chatMessageJoinsTableStatement);
      batch.execute(_chatMessageJoinsSourceIndexStatement);
      batch.execute(_chatMessageJoinsMessageIndexStatement);
      batch.execute(_chatMessageJoinsChatIndexStatement);
      await batch.commit(noResult: true);

      await db.insert('schema_migrations', <String, Object?>{
        'version': 10,
        'applied_at_utc': DateTime.now().toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> _addColumnIfMissing(
    Database db, {
    required String table,
    required String column,
    required String columnDefinition,
  }) async {
    final tableInfo = await db.rawQuery('PRAGMA table_info($table)');
    if (tableInfo.isEmpty) {
      return;
    }

    final hasColumn = tableInfo.any((row) => row['name'] == column);
    if (hasColumn) {
      return;
    }

    await db.execute('ALTER TABLE $table ADD COLUMN $column $columnDefinition');
  }

  Future<void> _upgradeHandlesTableToPreserveSourceRows(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('PRAGMA foreign_keys = OFF');
      await txn.execute('DROP INDEX IF EXISTS idx_handles_compound');
      await txn.execute('DROP INDEX IF EXISTS idx_handles_norm');
      await txn.execute('DROP INDEX IF EXISTS idx_handles_ignore');
      await txn.execute('ALTER TABLE handles RENAME TO handles_old');
      await txn.execute(_handlesTableStatementWithoutUniqueness);
      await txn.execute('''
INSERT INTO handles (
  id,
  source_rowid,
  service,
  raw_identifier,
  normalized_identifier,
  compound_identifier,
  country,
  last_seen_utc,
  is_ignored,
  batch_id
)
SELECT
  id,
  source_rowid,
  service,
  raw_identifier,
  normalized_identifier,
  compound_identifier,
  country,
  last_seen_utc,
  is_ignored,
  batch_id
FROM handles_old
''');
      await txn.execute('DROP TABLE handles_old');
      await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_handles_compound ON handles(compound_identifier)',
      );
      await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_handles_norm ON handles(normalized_identifier)',
      );
      await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_handles_ignore ON handles(is_ignored)',
      );
      await txn.execute('PRAGMA foreign_keys = ON');
    });
  }

  Future<void> close() async {
    if (_database != null) {
      _debugSettings.logDatabase(
        'SqfliteImportDatabase.close: closing database',
      );
      await _database!.close();
      _database = null;
    }
  }

  Future<void> upsertHistoricalArchiveSource({
    required String sourceChatDb,
    required String folderPath,
    required String sourceLabel,
    required String chatDbStatusLabel,
    required String attachmentsStatusLabel,
    required String preflightStatusLabel,
    required String preflightDetail,
    required String updatedAtUtc,
    int? totalMessages,
    int? totalChats,
    int? totalHandles,
    int? missingGuids,
    String? earliestMessageUtc,
    String? latestMessageUtc,
    int? dryRunNewMessages,
    int? dryRunDuplicateMessages,
    String? lastImportFinishedAtUtc,
    bool? lastImportSuccess,
    String? lastImportError,
    int? lastImportedMessageCount,
  }) async {
    final db = await database;
    final data = _cleanMap(<String, Object?>{
      'source_chat_db': sourceChatDb,
      'folder_path': folderPath,
      'source_label': sourceLabel,
      'chat_db_status_label': chatDbStatusLabel,
      'attachments_status_label': attachmentsStatusLabel,
      'preflight_status_label': preflightStatusLabel,
      'preflight_detail': preflightDetail,
      'total_messages': totalMessages,
      'total_chats': totalChats,
      'total_handles': totalHandles,
      'missing_guids': missingGuids,
      'earliest_message_utc': earliestMessageUtc,
      'latest_message_utc': latestMessageUtc,
      'dry_run_new_messages': dryRunNewMessages,
      'dry_run_duplicate_messages': dryRunDuplicateMessages,
      'last_import_finished_at_utc': lastImportFinishedAtUtc,
      'last_import_success': _boolToNullableInt(value: lastImportSuccess),
      'last_import_error': lastImportError,
      'last_imported_message_count': lastImportedMessageCount,
      'updated_at_utc': updatedAtUtc,
    });

    await db.insert(
      'historical_archive_sources',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HistoricalArchiveSourceRecord>>
  listHistoricalArchiveSources() async {
    final db = await database;
    final rows = await db.query(
      'historical_archive_sources',
      orderBy: 'updated_at_utc DESC, source_label COLLATE NOCASE ASC',
    );

    return <HistoricalArchiveSourceRecord>[
      for (final row in rows)
        HistoricalArchiveSourceRecord(
          sourceChatDb: _readRequiredString(row, 'source_chat_db'),
          folderPath: _readRequiredString(row, 'folder_path'),
          sourceLabel: _readRequiredString(row, 'source_label'),
          chatDbStatusLabel: _readRequiredString(row, 'chat_db_status_label'),
          attachmentsStatusLabel: _readRequiredString(
            row,
            'attachments_status_label',
          ),
          preflightStatusLabel: _readRequiredString(
            row,
            'preflight_status_label',
          ),
          preflightDetail: _readRequiredString(row, 'preflight_detail'),
          totalMessages: _asNullableInt(row['total_messages']),
          totalChats: _asNullableInt(row['total_chats']),
          totalHandles: _asNullableInt(row['total_handles']),
          missingGuids: _asNullableInt(row['missing_guids']),
          earliestMessageUtc: row['earliest_message_utc'] as String?,
          latestMessageUtc: row['latest_message_utc'] as String?,
          dryRunNewMessages: _asNullableInt(row['dry_run_new_messages']),
          dryRunDuplicateMessages: _asNullableInt(
            row['dry_run_duplicate_messages'],
          ),
          lastImportFinishedAtUtc:
              row['last_import_finished_at_utc'] as String?,
          lastImportSuccess: _asNullableBool(row['last_import_success']),
          lastImportError: row['last_import_error'] as String?,
          lastImportedMessageCount: _asNullableInt(
            row['last_imported_message_count'],
          ),
          updatedAtUtc: _readRequiredString(row, 'updated_at_utc'),
        ),
    ];
  }

  Map<String, Object?> _cleanMap(Map<String, Object?> data) {
    final result = <String, Object?>{};
    data.forEach((key, value) {
      if (value != null) {
        result[key] = value;
      }
    });
    return result;
  }

  int? _boolToNullableInt({required bool? value}) =>
      value == null ? null : (value ? 1 : 0);

  int? _asNullableInt(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value');
  }

  String _readRequiredString(Map<String, Object?> row, String key) {
    final value = _readNullableString(row, key);
    if (value == null) {
      throw StateError('Missing required string column $key');
    }
    return value;
  }

  String? _readNullableString(Map<String, Object?> row, String key) {
    return row[key] as String?;
  }

  bool? _asNullableBool(Object? value) {
    final intValue = _asNullableInt(value);
    if (intValue == null) {
      return null;
    }
    if (intValue == 1) {
      return true;
    }
    if (intValue == 0) {
      return false;
    }
    return null;
  }

  static const List<String> _schemaStatements = <String>[
    'CREATE TABLE IF NOT EXISTS schema_migrations (version INTEGER PRIMARY KEY, applied_at_utc TEXT NOT NULL)',
    _historicalArchiveSourcesTableStatement,
  ];

  static const List<String> _indexStatements = <String>[];

  static const List<String> _v2SchemaStatements = <String>[
    "CREATE TABLE IF NOT EXISTS recovered_unlinked_messages (id INTEGER PRIMARY KEY, source_rowid INTEGER, guid TEXT NOT NULL, sender_handle_id INTEGER REFERENCES handles(id) ON DELETE SET NULL, service TEXT, is_from_me INTEGER NOT NULL CHECK(is_from_me IN (0,1)), date_utc TEXT, date_read_utc TEXT, date_delivered_utc TEXT, subject TEXT, text TEXT, attributed_body_blob BLOB, item_type TEXT CHECK(item_type IN ('text','attachment-only','sticker','reaction-carrier','system','unknown','balloon')), error_code INTEGER, is_system_message INTEGER NOT NULL DEFAULT 0 CHECK(is_system_message IN (0,1)), thread_originator_guid TEXT, associated_message_guid TEXT, balloon_bundle_id TEXT, payload_json TEXT, is_ignored INTEGER NOT NULL DEFAULT 0 CHECK(is_ignored IN (0,1)), batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT, UNIQUE(guid))",
    'CREATE TABLE IF NOT EXISTS recovered_unlinked_message_attachments (message_id INTEGER NOT NULL REFERENCES recovered_unlinked_messages(id) ON DELETE CASCADE, attachment_id INTEGER NOT NULL REFERENCES attachments(id) ON DELETE CASCADE, source_rowid INTEGER, PRIMARY KEY (message_id, attachment_id))',
  ];

  static const List<String> _v3SchemaStatements = <String>[
    'ALTER TABLE messages ADD COLUMN raw_item_type INTEGER',
    'ALTER TABLE messages ADD COLUMN raw_associated_message_type INTEGER',
    'ALTER TABLE messages ADD COLUMN message_summary_info_blob BLOB',
    'ALTER TABLE messages ADD COLUMN payload_data_blob BLOB',
    'ALTER TABLE messages ADD COLUMN has_attributed_body_source INTEGER NOT NULL DEFAULT 0 CHECK(has_attributed_body_source IN (0,1))',
    'ALTER TABLE messages ADD COLUMN has_message_summary_info INTEGER NOT NULL DEFAULT 0 CHECK(has_message_summary_info IN (0,1))',
    'ALTER TABLE messages ADD COLUMN has_payload_data_source INTEGER NOT NULL DEFAULT 0 CHECK(has_payload_data_source IN (0,1))',
    'ALTER TABLE recovered_unlinked_messages ADD COLUMN raw_item_type INTEGER',
    'ALTER TABLE recovered_unlinked_messages ADD COLUMN raw_associated_message_type INTEGER',
    'ALTER TABLE recovered_unlinked_messages ADD COLUMN message_summary_info_blob BLOB',
    'ALTER TABLE recovered_unlinked_messages ADD COLUMN payload_data_blob BLOB',
    'ALTER TABLE recovered_unlinked_messages ADD COLUMN has_attributed_body_source INTEGER NOT NULL DEFAULT 0 CHECK(has_attributed_body_source IN (0,1))',
    'ALTER TABLE recovered_unlinked_messages ADD COLUMN has_message_summary_info INTEGER NOT NULL DEFAULT 0 CHECK(has_message_summary_info IN (0,1))',
    'ALTER TABLE recovered_unlinked_messages ADD COLUMN has_payload_data_source INTEGER NOT NULL DEFAULT 0 CHECK(has_payload_data_source IN (0,1))',
  ];

  static const List<String> _v5SchemaStatements = <String>[
    _historicalArchiveSourcesTableStatement,
  ];

  static const List<String> _v6SchemaStatements = <String>[
    'ALTER TABLE messages ADD COLUMN source_id TEXT',
    'ALTER TABLE messages ADD COLUMN source_kind TEXT',
  ];

  static const List<String> _v7SchemaStatements = <String>[
    'ALTER TABLE messages ADD COLUMN source_chat_rowid INTEGER',
    'ALTER TABLE messages ADD COLUMN source_sender_handle_rowid INTEGER',
  ];

  static const String _handlesTableStatementWithoutUniqueness =
      "CREATE TABLE IF NOT EXISTS handles (id INTEGER PRIMARY KEY, source_rowid INTEGER, source_id TEXT, source_kind TEXT, service TEXT NOT NULL, raw_identifier TEXT NOT NULL, normalized_identifier TEXT, compound_identifier TEXT NOT NULL DEFAULT '', country TEXT, last_seen_utc TEXT, is_ignored INTEGER NOT NULL DEFAULT 0 CHECK(is_ignored IN (0,1)), batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT)";

  static const String _historicalArchiveSourcesTableStatement =
      'CREATE TABLE IF NOT EXISTS historical_archive_sources (source_chat_db TEXT PRIMARY KEY, folder_path TEXT NOT NULL, source_label TEXT NOT NULL, chat_db_status_label TEXT NOT NULL, attachments_status_label TEXT NOT NULL, preflight_status_label TEXT NOT NULL, preflight_detail TEXT NOT NULL, total_messages INTEGER, total_chats INTEGER, total_handles INTEGER, missing_guids INTEGER, earliest_message_utc TEXT, latest_message_utc TEXT, dry_run_new_messages INTEGER, dry_run_duplicate_messages INTEGER, last_import_finished_at_utc TEXT, last_import_success INTEGER CHECK(last_import_success IN (0,1)), last_import_error TEXT, last_imported_message_count INTEGER, updated_at_utc TEXT NOT NULL)';

  static const String _chatMessageJoinsTableStatement =
      'CREATE TABLE IF NOT EXISTS chat_message_joins (id INTEGER PRIMARY KEY, source_rowid INTEGER NOT NULL, source_id TEXT NOT NULL, source_kind TEXT NOT NULL, source_chat_rowid INTEGER NOT NULL, source_message_rowid INTEGER NOT NULL, batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT, UNIQUE(source_id, source_rowid), UNIQUE(source_id, source_chat_rowid, source_message_rowid))';

  static const String _chatMessageJoinsSourceIndexStatement =
      'CREATE INDEX IF NOT EXISTS idx_chat_message_joins_source ON chat_message_joins(source_id, source_rowid)';

  static const String _chatMessageJoinsMessageIndexStatement =
      'CREATE INDEX IF NOT EXISTS idx_chat_message_joins_message ON chat_message_joins(source_id, source_message_rowid)';

  static const String _chatMessageJoinsChatIndexStatement =
      'CREATE INDEX IF NOT EXISTS idx_chat_message_joins_chat ON chat_message_joins(source_id, source_chat_rowid)';

  static const List<String> _v2IndexStatements = <String>[
    'CREATE INDEX IF NOT EXISTS idx_recovered_unlinked_messages_date ON recovered_unlinked_messages(date_utc)',
    'CREATE INDEX IF NOT EXISTS idx_recovered_unlinked_messages_ignore ON recovered_unlinked_messages(is_ignored)',
    'CREATE INDEX IF NOT EXISTS idx_recovered_unlinked_messages_assoc ON recovered_unlinked_messages(associated_message_guid)',
    'CREATE INDEX IF NOT EXISTS idx_recovered_unlinked_messages_sender ON recovered_unlinked_messages(sender_handle_id)',
    'CREATE INDEX IF NOT EXISTS idx_recovered_unlinked_message_attachments_attachment ON recovered_unlinked_message_attachments(attachment_id)',
  ];
}
