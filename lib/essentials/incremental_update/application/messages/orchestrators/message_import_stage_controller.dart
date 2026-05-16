import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/sealed_unions/import_decision.dart';
import '../integrators/import_decision_provider.dart';
import '../integrators/message_import_prerequisite_assessment_provider.dart';
import '../integrators/prerequisite_aware_message_import_decision_provider.dart';
import '../integrators/snapshot_delta_integrator_provider.dart';
import '../integrators/sync_assessment_integrator_provider.dart';
import '../models/message_import_stage_report.dart';
import '../readers/import_ledger_message_snapshot_provider.dart';
import '../readers/live_chat_db_message_snapshot_provider.dart';
import 'shadow_import_execution_orchestrator_provider.dart';

class MessageImportStageController {
  const MessageImportStageController(this._ref);

  final Ref _ref;

  Future<MessageImportStageReport> refreshAndMaybeExecute() async {
    final startedAt = DateTime.now();
    final diagnosticEvents = <String>[];

    _ref.invalidate(liveChatDbMessageSnapshotProvider);
    _ref.invalidate(importLedgerMessageSnapshotProvider);
    diagnosticEvents.add('reader refresh started');
    diagnosticEvents.add('import observation boundary invalidated');

    final preExecutionDelta = await _ref.read(
      snapshotDeltaIntegratorProvider.future,
    );
    diagnosticEvents.add(
      'import delta observed: '
      'rowIdDelta=${preExecutionDelta.rowIdDelta}, '
      'messageCountDelta=${preExecutionDelta.messageCountDelta}',
    );

    final preExecutionState = await _ref.read(messageSyncStateProvider.future);
    final decision = await _ref.read(importDecisionProvider.future);
    diagnosticEvents.add(
      'import decision observed: ${formatMessageImportDecision(decision)}',
    );

    final prerequisiteAssessment = await _ref.read(
      messageImportPrerequisiteAssessmentProvider.future,
    );
    diagnosticEvents.add(
      'prerequisite assessment observed: '
      '${prerequisiteAssessment.isSatisfied ? 'satisfied' : 'blocked'} '
      'blockers=${formatMessageImportBlockers(prerequisiteAssessment.blockers)}',
    );

    final prerequisiteAwareDecision = await _ref.read(
      prerequisiteAwareMessageImportDecisionProvider.future,
    );
    diagnosticEvents.add(
      'prerequisite-aware message import decision observed: '
      '${formatPrerequisiteAwareMessageImportDecision(prerequisiteAwareDecision)}',
    );

    final executionOrchestrator = await _ref.read(
      shadowImportExecutionOrchestratorProvider.future,
    );
    final result = await executionOrchestrator.runForDecision(decision);

    if (result != null) {
      diagnosticEvents.add(
        'shadow import executed: '
        'insertedMessageCount=${result.insertedMessageCount}, '
        'lastImportedSourceRowId=${result.lastImportedSourceRowId}',
      );
      _ref.invalidate(liveChatDbMessageSnapshotProvider);
      _ref.invalidate(importLedgerMessageSnapshotProvider);

      final postExecutionDelta = await _ref.read(
        snapshotDeltaIntegratorProvider.future,
      );
      final postExecutionState = await _ref.read(
        messageSyncStateProvider.future,
      );

      return MessageImportStageReport(
        startedAt: startedAt,
        finishedAt: DateTime.now(),
        preExecutionDelta: preExecutionDelta,
        preExecutionState: preExecutionState,
        decision: decision,
        prerequisiteAssessment: prerequisiteAssessment,
        prerequisiteAwareDecision: prerequisiteAwareDecision,
        executionOutcome: MessageImportStageExecutionOutcome.executed,
        importResult: result,
        postExecutionDelta: postExecutionDelta,
        postExecutionState: postExecutionState,
        diagnosticEvents: diagnosticEvents,
      );
    }

    diagnosticEvents.add(
      'shadow import skipped: ${messageImportSkipReason(decision)}',
    );

    return MessageImportStageReport(
      startedAt: startedAt,
      finishedAt: DateTime.now(),
      preExecutionDelta: preExecutionDelta,
      preExecutionState: preExecutionState,
      decision: decision,
      prerequisiteAssessment: prerequisiteAssessment,
      prerequisiteAwareDecision: prerequisiteAwareDecision,
      executionOutcome: _skippedOutcomeForDecision(decision),
      diagnosticEvents: diagnosticEvents,
    );
  }
}

MessageImportStageExecutionOutcome _skippedOutcomeForDecision(
  ImportDecision decision,
) {
  return switch (decision) {
    ImportDecisionDoNothing() => MessageImportStageExecutionOutcome.skipped,
    ImportDecisionBlockAndReportLedgerAhead() =>
      MessageImportStageExecutionOutcome.blocked,
    ImportDecisionConsiderIncrementalImport() =>
      MessageImportStageExecutionOutcome.skipped,
  };
}
