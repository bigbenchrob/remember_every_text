import '../../../domain/models/snapshot_delta.dart';
import '../../../domain/sealed_unions/sync_state.dart';

class MessageSyncAssessmentIntegrator {
  const MessageSyncAssessmentIntegrator();

  MessageSyncState integrate(MessageSnapshotDelta delta) {
    if (delta.isLiveSourceRowAhead) {
      return const MessageSyncState.sourceAheadOfLedger();
    }

    if (delta.isLedgerSourceRowAhead) {
      return const MessageSyncState.ledgerAheadOfSource();
    }

    return const MessageSyncState.sourceAndLedgerCursorsMatch();
  }
}
