import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/incremental_update/application/handles/importers/handle_importer.dart';
import 'package:remember_this_text/essentials/incremental_update/application/handles/orchestrators/handle_import_execution_orchestrator.dart';
import 'package:remember_this_text/essentials/incremental_update/application/handles/orchestrators/handle_import_execution_orchestrator_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/handles/orchestrators/handle_stage_controller_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/handles/orchestrators/handle_stage_report.dart';
import 'package:remember_this_text/essentials/incremental_update/application/handles/readers/import_ledger_handle_snapshot_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/handles/readers/live_chat_db_handle_snapshot_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/handle_snapshot.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/handle_snapshot_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/handle_import_decision.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/handle_sync_state.dart';

void main() {
  group('HandleStageController', () {
    test('reports do-nothing path without invoking execution', () async {
      var importerInvocationCount = 0;
      final container = _container(
        source: const HandleSnapshot(maxRowId: 20, totalHandleCount: 8),
        ledger: const HandleSnapshot(maxRowId: 20, totalHandleCount: 8),
        importNewHandles: () async {
          importerInvocationCount += 1;
          return const HandleImportResult(
            startedAfterSourceRowId: 20,
            lastImportedSourceRowId: 20,
            insertedHandleCount: 0,
            batchId: 1,
          );
        },
      );
      addTearDown(container.dispose);

      final report = await container
          .read(handleStageControllerProvider)
          .refreshAndMaybeExecute();

      expect(importerInvocationCount, 0);
      expect(
        report.preExecutionDelta,
        const HandleSnapshotDelta(rowIdDelta: 0, handleCountDelta: 0),
      );
      expect(
        report.preExecutionState,
        const HandleSyncState.sourceAndLedgerCursorsMatch(),
      );
      expect(report.decision, const HandleImportDecision.doNothing());
      expect(report.executionOutcome, HandleStageExecutionOutcome.skipped);
      expect(report.importResult, isNull);
      expect(report.postExecutionDelta, isNull);
      expect(report.postExecutionState, isNull);
      expect(report.diagnosticEvents, <String>[
        'handle observation boundary invalidated',
        'handle delta observed: rowIdDelta=0, handleCountDelta=0',
        'handle import decision observed: HandleImportDecision.doNothing',
        'shadow handle import skipped: decision doNothing',
      ]);
    });

    test('reports ledger-ahead path as blocked without execution', () async {
      var importerInvocationCount = 0;
      final container = _container(
        source: const HandleSnapshot(maxRowId: 20, totalHandleCount: 8),
        ledger: const HandleSnapshot(maxRowId: 22, totalHandleCount: 9),
        importNewHandles: () async {
          importerInvocationCount += 1;
          return const HandleImportResult(
            startedAfterSourceRowId: 22,
            lastImportedSourceRowId: 22,
            insertedHandleCount: 0,
            batchId: 1,
          );
        },
      );
      addTearDown(container.dispose);

      final report = await container
          .read(handleStageControllerProvider)
          .refreshAndMaybeExecute();

      expect(importerInvocationCount, 0);
      expect(
        report.preExecutionDelta,
        const HandleSnapshotDelta(rowIdDelta: -2, handleCountDelta: -1),
      );
      expect(
        report.preExecutionState,
        const HandleSyncState.ledgerAheadOfSource(),
      );
      expect(
        report.decision,
        const HandleImportDecision.blockAndReportLedgerAhead(),
      );
      expect(report.executionOutcome, HandleStageExecutionOutcome.blocked);
      expect(report.importResult, isNull);
      expect(report.diagnosticEvents, <String>[
        'handle observation boundary invalidated',
        'handle delta observed: rowIdDelta=-2, handleCountDelta=-1',
        'handle import decision observed: HandleImportDecision.blockAndReportLedgerAhead',
        'shadow handle import skipped: decision blockAndReportLedgerAhead',
      ]);
    });

    test('reports execution and post-execution convergence', () async {
      var ledger = const HandleSnapshot(maxRowId: 10, totalHandleCount: 5);
      var importerInvocationCount = 0;
      final container = _container(
        source: const HandleSnapshot(maxRowId: 12, totalHandleCount: 7),
        ledger: () => ledger,
        importNewHandles: () async {
          importerInvocationCount += 1;
          ledger = const HandleSnapshot(maxRowId: 12, totalHandleCount: 7);
          return const HandleImportResult(
            startedAfterSourceRowId: 10,
            lastImportedSourceRowId: 12,
            insertedHandleCount: 2,
            batchId: 1,
          );
        },
      );
      addTearDown(container.dispose);

      final report = await container
          .read(handleStageControllerProvider)
          .refreshAndMaybeExecute();

      expect(importerInvocationCount, 1);
      expect(
        report.preExecutionDelta,
        const HandleSnapshotDelta(rowIdDelta: 2, handleCountDelta: 2),
      );
      expect(
        report.preExecutionState,
        const HandleSyncState.sourceAheadOfLedger(),
      );
      expect(
        report.decision,
        const HandleImportDecision.considerIncrementalImport(),
      );
      expect(report.executionOutcome, HandleStageExecutionOutcome.executed);
      expect(report.importResult?.insertedHandleCount, 2);
      expect(report.importResult?.lastImportedSourceRowId, 12);
      expect(
        report.postExecutionDelta,
        const HandleSnapshotDelta(rowIdDelta: 0, handleCountDelta: 0),
      );
      expect(
        report.postExecutionState,
        const HandleSyncState.sourceAndLedgerCursorsMatch(),
      );
      expect(report.diagnosticEvents, <String>[
        'handle observation boundary invalidated',
        'handle delta observed: rowIdDelta=2, handleCountDelta=2',
        'handle import decision observed: HandleImportDecision.considerIncrementalImport',
        'shadow handle import executed: insertedHandleCount=2, lastImportedSourceRowId=12',
      ]);
    });
  });
}

ProviderContainer _container({
  required HandleSnapshot source,
  required Object ledger,
  required Future<HandleImportResult> Function() importNewHandles,
}) {
  HandleSnapshot readLedger() {
    final value = ledger;
    if (value is HandleSnapshot Function()) {
      return value();
    }
    return value as HandleSnapshot;
  }

  return ProviderContainer(
    overrides: <Override>[
      liveChatDbHandleSnapshotProvider.overrideWith((ref) async => source),
      importLedgerHandleSnapshotProvider.overrideWith(
        (ref) async => readLedger(),
      ),
      handleImportExecutionOrchestratorProvider.overrideWith(
        (ref) async => HandleImportExecutionOrchestrator.withImportCallback(
          importNewHandles: importNewHandles,
        ),
      ),
    ],
  );
}
