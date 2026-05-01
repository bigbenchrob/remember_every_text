import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/core/util/paths_helper.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/db_importers/domain/ports/message_extractor_port.dart';
import 'package:remember_this_text/essentials/db_importers/feature_level_providers.dart';
import 'package:remember_this_text/providers.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('historical archive ledger import', () {
    late Directory tempDir;
    late String currentChatDbPath;
    late String archiveChatDbPath;
    late SqfliteImportDatabase ledgerDb;
    late ProviderContainer container;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'historical_archive_ledger_import_test',
      );
      currentChatDbPath = '${tempDir.path}/current_chat.db';
      archiveChatDbPath = '${tempDir.path}/Archive-2017-chat.db';

      await _createCurrentChatDb(currentChatDbPath);
      await _createArchiveChatDb(archiveChatDbPath);

      ledgerDb = SqfliteImportDatabase(
        databaseDirectory: tempDir.path,
        databaseName: 'macos_import.db',
        debugSettings: const ImportDebugSettingsState(),
      );

      container = ProviderContainer(
        overrides: <Override>[
          sqfliteImportDatabaseProvider.overrideWith((ref) async => ledgerDb),
          pathsHelperProvider.overrideWith(
            (ref) async => _FakePathsHelper(chatDbPath: currentChatDbPath),
          ),
          dbImportMessageExtractorProvider.overrideWith(
            (ref) => const _FakeMessageExtractor(),
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await ledgerDb.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'writes archive rows into macos_import.db with provenance, dedupe, and idempotent reimport',
      () async {
        final service = container.read(orchestratedLedgerImportServiceProvider);

        final currentResult = await service.runImport(
          executionOwner: 'archive-step6-current',
          sourceChatDbOverride: currentChatDbPath,
          includeContactImport: false,
          includeAttachmentImport: false,
        );
        expect(currentResult.success, isTrue);

        final archiveResult = await service.runImport(
          executionOwner: 'archive-step6-archive-1',
          sourceChatDbOverride: archiveChatDbPath,
          chatSourceKind: 'historical_archive',
          sourceLabelOverride: 'Archive-2017',
          includeContactImport: false,
          includeAttachmentImport: false,
        );
        expect(archiveResult.success, isTrue);

        final db = await ledgerDb.database;
        final batchRows = await db.query('import_batches', orderBy: 'id ASC');
        expect(batchRows, hasLength(2));

        final currentBatchRow = batchRows.first;
        final archiveBatchRow = batchRows.last;
        final currentSourceId = currentBatchRow['chat_source_id']! as int;
        final archiveSourceId = archiveBatchRow['chat_source_id']! as int;

        expect(currentBatchRow['chat_source_kind'], 'current_mac');
        expect(archiveBatchRow['chat_source_kind'], 'historical_archive');
        expect(archiveBatchRow['status'], 'succeeded');
        expect(archiveBatchRow['source_chat_db'], archiveChatDbPath);
        expect(archiveBatchRow['rows_deduplicated'], 2);
        expect(archiveBatchRow['rows_failed'], 1);

        expect(await ledgerDb.countRows('messages'), 2);
        expect(await ledgerDb.countRows('chats'), 1);
        expect(await ledgerDb.countRows('handles'), 2);
        expect(await ledgerDb.countRows('chat_to_message'), 2);
        expect(await ledgerDb.countRows('chat_to_handle'), 2);

        final sharedMessageRow = (await db.query(
          'messages',
          where: 'guid = ?',
          whereArgs: <Object>['shared-guid-1'],
        )).single;
        expect(sharedMessageRow['source_id'], currentSourceId);
        expect(sharedMessageRow['source_message_rowid'], 101);
        expect(sharedMessageRow['last_import_batch_id'], currentResult.batchId);

        final archiveOnlyMessageRow = (await db.query(
          'messages',
          where: 'guid = ?',
          whereArgs: <Object>['archive-only-guid-1'],
        )).single;
        expect(archiveOnlyMessageRow['id'], isNot(302));
        expect(archiveOnlyMessageRow['source_id'], archiveSourceId);
        expect(archiveOnlyMessageRow['source_message_rowid'], 302);
        expect(
          archiveOnlyMessageRow['first_import_batch_id'],
          archiveResult.batchId,
        );
        expect(
          archiveOnlyMessageRow['last_import_batch_id'],
          archiveResult.batchId,
        );

        final reimportResult = await service.runImport(
          executionOwner: 'archive-step6-archive-2',
          sourceChatDbOverride: archiveChatDbPath,
          chatSourceKind: 'historical_archive',
          sourceLabelOverride: 'Archive-2017',
          includeContactImport: false,
          includeAttachmentImport: false,
        );
        expect(reimportResult.success, isTrue);

        expect(await ledgerDb.countRows('messages'), 2);
        expect(await ledgerDb.countRows('chats'), 1);
        expect(await ledgerDb.countRows('handles'), 2);

        final archiveOnlyMessageAfterReimport = (await db.query(
          'messages',
          where: 'guid = ?',
          whereArgs: <Object>['archive-only-guid-1'],
        )).single;
        expect(
          archiveOnlyMessageAfterReimport['last_import_batch_id'],
          reimportResult.batchId,
        );

        final sharedMessageAfterReimport = (await db.query(
          'messages',
          where: 'guid = ?',
          whereArgs: <Object>['shared-guid-1'],
        )).single;
        expect(
          sharedMessageAfterReimport['last_import_batch_id'],
          currentResult.batchId,
        );

        final archiveReimportBatchRow = (await db.query(
          'import_batches',
          where: 'id = ?',
          whereArgs: <Object>[reimportResult.batchId],
        )).single;
        expect(
          archiveReimportBatchRow['chat_source_kind'],
          'historical_archive',
        );
        expect(archiveReimportBatchRow['status'], 'succeeded');
        expect(archiveReimportBatchRow['rows_failed'], 1);
      },
    );
  });
}

Future<void> _createCurrentChatDb(String dbPath) async {
  final db = await openDatabase(dbPath);
  try {
    await db.execute(
      'CREATE TABLE handle (ROWID INTEGER PRIMARY KEY, id TEXT, service TEXT, country TEXT, last_read_date INTEGER, last_use INTEGER)',
    );
    await db.execute(
      'CREATE TABLE chat (ROWID INTEGER PRIMARY KEY, guid TEXT, service_name TEXT, display_name TEXT, is_group INTEGER, creation_date INTEGER, last_read_message_timestamp INTEGER)',
    );
    await db.execute(
      'CREATE TABLE chat_handle_join (chat_id INTEGER NOT NULL, handle_id INTEGER NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE message (ROWID INTEGER PRIMARY KEY, guid TEXT, handle_id INTEGER, service TEXT, is_from_me INTEGER, date INTEGER, date_read INTEGER, date_delivered INTEGER, subject TEXT, text TEXT, attributedBody BLOB, message_summary_info BLOB, payload_data BLOB, item_type INTEGER, associated_message_type INTEGER, error INTEGER, is_system_message INTEGER, thread_originator_guid TEXT, associated_message_guid TEXT, balloon_bundle_id TEXT)',
    );
    await db.execute(
      'CREATE TABLE chat_message_join (chat_id INTEGER NOT NULL, message_id INTEGER NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE attachment (ROWID INTEGER PRIMARY KEY, guid TEXT, transfer_name TEXT, uti TEXT, mime_type TEXT, total_bytes INTEGER, is_sticker INTEGER, is_outgoing INTEGER, created_date INTEGER, filename TEXT)',
    );

    await db.insert('handle', <String, Object?>{
      'ROWID': 22,
      'id': 'current@example.com',
      'service': 'iMessage',
      'country': 'US',
    });
    await db.insert('chat', <String, Object?>{
      'ROWID': 17,
      'guid': 'chat-guid-shared-1',
      'service_name': 'iMessage',
      'display_name': 'Current Chat',
      'is_group': 0,
      'creation_date': 0,
      'last_read_message_timestamp': 0,
    });
    await db.insert('chat_handle_join', <String, Object?>{
      'chat_id': 17,
      'handle_id': 22,
    });
    await db.insert('message', <String, Object?>{
      'ROWID': 101,
      'guid': 'shared-guid-1',
      'handle_id': 22,
      'service': 'iMessage',
      'is_from_me': 0,
      'date': 0,
      'date_read': 0,
      'date_delivered': 0,
      'text': 'Current shared message',
      'item_type': 0,
      'associated_message_type': 0,
      'is_system_message': 0,
    });
    await db.insert('chat_message_join', <String, Object?>{
      'chat_id': 17,
      'message_id': 101,
    });
  } finally {
    await db.close();
  }
}

Future<void> _createArchiveChatDb(String dbPath) async {
  final db = await openDatabase(dbPath);
  try {
    await db.execute(
      'CREATE TABLE handle (ROWID INTEGER PRIMARY KEY, id TEXT, service TEXT, country TEXT, last_read_date INTEGER, last_use INTEGER)',
    );
    await db.execute(
      'CREATE TABLE chat (ROWID INTEGER PRIMARY KEY, guid TEXT, service_name TEXT, display_name TEXT, is_group INTEGER, creation_date INTEGER, last_read_message_timestamp INTEGER)',
    );
    await db.execute(
      'CREATE TABLE chat_handle_join (chat_id INTEGER NOT NULL, handle_id INTEGER NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE message (ROWID INTEGER PRIMARY KEY, guid TEXT, handle_id INTEGER, service TEXT, is_from_me INTEGER, date INTEGER, date_read INTEGER, date_delivered INTEGER, subject TEXT, text TEXT, attributedBody BLOB, message_summary_info BLOB, payload_data BLOB, item_type INTEGER, associated_message_type INTEGER, error INTEGER, is_system_message INTEGER, thread_originator_guid TEXT, associated_message_guid TEXT, balloon_bundle_id TEXT)',
    );
    await db.execute(
      'CREATE TABLE chat_message_join (chat_id INTEGER NOT NULL, message_id INTEGER NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE attachment (ROWID INTEGER PRIMARY KEY, guid TEXT, transfer_name TEXT, uti TEXT, mime_type TEXT, total_bytes INTEGER, is_sticker INTEGER, is_outgoing INTEGER, created_date INTEGER, filename TEXT)',
    );

    await db.insert('handle', <String, Object?>{
      'ROWID': 44,
      'id': 'archive@example.com',
      'service': 'iMessage',
      'country': 'US',
    });
    await db.insert('chat', <String, Object?>{
      'ROWID': 201,
      'guid': 'chat-guid-shared-1',
      'service_name': 'iMessage',
      'display_name': 'Archive Chat',
      'is_group': 0,
      'creation_date': 0,
      'last_read_message_timestamp': 0,
    });
    await db.insert('chat_handle_join', <String, Object?>{
      'chat_id': 201,
      'handle_id': 44,
    });
    await db.insert('message', <String, Object?>{
      'ROWID': 301,
      'guid': 'shared-guid-1',
      'handle_id': 44,
      'service': 'iMessage',
      'is_from_me': 0,
      'date': 0,
      'date_read': 0,
      'date_delivered': 0,
      'text': 'Archive duplicate shared message',
      'item_type': 0,
      'associated_message_type': 0,
      'is_system_message': 0,
    });
    await db.insert('message', <String, Object?>{
      'ROWID': 302,
      'guid': 'archive-only-guid-1',
      'handle_id': 44,
      'service': 'iMessage',
      'is_from_me': 0,
      'date': 0,
      'date_read': 0,
      'date_delivered': 0,
      'text': 'Archive only message',
      'item_type': 0,
      'associated_message_type': 0,
      'is_system_message': 0,
    });
    await db.insert('message', <String, Object?>{
      'ROWID': 303,
      'guid': null,
      'handle_id': 44,
      'service': 'iMessage',
      'is_from_me': 0,
      'date': 0,
      'date_read': 0,
      'date_delivered': 0,
      'text': 'Missing guid message',
      'item_type': 0,
      'associated_message_type': 0,
      'is_system_message': 0,
    });
    await db.insert('chat_message_join', <String, Object?>{
      'chat_id': 201,
      'message_id': 301,
    });
    await db.insert('chat_message_join', <String, Object?>{
      'chat_id': 201,
      'message_id': 302,
    });
    await db.insert('chat_message_join', <String, Object?>{
      'chat_id': 201,
      'message_id': 303,
    });
  } finally {
    await db.close();
  }
}

class _FakePathsHelper implements PathsHelper {
  _FakePathsHelper({required String chatDbPath}) : _chatDbPath = chatDbPath;

  final String _chatDbPath;

  @override
  String get applicationDocumentsPath => '/tmp';

  @override
  String get chatDBPath => _chatDbPath;

  @override
  String? get downloadsPath => '/tmp';

  @override
  String get libraryPath => '/tmp';

  @override
  String get temporaryPath => '/tmp';

  @override
  String getUserName() {
    return 'test-user';
  }

  @override
  String stripTilde(String path) {
    return path.startsWith('~') ? path.replaceFirst('~', '/Users/test') : path;
  }

  @override
  String userGraft(String graft) {
    return '/Users/test/$graft';
  }
}

class _FakeMessageExtractor implements MessageExtractorPort {
  const _FakeMessageExtractor();

  @override
  Future<Map<int, String>> extractAllMessageTexts({
    int? limit,
    String? dbPath,
  }) async {
    return const <int, String>{};
  }

  @override
  Future<bool> isAvailable() async {
    return true;
  }
}
