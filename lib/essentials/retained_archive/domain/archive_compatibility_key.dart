import 'package:flutter/foundation.dart';

import '../../source_scoped_import/domain/known_sources.dart';
import '../../source_scoped_import/domain/source_scoped_row_key.dart';

/// Current compatibility key for retained attachment archive storage.
///
/// The archive overlay still stores records by `(message_guid,
/// import_attachment_id)`. This value object names that bridge explicitly so
/// graph-facing code does not treat the pair as canonical graph identity.
@immutable
class ArchiveCompatibilityKey {
  const ArchiveCompatibilityKey({
    required this.messageGuid,
    required this.importAttachmentId,
  });

  factory ArchiveCompatibilityKey.fromLiveAttachmentSsId({
    required String messageGuid,
    required int attachmentSsId,
  }) {
    final sourceId = SourceScopedRowKey.unpackSourceId(attachmentSsId);
    if (sourceId != liveChatDbSourceId) {
      throw ArgumentError.value(
        attachmentSsId,
        'attachmentSsId',
        'Archive compatibility keys can only be derived from live chat.db '
            'attachment ss_ids.',
      );
    }
    return ArchiveCompatibilityKey(
      messageGuid: messageGuid,
      importAttachmentId: SourceScopedRowKey.unpackSourceRowId(attachmentSsId),
    );
  }

  final String messageGuid;
  final int importAttachmentId;

  String get storageKeySegment => '$messageGuid::$importAttachmentId';

  @override
  bool operator ==(Object other) {
    return other is ArchiveCompatibilityKey &&
        other.messageGuid == messageGuid &&
        other.importAttachmentId == importAttachmentId;
  }

  @override
  int get hashCode => Object.hash(messageGuid, importAttachmentId);

  @override
  String toString() {
    return 'ArchiveCompatibilityKey(messageGuid: $messageGuid, '
        'importAttachmentId: $importAttachmentId)';
  }
}
