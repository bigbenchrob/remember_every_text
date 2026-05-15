import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/executors/message_importer.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/integrators/import_decision_integrator.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/integrators/sync_assessment_integrator.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/orchestrators/shadow_import_execution_orchestrator.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/snapshot_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/import_decision.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/sync_state.dart';

void main() {
  group('ShadowImportExecutionOrchestrator', () {
    test('does not invoke importer for do-nothing decision', () async {
      final fakeImporter = _FakeMessageImporter();
      final orchestrator = ShadowImportExecutionOrchestrator.withImportCallback(
        importNewMessages: fakeImporter.importNewMessages,
      );

      final result = await orchestrator.runForDecision(
        const ImportDecision.doNothing(),
      );

      expect(result, isNull);
      expect(fakeImporter.invocationCount, 0);
    });

    test(
      'does not invoke importer for ledger-ahead blocked decision',
      () async {
        final fakeImporter = _FakeMessageImporter();
        final orchestrator =
            ShadowImportExecutionOrchestrator.withImportCallback(
              importNewMessages: fakeImporter.importNewMessages,
            );

        final result = await orchestrator.runForDecision(
          const ImportDecision.blockAndReportLedgerAhead(),
        );

        expect(result, isNull);
        expect(fakeImporter.invocationCount, 0);
      },
    );

    test(
      'invokes importer exactly once for incremental import decision',
      () async {
        final fakeImporter = _FakeMessageImporter();
        final orchestrator =
            ShadowImportExecutionOrchestrator.withImportCallback(
              importNewMessages: fakeImporter.importNewMessages,
            );

        final result = await orchestrator.runForDecision(
          const ImportDecision.considerIncrementalImport(),
        );

        expect(result, isNotNull);
        expect(fakeImporter.invocationCount, 1);
      },
    );

    test('blocks execution for explicit ledger-ahead scenario', () async {
      const liveMaxRowId = 100;
      const ledgerMaxSourceRowId = 105;
      const rowIdDelta = liveMaxRowId - ledgerMaxSourceRowId;

      final syncState = const MessageSyncAssessmentIntegrator().integrate(
        const MessageSnapshotDelta(
          rowIdDelta: rowIdDelta,
          messageCountDelta: -5,
        ),
      );
      final decision = ImportDecisionIntegrator().integrate(syncState);

      final fakeImporter = _FakeMessageImporter();
      final orchestrator = ShadowImportExecutionOrchestrator.withImportCallback(
        importNewMessages: fakeImporter.importNewMessages,
      );

      final result = await orchestrator.runForDecision(decision);

      expect(rowIdDelta, -5);
      expect(syncState, const MessageSyncState.ledgerAheadOfSource());
      expect(decision, const ImportDecision.blockAndReportLedgerAhead());
      expect(result, isNull);
      expect(fakeImporter.invocationCount, 0);
    });
  });
}

class _FakeMessageImporter {
  int invocationCount = 0;

  Future<MessageImportResult> importNewMessages() async {
    invocationCount += 1;
    return const MessageImportResult(
      startedAfterSourceRowId: 100,
      lastImportedSourceRowId: 105,
      insertedMessageCount: 5,
      batchId: 1,
    );
  }
}
