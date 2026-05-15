import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/incremental_update/application/handles/integrators/handle_import_decision_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/handles/integrators/handle_snapshot_delta_integrator_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/handles/integrators/handle_sync_state_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/handles/readers/import_ledger_handle_snapshot_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/handles/readers/live_chat_db_handle_snapshot_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/handle_snapshot.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/handle_snapshot_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/handle_import_decision.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/handle_sync_state.dart';

void main() {
  group('handle provider chain', () {
    test(
      'propagates source and ledger snapshots into decision meaning',
      () async {
        final container = ProviderContainer(
          overrides: <Override>[
            liveChatDbHandleSnapshotProvider.overrideWith(
              (ref) async =>
                  const HandleSnapshot(maxRowId: 105, totalHandleCount: 55),
            ),
            importLedgerHandleSnapshotProvider.overrideWith(
              (ref) async =>
                  const HandleSnapshot(maxRowId: 100, totalHandleCount: 50),
            ),
          ],
        );
        addTearDown(container.dispose);

        final delta = await container.read(
          handleSnapshotDeltaIntegratorProvider.future,
        );
        final state = await container.read(handleSyncStateProvider.future);
        final decision = await container.read(
          handleImportDecisionProvider.future,
        );

        expect(
          delta,
          const HandleSnapshotDelta(rowIdDelta: 5, handleCountDelta: 5),
        );
        expect(state, const HandleSyncState.sourceAheadOfLedger());
        expect(
          decision,
          const HandleImportDecision.considerIncrementalImport(),
        );
      },
    );

    test(
      'blocks execution eligibility for ledger-ahead observations',
      () async {
        final container = ProviderContainer(
          overrides: <Override>[
            liveChatDbHandleSnapshotProvider.overrideWith(
              (ref) async =>
                  const HandleSnapshot(maxRowId: 100, totalHandleCount: 50),
            ),
            importLedgerHandleSnapshotProvider.overrideWith(
              (ref) async =>
                  const HandleSnapshot(maxRowId: 105, totalHandleCount: 55),
            ),
          ],
        );
        addTearDown(container.dispose);

        final state = await container.read(handleSyncStateProvider.future);
        final decision = await container.read(
          handleImportDecisionProvider.future,
        );

        expect(state, const HandleSyncState.ledgerAheadOfSource());
        expect(
          decision,
          const HandleImportDecision.blockAndReportLedgerAhead(),
        );
      },
    );
  });
}
