import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/source_identity.dart';
import 'package:remember_this_text/essentials/incremental_update/infrastructure/import_ledger_handle_repository.dart';
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
      'import_ledger_handle_repository_test_',
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

  test('returns zero snapshot for an empty handles table', () async {
    final repository = ImportLedgerHandleRepository(ledgerDb: ledgerDb);
    final snapshot = await repository.readHandleSnapshot();

    expect(snapshot.maxRowId, 0);
    expect(snapshot.totalHandleCount, 0);
  });

  test('returns live-source handle cursor and count only', () async {
    final batchId = await ledgerDb.insertImportBatch(
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );
    final db = await ledgerDb.database;
    await _insertLedgerHandle(
      db,
      id: 1,
      sourceRowid: 10,
      rawIdentifier: '+15550000001',
      batchId: batchId,
      sourceId: liveChatDbSourceIdentity.sourceId,
      sourceKind: liveChatDbSourceIdentity.sourceKind,
    );
    await _insertLedgerHandle(
      db,
      id: 2,
      sourceRowid: 20,
      rawIdentifier: '+15550000002',
      batchId: batchId,
      sourceId: liveChatDbSourceIdentity.sourceId,
      sourceKind: liveChatDbSourceIdentity.sourceKind,
    );
    await _insertLedgerHandle(
      db,
      id: 3,
      sourceRowid: 999999,
      rawIdentifier: '+15550009999',
      batchId: batchId,
      sourceId: 'archive-test',
      sourceKind: 'archived_messages_folder',
    );

    final repository = ImportLedgerHandleRepository(ledgerDb: ledgerDb);
    final snapshot = await repository.readHandleSnapshot();

    expect(snapshot.maxRowId, 20);
    expect(snapshot.totalHandleCount, 2);
  });
}

Future<void> _insertLedgerHandle(
  Database db, {
  required int id,
  required int sourceRowid,
  required String rawIdentifier,
  required int batchId,
  required String sourceId,
  required String sourceKind,
}) async {
  await db.insert('handles', <String, Object?>{
    'id': id,
    'source_rowid': sourceRowid,
    'source_id': sourceId,
    'source_kind': sourceKind,
    'service': 'iMessage',
    'raw_identifier': rawIdentifier,
    'compound_identifier': 'iMessage:$rawIdentifier',
    'batch_id': batchId,
  });
}
