import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/models/message_snapshot_source_ledger_delta.dart';
import '../integrators/message_snapshot_source_ledger_delta_provider.dart';

class MessageSnapshotDeltaRefreshOrchestrator {
  MessageSnapshotDeltaRefreshOrchestrator(this._ref);

  final Ref _ref;

  Future<MessageSnapshotSourceLedgerDelta> refreshOnce() async {
    _ref.invalidate(messageSnapshotSourceLedgerDeltaProvider);
    return _ref.read(messageSnapshotSourceLedgerDeltaProvider.future);
  }
}
