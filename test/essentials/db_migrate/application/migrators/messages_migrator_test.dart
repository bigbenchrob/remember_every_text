import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/essentials/db/shared/handle_identifier_utils.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/db_migrate/application/migrators/messages_migrator.dart';
import 'package:remember_this_text/essentials/db_migrate/infrastructure/sqlite/migration_context_sqlite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('MessagesMigrator', () {
    late Directory tempDir;
    late SqfliteImportDatabase importDb;
    late WorkingDatabase workingDb;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('messages_migrator_test');
      importDb = SqfliteImportDatabase(
        databaseDirectory: tempDir.path,
        databaseName: 'import_test.db',
        debugSettings: const ImportDebugSettingsState(),
      );
      workingDb = WorkingDatabase(NativeDatabase.memory());
      await workingDb.customStatement('PRAGMA foreign_keys = ON');
    });

    tearDown(() async {
      await workingDb.close();
      await importDb.deleteDatabaseFile();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'incremental copy backfills existing incoming rows with null sender_handle_id',
      () async {
        const importHandleId = 12;
        const importChatId = 8;
        const importMessageId = 101;
        const messageGuid = 'message-guid-1';
        const handleValue = 'backfill@example.com';
        const handleService = 'iMessage';
        const sentAtUtc = '2024-01-02T03:04:05Z';

        final batchId = await importDb.insertImportBatch(
          startedAtUtc: DateTime.now().toUtc().toIso8601String(),
        );

        await importDb.insertHandle(
          id: importHandleId,
          service: handleService,
          rawIdentifier: handleValue,
          normalizedIdentifier: handleValue,
          compoundIdentifier: buildCompoundIdentifier(
            normalizedIdentifier: handleValue,
            rawIdentifier: handleValue,
            service: handleService,
          ),
          batchId: batchId,
        );

        await importDb.insertChat(
          id: importChatId,
          guid: 'import-chat-guid-1',
          service: handleService,
          batchId: batchId,
        );

        await importDb.insertMessage(
          id: importMessageId,
          guid: messageGuid,
          chatId: importChatId,
          senderHandleId: importHandleId,
          service: handleService,
          isFromMe: false,
          dateUtc: sentAtUtc,
          text: 'Backfill me',
          hasAttributedBodySource: false,
          hasMessageSummaryInfo: false,
          hasPayloadDataSource: false,
          itemType: 'text',
          isSystemMessage: false,
          batchId: batchId,
        );

        final canonicalHandleId = await workingDb
            .into(workingDb.handlesCanonical)
            .insert(
              HandlesCanonicalCompanion.insert(
                rawIdentifier: handleValue,
                displayName: handleValue,
                compoundIdentifier: buildCompoundIdentifier(
                  normalizedIdentifier: handleValue,
                  rawIdentifier: handleValue,
                  service: handleService,
                ),
                service: const drift.Value(handleService),
              ),
            );

        await workingDb
            .into(workingDb.handlesCanonicalToAlias)
            .insert(
              HandlesCanonicalToAliasCompanion.insert(
                sourceHandleId: const drift.Value(importHandleId),
                canonicalHandleId: canonicalHandleId,
                rawIdentifier: handleValue,
                compoundIdentifier: buildCompoundIdentifier(
                  normalizedIdentifier: handleValue,
                  rawIdentifier: handleValue,
                  service: handleService,
                ),
                normalizedIdentifier: handleValue,
                service: const drift.Value(handleService),
                aliasKind: const drift.Value('variant'),
              ),
            );

        await workingDb.customStatement('''
          INSERT INTO chats (id, guid, service)
          VALUES ($importChatId, 'working-chat-guid-1', '$handleService')
        ''');

        final workingMessageId = await workingDb
            .into(workingDb.workingMessages)
            .insert(
              WorkingMessagesCompanion.insert(
                guid: messageGuid,
                chatId: importChatId,
                isFromMe: const drift.Value(false),
                sentAtUtc: const drift.Value(sentAtUtc),
                textContent: const drift.Value('Backfill me'),
              ),
            );

        final logs = <String>[];
        final context = MigrationContextSqlite(
          importDb: importDb,
          workingDb: workingDb,
          incrementalMode: true,
          log: logs.add,
        );
        final migrator = MessagesMigrator();

        await migrator.validatePrereqs(context);
        await migrator.copy(context);
        await migrator.postValidate(context);

        final backfilledMessage = await (workingDb.select(
          workingDb.workingMessages,
        )..where((tbl) => tbl.id.equals(workingMessageId))).getSingle();
        expect(backfilledMessage.senderHandleId, canonicalHandleId);
        expect(backfilledMessage.sentAtUtc, sentAtUtc);

        final backfilledChat = await (workingDb.select(
          workingDb.workingChats,
        )..where((tbl) => tbl.id.equals(importChatId))).getSingle();
        expect(backfilledChat.lastSenderHandleId, canonicalHandleId);
      },
    );

    test(
      'reports determinate chunk progress for working message projection',
      () async {
        const importChatId = 8;
        const handleValue = 'progress@example.com';
        const handleService = 'iMessage';
        final batchId = await importDb.insertImportBatch(
          startedAtUtc: DateTime.now().toUtc().toIso8601String(),
        );

        await importDb.insertChat(
          id: importChatId,
          guid: 'import-chat-guid-progress',
          service: handleService,
          batchId: batchId,
        );

        for (var index = 0; index < 1001; index++) {
          await importDb.insertMessage(
            id: index + 1,
            guid: 'message-guid-progress-$index',
            chatId: importChatId,
            service: handleService,
            isFromMe: true,
            dateUtc: '2024-01-02T03:04:05Z',
            text: 'Progress row $index',
            hasAttributedBodySource: false,
            hasMessageSummaryInfo: false,
            hasPayloadDataSource: false,
            itemType: 'text',
            isSystemMessage: false,
            batchId: batchId,
          );
        }

        await workingDb
            .into(workingDb.handlesCanonical)
            .insert(
              HandlesCanonicalCompanion.insert(
                rawIdentifier: handleValue,
                displayName: handleValue,
                compoundIdentifier: buildCompoundIdentifier(
                  normalizedIdentifier: handleValue,
                  rawIdentifier: handleValue,
                  service: handleService,
                ),
                service: const drift.Value(handleService),
              ),
            );

        await workingDb.customStatement('''
        INSERT INTO chats (id, guid, service)
        VALUES ($importChatId, 'working-chat-guid-progress', '$handleService')
      ''');

        final logs = <String>[];
        final context = MigrationContextSqlite(
          importDb: importDb,
          workingDb: workingDb,
          incrementalMode: true,
          log: logs.add,
        );
        final migrator = MessagesMigrator();
        final progressEvents =
            <(int processed, int total, String? currentItem)>[];
        migrator.setProgressCallback(({
          required int processed,
          required int total,
          String? currentItem,
        }) {
          progressEvents.add((processed, total, currentItem));
        });

        await migrator.validatePrereqs(context);
        await migrator.copy(context);
        await migrator.postValidate(context);

        // The first emission must come from validatePrereqs and report a
        // determinate "0 of N" so the modal renders a determinate bar
        // immediately, not an indeterminate stripe.
        expect(progressEvents, isNotEmpty);
        expect(progressEvents.first.$1, 0);
        expect(progressEvents.first.$2, 1001);
        expect(progressEvents.first.$3, 'Validating message prerequisites…');

        // The chunk loop must emit at least one mid-run determinate event.
        expect(progressEvents.any((event) => event.$1 == 1000), isTrue);

        // Backfill, chats-update, and postValidate must each keep the bar
        // pinned at 100% with a descriptive currentItem so it never reverts
        // to indeterminate after the chunk loop finishes.
        expect(
          progressEvents.any(
            (event) =>
                event.$1 == 1001 &&
                event.$2 == 1001 &&
                event.$3 == 'Backfilling sender handles…',
          ),
          isTrue,
        );
        expect(
          progressEvents.any(
            (event) =>
                event.$1 == 1001 &&
                event.$2 == 1001 &&
                event.$3 == 'Updating per-chat metadata…',
          ),
          isTrue,
        );
        expect(
          progressEvents.last.$1,
          1001,
          reason: 'final emission must remain at total',
        );
        expect(progressEvents.last.$2, 1001);
        expect(progressEvents.last.$3, 'Validating projected message rows…');

        expect(
          logs.any(
            (log) => log.contains(
              '[messages] phase=backfill_sender_handles start_at_utc=',
            ),
          ),
          isTrue,
        );
        expect(
          logs.any(
            (log) =>
                log.contains(
                  '[messages] phase=backfill_sender_handles end_at_utc=',
                ) &&
                log.contains('duration_ms='),
          ),
          isTrue,
        );
        expect(
          logs.any(
            (log) => log.contains(
              '[messages] phase=update_chat_metadata start_at_utc=',
            ),
          ),
          isTrue,
        );
        expect(
          logs.any(
            (log) =>
                log.contains(
                  '[messages] phase=update_chat_metadata end_at_utc=',
                ) &&
                log.contains('duration_ms='),
          ),
          isTrue,
        );
        expect(
          logs.any(
            (log) =>
                log.contains('[messages] phase=post_validate start_at_utc='),
          ),
          isTrue,
        );
        expect(
          logs.any(
            (log) =>
                log.contains('[messages] phase=post_validate end_at_utc=') &&
                log.contains('duration_ms='),
          ),
          isTrue,
        );
        expect(
          logs.any(
            (log) =>
                log.contains('[messages] latest_historical_archive_batch_id='),
          ),
          isTrue,
        );
        expect(
          logs.any(
            (log) => log.contains(
              '[messages][chunk] offset=0 limit=1000 stage=before_select',
            ),
          ),
          isTrue,
        );
        expect(
          logs.any(
            (log) =>
                log.contains(
                  '[messages][chunk] offset=0 limit=1000 stage=after_select',
                ) &&
                log.contains('selected_count=1000') &&
                log.contains('first_id=1 last_id=1000') &&
                log.contains('first_guid=message-guid-progress-0') &&
                log.contains('last_guid=message-guid-progress-999'),
          ),
          isTrue,
        );
        expect(
          logs.any(
            (log) =>
                log.contains(
                  '[messages][chunk] offset=0 limit=1000 stage=before_insert',
                ) &&
                log.contains('first_id=1') &&
                log.contains('last_id=1000'),
          ),
          isTrue,
        );
        expect(
          logs.any(
            (log) =>
                log.contains(
                  '[messages][chunk] offset=0 limit=1000 stage=after_insert',
                ) &&
                log.contains('insert_duration_ms='),
          ),
          isTrue,
        );
        expect(
          logs.any(
            (log) => log.contains(
              '[messages][chunk] offset=0 limit=1000 stage=before_changes',
            ),
          ),
          isTrue,
        );
        expect(
          logs.any(
            (log) =>
                log.contains(
                  '[messages][chunk] offset=0 limit=1000 stage=after_changes',
                ) &&
                log.contains('changes_count='),
          ),
          isTrue,
        );
        expect(
          logs.any(
            (log) =>
                log.contains(
                  '[messages][chunk] offset=0 limit=1000 stage=chunk_complete',
                ) &&
                log.contains('processed_rows=1000') &&
                log.contains('total_rows=1001') &&
                log.contains('chunk_elapsed_ms='),
          ),
          isTrue,
        );
        expect(
          logs.any(
            (log) =>
                log.contains(
                  '[messages][chunk] offset=1000 limit=1000 stage=after_select',
                ) &&
                log.contains('selected_count=1') &&
                log.contains('first_id=1001 last_id=1001') &&
                log.contains('first_guid=message-guid-progress-1000') &&
                log.contains('last_guid=message-guid-progress-1000'),
          ),
          isTrue,
        );
      },
    );
  });
}
