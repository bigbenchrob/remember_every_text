import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/essentials/db/shared/handle_identifier_utils.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/db_migrate/feature_level_providers.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test(
    'detects repair need when joinable relationship rows exist but projection tables are empty',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'handles_migration_service_test',
      );
      addTearDown(() async {
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      });

      final importDb = SqfliteImportDatabase(
        databaseDirectory: tempDir.path,
        databaseName: 'import_test.db',
        debugSettings: const ImportDebugSettingsState(),
      );
      addTearDown(() async {
        await importDb.deleteDatabaseFile();
      });

      final workingDb = WorkingDatabase(NativeDatabase.memory());
      await workingDb.customStatement('PRAGMA foreign_keys = ON');
      addTearDown(() async {
        await workingDb.close();
      });

      final batchId = await importDb.insertImportBatch(
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );

      await importDb.insertHandle(
        id: 1,
        service: 'iMessage',
        rawIdentifier: 'alice@example.com',
        normalizedIdentifier: 'alice@example.com',
        compoundIdentifier: buildCompoundIdentifier(
          normalizedIdentifier: 'alice@example.com',
          rawIdentifier: 'alice@example.com',
          service: 'iMessage',
        ),
        batchId: batchId,
      );
      await importDb.insertChat(
        id: 1,
        guid: 'chat-1',
        service: 'iMessage',
        batchId: batchId,
      );
      await importDb.insertChatParticipant(
        chatId: 1,
        handleId: 1,
        role: 'member',
      );
      await importDb.insertContact(
        zPk: 24,
        displayName: 'Alice',
        firstName: 'Alice',
        lastName: 'Example',
        batchId: batchId,
      );
      await importDb.insertContactHandleLink(
        contactZpk: 24,
        handleId: 1,
        batchId: batchId,
      );

      final canonicalHandleId = await workingDb
          .into(workingDb.handlesCanonical)
          .insert(
            HandlesCanonicalCompanion.insert(
              rawIdentifier: 'alice@example.com',
              displayName: 'alice@example.com',
              compoundIdentifier: buildCompoundIdentifier(
                normalizedIdentifier: 'alice@example.com',
                rawIdentifier: 'alice@example.com',
                service: 'iMessage',
              ),
              service: const drift.Value('iMessage'),
              batchId: drift.Value(batchId),
            ),
          );
      await workingDb
          .into(workingDb.handlesCanonicalToAlias)
          .insert(
            HandlesCanonicalToAliasCompanion.insert(
              sourceHandleId: const drift.Value(1),
              canonicalHandleId: canonicalHandleId,
              rawIdentifier: 'alice@example.com',
              compoundIdentifier: buildCompoundIdentifier(
                normalizedIdentifier: 'alice@example.com',
                rawIdentifier: 'alice@example.com',
                service: 'iMessage',
              ),
              normalizedIdentifier: 'alice@example.com',
              service: const drift.Value('iMessage'),
              aliasKind: const drift.Value('variant'),
            ),
          );
      await workingDb
          .into(workingDb.workingChats)
          .insert(
            WorkingChatsCompanion.insert(
              id: const drift.Value(1),
              guid: 'chat-1',
              service: const drift.Value('iMessage'),
            ),
          );
      await workingDb
          .into(workingDb.workingParticipants)
          .insert(
            WorkingParticipantsCompanion.insert(
              id: const drift.Value(24),
              originalName: 'Alice',
              displayName: 'Alice',
              shortName: 'Alice',
            ),
          );

      final container = ProviderContainer(
        overrides: [
          sqfliteImportDatabaseProvider.overrideWith((ref) async => importDb),
          driftWorkingDatabaseProvider.overrideWith((ref) async => workingDb),
        ],
      );
      addTearDown(container.dispose);

      final service = container.read(handlesMigrationServiceProvider);

      expect(await service.relationshipProjectionRepairRequired(), isTrue);

      await workingDb
          .into(workingDb.chatToHandle)
          .insert(
            ChatToHandleCompanion.insert(
              chatId: 1,
              handleId: canonicalHandleId,
              role: const drift.Value('member'),
            ),
          );
      await workingDb
          .into(workingDb.handleToParticipant)
          .insert(
            HandleToParticipantCompanion.insert(
              handleId: canonicalHandleId,
              participantId: 24,
              confidence: const drift.Value(1.0),
              source: const drift.Value('addressbook'),
            ),
          );

      expect(await service.relationshipProjectionRepairRequired(), isFalse);
    },
  );
}
