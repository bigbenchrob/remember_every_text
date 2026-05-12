import '../../../domain/models/import_ledger_message_snapshot.dart';
import '../../../domain/models/live_chat_db_message_snapshot.dart';
import '../../../domain/models/snapshot_delta.dart';

class MessageSnapshotDeltaIntegrator {
  const MessageSnapshotDeltaIntegrator();

  MessageSnapshotDelta integrate({
    required LiveChatDbMessageSnapshot source,

    required ImportLedgerMessageSnapshot ledger,
  }) {
    return MessageSnapshotDelta(
      rowIdDelta: source.maxRowId - ledger.maxRowId,
      messageCountDelta: source.totalMessageCount - ledger.totalMessageCount,
    );
  }
}
