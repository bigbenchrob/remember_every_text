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

        final context = MigrationContextSqlite(
          importDb: importDb,
          workingDb: workingDb,
          incrementalMode: true,
          log: (_) {},
        );
        const migrator = MessagesMigrator();

        await migrator.validatePrereqs(context);
        await migrator.copy(context);
        await migrator.postValidate(context);

        final backfilledMessage = await (workingDb.select(
          workingDb.workingMessages,
        )..where((tbl) => tbl.id.equals(workingMessageId))).getSingle();
        expect(backfilledMessage.senderHandleId, canonicalHandleId);

        final backfilledChat = await (workingDb.select(
          workingDb.workingChats,
        )..where((tbl) => tbl.id.equals(importChatId))).getSingle();
        expect(backfilledChat.lastSenderHandleId, canonicalHandleId);
      },
    );
  });
}
