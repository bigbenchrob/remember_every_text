import '../../../domain/models/chat_message_join_snapshot.dart';
import '../../../domain/models/chat_message_join_snapshot_delta.dart';

class ChatMessageJoinSnapshotDeltaIntegrator {
  const ChatMessageJoinSnapshotDeltaIntegrator();

  ChatMessageJoinSnapshotDelta integrate({
    required ChatMessageJoinSnapshot source,
    required ChatMessageJoinSnapshot ledger,
  }) {
    return ChatMessageJoinSnapshotDelta(
      rowIdDelta: source.maxRowId - ledger.maxRowId,
      joinCountDelta: source.totalJoinCount - ledger.totalJoinCount,
      messageRowIdDelta: source.maxMessageRowId - ledger.maxMessageRowId,
      chatRowIdDelta: source.maxChatRowId - ledger.maxChatRowId,
      ledgerSourceScopedObservationAvailable:
          ledger.sourceScopedObservationAvailable,
    );
  }
}
