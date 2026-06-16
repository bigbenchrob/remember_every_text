import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:remember_this_text/features/attachments/application/cross_snapshot_mapping.dart';
import 'package:remember_this_text/features/attachments/application/historical_snapshot_reader.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/graph_cross_snapshot_mapper.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/source_scoped_attachment_snapshot_lookup.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../essentials/conversation_graph/conversation_graph_test_database.dart';

void main() {
  late Directory tempDir;
  late ImportDatabase importLedgerDb;
  late ConversationGraphDatabase graphDb;
  late GraphCrossSnapshotMapper mapper;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'graph_cross_snapshot_mapper_test_',
    );
    importLedgerDb = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
    graphDb = await openConversationGraphTestDatabase();
    mapper = GraphCrossSnapshotMapper(
      attachmentLookup: SourceScopedAttachmentSnapshotLookup(
        importLedgerDb: importLedgerDb,
      ),
      graphDb: graphDb,
    );
  });

  tearDown(() async {
    await graphDb.close();
    await importLedgerDb.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('empty current attachment snapshot reports unavailable', () async {
    expect(await mapper.hasCurrentAttachmentSnapshot(), isFalse);
  });

  test('maps historical attachment GUID to graph attachment ss_id', () async {
    final messageSsId = _ss(101);
    final attachmentSsId = _ss(201);
    await _insertImportAttachment(
      importLedgerDb,
      attachmentSsId: attachmentSsId,
      sourceRowId: 201,
      guid: 'attachment-guid-201',
    );
    await _insertGraphMessageAttachment(
      graphDb,
      messageSsId: messageSsId,
      attachmentSsId: attachmentSsId,
      messageGuid: 'message-guid-101',
    );

    final result = await mapper.mapRecords(
      historicalRecords: [
        _record(
          histMessageGuid: 'message-guid-101',
          histAttachmentGuid: 'attachment-guid-201',
        ),
      ],
    );

    expect(result, isNotNull);
    expect(result!.mapped, hasLength(1));
    expect(result.mapped.first.matchMethod, MatchMethod.guidMatch);
    expect(result.mapped.first.currentMessageSsId, messageSsId);
    expect(result.mapped.first.currentAttachmentSsId, attachmentSsId);
    expect(result.mapped.first.currentImportAttachmentId, 201);
    expect(result.mappedByGuid, 1);
  });

  test(
    'uses single-attachment fallback when GUID is null and unambiguous',
    () async {
      final messageSsId = _ss(102);
      final attachmentSsId = _ss(202);
      await _insertImportAttachment(
        importLedgerDb,
        attachmentSsId: attachmentSsId,
        sourceRowId: 202,
        guid: null,
      );
      await _insertGraphMessageAttachment(
        graphDb,
        messageSsId: messageSsId,
        attachmentSsId: attachmentSsId,
        messageGuid: 'message-guid-102',
      );

      final result = await mapper.mapRecords(
        historicalRecords: [
          _record(
            histMessageGuid: 'message-guid-102',
            histAttachmentGuid: null,
          ),
        ],
      );

      expect(result, isNotNull);
      expect(result!.mapped, hasLength(1));
      expect(
        result.mapped.first.matchMethod,
        MatchMethod.singleAttachmentFallback,
      );
      expect(result.mapped.first.currentAttachmentSsId, attachmentSsId);
      expect(result.mappedBySingleFallback, 1);
    },
  );

  test(
    'reports message missing when historical GUID is not in graph',
    () async {
      await _insertImportAttachment(
        importLedgerDb,
        attachmentSsId: _ss(203),
        sourceRowId: 203,
        guid: 'attachment-guid-203',
      );

      final result = await mapper.mapRecords(
        historicalRecords: [
          _record(
            histMessageGuid: 'missing-message-guid',
            histAttachmentGuid: 'attachment-guid-203',
          ),
        ],
      );

      expect(result, isNotNull);
      expect(result!.unmapped, hasLength(1));
      expect(result.unmapped.first.reason, UnmappedReason.messageNotInGraph);
      expect(result.unmappedMessageMissing, 1);
    },
  );
}

HistoricalAttachmentRecord _record({
  required String histMessageGuid,
  required String? histAttachmentGuid,
}) {
  return HistoricalAttachmentRecord(
    histMessageGuid: histMessageGuid,
    histAttachmentGuid: histAttachmentGuid,
    histLocalPath: '/tmp/test.jpg',
    resolvedFilePath: '/tmp/test.jpg',
    fileFound: true,
    histTransferName: null,
    histMimeType: null,
    histUti: null,
    histFileSize: null,
    histIsOutgoing: false,
  );
}

Future<void> _insertImportAttachment(
  ImportDatabase importLedgerDb, {
  required int attachmentSsId,
  required int sourceRowId,
  required String? guid,
}) async {
  final batchId = await importLedgerDb.insertImportBatch(
    sourceId: liveChatDbSourceId,
    startedAtUtc: '2026-05-31T10:00:00.000Z',
  );
  await importLedgerDb.database.insert('attachments', <String, Object?>{
    'ss_id': attachmentSsId,
    'source_id': liveChatDbSourceId,
    'source_rowid': sourceRowId,
    'guid': guid,
    'batch_id': batchId,
  });
}

Future<void> _insertGraphMessageAttachment(
  ConversationGraphDatabase graphDb, {
  required int messageSsId,
  required int attachmentSsId,
  required String messageGuid,
}) async {
  await graphDb.executeSql(
    '''
    INSERT INTO messages (ss_id, guid, is_from_me)
    VALUES (?, ?, 0)
    ''',
    <Object?>[messageSsId, messageGuid],
  );
  await graphDb.executeSql(
    '''
    INSERT INTO attachments (ss_id, guid, filename)
    VALUES (?, ?, ?)
    ''',
    <Object?>[attachmentSsId, 'attachment-guid', 'photo.jpg'],
  );
  await graphDb.executeSql(
    '''
    INSERT INTO message_to_attachment (message_ss_id, attachment_ss_id)
    VALUES (?, ?)
    ''',
    <Object?>[messageSsId, attachmentSsId],
  );
}

int _ss(int sourceRowId) {
  return SourceScopedRowKey.pack(
    sourceId: liveChatDbSourceId,
    sourceRowId: sourceRowId,
  );
}
