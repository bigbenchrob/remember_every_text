import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/essentials/db/shared/handle_identifier_utils.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/features/handles/infrastructure/repositories/stray_handles_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('strayHandlesProvider', () {
    late Directory tempDir;
    late SqfliteImportDatabase importDb;
    late WorkingDatabase workingDb;
    late OverlayDatabase overlayDb;
    late ProviderContainer container;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('stray_handles_test');
      importDb = SqfliteImportDatabase(
        databaseDirectory: tempDir.path,
        databaseName: 'import_test.db',
        debugSettings: const ImportDebugSettingsState(),
      );
      workingDb = WorkingDatabase(NativeDatabase.memory());
      overlayDb = OverlayDatabase(NativeDatabase.memory());

      await workingDb.customStatement('PRAGMA foreign_keys = ON');

      container = ProviderContainer(
        overrides: [
          sqfliteImportDatabaseProvider.overrideWith((ref) async => importDb),
          driftWorkingDatabaseProvider.overrideWith((ref) async => workingDb),
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await overlayDb.close();
      await workingDb.close();
      await importDb.deleteDatabaseFile();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'returns stray handles when sender projection already exists',
      () async {
        const importHandleId = 9001;
        const handleValue = 'stray@example.com';
        const handleService = 'iMessage';
        const messageGuid = 'message-guid-1';
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

        final importChat = await importDb.insertChat(
          id: 7001,
          guid: 'import-chat-guid-1',
          service: handleService,
          batchId: batchId,
        );
        final importChatId = importChat.id;

        await importDb.insertMessage(
          id: 8001,
          guid: messageGuid,
          chatId: importChatId,
          senderHandleId: importHandleId,
          service: handleService,
          isFromMe: false,
          dateUtc: sentAtUtc,
          text: 'Recovered sender projection',
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

        final workingChatId = await workingDb
            .into(workingDb.workingChats)
            .insert(WorkingChatsCompanion.insert(guid: 'working-chat-guid-1'));

        await workingDb
            .into(workingDb.workingMessages)
            .insert(
              WorkingMessagesCompanion.insert(
                guid: messageGuid,
                chatId: workingChatId,
                senderHandleId: drift.Value(canonicalHandleId),
                isFromMe: const drift.Value(false),
                sentAtUtc: const drift.Value(sentAtUtc),
                textContent: const drift.Value('Recovered sender projection'),
              ),
            );

        final results = await container.read(strayHandlesProvider.future);

        expect(results, hasLength(1));
        expect(results.single.handleId, canonicalHandleId);
        expect(results.single.handleValue, handleValue);
        expect(results.single.totalMessages, 1);
      },
    );
  });
}
