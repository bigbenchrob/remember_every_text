import '../../../domain/models/chat_snapshot.dart';
import '../../../domain/models/chat_snapshot_delta.dart';

class ChatSnapshotDeltaIntegrator {
  const ChatSnapshotDeltaIntegrator();

  ChatSnapshotDelta integrate({
    required ChatSnapshot source,
    required ChatSnapshot ledger,
  }) {
    return ChatSnapshotDelta(
      rowIdDelta: source.maxRowId - ledger.maxRowId,
      chatCountDelta: source.totalChatCount - ledger.totalChatCount,
    );
  }
}
