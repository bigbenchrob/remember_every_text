import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/sealed_unions/handle_import_decision.dart';
import '../integrators/handle_import_decision_provider.dart';
import '../integrators/handle_snapshot_delta_integrator_provider.dart';
import '../integrators/handle_sync_state_provider.dart';
import '../models/handle_stage_report.dart';
import '../readers/import_ledger_handle_snapshot_provider.dart';
import '../readers/live_chat_db_handle_snapshot_provider.dart';
import 'handle_import_execution_orchestrator_provider.dart';

class HandleStageController {
  const HandleStageController(this._ref);

  final Ref _ref;

  Future<HandleStageReport> refreshAndMaybeExecute() async {
    final startedAt = DateTime.now();
    final diagnosticEvents = <String>[];

    _ref.invalidate(liveChatDbHandleSnapshotProvider);
    _ref.invalidate(importLedgerHandleSnapshotProvider);
    diagnosticEvents.add('handle observation boundary invalidated');

    final preExecutionDelta = await _ref.read(
      handleSnapshotDeltaIntegratorProvider.future,
    );
    diagnosticEvents.add(
      'handle delta observed: '
      'rowIdDelta=${preExecutionDelta.rowIdDelta}, '
      'handleCountDelta=${preExecutionDelta.handleCountDelta}',
    );

    final preExecutionState = await _ref.read(handleSyncStateProvider.future);
    final decision = await _ref.read(handleImportDecisionProvider.future);
    diagnosticEvents.add(
      'handle import decision observed: '
      '${formatHandleImportDecision(decision)}',
    );

    final executionOrchestrator = await _ref.read(
      handleImportExecutionOrchestratorProvider.future,
    );
    final result = await executionOrchestrator.runForDecision(decision);

    if (result != null) {
      diagnosticEvents.add(
        'shadow handle import executed: '
        'insertedHandleCount=${result.insertedHandleCount}, '
        'lastImportedSourceRowId=${result.lastImportedSourceRowId}',
      );
      _ref.invalidate(liveChatDbHandleSnapshotProvider);
      _ref.invalidate(importLedgerHandleSnapshotProvider);

      final postExecutionDelta = await _ref.read(
        handleSnapshotDeltaIntegratorProvider.future,
      );
      final postExecutionState = await _ref.read(
        handleSyncStateProvider.future,
      );

      return HandleStageReport(
        startedAt: startedAt,
        finishedAt: DateTime.now(),
        preExecutionDelta: preExecutionDelta,
        preExecutionState: preExecutionState,
        decision: decision,
        executionOutcome: HandleStageExecutionOutcome.executed,
        importResult: result,
        postExecutionDelta: postExecutionDelta,
        postExecutionState: postExecutionState,
        diagnosticEvents: diagnosticEvents,
      );
    }

    diagnosticEvents.add(
      'shadow handle import skipped: ${handleImportSkipReason(decision)}',
    );

    return HandleStageReport(
      startedAt: startedAt,
      finishedAt: DateTime.now(),
      preExecutionDelta: preExecutionDelta,
      preExecutionState: preExecutionState,
      decision: decision,
      executionOutcome: _skippedOutcomeForDecision(decision),
      diagnosticEvents: diagnosticEvents,
    );
  }
}

HandleStageExecutionOutcome _skippedOutcomeForDecision(
  HandleImportDecision decision,
) {
  return switch (decision) {
    HandleImportDecisionDoNothing() => HandleStageExecutionOutcome.skipped,
    HandleImportDecisionBlockAndReportLedgerAhead() =>
      HandleStageExecutionOutcome.blocked,
    HandleImportDecisionConsiderIncrementalImport() =>
      HandleStageExecutionOutcome.skipped,
  };
}
