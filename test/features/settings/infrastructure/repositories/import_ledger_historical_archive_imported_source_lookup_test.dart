import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/historical_archive_source_identity.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:remember_this_text/features/settings/infrastructure/repositories/import_ledger_historical_archive_imported_source_lookup.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  const sourceKey = 'historical-messages-archive:/archive/chat.db';
  final identity = HistoricalArchiveSourceIdentity.fromPersistedValue(
    sourceKey,
  );
  late Directory tempDirectory;
  late ImportDatabase importDatabase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'historical_archive_imported_source_lookup_test_',
    );
    importDatabase = await ImportDatabase.open(
      databaseDirectory: tempDirectory.path,
      databaseName: 'macos_import_ss_test.db',
    );
  });

  tearDown(() async {
    await importDatabase.close();
    await tempDirectory.delete(recursive: true);
  });

  test('requires registration and a positive source message count', () async {
    final lookup = ImportLedgerHistoricalArchiveImportedSourceLookup(
      importLedger: importDatabase,
    );

    expect(await lookup.findImportedSource(identity: identity), isNull);

    final sourceId = await importDatabase.getOrCreateSource(
      sourceKey: sourceKey,
      sourceKind: historicalMessagesArchiveSourceKind,
      sourceLabel: 'Archive',
    );
    expect(await lookup.findImportedSource(identity: identity), isNull);

    final batchId = await importDatabase.insertImportBatch(
      sourceId: sourceId,
      startedAtUtc: '2026-08-17T00:00:00.000Z',
    );
    await importDatabase.database.insert('messages', <String, Object?>{
      'ss_id': SourceScopedRowKey.pack(sourceId: sourceId, sourceRowId: 1),
      'source_id': sourceId,
      'source_rowid': 1,
      'guid': 'message-1',
      'is_from_me': 0,
      'batch_id': batchId,
    });

    final match = await lookup.findImportedSource(identity: identity);

    expect(match?.sourceKey, sourceKey);
    expect(match?.sourceId, sourceId);
    expect(match?.importedMessageCount, 1);
  });
}
