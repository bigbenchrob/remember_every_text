import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/sealed_unions/chat_message_join_import_decision.dart';
import '../integrators/chat_message_join_import_decision_provider.dart';
import '../integrators/chat_message_join_snapshot_delta_integrator_provider.dart';
import '../integrators/chat_message_join_sync_state_provider.dart';
import '../models/chat_message_join_stage_report.dart';
import '../readers/import_ledger_chat_message_join_snapshot_provider.dart';
import '../readers/live_chat_db_chat_message_join_snapshot_provider.dart';
import 'chat_message_join_import_execution_orchestrator_provider.dart';

class ChatMessageJoinStageController {
  const ChatMessageJoinStageController(this._ref);

  final Ref _ref;

  Future<ChatMessageJoinStageReport> refreshAndMaybeExecute() async {
    final startedAt = DateTime.now();
    final diagnosticEvents = <String>[];

    _ref.invalidate(liveChatDbChatMessageJoinSnapshotProvider);
    _ref.invalidate(importLedgerChatMessageJoinSnapshotProvider);
    diagnosticEvents.add('topology observation boundary invalidated');

    final preExecutionSourceSnapshot = await _ref.read(
      liveChatDbChatMessageJoinSnapshotProvider.future,
    );
    final preExecutionLedgerSnapshot = await _ref.read(
      importLedgerChatMessageJoinSnapshotProvider.future,
    );
    final preExecutionDelta = await _ref.read(
      chatMessageJoinSnapshotDeltaIntegratorProvider.future,
    );
    diagnosticEvents.add(
      'topology delta observed: '
      'rowIdDelta=${preExecutionDelta.rowIdDelta}, '
      'joinCountDelta=${preExecutionDelta.joinCountDelta}, '
      'messageRowIdDelta=${preExecutionDelta.messageRowIdDelta}, '
      'chatRowIdDelta=${preExecutionDelta.chatRowIdDelta}',
    );

    final preExecutionSyncState = await _ref.read(
      chatMessageJoinSyncStateProvider.future,
    );
    final preExecutionDecision = await _ref.read(
      chatMessageJoinImportDecisionProvider.future,
    );
    diagnosticEvents.add(
      'topology import decision observed: '
      '${formatChatMessageJoinImportDecision(preExecutionDecision)}',
    );

    final executionOrchestrator = await _ref.read(
      chatMessageJoinImportExecutionOrchestratorProvider.future,
    );
    final result = await executionOrchestrator.runForDecision(
      preExecutionDecision,
    );

    if (result != null) {
      diagnosticEvents.add(
        'shadow topology import executed: '
        'insertedJoinCount=${result.insertedJoinCount}, '
        'lastImportedSourceRowId=${result.lastImportedSourceRowId}',
      );
      _ref.invalidate(liveChatDbChatMessageJoinSnapshotProvider);
      _ref.invalidate(importLedgerChatMessageJoinSnapshotProvider);

      final postExecutionSourceSnapshot = await _ref.read(
        liveChatDbChatMessageJoinSnapshotProvider.future,
      );
      final postExecutionLedgerSnapshot = await _ref.read(
        importLedgerChatMessageJoinSnapshotProvider.future,
      );
      final postExecutionDelta = await _ref.read(
        chatMessageJoinSnapshotDeltaIntegratorProvider.future,
      );
      final postExecutionSyncState = await _ref.read(
        chatMessageJoinSyncStateProvider.future,
      );

      return ChatMessageJoinStageReport(
        startedAt: startedAt,
        finishedAt: DateTime.now(),
        preExecutionSourceSnapshot: preExecutionSourceSnapshot,
        preExecutionLedgerSnapshot: preExecutionLedgerSnapshot,
        preExecutionDelta: preExecutionDelta,
        preExecutionSyncState: preExecutionSyncState,
        preExecutionDecision: preExecutionDecision,
        executionOutcome: ChatMessageJoinStageExecutionOutcome.executed,
        importResult: result,
        postExecutionSourceSnapshot: postExecutionSourceSnapshot,
        postExecutionLedgerSnapshot: postExecutionLedgerSnapshot,
        postExecutionDelta: postExecutionDelta,
        postExecutionSyncState: postExecutionSyncState,
        diagnosticEvents: diagnosticEvents,
      );
    }

    diagnosticEvents.add(
      'shadow topology import skipped: '
      '${chatMessageJoinImportSkipReason(preExecutionDecision)}',
    );

    return ChatMessageJoinStageReport(
      startedAt: startedAt,
      finishedAt: DateTime.now(),
      preExecutionSourceSnapshot: preExecutionSourceSnapshot,
      preExecutionLedgerSnapshot: preExecutionLedgerSnapshot,
      preExecutionDelta: preExecutionDelta,
      preExecutionSyncState: preExecutionSyncState,
      preExecutionDecision: preExecutionDecision,
      executionOutcome: _skippedOutcomeForDecision(preExecutionDecision),
      diagnosticEvents: diagnosticEvents,
    );
  }
}

ChatMessageJoinStageExecutionOutcome _skippedOutcomeForDecision(
  ChatMessageJoinImportDecision decision,
) {
  return switch (decision) {
    ChatMessageJoinImportDecisionDoNothing() =>
      ChatMessageJoinStageExecutionOutcome.skipped,
    ChatMessageJoinImportDecisionBlockAndReportLedgerAhead() =>
      ChatMessageJoinStageExecutionOutcome.blocked,
    ChatMessageJoinImportDecisionConsiderTopologyImport() =>
      ChatMessageJoinStageExecutionOutcome.skipped,
  };
}
