import 'package:flutter/foundation.dart';

import '../../source_scoped_import/domain/known_sources.dart';
import '../../source_scoped_import/domain/source_scoped_row_key.dart';

/// Current compatibility key for existing attachment archive storage.
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

  factory ArchiveCompatibilityKey.fromStoredTuple({
    required String messageGuid,
    required int importAttachmentId,
  }) {
    return ArchiveCompatibilityKey(
      messageGuid: messageGuid,
      importAttachmentId: importAttachmentId,
    );
  }

  static bool supportsLiveGraphEndpoints({
    required int messageSsId,
    required int attachmentSsId,
  }) {
    return _isLiveChatDbId(messageSsId) && _isLiveChatDbId(attachmentSsId);
  }

  factory ArchiveCompatibilityKey.fromLiveAttachmentSsId({
    required String messageGuid,
    required int attachmentSsId,
  }) {
    if (!_isLiveChatDbId(attachmentSsId)) {
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

  /// Attachment ROWID used when resolving this compatibility key against live
  /// `chat.db` attachment paths.
  ///
  /// The existing archive table calls this `import_attachment_id`. For the live
  /// source it is the Apple attachment ROWID, so application code that refreshes
  /// source paths should use this semantic name instead of repeating storage
  /// column terminology.
  int get liveSourceAttachmentRowId => importAttachmentId;

  /// Attachment id component used by the archive compatibility tuple.
  ///
  /// Prefer this name when code is reasoning about archive lookup identity but
  /// is not directly reading or writing the persisted overlay column.
  int get archiveCompatibilityAttachmentId => importAttachmentId;

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
        'archiveCompatibilityAttachmentId: $archiveCompatibilityAttachmentId)';
  }

  static bool _isLiveChatDbId(int ssId) {
    return SourceScopedRowKey.unpackSourceId(ssId) == liveChatDbSourceId;
  }
}
