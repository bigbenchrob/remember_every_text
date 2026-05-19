import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chat_message_joins/integrators/chat_message_join_import_decision_integrator.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chat_message_joins/integrators/chat_message_join_snapshot_delta_integrator.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chat_message_joins/integrators/chat_message_join_sync_state_integrator.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/chat_message_join_snapshot.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/chat_message_join_snapshot_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/chat_message_join_import_decision.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/chat_message_join_sync_state.dart';

void main() {
  group('ChatMessageJoinSnapshotDeltaIntegrator', () {
    test('derives topology deltas from source and ledger snapshots', () {
      final delta = const ChatMessageJoinSnapshotDeltaIntegrator().integrate(
        source: const ChatMessageJoinSnapshot(
          maxRowId: 12,
          totalJoinCount: 4,
          maxMessageRowId: 100,
          maxChatRowId: 20,
          sourceScopedObservationAvailable: true,
        ),
        ledger: const ChatMessageJoinSnapshot(
          maxRowId: 10,
          totalJoinCount: 3,
          maxMessageRowId: 90,
          maxChatRowId: 18,
          sourceScopedObservationAvailable: true,
        ),
      );

      expect(delta.rowIdDelta, 2);
      expect(delta.joinCountDelta, 1);
      expect(delta.messageRowIdDelta, 10);
      expect(delta.chatRowIdDelta, 2);
      expect(delta.ledgerSourceScopedObservationAvailable, isTrue);
    });
  });

  group('ChatMessageJoinSyncStateIntegrator', () {
    test(
      'reports topology not yet imported when ledger is not source-scoped',
      () {
        final state = const ChatMessageJoinSyncStateIntegrator().integrate(
          const ChatMessageJoinSnapshotDelta(
            rowIdDelta: 10,
            joinCountDelta: 10,
            messageRowIdDelta: 100,
            chatRowIdDelta: 20,
            ledgerSourceScopedObservationAvailable: false,
          ),
        );

        expect(state, const ChatMessageJoinSyncState.topologyNotYetImported());
      },
    );

    test('reports source topology ahead from positive cursor delta', () {
      final state = const ChatMessageJoinSyncStateIntegrator().integrate(
        const ChatMessageJoinSnapshotDelta(
          rowIdDelta: 1,
          joinCountDelta: 1,
          messageRowIdDelta: 1,
          chatRowIdDelta: 0,
          ledgerSourceScopedObservationAvailable: true,
        ),
      );

      expect(
        state,
        const ChatMessageJoinSyncState.sourceTopologyAheadOfLedger(),
      );
    });

    test('reports ledger topology ahead from negative cursor delta', () {
      final state = const ChatMessageJoinSyncStateIntegrator().integrate(
        const ChatMessageJoinSnapshotDelta(
          rowIdDelta: -1,
          joinCountDelta: -1,
          messageRowIdDelta: -1,
          chatRowIdDelta: 0,
          ledgerSourceScopedObservationAvailable: true,
        ),
      );

      expect(
        state,
        const ChatMessageJoinSyncState.ledgerTopologyAheadOfSource(),
      );
    });

    test('reports topology match from zero cursor delta', () {
      final state = const ChatMessageJoinSyncStateIntegrator().integrate(
        const ChatMessageJoinSnapshotDelta(
          rowIdDelta: 0,
          joinCountDelta: 2,
          messageRowIdDelta: 0,
          chatRowIdDelta: 0,
          ledgerSourceScopedObservationAvailable: true,
        ),
      );

      expect(
        state,
        const ChatMessageJoinSyncState.sourceAndLedgerTopologyMatch(),
      );
    });
  });

  group('ChatMessageJoinImportDecisionIntegrator', () {
    test('does nothing when topology matches', () {
      final decision = const ChatMessageJoinImportDecisionIntegrator()
          .integrate(
            const ChatMessageJoinSyncState.sourceAndLedgerTopologyMatch(),
          );

      expect(decision, const ChatMessageJoinImportDecision.doNothing());
    });

    test('considers topology import when source topology is ahead', () {
      final decision = const ChatMessageJoinImportDecisionIntegrator()
          .integrate(
            const ChatMessageJoinSyncState.sourceTopologyAheadOfLedger(),
          );

      expect(
        decision,
        const ChatMessageJoinImportDecision.considerTopologyImport(),
      );
    });

    test('considers topology import when topology is not yet imported', () {
      final decision = const ChatMessageJoinImportDecisionIntegrator()
          .integrate(const ChatMessageJoinSyncState.topologyNotYetImported());

      expect(
        decision,
        const ChatMessageJoinImportDecision.considerTopologyImport(),
      );
    });

    test('blocks when ledger topology is ahead', () {
      final decision = const ChatMessageJoinImportDecisionIntegrator()
          .integrate(
            const ChatMessageJoinSyncState.ledgerTopologyAheadOfSource(),
          );

      expect(
        decision,
        const ChatMessageJoinImportDecision.blockAndReportLedgerAhead(),
      );
    });
  });
}
