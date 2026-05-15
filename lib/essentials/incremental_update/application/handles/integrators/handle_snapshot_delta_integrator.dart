import '../../../domain/models/handle_snapshot.dart';
import '../../../domain/models/handle_snapshot_delta.dart';

class HandleSnapshotDeltaIntegrator {
  const HandleSnapshotDeltaIntegrator();

  HandleSnapshotDelta integrate({
    required HandleSnapshot source,
    required HandleSnapshot ledger,
  }) {
    return HandleSnapshotDelta(
      rowIdDelta: source.maxRowId - ledger.maxRowId,
      handleCountDelta: source.totalHandleCount - ledger.totalHandleCount,
    );
  }
}
