import '../../../../essentials/conversation_graph/domain/identity_key_bridge.dart';

/// Resolves a message selection id to the canonical graph id used by evidence.
///
/// Some retained overlay/search entry points can still hand the evidence spine
/// an old live `chat.db.message` rowid. Message evidence remains graph-native:
/// callers get back the canonical `message_ss_id` whenever the retained key is
/// recognizable, otherwise the supplied id is assumed to already be canonical.
int canonicalMessageEvidenceId(int messageId) {
  return graphMessageIdForRetainedOverlayMessageRowId(messageId) ?? messageId;
}
