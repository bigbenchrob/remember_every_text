import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chats/integrators/chat_sync_state_integrator.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/chat_snapshot_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/chat_sync_state.dart';

void main() {
  const integrator = ChatSyncStateIntegrator();

  group('ChatSyncStateIntegrator', () {
    test('maps zero row id delta to cursors-match state', () {
      final state = integrator.integrate(
        const ChatSnapshotDelta(rowIdDelta: 0, chatCountDelta: 0),
      );

      expect(state, const ChatSyncState.sourceAndLedgerCursorsMatch());
    });

    test('maps positive row id delta to source-ahead state', () {
      final state = integrator.integrate(
        const ChatSnapshotDelta(rowIdDelta: 5, chatCountDelta: 5),
      );

      expect(state, const ChatSyncState.sourceAheadOfLedger());
    });

    test('maps negative row id delta to ledger-ahead state', () {
      final state = integrator.integrate(
        const ChatSnapshotDelta(rowIdDelta: -5, chatCountDelta: -5),
      );

      expect(state, const ChatSyncState.ledgerAheadOfSource());
    });
  });
}
