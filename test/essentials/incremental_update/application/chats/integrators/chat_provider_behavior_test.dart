import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chats/integrators/chat_import_decision_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chats/integrators/chat_snapshot_delta_integrator_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chats/integrators/chat_sync_state_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chats/readers/import_ledger_chat_snapshot_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chats/readers/live_chat_db_chat_snapshot_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/chat_snapshot.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/chat_snapshot_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/chat_import_decision.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/chat_sync_state.dart';

void main() {
  group('chat provider chain', () {
    test(
      'propagates source and ledger snapshots into decision meaning',
      () async {
        final container = ProviderContainer(
          overrides: <Override>[
            liveChatDbChatSnapshotProvider.overrideWith(
              (ref) async =>
                  const ChatSnapshot(maxRowId: 105, totalChatCount: 55),
            ),
            importLedgerChatSnapshotProvider.overrideWith(
              (ref) async =>
                  const ChatSnapshot(maxRowId: 100, totalChatCount: 50),
            ),
          ],
        );
        addTearDown(container.dispose);

        final delta = await container.read(
          chatSnapshotDeltaIntegratorProvider.future,
        );
        final state = await container.read(chatSyncStateProvider.future);
        final decision = await container.read(
          chatImportDecisionProvider.future,
        );

        expect(
          delta,
          const ChatSnapshotDelta(rowIdDelta: 5, chatCountDelta: 5),
        );
        expect(state, const ChatSyncState.sourceAheadOfLedger());
        expect(decision, const ChatImportDecision.considerIncrementalImport());
      },
    );

    test(
      'blocks execution eligibility for ledger-ahead observations',
      () async {
        final container = ProviderContainer(
          overrides: <Override>[
            liveChatDbChatSnapshotProvider.overrideWith(
              (ref) async =>
                  const ChatSnapshot(maxRowId: 100, totalChatCount: 50),
            ),
            importLedgerChatSnapshotProvider.overrideWith(
              (ref) async =>
                  const ChatSnapshot(maxRowId: 105, totalChatCount: 55),
            ),
          ],
        );
        addTearDown(container.dispose);

        final state = await container.read(chatSyncStateProvider.future);
        final decision = await container.read(
          chatImportDecisionProvider.future,
        );

        expect(state, const ChatSyncState.ledgerAheadOfSource());
        expect(decision, const ChatImportDecision.blockAndReportLedgerAhead());
      },
    );
  });
}
