import '../../../../essentials/source_scoped_import/domain/known_sources.dart';
import '../../../../essentials/source_scoped_import/domain/source_scoped_row_key.dart';

/// Resolves a message selection id to the canonical graph id used by evidence.
///
/// Some compatibility overlay/navigation entry points can still hand the
/// evidence spine an old live `chat.db.message` rowid. Message evidence remains
/// graph-native: callers get back the canonical `message_ss_id` whenever the
/// live rowid is recognizable, otherwise the supplied id is assumed to already
/// be canonical.
int canonicalMessageEvidenceId(int messageId) {
  if (SourceScopedRowKey.unpackSourceId(messageId) == liveChatDbSourceId) {
    return messageId;
  }
  if (messageId <= 0 || messageId > SourceScopedRowKey.maxSourceRowId) {
    return messageId;
  }
  return SourceScopedRowKey.pack(
    sourceId: liveChatDbSourceId,
    sourceRowId: messageId,
  );
}

/// Returns the live `chat.db.message` ROWID for a graph message evidence id.
///
/// This exists only for older rowid-keyed overlay compatibility. Ordinary message
/// evidence remains keyed by `message_ss_id`.
int? liveMessageRowIdForEvidenceId(int messageId) {
  if (SourceScopedRowKey.unpackSourceId(messageId) != liveChatDbSourceId) {
    return null;
  }
  return SourceScopedRowKey.unpackSourceRowId(messageId);
}
