import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chats/integrators/chat_snapshot_delta_integrator.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/chat_snapshot.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/chat_snapshot_delta.dart';

void main() {
  const integrator = ChatSnapshotDeltaIntegrator();

  group('ChatSnapshotDeltaIntegrator', () {
    test('derives zero delta when source and ledger match', () {
      final delta = integrator.integrate(
        source: const ChatSnapshot(maxRowId: 10, totalChatCount: 4),
        ledger: const ChatSnapshot(maxRowId: 10, totalChatCount: 4),
      );

      expect(delta, const ChatSnapshotDelta(rowIdDelta: 0, chatCountDelta: 0));
    });

    test('derives positive delta when source is ahead', () {
      final delta = integrator.integrate(
        source: const ChatSnapshot(maxRowId: 15, totalChatCount: 7),
        ledger: const ChatSnapshot(maxRowId: 10, totalChatCount: 4),
      );

      expect(delta, const ChatSnapshotDelta(rowIdDelta: 5, chatCountDelta: 3));
      expect(delta.isLiveSourceRowAhead, isTrue);
    });

    test('derives negative delta when ledger is ahead', () {
      final delta = integrator.integrate(
        source: const ChatSnapshot(maxRowId: 10, totalChatCount: 4),
        ledger: const ChatSnapshot(maxRowId: 15, totalChatCount: 7),
      );

      expect(
        delta,
        const ChatSnapshotDelta(rowIdDelta: -5, chatCountDelta: -3),
      );
      expect(delta.isLedgerSourceRowAhead, isTrue);
    });
  });
}
