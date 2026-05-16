import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/infrastructure/import_ledger_chat_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late SqfliteImportDatabase ledgerDb;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'import_ledger_chat_repository_test_',
    );
    ledgerDb = SqfliteImportDatabase(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_shadow.db',
      debugSettings: const ImportDebugSettingsState(),
    );
  });

  tearDown(() async {
    await ledgerDb.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('returns zero snapshot for an empty chats table', () async {
    final repository = ImportLedgerChatRepository(ledgerDb: ledgerDb);
    final snapshot = await repository.readChatSnapshot();

    expect(snapshot.maxRowId, 0);
    expect(snapshot.totalChatCount, 0);
  });

  test('returns max source row id and total count for ledger chats', () async {
    final batchId = await ledgerDb.insertImportBatch(
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );
    await ledgerDb.insertChat(
      id: 1,
      sourceRowid: 10,
      guid: 'chat-one',
      batchId: batchId,
    );
    await ledgerDb.insertChat(
      id: 2,
      sourceRowid: 20,
      guid: 'chat-two',
      batchId: batchId,
    );

    final repository = ImportLedgerChatRepository(ledgerDb: ledgerDb);
    final snapshot = await repository.readChatSnapshot();

    expect(snapshot.maxRowId, 20);
    expect(snapshot.totalChatCount, 2);
  });

  test(
    'excludes non-source placeholder chats from source snapshot count',
    () async {
      final batchId = await ledgerDb.insertImportBatch(
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );
      await ledgerDb.insertChat(
        id: -1,
        guid: '__shadow_incremental_update_placeholder_chat__',
        displayName: 'Shadow incremental update placeholder chat',
        batchId: batchId,
      );
      await ledgerDb.insertChat(
        id: 12,
        sourceRowid: 12,
        guid: 'source-chat',
        batchId: batchId,
      );

      final repository = ImportLedgerChatRepository(ledgerDb: ledgerDb);
      final snapshot = await repository.readChatSnapshot();

      expect(snapshot.maxRowId, 12);
      expect(snapshot.totalChatCount, 1);
    },
  );
}
