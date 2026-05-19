import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/source_identity.dart';
import 'package:remember_this_text/essentials/incremental_update/infrastructure/import_ledger_chat_message_join_repository.dart';
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
      'import_ledger_chat_message_join_repository_test_',
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

  test('reports empty source-scoped topology for a fresh ledger', () async {
    final repository = ImportLedgerChatMessageJoinRepository(
      ledgerDb: ledgerDb,
    );

    final snapshot = await repository.readChatMessageJoinSnapshot();

    expect(snapshot.maxRowId, 0);
    expect(snapshot.totalJoinCount, 0);
    expect(snapshot.maxMessageRowId, 0);
    expect(snapshot.maxChatRowId, 0);
    expect(snapshot.sourceScopedObservationAvailable, isTrue);
  });

  test(
    'reports only live source topology when ledger table is source-scoped',
    () async {
      final db = await ledgerDb.database;

      final batchId = await ledgerDb.insertImportBatch(
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );
      await db.insert('chat_message_joins', <String, Object?>{
        'source_rowid': 10,
        'source_id': liveChatDbSourceIdentity.sourceId,
        'source_kind': liveChatDbSourceIdentity.sourceKind,
        'source_chat_rowid': 3,
        'source_message_rowid': 30,
        'batch_id': batchId,
      });
      await db.insert('chat_message_joins', <String, Object?>{
        'source_rowid': 999999,
        'source_id': 'archive-test',
        'source_kind': 'archived_messages_folder',
        'source_chat_rowid': 99,
        'source_message_rowid': 999,
        'batch_id': batchId,
      });

      final repository = ImportLedgerChatMessageJoinRepository(
        ledgerDb: ledgerDb,
      );

      final snapshot = await repository.readChatMessageJoinSnapshot();

      expect(snapshot.maxRowId, 10);
      expect(snapshot.totalJoinCount, 1);
      expect(snapshot.maxMessageRowId, 30);
      expect(snapshot.maxChatRowId, 3);
      expect(snapshot.sourceScopedObservationAvailable, isTrue);
    },
  );
}
