import '../../../../essentials/conversation_graph/application/identity/live_chat_graph_identity.dart';

/// Resolves a message selection id to the canonical graph id used by evidence.
///
/// Some compatibility overlay/navigation entry points can still hand the
/// evidence spine an old live `chat.db.message` rowid. Message evidence remains
/// graph-native: callers get back the canonical `message_ss_id` whenever the
/// live rowid is recognizable, otherwise the supplied id is assumed to already
/// be canonical.
int canonicalMessageEvidenceId(int messageId) {
  return canonicalLiveChatGraphId(messageId);
}

/// Returns the live `chat.db.message` ROWID for a graph message evidence id.
///
/// This exists only for older rowid-keyed overlay compatibility. Ordinary message
/// evidence remains keyed by `message_ss_id`.
int? liveMessageRowIdForEvidenceId(int messageId) {
  return liveChatSourceRowIdForGraphId(messageId);
}
