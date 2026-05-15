import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/handles/integrators/handle_sync_state_integrator.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/handle_snapshot_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/handle_sync_state.dart';

void main() {
  const integrator = HandleSyncStateIntegrator();

  group('HandleSyncStateIntegrator', () {
    test('maps zero row id delta to cursors-match state', () {
      final state = integrator.integrate(
        const HandleSnapshotDelta(rowIdDelta: 0, handleCountDelta: 0),
      );

      expect(state, const HandleSyncState.sourceAndLedgerCursorsMatch());
    });

    test('maps positive row id delta to source-ahead state', () {
      final state = integrator.integrate(
        const HandleSnapshotDelta(rowIdDelta: 5, handleCountDelta: 5),
      );

      expect(state, const HandleSyncState.sourceAheadOfLedger());
    });

    test('maps negative row id delta to ledger-ahead state', () {
      final state = integrator.integrate(
        const HandleSnapshotDelta(rowIdDelta: -5, handleCountDelta: -5),
      );

      expect(state, const HandleSyncState.ledgerAheadOfSource());
    });
  });
}
