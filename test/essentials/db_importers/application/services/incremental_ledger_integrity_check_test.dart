import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db/shared/handle_identifier_utils.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/db_importers/application/services/incremental_ledger_integrity_check.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('hasMissingChatMembershipParents', () {
    late Directory tempDir;
    late SqfliteImportDatabase ledgerDb;
    late String sourceDbPath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'incremental_ledger_integrity_test',
      );
      sourceDbPath = '${tempDir.path}/chat.db';
      ledgerDb = SqfliteImportDatabase(
        databaseDirectory: tempDir.path,
        databaseName: 'import_test.db',
        debugSettings: const ImportDebugSettingsState(),
      );

      final sourceDb = await openDatabase(sourceDbPath);
      await sourceDb.execute(
        'CREATE TABLE handle (ROWID INTEGER PRIMARY KEY, id TEXT, service TEXT)',
      );
      await sourceDb.execute(
        'CREATE TABLE chat (ROWID INTEGER PRIMARY KEY, guid TEXT, service_name TEXT)',
      );
      await sourceDb.execute(
        'CREATE TABLE chat_handle_join (chat_id INTEGER NOT NULL, handle_id INTEGER NOT NULL)',
      );

      await sourceDb.insert('handle', <String, Object?>{
        'ROWID': 22,
        'id': 'cathie.campbell@gmail.com',
        'service': 'iMessage',
      });
      await sourceDb.insert('chat', <String, Object?>{
        'ROWID': 17,
        'guid': 'any;+;chat657567557914895040',
        'service_name': 'iMessage',
      });
      await sourceDb.insert('chat_handle_join', <String, Object?>{
        'chat_id': 17,
        'handle_id': 22,
      });
      await sourceDb.close();
    });

    tearDown(() async {
      await ledgerDb.deleteDatabaseFile();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'returns true when a referenced handle is missing from the ledger',
      () async {
        final batchId = await ledgerDb.insertImportBatch(
          startedAtUtc: DateTime.now().toUtc().toIso8601String(),
        );

        await ledgerDb.insertChat(
          id: 17,
          sourceRowid: 17,
          guid: 'any;+;chat657567557914895040',
          service: 'iMessage',
          batchId: batchId,
        );

        final result = await hasMissingChatMembershipParents(
          ledgerDb: ledgerDb,
          messagesDbPath: sourceDbPath,
        );

        expect(result, isTrue);
      },
    );

    test(
      'returns false when all referenced parents exist in the ledger',
      () async {
        final batchId = await ledgerDb.insertImportBatch(
          startedAtUtc: DateTime.now().toUtc().toIso8601String(),
        );

        await ledgerDb.insertHandle(
          id: 22,
          sourceRowid: 22,
          service: 'iMessage',
          rawIdentifier: 'cathie.campbell@gmail.com',
          normalizedIdentifier: 'cathie.campbell@gmail.com',
          compoundIdentifier: buildCompoundIdentifier(
            normalizedIdentifier: 'cathie.campbell@gmail.com',
            rawIdentifier: 'cathie.campbell@gmail.com',
            service: 'iMessage',
          ),
          batchId: batchId,
        );

        await ledgerDb.insertChat(
          id: 17,
          sourceRowid: 17,
          guid: 'any;+;chat657567557914895040',
          service: 'iMessage',
          batchId: batchId,
        );

        final result = await hasMissingChatMembershipParents(
          ledgerDb: ledgerDb,
          messagesDbPath: sourceDbPath,
        );

        expect(result, isFalse);
      },
    );
  });
}
