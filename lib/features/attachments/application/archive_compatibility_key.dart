import 'package:flutter/foundation.dart';

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

  final String messageGuid;
  final int importAttachmentId;

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
