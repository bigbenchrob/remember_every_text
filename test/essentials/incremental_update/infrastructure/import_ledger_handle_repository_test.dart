import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
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

  test(
    'returns max source row id and total count for ledger handles',
    () async {
      final batchId = await ledgerDb.insertImportBatch(
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );
      final db = await ledgerDb.database;
      await db.insert('handles', <String, Object?>{
        'id': 1,
        'source_rowid': 10,
        'service': 'iMessage',
        'raw_identifier': '+15550000001',
        'compound_identifier': 'iMessage:+15550000001',
        'batch_id': batchId,
      });
      await db.insert('handles', <String, Object?>{
        'id': 2,
        'source_rowid': 20,
        'service': 'iMessage',
        'raw_identifier': '+15550000002',
        'compound_identifier': 'iMessage:+15550000002',
        'batch_id': batchId,
      });

      final repository = ImportLedgerHandleRepository(ledgerDb: ledgerDb);
      final snapshot = await repository.readHandleSnapshot();

      expect(snapshot.maxRowId, 20);
      expect(snapshot.totalHandleCount, 2);
    },
  );
}
