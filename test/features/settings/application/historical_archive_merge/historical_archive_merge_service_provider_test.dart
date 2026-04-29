// ignore_for_file: unnecessary_string_escapes

import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/core/util/date_converter.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/logging/application/app_logger.dart';
import 'package:remember_this_text/essentials/logging/domain/log_entry.dart';
import 'package:remember_this_text/features/settings/application/historical_archive_merge/historical_archive_merge_service_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('HistoricalArchiveMergeService', () {
    late WorkingDatabase workingDb;
    late SqfliteImportDatabase archiveImportDb;
    late Directory archiveImportDirectory;
    late ProviderContainer container;

    setUp(() async {
      workingDb = WorkingDatabase(NativeDatabase.memory());
      archiveImportDirectory = await Directory.systemTemp.createTemp(
        'historical-archive-import-db-',
      );
      archiveImportDb = SqfliteImportDatabase(
        databaseDirectory: archiveImportDirectory.path,
        databaseName: 'historical_archive_import_test.db',
        debugSettings: const ImportDebugSettingsState(),
      );
      await archiveImportDb.database;
      container = ProviderContainer(
        overrides: [
          driftWorkingDatabaseProvider.overrideWith((ref) async => workingDb),
          historicalArchiveImportDatabaseProvider.overrideWith(
            (ref) async => archiveImportDb,
          ),
          appLoggerProvider.overrideWith(_TestAppLogger.new),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await archiveImportDb.close();
      await workingDb.close();
      if (archiveImportDirectory.existsSync()) {
        await archiveImportDirectory.delete(recursive: true);
      }
    });

    test('reports a missing chat.db archive as non-importable', () async {
      final archiveDir = await Directory.systemTemp.createTemp(
        'historical-archive-missing-chatdb-',
      );
      addTearDown(() async {
        if (archiveDir.existsSync()) {
          await archiveDir.delete(recursive: true);
        }
      });

      final service = container.read(historicalArchiveMergeServiceProvider);
      final summary = await service.runPreflightForFolder(archiveDir.path);

      expect(summary.canImport, isFalse);
      expect(summary.totalMessages, 0);
      expect(summary.warnings.first, contains('does not contain chat.db'));
    });

    test('summarizes a minimal valid archive and counts duplicates by guid', () async {
      await workingDb.customStatement(
        "INSERT INTO recovered_unlinked_messages (id, guid, service) VALUES (1, 'dup-guid', 'Unknown')",
      );

      final archiveDir = await Directory.systemTemp.createTemp(
        'historical-archive-valid-',
      );
      addTearDown(() async {
        if (archiveDir.existsSync()) {
          await archiveDir.delete(recursive: true);
        }
      });

      final chatDbPath = '${archiveDir.path}/chat.db';
      final archiveDb = sqlite3.sqlite3.open(chatDbPath);
      try {
        archiveDb.execute('CREATE TABLE message (guid TEXT, date INTEGER)');
        archiveDb.execute(
          "INSERT INTO message (guid, date) VALUES ('dup-guid', 315532800000000000)",
        );
        archiveDb.execute(
          "INSERT INTO message (guid, date) VALUES ('new-guid', 347155200000000000)",
        );
        archiveDb.execute(
          'INSERT INTO message (guid, date) VALUES (NULL, 347241600000000000)',
        );
      } finally {
        archiveDb.dispose();
      }

      final service = container.read(historicalArchiveMergeServiceProvider);
      final summary = await service.runPreflightForFolder(archiveDir.path);

      expect(summary.canImport, isTrue);
      expect(summary.totalMessages, 3);
      expect(summary.duplicateMessages, 1);
      expect(summary.newMessages, 1);
      expect(summary.rowsWithoutGuidCount, 1);
      expect(summary.earliestDate, isNotNull);
      expect(summary.latestDate, isNotNull);
    });

    test('imports a minimal valid archive into the dedicated archive ledger', () async {
      await workingDb.customStatement(
        "INSERT INTO recovered_unlinked_messages (id, guid, service) VALUES (1, 'dup-guid', 'Unknown')",
      );

      final archiveDir = await Directory.systemTemp.createTemp(
        'historical-archive-import-',
      );
      addTearDown(() async {
        if (archiveDir.existsSync()) {
          await archiveDir.delete(recursive: true);
        }
      });

      final chatDbPath = '${archiveDir.path}/chat.db';
      final archiveDb = sqlite3.sqlite3.open(chatDbPath);
      try {
        archiveDb.execute(
          'CREATE TABLE message (guid TEXT, date INTEGER, service TEXT, is_from_me INTEGER, text TEXT)',
        );
        archiveDb.execute(
          "INSERT INTO message (guid, date, service, is_from_me, text) VALUES ('dup-guid', 315532800000000000, 'iMessage', 0, 'duplicate')",
        );
        archiveDb.execute(
          "INSERT INTO message (guid, date, service, is_from_me, text) VALUES ('new-guid', 347155200000000000, 'iMessage', 1, 'hello archive')",
        );
        archiveDb.execute(
          'INSERT INTO message (guid, date, service, is_from_me, text) VALUES (NULL, 347241600000000000, \"iMessage\", 0, \"missing guid\")',
        );
      } finally {
        archiveDb.dispose();
      }

      final service = container.read(historicalArchiveMergeServiceProvider);
      final result = await service.importArchiveForFutureMerge(
        archivePath: archiveDir.path,
        archiveLabel: archiveDir.uri.pathSegments
            .where((segment) => segment.isNotEmpty)
            .last,
      );

      expect(result.importedMessages, 1);
      expect(result.skippedDuplicates, 1);
      expect(result.failedRows, 1);
      expect(result.rowsWithoutGuidCount, 1);
      expect(result.batchId, isNotNull);

      final stagedRows = await archiveImportDb.rawQuery(
        'SELECT guid, text FROM recovered_unlinked_messages',
      );
      expect(stagedRows, hasLength(1));
      expect(stagedRows.first['guid'], 'new-guid');
      expect(stagedRows.first['text'], 'hello archive');

      final workingRows = await workingDb
          .select(workingDb.workingMessages)
          .get();
      expect(workingRows, hasLength(1));
      expect(workingRows.first.guid, 'new-guid');
      expect(workingRows.first.textContent, 'hello archive');
      expect(
        workingRows.first.sourceProvenance,
        startsWith('archive_historical_archive_import_'),
      );
      expect(workingRows.first.importBatchId, result.batchId);

      final globalIndexRows = await workingDb
          .select(workingDb.globalMessageIndex)
          .get();
      expect(globalIndexRows, hasLength(1));
      expect(globalIndexRows.first.messageId, workingRows.first.id);
    });

    test(
      'imports second-resolution archive dates with the expected UTC timestamp',
      () async {
        final archiveDir = await Directory.systemTemp.createTemp(
          'historical-archive-seconds-date-',
        );
        addTearDown(() async {
          if (archiveDir.existsSync()) {
            await archiveDir.delete(recursive: true);
          }
        });

        final chatDbPath = '${archiveDir.path}/chat.db';
        final archiveDb = sqlite3.sqlite3.open(chatDbPath);
        final july2012AppleSeconds = DateConverter.apple2CoreTS(
          DateConverter.dateString2Apple('2012-07-01T00:00:00Z'),
        ).round();
        try {
          archiveDb.execute(
            'CREATE TABLE message (guid TEXT, date INTEGER, service TEXT, is_from_me INTEGER, text TEXT)',
          );
          archiveDb.execute(
            "INSERT INTO message (guid, date, service, is_from_me, text) VALUES ('seconds-guid', $july2012AppleSeconds, 'iMessage', 0, 'older archive message')",
          );
        } finally {
          archiveDb.dispose();
        }

        final service = container.read(historicalArchiveMergeServiceProvider);
        final summary = await service.runPreflightForFolder(archiveDir.path);
        final result = await service.importArchiveForFutureMerge(
          archivePath: archiveDir.path,
          archiveLabel: archiveDir.uri.pathSegments
              .where((segment) => segment.isNotEmpty)
              .last,
        );

        expect(summary.earliestDate, DateTime.utc(2012, 7, 1));
        expect(summary.latestDate, DateTime.utc(2012, 7, 1));
        expect(result.importedMessages, 1);

        final stagedRows = await archiveImportDb.rawQuery(
          "SELECT date_utc FROM recovered_unlinked_messages WHERE guid = 'seconds-guid'",
        );
        expect(stagedRows, hasLength(1));
        expect(stagedRows.first['date_utc'], '2012-07-01T00:00:00.000Z');

        final workingRows = await (workingDb.select(
          workingDb.workingMessages,
        )..where((row) => row.guid.equals('seconds-guid'))).get();
        expect(workingRows, hasLength(1));
        expect(workingRows.first.sentAtUtc, '2012-07-01T00:00:00.000Z');
      },
    );

    test(
      'reimports previously staged archive rows when working projection no longer has them',
      () async {
        final archiveDir = await Directory.systemTemp.createTemp(
          'historical-archive-reimport-',
        );
        addTearDown(() async {
          if (archiveDir.existsSync()) {
            await archiveDir.delete(recursive: true);
          }
        });

        final chatDbPath = '${archiveDir.path}/chat.db';
        final archiveDb = sqlite3.sqlite3.open(chatDbPath);
        try {
          archiveDb.execute(
            'CREATE TABLE message (guid TEXT, date INTEGER, service TEXT, is_from_me INTEGER, text TEXT)',
          );
          archiveDb.execute(
            "INSERT INTO message (guid, date, service, is_from_me, text) VALUES ('reimport-guid', 347155200000000000, 'iMessage', 0, 'reimport me')",
          );
        } finally {
          archiveDb.dispose();
        }

        final service = container.read(historicalArchiveMergeServiceProvider);

        final firstResult = await service.importArchiveForFutureMerge(
          archivePath: archiveDir.path,
          archiveLabel: archiveDir.uri.pathSegments
              .where((segment) => segment.isNotEmpty)
              .last,
        );

        expect(firstResult.importedMessages, 1);
        expect(firstResult.skippedDuplicates, 0);

        await workingDb.customStatement(
          "DELETE FROM messages WHERE guid = 'reimport-guid'",
        );
        await workingDb.rebuildGlobalMessageIndex();
        await workingDb.rebuildMessageIndex();
        await workingDb.rebuildContactMessageIndex();
        await workingDb.createMessageIndexTriggers();

        final secondResult = await service.importArchiveForFutureMerge(
          archivePath: archiveDir.path,
          archiveLabel: archiveDir.uri.pathSegments
              .where((segment) => segment.isNotEmpty)
              .last,
        );

        expect(secondResult.importedMessages, 1);
        expect(secondResult.skippedDuplicates, 0);

        final workingRows = await (workingDb.select(
          workingDb.workingMessages,
        )..where((row) => row.guid.equals('reimport-guid'))).get();
        expect(workingRows, hasLength(1));

        final stagedRows = await archiveImportDb.rawQuery(
          "SELECT guid, batch_id FROM recovered_unlinked_messages WHERE guid = 'reimport-guid'",
        );
        expect(stagedRows, hasLength(1));
        expect(stagedRows.first['batch_id'], secondResult.batchId);
      },
    );

    test('coalesces concurrent archive import requests into one batch', () async {
      final archiveDir = await Directory.systemTemp.createTemp(
        'historical-archive-concurrent-import-',
      );
      addTearDown(() async {
        if (archiveDir.existsSync()) {
          await archiveDir.delete(recursive: true);
        }
      });

      final chatDbPath = '${archiveDir.path}/chat.db';
      final archiveDb = sqlite3.sqlite3.open(chatDbPath);
      try {
        archiveDb.execute(
          'CREATE TABLE message (guid TEXT, date INTEGER, service TEXT, is_from_me INTEGER, text TEXT)',
        );
        archiveDb.execute(
          "INSERT INTO message (guid, date, service, is_from_me, text) VALUES ('concurrent-guid', 347155200000000000, 'iMessage', 0, 'hello archive')",
        );
      } finally {
        archiveDb.dispose();
      }

      final service = container.read(historicalArchiveMergeServiceProvider);
      final archiveLabel = archiveDir.uri.pathSegments
          .where((segment) => segment.isNotEmpty)
          .last;
      final results = await Future.wait([
        service.importArchiveForFutureMerge(
          archivePath: archiveDir.path,
          archiveLabel: archiveLabel,
        ),
        service.importArchiveForFutureMerge(
          archivePath: archiveDir.path,
          archiveLabel: archiveLabel,
        ),
      ]);

      expect(results, hasLength(2));
      expect(results.first.batchId, isNotNull);
      expect(results.first.batchId, results.last.batchId);
      expect(results.first.importedMessages, 1);
      expect(results.last.importedMessages, 1);

      final batches = await archiveImportDb.rawQuery(
        'SELECT id FROM import_batches ORDER BY id',
      );
      expect(batches, hasLength(1));

      final workingRows = await (workingDb.select(
        workingDb.workingMessages,
      )..where((row) => row.guid.equals('concurrent-guid'))).get();
      expect(workingRows, hasLength(1));
    });

    test('clears the dedicated historical archive ledger', () async {
      final archiveDir = await Directory.systemTemp.createTemp(
        'historical-archive-clear-ledger-',
      );
      addTearDown(() async {
        if (archiveDir.existsSync()) {
          await archiveDir.delete(recursive: true);
        }
      });

      final chatDbPath = '${archiveDir.path}/chat.db';
      final archiveDb = sqlite3.sqlite3.open(chatDbPath);
      try {
        archiveDb.execute(
          'CREATE TABLE message (guid TEXT, date INTEGER, service TEXT, is_from_me INTEGER, text TEXT)',
        );
        archiveDb.execute(
          "INSERT INTO message (guid, date, service, is_from_me, text) VALUES ('clear-guid', 347155200000000000, 'iMessage', 0, 'clear me')",
        );
      } finally {
        archiveDb.dispose();
      }

      final service = container.read(historicalArchiveMergeServiceProvider);
      await service.importArchiveForFutureMerge(
        archivePath: archiveDir.path,
        archiveLabel: archiveDir.uri.pathSegments
            .where((segment) => segment.isNotEmpty)
            .last,
      );

      final stagedBeforeClear = await archiveImportDb.rawQuery(
        'SELECT guid FROM recovered_unlinked_messages',
      );
      expect(stagedBeforeClear, hasLength(1));

      await service.clearArchiveImportDatabase();

      final stagedAfterClear = await archiveImportDb.rawQuery(
        'SELECT guid FROM recovered_unlinked_messages',
      );
      final batchesAfterClear = await archiveImportDb.rawQuery(
        'SELECT id FROM import_batches',
      );
      expect(stagedAfterClear, isEmpty);
      expect(batchesAfterClear, isEmpty);
    });

    test('replays linked archive messages into the matching working chat', () async {
      final existingChatId = await workingDb
          .into(workingDb.workingChats)
          .insert(
            WorkingChatsCompanion.insert(
              guid: 'chat-guid-1',
              service: const Value('iMessage'),
            ),
          );

      final archiveDir = await Directory.systemTemp.createTemp(
        'historical-archive-linked-chat-',
      );
      addTearDown(() async {
        if (archiveDir.existsSync()) {
          await archiveDir.delete(recursive: true);
        }
      });

      final chatDbPath = '${archiveDir.path}/chat.db';
      final archiveDb = sqlite3.sqlite3.open(chatDbPath);
      try {
        archiveDb.execute(
          'CREATE TABLE chat (guid TEXT, service_name TEXT, display_name TEXT, is_group INTEGER, creation_date INTEGER, last_read_message_timestamp INTEGER)',
        );
        archiveDb.execute(
          'CREATE TABLE handle (id TEXT, service TEXT, country TEXT, last_use INTEGER)',
        );
        archiveDb.execute(
          'CREATE TABLE message (guid TEXT, date INTEGER, handle_id INTEGER, service TEXT, is_from_me INTEGER, text TEXT)',
        );
        archiveDb.execute(
          'CREATE TABLE chat_message_join (message_id INTEGER, chat_id INTEGER)',
        );
        archiveDb.execute(
          'CREATE TABLE chat_handle_join (chat_id INTEGER, handle_id INTEGER)',
        );

        archiveDb.execute(
          "INSERT INTO chat (guid, service_name, display_name, is_group, creation_date, last_read_message_timestamp) VALUES ('chat-guid-1', 'iMessage', 'Archive Chat', 0, 315532800000000000, 347155200000000000)",
        );
        archiveDb.execute(
          "INSERT INTO handle (id, service, country, last_use) VALUES ('+15550001', 'iMessage', 'US', 347155200000000000)",
        );
        archiveDb.execute(
          "INSERT INTO message (guid, date, handle_id, service, is_from_me, text) VALUES ('linked-guid', 347155200000000000, 1, 'iMessage', 1, 'linked archive message')",
        );
        archiveDb.execute(
          'INSERT INTO chat_message_join (message_id, chat_id) VALUES (1, 1)',
        );
        archiveDb.execute(
          'INSERT INTO chat_handle_join (chat_id, handle_id) VALUES (1, 1)',
        );
      } finally {
        archiveDb.dispose();
      }

      final service = container.read(historicalArchiveMergeServiceProvider);
      final result = await service.importArchiveForFutureMerge(
        archivePath: archiveDir.path,
        archiveLabel: archiveDir.uri.pathSegments
            .where((segment) => segment.isNotEmpty)
            .last,
      );

      expect(result.importedMessages, 1);

      final stagedLinkedRows = await archiveImportDb.rawQuery(
        'SELECT guid, chat_id, sender_handle_id FROM messages',
      );
      expect(stagedLinkedRows, hasLength(1));
      expect(stagedLinkedRows.first['guid'], 'linked-guid');
      expect(stagedLinkedRows.first['sender_handle_id'], 1);

      final stagedHandles = await archiveImportDb.rawQuery(
        'SELECT raw_identifier, compound_identifier FROM handles',
      );
      expect(stagedHandles, hasLength(1));
      expect(stagedHandles.first['raw_identifier'], '+15550001');

      final stagedParticipants = await archiveImportDb.rawQuery(
        'SELECT chat_id, handle_id FROM chat_to_handle',
      );
      expect(stagedParticipants, hasLength(1));
      expect(stagedParticipants.first['chat_id'], 1);
      expect(stagedParticipants.first['handle_id'], 1);

      final workingRows = await workingDb
          .select(workingDb.workingMessages)
          .get();
      expect(workingRows, hasLength(1));
      expect(workingRows.first.guid, 'linked-guid');
      expect(workingRows.first.chatId, existingChatId);
      expect(workingRows.first.senderHandleId, isNotNull);
      expect(
        workingRows.first.sourceProvenance,
        startsWith('archive_historical_archive_linked_chat_'),
      );
      expect(workingRows.first.importBatchId, result.batchId);

      final workingHandles = await workingDb
          .select(workingDb.handlesCanonical)
          .get();
      expect(workingHandles, hasLength(1));
      expect(workingHandles.first.rawIdentifier, '+15550001');
      expect(workingRows.first.senderHandleId, workingHandles.first.id);

      final workingParticipants = await workingDb
          .select(workingDb.chatToHandle)
          .get();
      expect(workingParticipants, hasLength(1));
      expect(workingParticipants.first.chatId, existingChatId);
      expect(workingParticipants.first.handleId, workingHandles.first.id);

      final workingChats = await workingDb.select(workingDb.workingChats).get();
      expect(workingChats, hasLength(1));
      expect(workingChats.first.guid, 'chat-guid-1');
    });

    test(
      'reuses an existing working handle when linked archive messages match by compound identifier',
      () async {
        final existingChatId = await workingDb
            .into(workingDb.workingChats)
            .insert(
              WorkingChatsCompanion.insert(
                guid: 'chat-guid-dup-handle',
                service: const Value('iMessage'),
              ),
            );

        final firstHandleId = await workingDb
            .into(workingDb.handlesCanonical)
            .insert(
              HandlesCanonicalCompanion.insert(
                rawIdentifier: '+15550002',
                displayName: '+15550002',
                compoundIdentifier: '+15550002-iMessage',
                service: const Value('iMessage'),
                batchId: const Value(1),
              ),
            );

        final archiveDir = await Directory.systemTemp.createTemp(
          'historical-archive-existing-working-handle-',
        );
        addTearDown(() async {
          if (archiveDir.existsSync()) {
            await archiveDir.delete(recursive: true);
          }
        });

        final chatDbPath = '${archiveDir.path}/chat.db';
        final archiveDb = sqlite3.sqlite3.open(chatDbPath);
        try {
          archiveDb.execute(
            'CREATE TABLE chat (guid TEXT, service_name TEXT, display_name TEXT, is_group INTEGER)',
          );
          archiveDb.execute('CREATE TABLE handle (id TEXT, service TEXT)');
          archiveDb.execute(
            'CREATE TABLE message (guid TEXT, date INTEGER, handle_id INTEGER, service TEXT, is_from_me INTEGER, text TEXT)',
          );
          archiveDb.execute(
            'CREATE TABLE chat_message_join (message_id INTEGER, chat_id INTEGER)',
          );
          archiveDb.execute(
            'CREATE TABLE chat_handle_join (chat_id INTEGER, handle_id INTEGER)',
          );

          archiveDb.execute(
            "INSERT INTO chat (guid, service_name, display_name, is_group) VALUES ('chat-guid-dup-handle', 'iMessage', 'Archive Chat', 0)",
          );
          archiveDb.execute(
            "INSERT INTO handle (id, service) VALUES ('+15550002', 'iMessage')",
          );
          archiveDb.execute(
            "INSERT INTO message (guid, date, handle_id, service, is_from_me, text) VALUES ('dup-handle-guid', 347155200000000000, 1, 'iMessage', 0, 'duplicate handle archive message')",
          );
          archiveDb.execute(
            'INSERT INTO chat_message_join (message_id, chat_id) VALUES (1, 1)',
          );
          archiveDb.execute(
            'INSERT INTO chat_handle_join (chat_id, handle_id) VALUES (1, 1)',
          );
        } finally {
          archiveDb.dispose();
        }

        final service = container.read(historicalArchiveMergeServiceProvider);
        final result = await service.importArchiveForFutureMerge(
          archivePath: archiveDir.path,
          archiveLabel: archiveDir.uri.pathSegments
              .where((segment) => segment.isNotEmpty)
              .last,
        );

        expect(result.importedMessages, 1);

        final workingHandles = await workingDb
            .select(workingDb.handlesCanonical)
            .get();
        final workingRows = await (workingDb.select(
          workingDb.workingMessages,
        )..where((row) => row.guid.equals('dup-handle-guid'))).get();
        expect(workingHandles, hasLength(1));
        expect(workingRows, hasLength(1));
        expect(workingRows.first.chatId, existingChatId);
        expect(workingRows.first.senderHandleId, firstHandleId);
      },
    );
  });
}

class _TestAppLogger extends AppLogger {
  @override
  List<LogEntry> build() {
    return const [];
  }

  @override
  void log(
    LogLevel level,
    String message, {
    String? source,
    Map<String, dynamic>? context,
  }) {
    state = [
      ...state,
      LogEntry(
        timestamp: DateTime.now().toUtc(),
        level: level,
        source: source,
        message: message,
        context: context ?? const <String, dynamic>{},
      ),
    ];
  }
}
