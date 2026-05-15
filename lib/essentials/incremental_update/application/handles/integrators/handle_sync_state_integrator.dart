import '../../../domain/models/handle_snapshot_delta.dart';
import '../../../domain/sealed_unions/handle_sync_state.dart';

class HandleSyncStateIntegrator {
  const HandleSyncStateIntegrator();

  HandleSyncState integrate(HandleSnapshotDelta delta) {
    if (delta.isLiveSourceRowAhead) {
      return const HandleSyncState.sourceAheadOfLedger();
    }

    if (delta.isLedgerSourceRowAhead) {
      return const HandleSyncState.ledgerAheadOfSource();
    }

    return const HandleSyncState.sourceAndLedgerCursorsMatch();
  }
}
