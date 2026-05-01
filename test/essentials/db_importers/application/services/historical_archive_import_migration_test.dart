import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/core/util/date_converter.dart';
import 'package:remember_this_text/core/util/paths_helper.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers/message_data_version_provider.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/db_importers/domain/ports/message_extractor_port.dart';
import 'package:remember_this_text/essentials/db_importers/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db_migrate/feature_level_providers.dart';
import 'package:remember_this_text/essentials/search/feature_level_providers.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/resolver_tools/global_messages_heatmap_provider.dart';
import 'package:remember_this_text/features/messages/domain/value_objects/message_timeline_scope.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/timeline/timeline_metadata_provider.dart';
import 'package:remember_this_text/providers.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _currentUnixTimestamp = 1704164645;
const _archiveUnixTimestamp = 1494028800;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('historical archive import + migration', () {
    late Directory tempDir;
    late Directory archiveFolder;
    late String currentChatDbPath;
    late String archiveChatDbPath;
    late SqfliteImportDatabase ledgerDb;
    late WorkingDatabase workingDb;
    late OverlayDatabase overlayDb;
    late ProviderContainer container;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'historical_archive_import_migration_test',
      );
      archiveFolder = Directory('${tempDir.path}/Archive-2017')..createSync();
      currentChatDbPath = '${tempDir.path}/chat.db';
      archiveChatDbPath = '${archiveFolder.path}/chat.db';

      await _createCurrentChatDb(currentChatDbPath);
      await _createArchiveChatDb(archiveChatDbPath);

      ledgerDb = SqfliteImportDatabase(
        databaseDirectory: tempDir.path,
        databaseName: 'macos_import.db',
        debugSettings: const ImportDebugSettingsState(),
      );
      workingDb = WorkingDatabase(NativeDatabase.memory());
      await workingDb.customStatement('PRAGMA foreign_keys = ON');
      overlayDb = OverlayDatabase(NativeDatabase.memory());

      container = ProviderContainer(
        overrides: <Override>[
          sqfliteImportDatabaseProvider.overrideWith((ref) async => ledgerDb),
          driftWorkingDatabaseProvider.overrideWith((ref) async => workingDb),
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
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
      await overlayDb.close();
      await workingDb.close();
      await ledgerDb.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'archive rows stay out of working.db until migration, then appear through timeline heatmap and search providers',
      () async {
        final importService = container.read(
          orchestratedLedgerImportServiceProvider,
        );
        final migrationService = container.read(
          handlesMigrationServiceProvider,
        );
        const globalScope = MessageTimelineScope.global();

        final currentImportResult = await importService.runImport(
          executionOwner: 'historical-archive-current-import',
          sourceChatDbOverride: currentChatDbPath,
          includeContactImport: false,
          includeAttachmentImport: false,
        );
        expect(currentImportResult.success, isTrue);

        final currentMigrationResult = await migrationService.run();
        expect(currentMigrationResult.success, isTrue);
        container.read(messageDataVersionProvider.notifier).bump();

        expect(await _workingMessageCount(workingDb), 1);

        final timelineBeforeArchive = await container.read(
          timelineMetadataProvider(scope: globalScope).future,
        );
        final heatmapBeforeArchive = await container.read(
          globalMessagesHeatmapProvider.future,
        );
        final searchService = container.read(searchServiceProvider);
        final archiveSearchBeforeImport = await searchService
            .searchGlobalMessageIds(query: 'Archive only');

        expect(timelineBeforeArchive.totalMessages, 1);
        expect(heatmapBeforeArchive?.totalMessages, 1);
        expect(archiveSearchBeforeImport, isEmpty);

        final archiveImportResult = await importService.runImport(
          executionOwner: 'historical-archive-ledger-import',
          sourceChatDbOverride: archiveChatDbPath,
          chatSourceKind: 'historical_archive',
          sourceLabelOverride: 'Archive-2017',
          includeContactImport: false,
          includeAttachmentImport: false,
        );
        expect(archiveImportResult.success, isTrue);

        expect(await _workingMessageCount(workingDb), 1);

        final timelineAfterLedgerOnly = await container.read(
          timelineMetadataProvider(scope: globalScope).future,
        );
        final heatmapAfterLedgerOnly = await container.read(
          globalMessagesHeatmapProvider.future,
        );
        final archiveSearchAfterLedgerOnly = await searchService
            .searchGlobalMessageIds(query: 'Archive only');

        expect(timelineAfterLedgerOnly.totalMessages, 1);
        expect(heatmapAfterLedgerOnly?.totalMessages, 1);
        expect(archiveSearchAfterLedgerOnly, isEmpty);

        final archiveMigrationResult = await migrationService.run(
          incrementalMode: true,
        );
        expect(archiveMigrationResult.success, isTrue);
        container.read(messageDataVersionProvider.notifier).bump();

        expect(await _workingMessageCount(workingDb), 2);

        final timelineAfterMigration = await container.read(
          timelineMetadataProvider(scope: globalScope).future,
        );
        final heatmapAfterMigration = await container.read(
          globalMessagesHeatmapProvider.future,
        );
        final archiveSearchAfterMigration = await searchService
            .searchGlobalMessageIds(query: 'Archive only');

        expect(timelineAfterMigration.totalMessages, 2);
        expect(timelineAfterMigration.firstMessageDate?.year, 2017);
        expect(timelineAfterMigration.lastMessageDate?.year, 2024);
        expect(heatmapAfterMigration, isNotNull);
        expect(heatmapAfterMigration!.totalMessages, 2);
        expect(heatmapAfterMigration.firstMessageDate.year, 2017);
        expect(heatmapAfterMigration.lastMessageDate.year, 2024);
        expect(archiveSearchAfterMigration, hasLength(1));

        final archiveReimportResult = await importService.runImport(
          executionOwner: 'historical-archive-ledger-reimport',
          sourceChatDbOverride: archiveChatDbPath,
          chatSourceKind: 'historical_archive',
          sourceLabelOverride: 'Archive-2017',
          includeContactImport: false,
          includeAttachmentImport: false,
        );
        expect(archiveReimportResult.success, isTrue);
        expect(await _workingMessageCount(workingDb), 2);

        final archiveRemigrationResult = await migrationService.run(
          incrementalMode: true,
        );
        expect(archiveRemigrationResult.success, isTrue);
        container.read(messageDataVersionProvider.notifier).bump();

        expect(await _workingMessageCount(workingDb), 2);
        final timelineAfterReimport = await container.read(
          timelineMetadataProvider(scope: globalScope).future,
        );
        final heatmapAfterReimport = await container.read(
          globalMessagesHeatmapProvider.future,
        );
        final archiveSearchAfterReimport = await searchService
            .searchGlobalMessageIds(query: 'Archive only');

        expect(timelineAfterReimport.totalMessages, 2);
        expect(heatmapAfterReimport?.totalMessages, 2);
        expect(archiveSearchAfterReimport, hasLength(1));
      },
    );
  });
}

Future<int> _workingMessageCount(WorkingDatabase workingDb) async {
  final row = await workingDb
      .customSelect('SELECT COUNT(*) AS c FROM messages')
      .getSingle();
  return row.read<int>('c');
}

Future<void> _createCurrentChatDb(String dbPath) async {
  final db = await openDatabase(dbPath);
  try {
    final appleTimestamp = DateConverter.unix2Apple(_currentUnixTimestamp);

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
      'creation_date': appleTimestamp,
      'last_read_message_timestamp': appleTimestamp,
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
      'date': appleTimestamp,
      'date_read': appleTimestamp,
      'date_delivered': appleTimestamp,
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
    final appleTimestamp = DateConverter.unix2Apple(_archiveUnixTimestamp);

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
      'creation_date': appleTimestamp,
      'last_read_message_timestamp': appleTimestamp,
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
      'date': appleTimestamp,
      'date_read': appleTimestamp,
      'date_delivered': appleTimestamp,
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
      'date': appleTimestamp,
      'date_read': appleTimestamp,
      'date_delivered': appleTimestamp,
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
      'date': appleTimestamp,
      'date_read': appleTimestamp,
      'date_delivered': appleTimestamp,
      'text': 'Archive missing guid message',
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
