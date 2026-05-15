import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/handles/integrators/handle_snapshot_delta_integrator.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/handle_snapshot.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/handle_snapshot_delta.dart';

void main() {
  const integrator = HandleSnapshotDeltaIntegrator();

  group('HandleSnapshotDeltaIntegrator', () {
    test('derives zero delta when source and ledger match', () {
      final delta = integrator.integrate(
        source: const HandleSnapshot(maxRowId: 10, totalHandleCount: 4),
        ledger: const HandleSnapshot(maxRowId: 10, totalHandleCount: 4),
      );

      expect(
        delta,
        const HandleSnapshotDelta(rowIdDelta: 0, handleCountDelta: 0),
      );
    });

    test('derives positive delta when source is ahead', () {
      final delta = integrator.integrate(
        source: const HandleSnapshot(maxRowId: 15, totalHandleCount: 7),
        ledger: const HandleSnapshot(maxRowId: 10, totalHandleCount: 4),
      );

      expect(
        delta,
        const HandleSnapshotDelta(rowIdDelta: 5, handleCountDelta: 3),
      );
      expect(delta.isLiveSourceRowAhead, isTrue);
    });

    test('derives negative delta when ledger is ahead', () {
      final delta = integrator.integrate(
        source: const HandleSnapshot(maxRowId: 10, totalHandleCount: 4),
        ledger: const HandleSnapshot(maxRowId: 15, totalHandleCount: 7),
      );

      expect(
        delta,
        const HandleSnapshotDelta(rowIdDelta: -5, handleCountDelta: -3),
      );
      expect(delta.isLedgerSourceRowAhead, isTrue);
    });
  });
}
