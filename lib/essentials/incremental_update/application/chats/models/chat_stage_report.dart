import 'package:flutter/foundation.dart';

import '../../../domain/models/chat_snapshot_delta.dart';
import '../../../domain/sealed_unions/chat_import_decision.dart';
import '../../../domain/sealed_unions/chat_sync_state.dart';
import '../importers/chat_importer.dart';

enum ChatStageExecutionOutcome { skipped, blocked, executed }

@immutable
final class ChatStageReport {
  ChatStageReport({
    required this.startedAt,
    required this.finishedAt,
    required this.preExecutionDelta,
    required this.preExecutionState,
    required this.decision,
    required this.executionOutcome,
    this.importResult,
    this.postExecutionDelta,
    this.postExecutionState,
    List<String> diagnosticEvents = const <String>[],
  }) : diagnosticEvents = List.unmodifiable(diagnosticEvents);

  final DateTime startedAt;
  final DateTime finishedAt;
  final ChatSnapshotDelta preExecutionDelta;
  final ChatSyncState preExecutionState;
  final ChatImportDecision decision;
  final ChatStageExecutionOutcome executionOutcome;
  final ChatImportResult? importResult;
  final ChatSnapshotDelta? postExecutionDelta;
  final ChatSyncState? postExecutionState;
  final List<String> diagnosticEvents;
}

String formatChatImportDecision(ChatImportDecision decision) {
  return switch (decision) {
    ChatImportDecisionDoNothing() => 'ChatImportDecision.doNothing',
    ChatImportDecisionConsiderIncrementalImport() =>
      'ChatImportDecision.considerIncrementalImport',
    ChatImportDecisionBlockAndReportLedgerAhead() =>
      'ChatImportDecision.blockAndReportLedgerAhead',
  };
}

String chatImportSkipReason(ChatImportDecision decision) {
  return switch (decision) {
    ChatImportDecisionDoNothing() => 'decision doNothing',
    ChatImportDecisionBlockAndReportLedgerAhead() =>
      'decision blockAndReportLedgerAhead',
    ChatImportDecisionConsiderIncrementalImport() =>
      'execution returned no result',
  };
}
