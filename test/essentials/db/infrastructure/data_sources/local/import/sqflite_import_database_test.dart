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
          rows.map((row) => row['source_handle_rowid']),
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
        'CREATE TABLE chats (id INTEGER PRIMARY KEY, source_rowid INTEGER, guid TEXT NOT NULL, service TEXT, display_name TEXT, is_group INTEGER NOT NULL DEFAULT 0 CHECK(is_group IN (0,1)), created_at_utc TEXT, updated_at_utc TEXT, is_ignored INTEGER NOT NULL DEFAULT 0 CHECK(is_ignored IN (0,1)), batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT, UNIQUE(guid))',
      );
      await legacyDb.execute(
        "CREATE TABLE messages (id INTEGER PRIMARY KEY, source_rowid INTEGER, guid TEXT NOT NULL, chat_id INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE, sender_handle_id INTEGER REFERENCES handles(id) ON DELETE SET NULL, service TEXT, is_from_me INTEGER NOT NULL CHECK(is_from_me IN (0,1)), date_utc TEXT, date_read_utc TEXT, date_delivered_utc TEXT, subject TEXT, text TEXT, attributed_body_blob BLOB, raw_item_type INTEGER, raw_associated_message_type INTEGER, message_summary_info_blob BLOB, payload_data_blob BLOB, has_attributed_body_source INTEGER NOT NULL DEFAULT 0 CHECK(has_attributed_body_source IN (0,1)), has_message_summary_info INTEGER NOT NULL DEFAULT 0 CHECK(has_message_summary_info IN (0,1)), has_payload_data_source INTEGER NOT NULL DEFAULT 0 CHECK(has_payload_data_source IN (0,1)), item_type TEXT CHECK(item_type IN ('text','attachment-only','sticker','reaction-carrier','system','unknown','balloon')), error_code INTEGER, is_system_message INTEGER NOT NULL DEFAULT 0 CHECK(is_system_message IN (0,1)), thread_originator_guid TEXT, associated_message_guid TEXT, balloon_bundle_id TEXT, payload_json TEXT, is_ignored INTEGER NOT NULL DEFAULT 0 CHECK(is_ignored IN (0,1)), batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT, UNIQUE(guid))",
      );
      await legacyDb.execute(
        "CREATE TABLE recovered_unlinked_messages (id INTEGER PRIMARY KEY, source_rowid INTEGER, guid TEXT NOT NULL, sender_handle_id INTEGER REFERENCES handles(id) ON DELETE SET NULL, service TEXT, is_from_me INTEGER NOT NULL CHECK(is_from_me IN (0,1)), date_utc TEXT, date_read_utc TEXT, date_delivered_utc TEXT, subject TEXT, text TEXT, attributed_body_blob BLOB, raw_item_type INTEGER, raw_associated_message_type INTEGER, message_summary_info_blob BLOB, payload_data_blob BLOB, has_attributed_body_source INTEGER NOT NULL DEFAULT 0 CHECK(has_attributed_body_source IN (0,1)), has_message_summary_info INTEGER NOT NULL DEFAULT 0 CHECK(has_message_summary_info IN (0,1)), has_payload_data_source INTEGER NOT NULL DEFAULT 0 CHECK(has_payload_data_source IN (0,1)), item_type TEXT CHECK(item_type IN ('text','attachment-only','sticker','reaction-carrier','system','unknown','balloon')), error_code INTEGER, is_system_message INTEGER NOT NULL DEFAULT 0 CHECK(is_system_message IN (0,1)), thread_originator_guid TEXT, associated_message_guid TEXT, balloon_bundle_id TEXT, payload_json TEXT, is_ignored INTEGER NOT NULL DEFAULT 0 CHECK(is_ignored IN (0,1)), batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT, UNIQUE(guid))",
      );
      await legacyDb.execute(
        'CREATE TABLE attachments (id INTEGER PRIMARY KEY, source_rowid INTEGER, guid TEXT, transfer_name TEXT, uti TEXT, mime_type TEXT, total_bytes INTEGER, is_sticker INTEGER NOT NULL DEFAULT 0 CHECK(is_sticker IN (0,1)), is_outgoing INTEGER CHECK(is_outgoing IN (0,1)), created_at_utc TEXT, local_path TEXT, sha256_hex TEXT, batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT)',
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

    test(
      'reconcileOrphanedRunningBatches marks running batches as failed and leaves others untouched',
      () async {
        final ledgerDb = SqfliteImportDatabase(
          databaseDirectory: tempDir.path,
          databaseName: 'import_test.db',
          debugSettings: const ImportDebugSettingsState(),
        );

        // A batch that "the previous process" left running.
        final orphanedBatchId = await ledgerDb.insertImportBatch(
          startedAtUtc: DateTime.now()
              .toUtc()
              .subtract(const Duration(minutes: 5))
              .toIso8601String(),
          status: 'running',
        );

        // A batch that completed normally before the (simulated) crash.
        final succeededBatchId = await ledgerDb.insertImportBatch(
          startedAtUtc: DateTime.now()
              .toUtc()
              .subtract(const Duration(minutes: 10))
              .toIso8601String(),
          finishedAtUtc: DateTime.now()
              .toUtc()
              .subtract(const Duration(minutes: 9))
              .toIso8601String(),
          status: 'succeeded',
        );

        // A batch that was already known-failed before startup.
        final preFailedBatchId = await ledgerDb.insertImportBatch(
          startedAtUtc: DateTime.now()
              .toUtc()
              .subtract(const Duration(minutes: 20))
              .toIso8601String(),
          finishedAtUtc: DateTime.now()
              .toUtc()
              .subtract(const Duration(minutes: 19))
              .toIso8601String(),
          status: 'failed',
          errorSummary: 'pre_existing_failure',
        );

        final reconciledCount = await ledgerDb
            .reconcileOrphanedRunningBatches();

        expect(reconciledCount, 1);

        final db = await ledgerDb.database;
        final rows = await db.query('import_batches', orderBy: 'id ASC');
        final byId = <int, Map<String, Object?>>{
          for (final row in rows) row['id']! as int: row,
        };

        expect(byId[orphanedBatchId]!['status'], 'failed');
        expect(byId[orphanedBatchId]!['finished_at_utc'], isNotNull);
        expect(byId[orphanedBatchId]!['finished_at'], isNotNull);
        expect(byId[orphanedBatchId]!['error_summary'], 'orphaned_on_startup');

        // Already-completed batch is left exactly as-is.
        expect(byId[succeededBatchId]!['status'], 'succeeded');

        // Pre-existing failure: status unchanged, original error_summary
        // preserved (COALESCE must not overwrite it).
        expect(byId[preFailedBatchId]!['status'], 'failed');
        expect(
          byId[preFailedBatchId]!['error_summary'],
          'pre_existing_failure',
        );

        // A second pass with no running batches must be a no-op.
        final secondPassCount = await ledgerDb
            .reconcileOrphanedRunningBatches();
        expect(secondPassCount, 0);

        await ledgerDb.close();
      },
    );

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
        expect(records.single.ledgerSourceId, isNull);
        expect(records.single.totalMessages, 42);
        expect(records.single.earliestMessageUtc, '2017-01-03T00:00:00.000Z');
        expect(records.single.lastImportSuccess, isTrue);
        expect(records.single.lastImportedMessageCount, 10);

        await ledgerDb.close();
      },
    );

    test(
      'prepareHistoricalArchiveSource links historical archive metadata to ledger_sources',
      () async {
        final ledgerDb = SqfliteImportDatabase(
          databaseDirectory: tempDir.path,
          databaseName: 'import_test.db',
          debugSettings: const ImportDebugSettingsState(),
        );

        final ledgerSourceId = await ledgerDb.prepareHistoricalArchiveSource(
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
          dryRunNewMessages: 10,
          dryRunDuplicateMessages: 32,
          updatedAtUtc: '2026-04-30T09:00:00.000Z',
        );

        final records = await ledgerDb.listHistoricalArchiveSources();
        final db = await ledgerDb.database;
        final ledgerRows = await db.query(
          'ledger_sources',
          where: 'id = ?',
          whereArgs: <Object>[ledgerSourceId],
        );

        expect(records, hasLength(1));
        expect(records.single.ledgerSourceId, ledgerSourceId);
        expect(ledgerRows, hasLength(1));
        expect(ledgerRows.single['source_kind'], 'historical_archive');
        expect(ledgerRows.single['stable_key'], '/Archives/2017/chat.db');

        await ledgerDb.close();
      },
    );

    test(
      'batchIdsForSourceChatDb ignores cancelled archive preparation batches',
      () async {
        final ledgerDb = SqfliteImportDatabase(
          databaseDirectory: tempDir.path,
          databaseName: 'import_test.db',
          debugSettings: const ImportDebugSettingsState(),
        );

        final ledgerSourceId = await ledgerDb.upsertLedgerSource(
          sourceKind: 'historical_archive',
          stableKey: '/Archives/2017/chat.db',
          sourceLabel: 'Archive-2017',
          chatDbPath: '/Archives/2017/chat.db',
          attachmentsPath: '/Archives/2017/Attachments',
          seenAt: 1777539600000,
        );

        final preparationBatchId = await ledgerDb
            .insertHistoricalArchivePreparationBatch(
              ledgerSourceId: ledgerSourceId,
              sourceChatDb: '/Archives/2017/chat.db',
              sourceLabel: 'Archive-2017',
              startedAtUtc: '2026-04-30T09:00:00.000Z',
              finishedAtUtc: '2026-04-30T09:00:01.000Z',
              detail: 'Archive provenance prepared only.',
            );
        final importedBatchId = await ledgerDb.insertImportBatch(
          startedAtUtc: '2026-04-30T09:10:00.000Z',
          sourceChatDb: '/Archives/2017/chat.db',
          chatSourceId: ledgerSourceId,
          chatSourceKind: 'historical_archive',
          status: 'failed',
        );

        final batchIds = await ledgerDb.batchIdsForSourceChatDb(
          sourceChatDb: '/Archives/2017/chat.db',
        );

        expect(batchIds, contains(importedBatchId));
        expect(batchIds, isNot(contains(preparationBatchId)));

        await ledgerDb.close();
      },
    );

    test(
      'fresh database includes ledger source and row provenance columns',
      () async {
        final ledgerDb = SqfliteImportDatabase(
          databaseDirectory: tempDir.path,
          databaseName: 'import_test.db',
          debugSettings: const ImportDebugSettingsState(),
        );

        final db = await ledgerDb.database;

        expect(
          await _columnNamesFor(db, 'import_batches'),
          containsAll(<String>[
            'chat_source_id',
            'chat_source_kind',
            'status',
            'started_at',
            'finished_at',
            'source_label_snapshot',
            'error_summary',
            'rows_seen',
            'rows_inserted',
            'rows_updated',
            'rows_deduplicated',
            'rows_failed',
          ]),
        );
        expect(
          await _columnNamesFor(db, 'messages'),
          containsAll(<String>[
            'source_id',
            'first_import_batch_id',
            'last_import_batch_id',
            'source_message_rowid',
          ]),
        );
        expect(
          await _columnNamesFor(db, 'chats'),
          containsAll(<String>[
            'source_id',
            'first_import_batch_id',
            'last_import_batch_id',
            'source_chat_rowid',
          ]),
        );
        expect(
          await _columnNamesFor(db, 'handles'),
          containsAll(<String>[
            'source_id',
            'first_import_batch_id',
            'last_import_batch_id',
            'source_handle_rowid',
          ]),
        );
        expect(
          await _columnNamesFor(db, 'attachments'),
          containsAll(<String>[
            'source_id',
            'first_import_batch_id',
            'last_import_batch_id',
            'source_attachment_rowid',
          ]),
        );
        expect(
          await _columnNamesFor(db, 'recovered_unlinked_messages'),
          containsAll(<String>[
            'source_id',
            'first_import_batch_id',
            'last_import_batch_id',
            'source_message_rowid',
          ]),
        );
        expect(
          await _columnNamesFor(db, 'historical_archive_sources'),
          contains('ledger_source_id'),
        );

        final ledgerSourceColumns = await _columnNamesFor(db, 'ledger_sources');
        expect(
          ledgerSourceColumns,
          containsAll(<String>[
            'id',
            'source_kind',
            'stable_key',
            'source_label',
            'chat_db_path',
            'attachments_path',
          ]),
        );

        await ledgerDb.close();
      },
    );

    test('upgrades a v5 database to add ledger provenance columns', () async {
      final dbPath = '${tempDir.path}/import_test.db';
      final legacyDb = await openDatabase(dbPath);
      await legacyDb.execute(
        'CREATE TABLE schema_migrations (version INTEGER PRIMARY KEY, applied_at_utc TEXT NOT NULL)',
      );
      await legacyDb.execute(
        'CREATE TABLE import_batches (id INTEGER PRIMARY KEY, started_at_utc TEXT NOT NULL, finished_at_utc TEXT, source_chat_db TEXT, source_addressbook TEXT, host_info_json TEXT, notes TEXT)',
      );
      await legacyDb.execute(
        'CREATE TABLE historical_archive_sources (source_chat_db TEXT PRIMARY KEY, folder_path TEXT NOT NULL, source_label TEXT NOT NULL, chat_db_status_label TEXT NOT NULL, attachments_status_label TEXT NOT NULL, preflight_status_label TEXT NOT NULL, preflight_detail TEXT NOT NULL, total_messages INTEGER, total_chats INTEGER, total_handles INTEGER, missing_guids INTEGER, earliest_message_utc TEXT, latest_message_utc TEXT, dry_run_new_messages INTEGER, dry_run_duplicate_messages INTEGER, matched_imported_batch_count INTEGER, last_import_batch_id INTEGER, last_import_started_at_utc TEXT, last_import_finished_at_utc TEXT, last_import_success INTEGER, last_import_error TEXT, last_imported_message_count INTEGER, updated_at_utc TEXT NOT NULL)',
      );
      await legacyDb.execute(
        "CREATE TABLE handles (id INTEGER PRIMARY KEY, source_rowid INTEGER, service TEXT NOT NULL, raw_identifier TEXT NOT NULL, normalized_identifier TEXT, compound_identifier TEXT NOT NULL DEFAULT '', country TEXT, last_seen_utc TEXT, is_ignored INTEGER NOT NULL DEFAULT 0 CHECK(is_ignored IN (0,1)), batch_id INTEGER NOT NULL)",
      );
      await legacyDb.execute(
        'CREATE TABLE chats (id INTEGER PRIMARY KEY, source_rowid INTEGER, guid TEXT NOT NULL, service TEXT, display_name TEXT, is_group INTEGER NOT NULL DEFAULT 0 CHECK(is_group IN (0,1)), created_at_utc TEXT, updated_at_utc TEXT, is_ignored INTEGER NOT NULL DEFAULT 0 CHECK(is_ignored IN (0,1)), batch_id INTEGER NOT NULL, UNIQUE(guid))',
      );
      await legacyDb.execute(
        'CREATE TABLE messages (id INTEGER PRIMARY KEY, source_rowid INTEGER, guid TEXT NOT NULL, chat_id INTEGER NOT NULL, sender_handle_id INTEGER, service TEXT, is_from_me INTEGER NOT NULL CHECK(is_from_me IN (0,1)), date_utc TEXT, date_read_utc TEXT, date_delivered_utc TEXT, subject TEXT, text TEXT, attributed_body_blob BLOB, raw_item_type INTEGER, raw_associated_message_type INTEGER, message_summary_info_blob BLOB, payload_data_blob BLOB, has_attributed_body_source INTEGER NOT NULL DEFAULT 0 CHECK(has_attributed_body_source IN (0,1)), has_message_summary_info INTEGER NOT NULL DEFAULT 0 CHECK(has_message_summary_info IN (0,1)), has_payload_data_source INTEGER NOT NULL DEFAULT 0 CHECK(has_payload_data_source IN (0,1)), item_type TEXT, error_code INTEGER, is_system_message INTEGER NOT NULL DEFAULT 0 CHECK(is_system_message IN (0,1)), thread_originator_guid TEXT, associated_message_guid TEXT, balloon_bundle_id TEXT, payload_json TEXT, is_ignored INTEGER NOT NULL DEFAULT 0 CHECK(is_ignored IN (0,1)), batch_id INTEGER NOT NULL, UNIQUE(guid))',
      );
      await legacyDb.execute(
        'CREATE TABLE recovered_unlinked_messages (id INTEGER PRIMARY KEY, source_rowid INTEGER, guid TEXT NOT NULL, sender_handle_id INTEGER, service TEXT, is_from_me INTEGER NOT NULL CHECK(is_from_me IN (0,1)), date_utc TEXT, date_read_utc TEXT, date_delivered_utc TEXT, subject TEXT, text TEXT, attributed_body_blob BLOB, raw_item_type INTEGER, raw_associated_message_type INTEGER, message_summary_info_blob BLOB, payload_data_blob BLOB, has_attributed_body_source INTEGER NOT NULL DEFAULT 0 CHECK(has_attributed_body_source IN (0,1)), has_message_summary_info INTEGER NOT NULL DEFAULT 0 CHECK(has_message_summary_info IN (0,1)), has_payload_data_source INTEGER NOT NULL DEFAULT 0 CHECK(has_payload_data_source IN (0,1)), item_type TEXT, error_code INTEGER, is_system_message INTEGER NOT NULL DEFAULT 0 CHECK(is_system_message IN (0,1)), thread_originator_guid TEXT, associated_message_guid TEXT, balloon_bundle_id TEXT, payload_json TEXT, is_ignored INTEGER NOT NULL DEFAULT 0 CHECK(is_ignored IN (0,1)), batch_id INTEGER NOT NULL, UNIQUE(guid))',
      );
      await legacyDb.execute(
        'CREATE TABLE attachments (id INTEGER PRIMARY KEY, source_rowid INTEGER, guid TEXT, transfer_name TEXT, uti TEXT, mime_type TEXT, total_bytes INTEGER, is_sticker INTEGER NOT NULL DEFAULT 0 CHECK(is_sticker IN (0,1)), is_outgoing INTEGER CHECK(is_outgoing IN (0,1)), created_at_utc TEXT, local_path TEXT, sha256_hex TEXT, batch_id INTEGER NOT NULL)',
      );
      await legacyDb.execute('PRAGMA user_version = 5');
      await legacyDb.close();

      final upgradedDb = SqfliteImportDatabase(
        databaseDirectory: tempDir.path,
        databaseName: 'import_test.db',
        debugSettings: const ImportDebugSettingsState(),
      );

      final db = await upgradedDb.database;

      expect(
        await _columnNamesFor(db, 'import_batches'),
        contains('chat_source_id'),
      );
      expect(await _columnNamesFor(db, 'messages'), contains('source_id'));
      expect(await _columnNamesFor(db, 'chats'), contains('source_chat_rowid'));
      expect(
        await _columnNamesFor(db, 'handles'),
        contains('source_handle_rowid'),
      );
      expect(
        await _columnNamesFor(db, 'attachments'),
        contains('source_attachment_rowid'),
      );
      expect(
        await _columnNamesFor(db, 'historical_archive_sources'),
        contains('ledger_source_id'),
      );
      expect(
        await _columnNamesFor(db, 'ledger_sources'),
        contains('stable_key'),
      );

      await upgradedDb.close();
    });
  });
}

Future<List<String>> _columnNamesFor(Database db, String tableName) async {
  final rows = await db.rawQuery('PRAGMA table_info($tableName)');
  return <String>[
    for (final row in rows)
      if (row['name'] case final String columnName) columnName,
  ];
}
