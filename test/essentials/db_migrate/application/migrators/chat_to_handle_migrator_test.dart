import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/essentials/db/shared/handle_identifier_utils.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/db_migrate/application/migrators/chat_to_handle_migrator.dart';
import 'package:remember_this_text/essentials/db_migrate/application/migrators/handles_migrator.dart';
import 'package:remember_this_text/essentials/db_migrate/infrastructure/sqlite/migration_context_sqlite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('ChatToHandleMigrator', () {
    late Directory tempDir;
    late SqfliteImportDatabase importDb;
    late WorkingDatabase workingDb;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'chat_to_handle_migrator_test',
      );
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
      'postValidate accepts collapsed duplicate memberships after canonical alias mapping',
      () async {
        const chatId = 700;

        final batchId = await importDb.insertImportBatch(
          startedAtUtc: DateTime.now().toUtc().toIso8601String(),
        );

        await importDb.insertHandle(
          id: 258,
          sourceRowid: 258,
          service: 'SMS',
          rawIdentifier: 'citycenter',
          compoundIdentifier: buildCompoundIdentifier(
            rawIdentifier: 'citycenter',
            service: 'SMS',
          ),
          batchId: batchId,
        );
        await importDb.insertHandle(
          id: 259,
          sourceRowid: 259,
          service: 'SMS',
          rawIdentifier: 'city center',
          compoundIdentifier: buildCompoundIdentifier(
            rawIdentifier: 'city center',
            service: 'SMS',
          ),
          batchId: batchId,
        );

        await importDb.insertChat(
          id: chatId,
          sourceRowid: chatId,
          guid: 'chat-guid-city-center',
          service: 'SMS',
          batchId: batchId,
        );

        await importDb.insertChatParticipant(chatId: chatId, handleId: 258);
        await importDb.insertChatParticipant(chatId: chatId, handleId: 259);

        await workingDb.customStatement('''
          INSERT INTO chats (id, guid, service)
          VALUES ($chatId, 'chat-guid-city-center', 'SMS')
        ''');

        final context = MigrationContextSqlite(
          importDb: importDb,
          workingDb: workingDb,
          incrementalMode: false,
          log: (_) {},
        );

        final handlesMigrator = HandlesMigrator();
        await handlesMigrator.validatePrereqs(context);
        await handlesMigrator.copy(context);
        await handlesMigrator.postValidate(context);

        const chatToHandleMigrator = ChatToHandleMigrator();
        await chatToHandleMigrator.validatePrereqs(context);
        await chatToHandleMigrator.copy(context);
        await chatToHandleMigrator.postValidate(context);

        final rows = await workingDb.customSelect('''
          SELECT chat_id, handle_id
          FROM chat_to_handle
          ORDER BY chat_id, handle_id
        ''').get();

        expect(rows, hasLength(1));
        expect(rows.single.data['chat_id'], chatId);
        expect(rows.single.data['handle_id'], 258);
      },
    );
  });
}
