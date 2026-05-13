import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/integrators/sync_assessment_integrator.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/snapshot_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/sync_state.dart';

void main() {
  const integrator = MessageSyncAssessmentIntegrator();

  group('MessageSyncAssessmentIntegrator', () {
    test('maps zero row id delta to cursors-match state', () {
      final state = integrator.integrate(
        const MessageSnapshotDelta(rowIdDelta: 0, messageCountDelta: 0),
      );

      expect(state, const MessageSyncState.sourceAndLedgerCursorsMatch());
    });

    test('maps positive row id delta to source-ahead state', () {
      final state = integrator.integrate(
        const MessageSnapshotDelta(rowIdDelta: 5, messageCountDelta: 5),
      );

      expect(state, const MessageSyncState.sourceAheadOfLedger());
    });

    test('maps negative row id delta to ledger-ahead state', () {
      final state = integrator.integrate(
        const MessageSnapshotDelta(rowIdDelta: -5, messageCountDelta: -5),
      );

      expect(state, const MessageSyncState.ledgerAheadOfSource());
    });
  });
}
