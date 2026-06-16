import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/retained_archive_metadata_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Retained archive metadata database handles schema', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'retained_archive_metadata_database_test',
      );
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'fresh database creates retained archive metadata schema only',
      () async {
        final metadataDb = RetainedArchiveMetadataDatabase(
          databaseDirectory: tempDir.path,
          databaseName: 'metadata_test.db',
        );

        final db = await metadataDb.database;
        final tableRows = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name",
        );
        final tableNames = <String>{
          for (final row in tableRows) row['name']! as String,
        };

        expect(
          tableNames,
          containsAll(<String>{
            'schema_migrations',
            'historical_archive_sources',
          }),
        );
        expect(tableNames, isNot(contains('import_batches')));
        expect(tableNames, isNot(contains('messages')));
        expect(tableNames, isNot(contains('handles')));
        expect(tableNames, isNot(contains('chats')));
        expect(tableNames, isNot(contains('chat_message_joins')));

        await metadataDb.close();
      },
    );

    test(
      'fresh database creates narrowed historical archive metadata schema',
      () async {
        final metadataDb = RetainedArchiveMetadataDatabase(
          databaseDirectory: tempDir.path,
          databaseName: 'metadata_test.db',
        );

        final db = await metadataDb.database;
        final rows = await db.rawQuery(
          'PRAGMA table_info(historical_archive_sources)',
        );
        final columnNames = <String>{
          for (final row in rows) row['name']! as String,
        };

        expect(columnNames, contains('source_chat_db'));
        expect(columnNames, contains('last_import_finished_at_utc'));
        expect(columnNames, contains('last_import_success'));
        expect(columnNames, contains('last_imported_message_count'));
        expect(columnNames, isNot(contains('matched_imported_batch_count')));
        expect(columnNames, isNot(contains('last_import_batch_id')));
        expect(columnNames, isNot(contains('last_import_started_at_utc')));

        await metadataDb.close();
      },
    );

    test(
      'upgrades a v5 database with nullable message source provenance columns',
      () async {
        final dbPath = '${tempDir.path}/metadata_test.db';
        final existingDb = await openDatabase(dbPath);
        await existingDb.execute(
          'CREATE TABLE schema_migrations (version INTEGER PRIMARY KEY, applied_at_utc TEXT NOT NULL)',
        );
        await existingDb.execute(
          'CREATE TABLE import_batches (id INTEGER PRIMARY KEY, started_at_utc TEXT NOT NULL)',
        );
        await existingDb.execute(
          'CREATE TABLE chats (id INTEGER PRIMARY KEY, guid TEXT NOT NULL, batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT)',
        );
        await existingDb.execute(
          'CREATE TABLE messages (id INTEGER PRIMARY KEY, source_rowid INTEGER, guid TEXT NOT NULL, chat_id INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE, is_from_me INTEGER NOT NULL CHECK(is_from_me IN (0,1)), batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT, UNIQUE(guid))',
        );
        await existingDb.execute(
          "INSERT INTO schema_migrations (version, applied_at_utc) VALUES (5, '2026-05-09T00:00:00.000Z')",
        );
        await existingDb.execute('PRAGMA user_version = 5');
        await existingDb.close();

        final upgradedDb = RetainedArchiveMetadataDatabase(
          databaseDirectory: tempDir.path,
          databaseName: 'metadata_test.db',
        );

        final db = await upgradedDb.database;
        final rows = await db.rawQuery('PRAGMA table_info(messages)');
        final columns = <String, Map<String, Object?>>{
          for (final row in rows) row['name']! as String: row,
        };

        expect(columns['source_rowid']?['type'], 'INTEGER');
        expect(columns['source_id']?['type'], 'TEXT');
        expect(columns['source_id']?['notnull'], 0);
        expect(columns['source_kind']?['type'], 'TEXT');
        expect(columns['source_kind']?['notnull'], 0);
        expect(columns['source_chat_rowid']?['type'], 'INTEGER');
        expect(columns['source_chat_rowid']?['notnull'], 0);
        expect(columns['source_sender_handle_rowid']?['type'], 'INTEGER');
        expect(columns['source_sender_handle_rowid']?['notnull'], 0);

        final migrationRows = await db.query(
          'schema_migrations',
          where: 'version IN (?, ?, ?, ?, ?)',
          whereArgs: <Object>[6, 7, 8, 9, 10],
        );
        expect(migrationRows, hasLength(5));

        await upgradedDb.close();
      },
    );

    test(
      'upgrades a v6 database with nullable message source relationship columns',
      () async {
        final dbPath = '${tempDir.path}/metadata_test.db';
        final existingDb = await openDatabase(dbPath);
        await existingDb.execute(
          'CREATE TABLE schema_migrations (version INTEGER PRIMARY KEY, applied_at_utc TEXT NOT NULL)',
        );
        await existingDb.execute(
          'CREATE TABLE import_batches (id INTEGER PRIMARY KEY, started_at_utc TEXT NOT NULL)',
        );
        await existingDb.execute(
          'CREATE TABLE chats (id INTEGER PRIMARY KEY, guid TEXT NOT NULL, batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT)',
        );
        await existingDb.execute(
          'CREATE TABLE messages (id INTEGER PRIMARY KEY, source_rowid INTEGER, source_id TEXT, source_kind TEXT, guid TEXT NOT NULL, chat_id INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE, is_from_me INTEGER NOT NULL CHECK(is_from_me IN (0,1)), batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT, UNIQUE(guid))',
        );
        await existingDb.execute(
          "INSERT INTO schema_migrations (version, applied_at_utc) VALUES (6, '2026-05-09T00:00:00.000Z')",
        );
        await existingDb.execute('PRAGMA user_version = 6');
        await existingDb.close();

        final upgradedDb = RetainedArchiveMetadataDatabase(
          databaseDirectory: tempDir.path,
          databaseName: 'metadata_test.db',
        );

        final db = await upgradedDb.database;
        final rows = await db.rawQuery('PRAGMA table_info(messages)');
        final columns = <String, Map<String, Object?>>{
          for (final row in rows) row['name']! as String: row,
        };

        expect(columns['source_chat_rowid']?['type'], 'INTEGER');
        expect(columns['source_chat_rowid']?['notnull'], 0);
        expect(columns['source_sender_handle_rowid']?['type'], 'INTEGER');
        expect(columns['source_sender_handle_rowid']?['notnull'], 0);

        final migrationRows = await db.query(
          'schema_migrations',
          where: 'version IN (?, ?, ?, ?)',
          whereArgs: <Object>[7, 8, 9, 10],
        );
        expect(migrationRows, hasLength(4));

        await upgradedDb.close();
      },
    );

    test('upgrades a v7 database with nullable handle provenance columns', () async {
      final dbPath = '${tempDir.path}/metadata_test.db';
      final existingDb = await openDatabase(dbPath);
      await existingDb.execute(
        'CREATE TABLE schema_migrations (version INTEGER PRIMARY KEY, applied_at_utc TEXT NOT NULL)',
      );
      await existingDb.execute(
        'CREATE TABLE import_batches (id INTEGER PRIMARY KEY, started_at_utc TEXT NOT NULL)',
      );
      await existingDb.execute(
        "CREATE TABLE handles (id INTEGER PRIMARY KEY, source_rowid INTEGER, service TEXT NOT NULL, raw_identifier TEXT NOT NULL, normalized_identifier TEXT, compound_identifier TEXT NOT NULL DEFAULT '', country TEXT, last_seen_utc TEXT, is_ignored INTEGER NOT NULL DEFAULT 0 CHECK(is_ignored IN (0,1)), batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT)",
      );
      await existingDb.execute(
        "INSERT INTO schema_migrations (version, applied_at_utc) VALUES (7, '2026-05-09T00:00:00.000Z')",
      );
      await existingDb.execute('PRAGMA user_version = 7');
      await existingDb.close();

      final upgradedDb = RetainedArchiveMetadataDatabase(
        databaseDirectory: tempDir.path,
        databaseName: 'metadata_test.db',
      );

      final db = await upgradedDb.database;
      final rows = await db.rawQuery('PRAGMA table_info(handles)');
      final columns = <String, Map<String, Object?>>{
        for (final row in rows) row['name']! as String: row,
      };

      expect(columns['source_id']?['type'], 'TEXT');
      expect(columns['source_id']?['notnull'], 0);
      expect(columns['source_kind']?['type'], 'TEXT');
      expect(columns['source_kind']?['notnull'], 0);

      final migrationRows = await db.query(
        'schema_migrations',
        where: 'version IN (?, ?, ?)',
        whereArgs: <Object>[8, 9, 10],
      );
      expect(migrationRows, hasLength(3));

      await upgradedDb.close();
    });

    test('upgrades a v8 database with nullable chat provenance columns', () async {
      final dbPath = '${tempDir.path}/metadata_test.db';
      final existingDb = await openDatabase(dbPath);
      await existingDb.execute(
        'CREATE TABLE schema_migrations (version INTEGER PRIMARY KEY, applied_at_utc TEXT NOT NULL)',
      );
      await existingDb.execute(
        'CREATE TABLE import_batches (id INTEGER PRIMARY KEY, started_at_utc TEXT NOT NULL)',
      );
      await existingDb.execute(
        'CREATE TABLE chats (id INTEGER PRIMARY KEY, source_rowid INTEGER, guid TEXT NOT NULL, service TEXT, display_name TEXT, is_group INTEGER NOT NULL DEFAULT 0 CHECK(is_group IN (0,1)), created_at_utc TEXT, updated_at_utc TEXT, is_ignored INTEGER NOT NULL DEFAULT 0 CHECK(is_ignored IN (0,1)), batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT, UNIQUE(guid))',
      );
      await existingDb.execute(
        "INSERT INTO schema_migrations (version, applied_at_utc) VALUES (8, '2026-05-09T00:00:00.000Z')",
      );
      await existingDb.execute('PRAGMA user_version = 8');
      await existingDb.close();

      final upgradedDb = RetainedArchiveMetadataDatabase(
        databaseDirectory: tempDir.path,
        databaseName: 'metadata_test.db',
      );

      final db = await upgradedDb.database;
      final rows = await db.rawQuery('PRAGMA table_info(chats)');
      final columns = <String, Map<String, Object?>>{
        for (final row in rows) row['name']! as String: row,
      };

      expect(columns['source_id']?['type'], 'TEXT');
      expect(columns['source_id']?['notnull'], 0);
      expect(columns['source_kind']?['type'], 'TEXT');
      expect(columns['source_kind']?['notnull'], 0);

      final migrationRows = await db.query(
        'schema_migrations',
        where: 'version IN (?, ?)',
        whereArgs: <Object>[9, 10],
      );
      expect(migrationRows, hasLength(2));

      await upgradedDb.close();
    });

    test('upgrades a v9 database with chat message join ledger table', () async {
      final dbPath = '${tempDir.path}/metadata_test.db';
      final existingDb = await openDatabase(dbPath);
      await existingDb.execute(
        'CREATE TABLE schema_migrations (version INTEGER PRIMARY KEY, applied_at_utc TEXT NOT NULL)',
      );
      await existingDb.execute(
        'CREATE TABLE import_batches (id INTEGER PRIMARY KEY, started_at_utc TEXT NOT NULL)',
      );
      await existingDb.execute(
        "INSERT INTO schema_migrations (version, applied_at_utc) VALUES (9, '2026-05-09T00:00:00.000Z')",
      );
      await existingDb.execute('PRAGMA user_version = 9');
      await existingDb.close();

      final upgradedDb = RetainedArchiveMetadataDatabase(
        databaseDirectory: tempDir.path,
        databaseName: 'metadata_test.db',
      );

      final db = await upgradedDb.database;
      final rows = await db.rawQuery('PRAGMA table_info(chat_message_joins)');
      final columns = <String, Map<String, Object?>>{
        for (final row in rows) row['name']! as String: row,
      };

      expect(columns['source_rowid']?['type'], 'INTEGER');
      expect(columns['source_id']?['type'], 'TEXT');
      expect(columns['source_chat_rowid']?['type'], 'INTEGER');
      expect(columns['source_message_rowid']?['type'], 'INTEGER');

      final migrationRows = await db.query(
        'schema_migrations',
        where: 'version = ?',
        whereArgs: <Object>[10],
      );
      expect(migrationRows, hasLength(1));

      await upgradedDb.close();
    });

    test('upgrades a v3 database to preserve multiple source rows', () async {
      final dbPath = '${tempDir.path}/metadata_test.db';
      final existingDb = await openDatabase(dbPath);
      await existingDb.execute(
        'CREATE TABLE schema_migrations (version INTEGER PRIMARY KEY, applied_at_utc TEXT NOT NULL)',
      );
      await existingDb.execute(
        'CREATE TABLE import_batches (id INTEGER PRIMARY KEY, started_at_utc TEXT NOT NULL, finished_at_utc TEXT, source_chat_db TEXT, source_addressbook TEXT, host_info_json TEXT, notes TEXT)',
      );
      await existingDb.execute(
        "CREATE TABLE handles (id INTEGER PRIMARY KEY, source_rowid INTEGER, service TEXT NOT NULL, raw_identifier TEXT NOT NULL, normalized_identifier TEXT, compound_identifier TEXT NOT NULL DEFAULT '', country TEXT, last_seen_utc TEXT, is_ignored INTEGER NOT NULL DEFAULT 0 CHECK(is_ignored IN (0,1)), batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT, UNIQUE(service, raw_identifier))",
      );
      await existingDb.execute(
        'CREATE TABLE messages (id INTEGER PRIMARY KEY, source_rowid INTEGER, guid TEXT NOT NULL, chat_id INTEGER NOT NULL, is_from_me INTEGER NOT NULL CHECK(is_from_me IN (0,1)), batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT, UNIQUE(guid))',
      );
      await existingDb.execute(
        'CREATE INDEX idx_handles_compound ON handles(compound_identifier)',
      );
      await existingDb.execute(
        'CREATE INDEX idx_handles_norm ON handles(normalized_identifier)',
      );
      await existingDb.execute(
        'CREATE INDEX idx_handles_ignore ON handles(is_ignored)',
      );
      await existingDb.execute('PRAGMA user_version = 3');
      await existingDb.close();

      final upgradedDb = RetainedArchiveMetadataDatabase(
        databaseDirectory: tempDir.path,
        databaseName: 'metadata_test.db',
      );

      final db = await upgradedDb.database;
      final batchId = await _insertImportBatch(db);
      await _insertHandleFixture(db, id: 22, sourceRowid: 22, batchId: batchId);
      await _insertHandleFixture(
        db,
        id: 203,
        sourceRowid: 203,
        batchId: batchId,
      );
      final rows = await db.query('handles', orderBy: 'id ASC');

      expect(rows, hasLength(2));
      expect(rows.map((row) => row['id']), orderedEquals(<Object?>[22, 203]));

      await upgradedDb.close();
    });

    test(
      'persists historical archive source metadata independently of workflow state',
      () async {
        final metadataDb = RetainedArchiveMetadataDatabase(
          databaseDirectory: tempDir.path,
          databaseName: 'metadata_test.db',
        );

        await metadataDb.database;
        await metadataDb.upsertHistoricalArchiveSource(
          sourceChatDb: '/Archives/2017/chat.db',
          folderPath: '/Archives/2017',
          sourceLabel: 'Archive-2017',
          chatDbStatusLabel: 'Found and readable',
          attachmentsStatusLabel: 'Found',
          preflightStatusLabel: 'Preflight complete',
          preflightDetail: 'Source checks succeeded.',
          totalMessages: 42,
          totalChats: 2,
          totalHandles: 10,
          missingGuids: 1,
          earliestMessageUtc: '2017-01-03T00:00:00.000Z',
          latestMessageUtc: '2017-01-05T00:00:00.000Z',
          dryRunNewMessages: 10,
          dryRunDuplicateMessages: 32,
          lastImportFinishedAtUtc: '2026-04-29T18:30:00.000Z',
          lastImportSuccess: true,
          lastImportedMessageCount: 10,
          updatedAtUtc: '2026-04-29T18:30:00.000Z',
        );

        final records = await metadataDb.listHistoricalArchiveSources();

        expect(records, hasLength(1));
        expect(records.single.sourceLabel, 'Archive-2017');
        expect(records.single.totalMessages, 42);
        expect(records.single.earliestMessageUtc, '2017-01-03T00:00:00.000Z');
        expect(records.single.lastImportSuccess, isTrue);
        expect(records.single.lastImportedMessageCount, 10);

        await metadataDb.close();
      },
    );
  });
}

Future<int> _insertImportBatch(Database db, {String? sourceChatDb}) {
  return db.insert('import_batches', <String, Object?>{
    'started_at_utc': DateTime.now().toUtc().toIso8601String(),
    'source_chat_db': sourceChatDb,
  });
}

Future<void> _insertHandleFixture(
  Database db, {
  required int id,
  required int sourceRowid,
  required int batchId,
}) {
  return db.insert('handles', <String, Object?>{
    'id': id,
    'source_rowid': sourceRowid,
    'service': 'iMessage',
    'raw_identifier': 'cathie.campbell@gmail.com',
    'normalized_identifier': 'cathie.campbell@gmail.com',
    'compound_identifier': 'cathie.campbell@gmail.com-iMessage',
    'batch_id': batchId,
  });
}
