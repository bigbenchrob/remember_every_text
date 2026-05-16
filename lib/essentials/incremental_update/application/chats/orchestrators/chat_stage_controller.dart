import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/sealed_unions/chat_import_decision.dart';
import '../integrators/chat_import_decision_provider.dart';
import '../integrators/chat_snapshot_delta_integrator_provider.dart';
import '../integrators/chat_sync_state_provider.dart';
import '../models/chat_stage_report.dart';
import '../readers/import_ledger_chat_snapshot_provider.dart';
import '../readers/live_chat_db_chat_snapshot_provider.dart';
import 'chat_import_execution_orchestrator_provider.dart';

class ChatStageController {
  const ChatStageController(this._ref);

  final Ref _ref;

  Future<ChatStageReport> refreshAndMaybeExecute() async {
    final startedAt = DateTime.now();
    final diagnosticEvents = <String>[];

    _ref.invalidate(liveChatDbChatSnapshotProvider);
    _ref.invalidate(importLedgerChatSnapshotProvider);
    diagnosticEvents.add('chat observation boundary invalidated');

    final preExecutionDelta = await _ref.read(
      chatSnapshotDeltaIntegratorProvider.future,
    );
    diagnosticEvents.add(
      'chat delta observed: '
      'rowIdDelta=${preExecutionDelta.rowIdDelta}, '
      'chatCountDelta=${preExecutionDelta.chatCountDelta}',
    );

    final preExecutionState = await _ref.read(chatSyncStateProvider.future);
    final decision = await _ref.read(chatImportDecisionProvider.future);
    diagnosticEvents.add(
      'chat import decision observed: ${formatChatImportDecision(decision)}',
    );

    final executionOrchestrator = await _ref.read(
      chatImportExecutionOrchestratorProvider.future,
    );
    final result = await executionOrchestrator.runForDecision(decision);

    if (result != null) {
      diagnosticEvents.add(
        'shadow chat import executed: '
        'insertedChatCount=${result.insertedChatCount}, '
        'lastImportedSourceRowId=${result.lastImportedSourceRowId}',
      );
      _ref.invalidate(liveChatDbChatSnapshotProvider);
      _ref.invalidate(importLedgerChatSnapshotProvider);

      final postExecutionDelta = await _ref.read(
        chatSnapshotDeltaIntegratorProvider.future,
      );
      final postExecutionState = await _ref.read(chatSyncStateProvider.future);

      return ChatStageReport(
        startedAt: startedAt,
        finishedAt: DateTime.now(),
        preExecutionDelta: preExecutionDelta,
        preExecutionState: preExecutionState,
        decision: decision,
        executionOutcome: ChatStageExecutionOutcome.executed,
        importResult: result,
        postExecutionDelta: postExecutionDelta,
        postExecutionState: postExecutionState,
        diagnosticEvents: diagnosticEvents,
      );
    }

    diagnosticEvents.add(
      'shadow chat import skipped: ${chatImportSkipReason(decision)}',
    );

    return ChatStageReport(
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

ChatStageExecutionOutcome _skippedOutcomeForDecision(
  ChatImportDecision decision,
) {
  return switch (decision) {
    ChatImportDecisionDoNothing() => ChatStageExecutionOutcome.skipped,
    ChatImportDecisionBlockAndReportLedgerAhead() =>
      ChatStageExecutionOutcome.blocked,
    ChatImportDecisionConsiderIncrementalImport() =>
      ChatStageExecutionOutcome.skipped,
  };
}
