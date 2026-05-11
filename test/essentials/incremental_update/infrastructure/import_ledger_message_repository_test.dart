import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/infrastructure/import_ledger_message_repository.dart';
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
      'import_ledger_message_repository_test_',
    );
    ledgerDb = SqfliteImportDatabase(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import.db',
      debugSettings: const ImportDebugSettingsState(),
    );
  });

  tearDown(() async {
    await ledgerDb.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('returns zero snapshot for an empty messages table', () async {
    final repository = ImportLedgerMessageRepository(ledgerDb: ledgerDb);
    final snapshot = await repository.readMessageSnapshot();

    expect(snapshot.maxRowId, 0);
    expect(snapshot.totalMessageCount, 0);
  });

  test(
    'returns max source row id and total count for ledger messages',
    () async {
      final batchId = await ledgerDb.insertImportBatch(
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );
      final chatId = await ledgerDb.insertChat(
        id: 10,
        sourceRowid: 10,
        guid: 'chat-one',
        batchId: batchId,
      );
      await ledgerDb.insertMessage(
        id: 1,
        sourceRowid: 30,
        guid: 'message-one',
        chatId: chatId,
        isFromMe: false,
        hasAttributedBodySource: false,
        hasMessageSummaryInfo: false,
        hasPayloadDataSource: false,
        isSystemMessage: false,
        batchId: batchId,
      );
      await ledgerDb.insertMessage(
        id: 2,
        sourceRowid: 40,
        guid: 'message-two',
        chatId: chatId,
        isFromMe: true,
        hasAttributedBodySource: false,
        hasMessageSummaryInfo: false,
        hasPayloadDataSource: false,
        isSystemMessage: false,
        batchId: batchId,
      );

      final repository = ImportLedgerMessageRepository(ledgerDb: ledgerDb);
      final snapshot = await repository.readMessageSnapshot();

      expect(snapshot.maxRowId, 40);
      expect(snapshot.totalMessageCount, 2);
    },
  );
}
