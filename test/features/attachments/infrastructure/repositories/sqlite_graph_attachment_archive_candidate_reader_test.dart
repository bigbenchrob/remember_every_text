import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/sqlite_graph_attachment_archive_candidate_reader.dart';

void main() {
  late ConversationGraphDatabase graphDatabase;
  late OverlayDatabase overlayDatabase;
  late SqliteGraphAttachmentArchiveCandidateReader reader;

  setUp(() {
    graphDatabase = ConversationGraphDatabase(NativeDatabase.memory());
    overlayDatabase = OverlayDatabase(NativeDatabase.memory());
    reader = SqliteGraphAttachmentArchiveCandidateReader(
      graphDatabase: graphDatabase,
      overlayDatabase: overlayDatabase,
    );
  });

  tearDown(() async {
    await graphDatabase.close();
    await overlayDatabase.close();
  });

  test(
    'reads source-range candidates with archive compatibility keys',
    () async {
      await _insertGraphAttachment(
        graphDatabase,
        messageSourceRowId: 100,
        attachmentSourceRowId: 200,
        messageGuid: 'message-guid-100',
        filename: '~/Library/Messages/Attachments/photo.jpg',
        mimeType: 'image/jpeg',
      );
      await _insertGraphAttachment(
        graphDatabase,
        messageSourceRowId: 104,
        attachmentSourceRowId: 204,
        messageGuid: 'message-guid-104',
        filename: ' ',
        mimeType: 'image/jpeg',
      );
      await _insertGraphAttachment(
        graphDatabase,
        messageSourceRowId: 110,
        attachmentSourceRowId: 210,
        messageGuid: 'message-guid-110',
        filename: '~/Library/Messages/Attachments/out-of-range.jpg',
        mimeType: 'image/jpeg',
      );

      final rows = await reader.readSourceRange(
        sourceId: 1,
        startedAfterSourceRowId: 99,
        lastSourceRowId: 105,
      );

      expect(rows, hasLength(1));
      expect(rows.single.graphAttachmentId, _ss(200));
      expect(rows.single.localPath, '~/Library/Messages/Attachments/photo.jpg');
      expect(rows.single.mimeType, 'image/jpeg');
      expect(
        rows.single.archiveCompatibilityKey!.messageGuid,
        'message-guid-100',
      );
      expect(rows.single.archiveCompatibilityKey!.importAttachmentId, 200);
    },
  );

  test('sweep selects only unarchived live image candidates', () async {
    await _insertGraphAttachment(
      graphDatabase,
      messageSourceRowId: 100,
      attachmentSourceRowId: 200,
      messageGuid: 'archived-message-guid',
      filename: '~/Library/Messages/Attachments/already-archived.jpg',
      mimeType: 'image/jpeg',
    );
    await _insertArchiveRow(
      overlayDatabase,
      messageGuid: 'archived-message-guid',
      importAttachmentId: 200,
    );
    await _insertGraphAttachment(
      graphDatabase,
      messageSourceRowId: 101,
      attachmentSourceRowId: 201,
      messageGuid: 'unarchived-message-guid',
      filename: '~/Library/Messages/Attachments/unarchived.png',
      mimeType: 'image/png',
    );
    await _insertGraphAttachment(
      graphDatabase,
      messageSourceRowId: 102,
      attachmentSourceRowId: 202,
      messageGuid: 'pdf-message-guid',
      filename: '~/Library/Messages/Attachments/file.pdf',
      mimeType: 'application/pdf',
    );
    await _insertGraphAttachment(
      graphDatabase,
      messageSourceRowId: 103,
      attachmentSourceRowId: 203,
      messageGuid: 'empty-path-message-guid',
      filename: ' ',
      mimeType: 'image/jpeg',
    );
    await _insertGraphAttachment(
      graphDatabase,
      sourceId: 2,
      messageSourceRowId: 104,
      attachmentSourceRowId: 204,
      messageGuid: 'other-source-message-guid',
      filename: '~/Library/Messages/Attachments/other-source.jpg',
      mimeType: 'image/jpeg',
    );

    final selection = await reader.selectSweepCandidates(
      afterAttachmentId: 0,
      limit: 10,
      pageSize: 10,
    );

    expect(selection.rows, hasLength(1));
    expect(selection.rows.single.graphAttachmentId, _ss(201));
    expect(
      selection.rows.single.localPath,
      '~/Library/Messages/Attachments/unarchived.png',
    );
    expect(
      selection.rows.single.archiveCompatibilityKey!.messageGuid,
      'unarchived-message-guid',
    );
    expect(
      selection.rows.single.archiveCompatibilityKey!.importAttachmentId,
      201,
    );
  });
}

Future<void> _insertGraphAttachment(
  ConversationGraphDatabase graphDatabase, {
  int sourceId = 1,
  required int messageSourceRowId,
  required int attachmentSourceRowId,
  required String messageGuid,
  required String filename,
  required String mimeType,
}) async {
  await graphDatabase.executeSql(
    '''
    INSERT INTO messages (ss_id, guid, is_from_me)
    VALUES (?, ?, 0)
    ''',
    <Object?>[_ss(messageSourceRowId, sourceId: sourceId), messageGuid],
  );
  await graphDatabase.executeSql(
    '''
    INSERT INTO attachments (ss_id, guid, filename, mime_type)
    VALUES (?, ?, ?, ?)
    ''',
    <Object?>[
      _ss(attachmentSourceRowId, sourceId: sourceId),
      'attachment-guid-$attachmentSourceRowId',
      filename,
      mimeType,
    ],
  );
  await graphDatabase.executeSql(
    '''
    INSERT INTO message_to_attachment (message_ss_id, attachment_ss_id)
    VALUES (?, ?)
    ''',
    <Object?>[
      _ss(messageSourceRowId, sourceId: sourceId),
      _ss(attachmentSourceRowId, sourceId: sourceId),
    ],
  );
}

Future<void> _insertArchiveRow(
  OverlayDatabase overlayDatabase, {
  required String messageGuid,
  required int importAttachmentId,
}) async {
  await overlayDatabase.customStatement(
    '''
    INSERT INTO archived_attachments (
      message_guid,
      import_attachment_id,
      archive_relative_path,
      archived_at_utc,
      file_size_bytes,
      content_hash,
      provenance
    ) VALUES (?, ?, ?, ?, ?, ?, ?)
    ''',
    <Object?>[
      messageGuid,
      importAttachmentId,
      'aa/bb/hash.jpg',
      '2026-06-19T10:00:00.000Z',
      5,
      'hash',
      'archived',
    ],
  );
}

int _ss(int sourceRowId, {int sourceId = 1}) {
  return SourceScopedRowKey.pack(sourceId: sourceId, sourceRowId: sourceRowId);
}
