import '../../../domain/models/import_ledger_message_snapshot.dart';
import '../../../domain/models/live_chat_db_message_snapshot.dart';
import '../../../domain/models/message_snapshot_source_ledger_delta.dart';

class MessageSnapshotSourceLedgerDeltaIntegrator {
  const MessageSnapshotSourceLedgerDeltaIntegrator();

  MessageSnapshotSourceLedgerDelta integrate({
    required LiveChatDbMessageSnapshot source,

    required ImportLedgerMessageSnapshot ledger,
  }) {
    return MessageSnapshotSourceLedgerDelta(
      rowIdDelta: source.maxRowId - ledger.maxRowId,
      messageCountDelta: source.totalMessageCount - ledger.totalMessageCount,
    );
  }
}
