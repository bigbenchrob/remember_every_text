import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/source_identity.dart';
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

  test('returns live-source message cursor and count only', () async {
    final batchId = await ledgerDb.insertImportBatch(
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );
    final chatId = await ledgerDb.insertChat(
      id: 10,
      sourceRowid: 10,
      guid: 'chat-one',
      batchId: batchId,
    );
    await _insertLedgerMessage(
      ledgerDb,
      id: 1,
      sourceRowid: 30,
      guid: 'message-one',
      chatId: chatId,
      batchId: batchId,
      sourceId: liveChatDbSourceIdentity.sourceId,
      sourceKind: liveChatDbSourceIdentity.sourceKind,
    );
    await _insertLedgerMessage(
      ledgerDb,
      id: 2,
      sourceRowid: 40,
      guid: 'message-two',
      chatId: chatId,
      batchId: batchId,
      sourceId: liveChatDbSourceIdentity.sourceId,
      sourceKind: liveChatDbSourceIdentity.sourceKind,
    );
    await _insertLedgerMessage(
      ledgerDb,
      id: 3,
      sourceRowid: 999999,
      guid: 'archive-message',
      chatId: chatId,
      batchId: batchId,
      sourceId: 'archive-test',
      sourceKind: 'archived_messages_folder',
    );

    final repository = ImportLedgerMessageRepository(ledgerDb: ledgerDb);
    final snapshot = await repository.readMessageSnapshot();

    expect(snapshot.maxRowId, 40);
    expect(snapshot.totalMessageCount, 2);
  });
}

Future<void> _insertLedgerMessage(
  SqfliteImportDatabase ledgerDb, {
  required int id,
  required int sourceRowid,
  required String guid,
  required int chatId,
  required int batchId,
  required String sourceId,
  required String sourceKind,
}) async {
  await ledgerDb.insertMessage(
    id: id,
    sourceRowid: sourceRowid,
    guid: guid,
    chatId: chatId,
    isFromMe: false,
    hasAttributedBodySource: false,
    hasMessageSummaryInfo: false,
    hasPayloadDataSource: false,
    isSystemMessage: false,
    batchId: batchId,
  );
  final db = await ledgerDb.database;
  await db.update(
    'messages',
    <String, Object?>{'source_id': sourceId, 'source_kind': sourceKind},
    where: 'id = ?',
    whereArgs: <Object?>[id],
  );
}
