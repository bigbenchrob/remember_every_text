import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/source_scoped_attachment_snapshot_lookup.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late ImportDatabase importLedgerDb;
  late SourceScopedAttachmentSnapshotLookup lookup;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'source_scoped_attachment_snapshot_lookup_test_',
    );
    importLedgerDb = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
    lookup = SourceScopedAttachmentSnapshotLookup(
      importLedgerDb: importLedgerDb,
    );
  });

  tearDown(() async {
    await importLedgerDb.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('reports whether a source has imported attachment facts', () async {
    expect(await lookup.hasAttachmentsForSource(liveChatDbSourceId), isFalse);

    await _insertImportAttachment(
      importLedgerDb,
      sourceId: liveChatDbSourceId,
      sourceRowId: 200,
      guid: 'attachment-guid',
    );

    expect(await lookup.hasAttachmentsForSource(liveChatDbSourceId), isTrue);
    expect(await lookup.hasAttachmentsForSource(2), isFalse);
  });

  test('resolves attachment ss ids by source-scoped GUID', () async {
    await _insertImportAttachment(
      importLedgerDb,
      sourceId: liveChatDbSourceId,
      sourceRowId: 200,
      guid: 'shared-attachment-guid',
    );
    await _insertImportAttachment(
      importLedgerDb,
      sourceId: 2,
      sourceRowId: 200,
      guid: 'shared-attachment-guid',
    );
    await _insertImportAttachment(
      importLedgerDb,
      sourceId: liveChatDbSourceId,
      sourceRowId: 201,
      guid: 'shared-attachment-guid',
    );

    final liveRows = await lookup.attachmentSsIdsForGuid(
      sourceId: liveChatDbSourceId,
      guid: 'shared-attachment-guid',
    );
    final otherRows = await lookup.attachmentSsIdsForGuid(
      sourceId: 2,
      guid: 'shared-attachment-guid',
    );

    expect(
      liveRows,
      unorderedEquals(<int>[
        _ss(liveChatDbSourceId, 200),
        _ss(liveChatDbSourceId, 201),
      ]),
    );
    expect(otherRows, <int>[_ss(2, 200)]);
  });
}

Future<void> _insertImportAttachment(
  ImportDatabase importLedgerDb, {
  required int sourceId,
  required int sourceRowId,
  required String guid,
}) async {
  await importLedgerDb.getOrCreateSource(
    sourceKey: 'source-$sourceId',
    sourceKind: 'test',
  );
  final batchId = await importLedgerDb.insertImportBatch(
    sourceId: sourceId,
    startedAtUtc: '2026-06-19T10:00:00.000Z',
  );
  await importLedgerDb.database.insert('attachments', <String, Object?>{
    'ss_id': _ss(sourceId, sourceRowId),
    'source_id': sourceId,
    'source_rowid': sourceRowId,
    'guid': guid,
    'batch_id': batchId,
  });
}

int _ss(int sourceId, int sourceRowId) {
  return SourceScopedRowKey.pack(sourceId: sourceId, sourceRowId: sourceRowId);
}
