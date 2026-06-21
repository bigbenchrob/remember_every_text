import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';

void main() {
  test('storageKeySegment preserves current archive compatibility shape', () {
    const key = ArchiveCompatibilityKey(
      messageGuid: 'message-guid',
      importAttachmentId: 42,
    );

    expect(key.storageKeySegment, 'message-guid::42');
  });

  test('fromLiveAttachmentSsId derives live source attachment row id', () {
    final attachmentSsId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 42,
    );

    final key = ArchiveCompatibilityKey.fromLiveAttachmentSsId(
      messageGuid: 'message-guid',
      attachmentSsId: attachmentSsId,
    );

    expect(key.messageGuid, 'message-guid');
    expect(key.importAttachmentId, 42);
    expect(key.archiveCompatibilityAttachmentId, 42);
    expect(key.liveSourceAttachmentRowId, 42);
  });

  test('fromStoredTuple preserves existing archive tuple values', () {
    final key = ArchiveCompatibilityKey.fromStoredTuple(
      messageGuid: 'message-guid',
      importAttachmentId: 42,
    );

    expect(key.messageGuid, 'message-guid');
    expect(key.importAttachmentId, 42);
    expect(key.storageKeySegment, 'message-guid::42');
  });

  test('debug label uses archive compatibility identity language', () {
    final key = ArchiveCompatibilityKey.fromStoredTuple(
      messageGuid: 'message-guid',
      importAttachmentId: 42,
    );

    expect(key.toString(), contains('archiveCompatibilityAttachmentId: 42'));
    expect(key.toString(), isNot(contains('importAttachmentId: 42')));
  });

  test(
    'supportsLiveGraphEndpoints accepts live message and attachment ids',
    () {
      final messageSsId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 41,
      );
      final attachmentSsId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 42,
      );

      expect(
        ArchiveCompatibilityKey.supportsLiveGraphEndpoints(
          messageSsId: messageSsId,
          attachmentSsId: attachmentSsId,
        ),
        isTrue,
      );
    },
  );

  test('supportsLiveGraphEndpoints rejects non-live message ids', () {
    final nonLiveMessageSsId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId + 1,
      sourceRowId: 41,
    );
    final attachmentSsId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 42,
    );

    expect(
      ArchiveCompatibilityKey.supportsLiveGraphEndpoints(
        messageSsId: nonLiveMessageSsId,
        attachmentSsId: attachmentSsId,
      ),
      isFalse,
    );
  });

  test('supportsLiveGraphEndpoints rejects non-live endpoint ids', () {
    final messageSsId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 41,
    );
    final nonLiveAttachmentSsId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId + 1,
      sourceRowId: 42,
    );

    expect(
      ArchiveCompatibilityKey.supportsLiveGraphEndpoints(
        messageSsId: messageSsId,
        attachmentSsId: nonLiveAttachmentSsId,
      ),
      isFalse,
    );
  });

  test('fromLiveAttachmentSsId rejects non-live source ids', () {
    final attachmentSsId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId + 1,
      sourceRowId: 42,
    );

    expect(
      () => ArchiveCompatibilityKey.fromLiveAttachmentSsId(
        messageGuid: 'message-guid',
        attachmentSsId: attachmentSsId,
      ),
      throwsArgumentError,
    );
  });
}
