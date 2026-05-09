import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SqfliteImportDatabase handles schema', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'sqflite_import_database_test',
      );
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'fresh database creates nullable message source provenance columns',
      () async {
        final ledgerDb = SqfliteImportDatabase(
          databaseDirectory: tempDir.path,
          databaseName: 'import_test.db',
          debugSettings: const ImportDebugSettingsState(),
        );

        final db = await ledgerDb.database;
        final rows = await db.rawQuery('PRAGMA table_info(messages)');
        final columns = <String, Map<String, Object?>>{
          for (final row in rows) row['name']! as String: row,
        };

        expect(columns['source_rowid']?['type'], 'INTEGER');
        expect(columns['source_id']?['type'], 'TEXT');
        expect(columns['source_id']?['notnull'], 0);
        expect(columns['source_kind']?['type'], 'TEXT');
        expect(columns['source_kind']?['notnull'], 0);

        await ledgerDb.close();
      },
    );

    test(
      'upgrades a v5 database with nullable message source provenance columns',
      () async {
        final dbPath = '${tempDir.path}/import_test.db';
        final legacyDb = await openDatabase(dbPath);
        await legacyDb.execute(
          'CREATE TABLE schema_migrations (version INTEGER PRIMARY KEY, applied_at_utc TEXT NOT NULL)',
        );
        await legacyDb.execute(
          'CREATE TABLE import_batches (id INTEGER PRIMARY KEY, started_at_utc TEXT NOT NULL)',
        );
        await legacyDb.execute(
          'CREATE TABLE chats (id INTEGER PRIMARY KEY, guid TEXT NOT NULL, batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT)',
        );
        await legacyDb.execute(
          'CREATE TABLE messages (id INTEGER PRIMARY KEY, source_rowid INTEGER, guid TEXT NOT NULL, chat_id INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE, is_from_me INTEGER NOT NULL CHECK(is_from_me IN (0,1)), batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT, UNIQUE(guid))',
        );
        await legacyDb.execute(
          "INSERT INTO schema_migrations (version, applied_at_utc) VALUES (5, '2026-05-09T00:00:00.000Z')",
        );
        await legacyDb.execute('PRAGMA user_version = 5');
        await legacyDb.close();

        final upgradedDb = SqfliteImportDatabase(
          databaseDirectory: tempDir.path,
          databaseName: 'import_test.db',
          debugSettings: const ImportDebugSettingsState(),
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

        final migrationRows = await db.query(
          'schema_migrations',
          where: 'version = ?',
          whereArgs: <Object>[6],
        );
        expect(migrationRows, hasLength(1));

        await upgradedDb.close();
      },
    );

    test(
      'fresh database preserves multiple source rows with same imported raw identifier',
      () async {
        final ledgerDb = SqfliteImportDatabase(
          databaseDirectory: tempDir.path,
          databaseName: 'import_test.db',
          debugSettings: const ImportDebugSettingsState(),
        );

        final batchId = await ledgerDb.insertImportBatch(
          startedAtUtc: DateTime.now().toUtc().toIso8601String(),
        );

        await ledgerDb.insertHandle(
          id: 22,
          sourceRowid: 22,
          service: 'iMessage',
          rawIdentifier: 'cathie.campbell@gmail.com',
          normalizedIdentifier: 'cathie.campbell@gmail.com',
          compoundIdentifier: 'cathie.campbell@gmail.com-iMessage',
          batchId: batchId,
        );
        await ledgerDb.insertHandle(
          id: 203,
          sourceRowid: 203,
          service: 'iMessage',
          rawIdentifier: 'cathie.campbell@gmail.com',
          normalizedIdentifier: 'cathie.campbell@gmail.com',
          compoundIdentifier: 'cathie.campbell@gmail.com-iMessage',
          batchId: batchId,
        );

        final db = await ledgerDb.database;
        final rows = await db.query('handles', orderBy: 'id ASC');

        expect(rows, hasLength(2));
        expect(rows.map((row) => row['id']), orderedEquals(<Object?>[22, 203]));
        expect(
          rows.map((row) => row['source_rowid']),
          orderedEquals(<Object?>[22, 203]),
        );

        await ledgerDb.close();
      },
    );

    test('upgrades a v3 database to preserve multiple source rows', () async {
      final dbPath = '${tempDir.path}/import_test.db';
      final legacyDb = await openDatabase(dbPath);
      await legacyDb.execute(
        'CREATE TABLE schema_migrations (version INTEGER PRIMARY KEY, applied_at_utc TEXT NOT NULL)',
      );
      await legacyDb.execute(
        'CREATE TABLE import_batches (id INTEGER PRIMARY KEY, started_at_utc TEXT NOT NULL, finished_at_utc TEXT, source_chat_db TEXT, source_addressbook TEXT, host_info_json TEXT, notes TEXT)',
      );
      await legacyDb.execute(
        "CREATE TABLE handles (id INTEGER PRIMARY KEY, source_rowid INTEGER, service TEXT NOT NULL, raw_identifier TEXT NOT NULL, normalized_identifier TEXT, compound_identifier TEXT NOT NULL DEFAULT '', country TEXT, last_seen_utc TEXT, is_ignored INTEGER NOT NULL DEFAULT 0 CHECK(is_ignored IN (0,1)), batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT, UNIQUE(service, raw_identifier))",
      );
      await legacyDb.execute(
        'CREATE TABLE messages (id INTEGER PRIMARY KEY, source_rowid INTEGER, guid TEXT NOT NULL, chat_id INTEGER NOT NULL, is_from_me INTEGER NOT NULL CHECK(is_from_me IN (0,1)), batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT, UNIQUE(guid))',
      );
      await legacyDb.execute(
        'CREATE INDEX idx_handles_compound ON handles(compound_identifier)',
      );
      await legacyDb.execute(
        'CREATE INDEX idx_handles_norm ON handles(normalized_identifier)',
      );
      await legacyDb.execute(
        'CREATE INDEX idx_handles_ignore ON handles(is_ignored)',
      );
      await legacyDb.execute('PRAGMA user_version = 3');
      await legacyDb.close();

      final upgradedDb = SqfliteImportDatabase(
        databaseDirectory: tempDir.path,
        databaseName: 'import_test.db',
        debugSettings: const ImportDebugSettingsState(),
      );

      final batchId = await upgradedDb.insertImportBatch(
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );

      await upgradedDb.insertHandle(
        id: 22,
        sourceRowid: 22,
        service: 'iMessage',
        rawIdentifier: 'cathie.campbell@gmail.com',
        normalizedIdentifier: 'cathie.campbell@gmail.com',
        compoundIdentifier: 'cathie.campbell@gmail.com-iMessage',
        batchId: batchId,
      );
      await upgradedDb.insertHandle(
        id: 203,
        sourceRowid: 203,
        service: 'iMessage',
        rawIdentifier: 'cathie.campbell@gmail.com',
        normalizedIdentifier: 'cathie.campbell@gmail.com',
        compoundIdentifier: 'cathie.campbell@gmail.com-iMessage',
        batchId: batchId,
      );

      final db = await upgradedDb.database;
      final rows = await db.query('handles', orderBy: 'id ASC');

      expect(rows, hasLength(2));
      expect(rows.map((row) => row['id']), orderedEquals(<Object?>[22, 203]));

      await upgradedDb.close();
    });

    test('deletes only the selected source batch ledger rows', () async {
      final ledgerDb = SqfliteImportDatabase(
        databaseDirectory: tempDir.path,
        databaseName: 'import_test.db',
        debugSettings: const ImportDebugSettingsState(),
      );

      final archiveBatchId = await ledgerDb.insertImportBatch(
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
        sourceChatDb: '/Archives/2017/chat.db',
      );
      final currentBatchId = await ledgerDb.insertImportBatch(
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
        sourceChatDb: '/Users/test/Library/Messages/chat.db',
      );

      final db = await ledgerDb.database;
      await db.insert('handles', <String, Object?>{
        'id': 1,
        'service': 'iMessage',
        'raw_identifier': 'archive@example.com',
        'compound_identifier': 'archive@example.com-iMessage',
        'batch_id': archiveBatchId,
      });
      await db.insert('handles', <String, Object?>{
        'id': 2,
        'service': 'iMessage',
        'raw_identifier': 'current@example.com',
        'compound_identifier': 'current@example.com-iMessage',
        'batch_id': currentBatchId,
      });
      await db.insert('chats', <String, Object?>{
        'id': 11,
        'guid': 'archive-chat',
        'service': 'iMessage',
        'batch_id': archiveBatchId,
      });
      await db.insert('chats', <String, Object?>{
        'id': 12,
        'guid': 'current-chat',
        'service': 'iMessage',
        'batch_id': currentBatchId,
      });
      await db.insert('messages', <String, Object?>{
        'id': 21,
        'guid': 'archive-guid',
        'chat_id': 11,
        'sender_handle_id': 1,
        'is_from_me': 0,
        'batch_id': archiveBatchId,
      });
      await db.insert('messages', <String, Object?>{
        'id': 22,
        'guid': 'current-guid',
        'chat_id': 12,
        'sender_handle_id': 2,
        'is_from_me': 0,
        'batch_id': currentBatchId,
      });
      await db.insert('chat_to_message', <String, Object?>{
        'chat_id': 11,
        'message_id': 21,
      });
      await db.insert('chat_to_message', <String, Object?>{
        'chat_id': 12,
        'message_id': 22,
      });

      expect(
        await ledgerDb.batchIdsForSourceChatDb(
          sourceChatDb: '/Archives/2017/chat.db',
        ),
        <int>[archiveBatchId],
      );

      await ledgerDb.deleteBatchLedgerData(batchId: archiveBatchId);

      expect(
        await ledgerDb.batchIdsForSourceChatDb(
          sourceChatDb: '/Archives/2017/chat.db',
        ),
        isEmpty,
      );
      expect(await ledgerDb.countRows('messages'), 1);
      expect(await ledgerDb.countRows('chats'), 1);
      expect(await ledgerDb.countRows('handles'), 1);

      final remainingMessages = await db.query('messages');
      expect(remainingMessages.single['guid'], 'current-guid');

      final remainingBatches = await db.query(
        'import_batches',
        orderBy: 'id ASC',
      );
      expect(remainingBatches, hasLength(1));
      expect(remainingBatches.single['id'], currentBatchId);

      await ledgerDb.close();
    });

    test(
      'persists historical archive source metadata independently of workflow state',
      () async {
        final ledgerDb = SqfliteImportDatabase(
          databaseDirectory: tempDir.path,
          databaseName: 'import_test.db',
          debugSettings: const ImportDebugSettingsState(),
        );

        final batchId = await ledgerDb.insertImportBatch(
          startedAtUtc: DateTime.now().toUtc().toIso8601String(),
          sourceChatDb: '/Archives/2017/chat.db',
        );

        await ledgerDb.upsertHistoricalArchiveSource(
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
          lastImportBatchId: batchId,
          lastImportFinishedAtUtc: '2026-04-29T18:30:00.000Z',
          lastImportSuccess: true,
          lastImportedMessageCount: 10,
          updatedAtUtc: '2026-04-29T18:30:00.000Z',
        );

        final records = await ledgerDb.listHistoricalArchiveSources();

        expect(records, hasLength(1));
        expect(records.single.sourceLabel, 'Archive-2017');
        expect(records.single.totalMessages, 42);
        expect(records.single.earliestMessageUtc, '2017-01-03T00:00:00.000Z');
        expect(records.single.lastImportSuccess, isTrue);
        expect(records.single.lastImportedMessageCount, 10);

        await ledgerDb.close();
      },
    );
  });
}
