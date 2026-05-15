import '../../../domain/models/chat_snapshot_delta.dart';
import '../../../domain/sealed_unions/chat_sync_state.dart';

class ChatSyncStateIntegrator {
  const ChatSyncStateIntegrator();

  ChatSyncState integrate(ChatSnapshotDelta delta) {
    if (delta.isLiveSourceRowAhead) {
      return const ChatSyncState.sourceAheadOfLedger();
    }

    if (delta.isLedgerSourceRowAhead) {
      return const ChatSyncState.ledgerAheadOfSource();
    }

    return const ChatSyncState.sourceAndLedgerCursorsMatch();
  }
}
