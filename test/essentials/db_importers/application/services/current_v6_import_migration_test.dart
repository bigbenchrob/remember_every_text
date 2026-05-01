import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/core/util/date_converter.dart';
import 'package:remember_this_text/core/util/paths_helper.dart';
import 'package:remember_this_text/domain_driven_development/value_objects.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/db_importers/domain/ports/message_extractor_port.dart';
import 'package:remember_this_text/essentials/db_importers/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db_migrate/feature_level_providers.dart';
import 'package:remember_this_text/essentials/search/feature_level_providers.dart';
import 'package:remember_this_text/features/address_book_folders/domain/entities/address_book_folder_aggregate.dart';
import 'package:remember_this_text/features/address_book_folders/domain/entities/address_book_folder_entity.dart';
import 'package:remember_this_text/features/address_book_folders/domain/failures/more_failures/failures.dart';
import 'package:remember_this_text/features/address_book_folders/domain/value_objects/value_objects.dart';
import 'package:remember_this_text/features/address_book_folders/feature_level_providers.dart';
import 'package:remember_this_text/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _expectedUnixTimestamp = 1704164645;
const _expectedWorkingTimestamp = '2024-01-02T03:04:05Z';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('current v6 import and migration pipeline', () {
    late Directory tempDir;
    late String chatDbPath;
    late String addressBookPath;
    late SqfliteImportDatabase ledgerDb;
    late WorkingDatabase workingDb;
    late OverlayDatabase overlayDb;
    late SharedPreferences preferences;
    late ProviderContainer container;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'current_v6_import_migration_test',
      );
      chatDbPath = '${tempDir.path}/chat.db';
      addressBookPath = '${tempDir.path}/AddressBook-v22.abcddb';

      await _createCurrentMacChatDb(chatDbPath);
      await _createAddressBookDb(addressBookPath);

      ledgerDb = SqfliteImportDatabase(
        databaseDirectory: tempDir.path,
        databaseName: 'macos_import.db',
        debugSettings: const ImportDebugSettingsState(),
      );
      workingDb = WorkingDatabase(NativeDatabase.memory());
      await workingDb.customStatement('PRAGMA foreign_keys = ON');
      overlayDb = OverlayDatabase(NativeDatabase.memory());

      SharedPreferences.setMockInitialValues(<String, Object>{});
      preferences = await SharedPreferences.getInstance();

      container = ProviderContainer(
        overrides: <Override>[
          sqfliteImportDatabaseProvider.overrideWith((ref) async => ledgerDb),
          driftWorkingDatabaseProvider.overrideWith((ref) async => workingDb),
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
          sharedPreferencesProvider.overrideWith((ref) async => preferences),
          pathsHelperProvider.overrideWith(
            (ref) async => _FakePathsHelper(chatDbPath: chatDbPath),
          ),
          futureGetFolderAggregateProvider.overrideWith(
            (ref) async =>
                right<FolderRetrievalFailure, AddressBookFolderAggregate>(
                  _addressBookAggregate(addressBookPath),
                ),
          ),
          dbImportMessageExtractorProvider.overrideWith(
            (ref) => const _FakeMessageExtractor(),
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await overlayDb.close();
      await workingDb.close();
      await ledgerDb.deleteDatabaseFile();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'fresh current import writes surrogate ledger ids while preserving source rowids separately',
      () async {
        final service = container.read(orchestratedLedgerImportServiceProvider);

        final result = await service.runImport(
          executionOwner: 'step2-current-import-test',
          sourceChatDbOverride: chatDbPath,
        );

        expect(result.success, isTrue);
        expect(result.batchId, greaterThan(0));

        final db = await ledgerDb.database;
        expect(await _countRows(db, 'import_batches'), 1);
        expect(await _countRows(db, 'handles'), 1);
        expect(await _countRows(db, 'chats'), 1);
        expect(await _countRows(db, 'messages'), 1);
        expect(await _countRows(db, 'attachments'), 1);
        expect(await _countRows(db, 'contacts'), 1);
        expect(await _countRows(db, 'contact_to_chat_handle'), 1);
        expect(await _countRows(db, 'chat_to_handle'), 1);
        expect(await _countRows(db, 'chat_to_message'), 1);
        expect(await _countRows(db, 'message_attachments'), 1);

        final batchRow = (await db.query('import_batches')).single;
        expect(batchRow['source_chat_db'], chatDbPath);
        expect(batchRow['chat_source_id'], isNotNull);
        expect(batchRow['chat_source_kind'], 'current_mac');
        expect(batchRow['status'], 'succeeded');
        expect(batchRow['started_at'], isNotNull);
        expect(batchRow['finished_at'], isNotNull);

        final ledgerSourceRow = (await db.query('ledger_sources')).single;
        expect(ledgerSourceRow['id'], batchRow['chat_source_id']);
        expect(ledgerSourceRow['source_kind'], 'current_mac');
        expect(ledgerSourceRow['chat_db_path'], chatDbPath);

        final handleRow = (await db.query('handles')).single;
        expect(handleRow['id'], isNot(22));
        expect(handleRow['source_rowid'], isNull);
        expect(handleRow['source_handle_rowid'], 22);
        expect(handleRow['source_id'], batchRow['chat_source_id']);
        expect(handleRow['first_import_batch_id'], result.batchId);
        expect(handleRow['last_import_batch_id'], result.batchId);

        final chatRow = (await db.query('chats')).single;
        expect(chatRow['id'], isNot(17));
        expect(chatRow['source_rowid'], isNull);
        expect(chatRow['source_chat_rowid'], 17);
        expect(chatRow['created_at_utc'], _expectedUnixTimestamp);
        expect(chatRow['updated_at_utc'], _expectedUnixTimestamp);
        expect(chatRow['source_id'], batchRow['chat_source_id']);
        expect(chatRow['first_import_batch_id'], result.batchId);
        expect(chatRow['last_import_batch_id'], result.batchId);

        final messageRow = (await db.query('messages')).single;
        expect(messageRow['text'], 'Current pipeline regression coverage');
        expect(messageRow['id'], isNot(101));
        expect(messageRow['chat_id'], chatRow['id']);
        expect(messageRow['sender_handle_id'], handleRow['id']);
        expect(messageRow['source_rowid'], isNull);
        expect(messageRow['date_utc'], _expectedUnixTimestamp);
        expect(messageRow['date_utc'], isNot(isA<String>()));
        expect(messageRow['source_message_rowid'], 101);
        expect(messageRow['source_id'], batchRow['chat_source_id']);
        expect(messageRow['first_import_batch_id'], result.batchId);
        expect(messageRow['last_import_batch_id'], result.batchId);

        final attachmentRow = (await db.query('attachments')).single;
        expect(attachmentRow['id'], isNot(303));
        expect(attachmentRow['source_rowid'], isNull);
        expect(attachmentRow['created_at_utc'], _expectedUnixTimestamp);
        expect(attachmentRow['created_at_utc'], isNot(isA<String>()));
        expect(attachmentRow['source_attachment_rowid'], 303);
        expect(attachmentRow['source_id'], batchRow['chat_source_id']);
        expect(attachmentRow['first_import_batch_id'], result.batchId);
        expect(attachmentRow['last_import_batch_id'], result.batchId);

        final chatMembershipRow = (await db.query('chat_to_handle')).single;
        expect(chatMembershipRow['chat_id'], chatRow['id']);
        expect(chatMembershipRow['handle_id'], handleRow['id']);

        final chatMessageRow = (await db.query('chat_to_message')).single;
        expect(chatMessageRow['chat_id'], chatRow['id']);
        expect(chatMessageRow['message_id'], messageRow['id']);

        final messageAttachmentRow = (await db.query(
          'message_attachments',
        )).single;
        expect(messageAttachmentRow['message_id'], messageRow['id']);
        expect(messageAttachmentRow['attachment_id'], attachmentRow['id']);
      },
    );

    test(
      'migration still builds working.db from v6 ledger with surrogate ledger ids',
      () async {
        final importService = container.read(
          orchestratedLedgerImportServiceProvider,
        );
        final importResult = await importService.runImport(
          executionOwner: 'step2-current-migration-test',
          sourceChatDbOverride: chatDbPath,
        );

        expect(importResult.success, isTrue);

        final importSqlite = await ledgerDb.database;
        final importedMessageRow = (await importSqlite.query(
          'messages',
        )).single;
        expect(importedMessageRow['id'], isNot(101));
        expect(importedMessageRow['source_message_rowid'], 101);
        expect(importedMessageRow['source_id'], isNotNull);
        expect(
          importedMessageRow['first_import_batch_id'],
          importResult.batchId,
        );
        expect(
          importedMessageRow['last_import_batch_id'],
          importResult.batchId,
        );

        final importedAttachmentRow = (await importSqlite.query(
          'attachments',
        )).single;
        expect(importedAttachmentRow['id'], isNot(303));
        expect(importedAttachmentRow['source_attachment_rowid'], 303);
        expect(importedAttachmentRow['source_id'], isNotNull);
        expect(
          importedAttachmentRow['first_import_batch_id'],
          importResult.batchId,
        );
        expect(
          importedAttachmentRow['last_import_batch_id'],
          importResult.batchId,
        );

        final migrationService = container.read(
          handlesMigrationServiceProvider,
        );
        final migrationResult = await migrationService.run();

        expect(migrationResult.success, isTrue);
        expect(migrationResult.messagesProjected, 1);
        expect(migrationResult.chatsProjected, 1);
        expect(migrationResult.identitiesProjected, 1);
        expect(migrationResult.attachmentsProjected, 1);

        final workingMessages = await workingDb.customSelect('''
          SELECT id, guid, text, sent_at_utc
          FROM messages
        ''').get();
        expect(workingMessages, hasLength(1));
        expect(
          workingMessages.single.data['text'],
          'Current pipeline regression coverage',
        );
        expect(
          workingMessages.single.data['sent_at_utc'],
          _expectedWorkingTimestamp,
        );

        final workingChats = await workingDb.customSelect('''
          SELECT created_at_utc, updated_at_utc
          FROM chats
        ''').get();
        expect(workingChats, hasLength(1));
        expect(
          workingChats.single.data['created_at_utc'],
          _expectedWorkingTimestamp,
        );
        expect(
          workingChats.single.data['updated_at_utc'],
          _expectedWorkingTimestamp,
        );

        final workingAttachments = await workingDb.customSelect('''
          SELECT created_at_utc
          FROM attachments
        ''').get();
        expect(workingAttachments, hasLength(1));
        expect(
          workingAttachments.single.data['created_at_utc'],
          _expectedWorkingTimestamp,
        );

        final globalIndexCount = await _workingCount(
          workingDb,
          'global_message_index',
        );
        final contactIndexCount = await _workingCount(
          workingDb,
          'contact_message_index',
        );
        expect(globalIndexCount, 1);
        expect(contactIndexCount, 1);

        final ftsCount = await _workingCount(workingDb, 'messages_fts');
        expect(ftsCount, 1);

        final searchService = container.read(searchServiceProvider);
        final searchResultIds = await searchService.searchGlobalMessageIds(
          query: 'pipeline regression',
        );
        expect(searchResultIds, hasLength(1));
        expect(searchResultIds.single, 1);
      },
    );
  });
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

AddressBookFolderAggregate _addressBookAggregate(String addressBookPath) {
  return AddressBookFolderAggregate(<AddressBookFolderEntity>[
    AddressBookFolderEntity(
      path: FolderPathValueObject(addressBookPath),
      shortPath: AddressBookFolderShortPath('TEST-SOURCE'),
      lastCreationDate: FolderCreationDate(DateTime.utc(2026, 4, 30)),
      lastModificationDate: FolderModificationDate(DateTime.utc(2026, 4, 30)),
      recordCount: NonZeroInt(1),
    ),
  ]);
}

Future<void> _createCurrentMacChatDb(String dbPath) async {
  final db = await openDatabase(dbPath);
  try {
    final appleTimestamp = DateConverter.unix2Apple(_expectedUnixTimestamp);

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
    await db.execute(
      'CREATE TABLE message_attachment_join (message_id INTEGER NOT NULL, attachment_id INTEGER NOT NULL)',
    );

    await db.insert('handle', <String, Object?>{
      'ROWID': 22,
      'id': 'pipeline@example.com',
      'service': 'iMessage',
      'country': 'US',
    });
    await db.insert('chat', <String, Object?>{
      'ROWID': 17,
      'guid': 'chat-guid-1',
      'service_name': 'iMessage',
      'display_name': 'Pipeline Chat',
      'is_group': 0,
      'creation_date': appleTimestamp,
      'last_read_message_timestamp': appleTimestamp,
    });
    await db.insert('chat_handle_join', <String, Object?>{
      'chat_id': 17,
      'handle_id': 22,
    });
    await db.insert('message', <String, Object?>{
      'ROWID': 101,
      'guid': 'message-guid-1',
      'handle_id': 22,
      'service': 'iMessage',
      'is_from_me': 0,
      'date': appleTimestamp,
      'date_read': appleTimestamp,
      'date_delivered': appleTimestamp,
      'text': 'Current pipeline regression coverage',
      'item_type': 0,
      'associated_message_type': 0,
      'is_system_message': 0,
    });
    await db.insert('chat_message_join', <String, Object?>{
      'chat_id': 17,
      'message_id': 101,
    });
    await db.insert('attachment', <String, Object?>{
      'ROWID': 303,
      'guid': 'attachment-guid-1',
      'transfer_name': 'pipeline.txt',
      'mime_type': 'text/plain',
      'created_date': appleTimestamp,
      'filename': '/tmp/pipeline.txt',
    });
    await db.insert('message_attachment_join', <String, Object?>{
      'message_id': 101,
      'attachment_id': 303,
    });
  } finally {
    await db.close();
  }
}

Future<void> _createAddressBookDb(String dbPath) async {
  final db = await openDatabase(dbPath);
  try {
    await db.execute(
      'CREATE TABLE ZABCDRECORD (Z_PK INTEGER PRIMARY KEY, ZFIRSTNAME TEXT, ZMIDDLENAME TEXT, ZLASTNAME TEXT, ZORGANIZATION TEXT, ZNICKNAME TEXT, ZCREATIONDATE INTEGER)',
    );
    await db.execute(
      'CREATE TABLE ZABCDEMAILADDRESS (ZOWNER INTEGER, ZADDRESSNORMALIZED TEXT, ZADDRESS TEXT, ZLABEL TEXT)',
    );
    await db.execute(
      'CREATE TABLE ZABCDPHONENUMBER (ZOWNER INTEGER, ZFULLNUMBER TEXT, ZVALUE TEXT, ZLABEL TEXT)',
    );

    await db.insert('ZABCDRECORD', <String, Object?>{
      'Z_PK': 1,
      'ZFIRSTNAME': 'Pipeline',
      'ZLASTNAME': 'Contact',
      'ZNICKNAME': 'Pipe',
      'ZCREATIONDATE': 0,
    });
    await db.insert('ZABCDEMAILADDRESS', <String, Object?>{
      'ZOWNER': 1,
      'ZADDRESSNORMALIZED': 'pipeline@example.com',
      'ZADDRESS': 'pipeline@example.com',
      'ZLABEL': 'home',
    });
  } finally {
    await db.close();
  }
}

Future<int> _countRows(Database db, String tableName) async {
  final rows = await db.rawQuery('SELECT COUNT(*) AS c FROM $tableName');
  return (rows.single['c'] as int?) ?? 0;
}

Future<int> _workingCount(WorkingDatabase db, String tableName) async {
  final rows = await db
      .customSelect('SELECT COUNT(*) AS c FROM $tableName')
      .get();
  return (rows.single.data['c'] as int?) ?? 0;
}
