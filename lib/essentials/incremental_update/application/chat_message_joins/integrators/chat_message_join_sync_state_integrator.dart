import '../../../domain/models/chat_message_join_snapshot_delta.dart';
import '../../../domain/sealed_unions/chat_message_join_sync_state.dart';

class ChatMessageJoinSyncStateIntegrator {
  const ChatMessageJoinSyncStateIntegrator();

  ChatMessageJoinSyncState integrate(ChatMessageJoinSnapshotDelta delta) {
    if (!delta.ledgerSourceScopedObservationAvailable) {
      return const ChatMessageJoinSyncState.topologyNotYetImported();
    }

    if (delta.isSourceTopologyAhead) {
      return const ChatMessageJoinSyncState.sourceTopologyAheadOfLedger();
    }

    if (delta.isLedgerTopologyAhead) {
      return const ChatMessageJoinSyncState.ledgerTopologyAheadOfSource();
    }

    return const ChatMessageJoinSyncState.sourceAndLedgerTopologyMatch();
  }
}
