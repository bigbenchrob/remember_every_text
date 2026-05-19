import 'package:flutter/foundation.dart';

import '../../../domain/models/chat_message_join_snapshot.dart';
import '../../../domain/models/chat_message_join_snapshot_delta.dart';
import '../../../domain/sealed_unions/chat_message_join_import_decision.dart';
import '../../../domain/sealed_unions/chat_message_join_sync_state.dart';
import '../importers/chat_message_join_importer.dart';

enum ChatMessageJoinStageExecutionOutcome { skipped, blocked, executed }

@immutable
final class ChatMessageJoinStageReport {
  ChatMessageJoinStageReport({
    required this.startedAt,
    required this.finishedAt,
    required this.preExecutionSourceSnapshot,
    required this.preExecutionLedgerSnapshot,
    required this.preExecutionDelta,
    required this.preExecutionSyncState,
    required this.preExecutionDecision,
    required this.executionOutcome,
    this.importResult,
    this.postExecutionSourceSnapshot,
    this.postExecutionLedgerSnapshot,
    this.postExecutionDelta,
    this.postExecutionSyncState,
    List<String> diagnosticEvents = const <String>[],
  }) : diagnosticEvents = List.unmodifiable(diagnosticEvents);

  final DateTime startedAt;
  final DateTime finishedAt;
  final ChatMessageJoinSnapshot preExecutionSourceSnapshot;
  final ChatMessageJoinSnapshot preExecutionLedgerSnapshot;
  final ChatMessageJoinSnapshotDelta preExecutionDelta;
  final ChatMessageJoinSyncState preExecutionSyncState;
  final ChatMessageJoinImportDecision preExecutionDecision;
  final ChatMessageJoinStageExecutionOutcome executionOutcome;
  final ChatMessageJoinImportResult? importResult;
  final ChatMessageJoinSnapshot? postExecutionSourceSnapshot;
  final ChatMessageJoinSnapshot? postExecutionLedgerSnapshot;
  final ChatMessageJoinSnapshotDelta? postExecutionDelta;
  final ChatMessageJoinSyncState? postExecutionSyncState;
  final List<String> diagnosticEvents;

  Duration get duration => finishedAt.difference(startedAt);
}

String formatChatMessageJoinImportDecision(
  ChatMessageJoinImportDecision decision,
) {
  return switch (decision) {
    ChatMessageJoinImportDecisionDoNothing() =>
      'ChatMessageJoinImportDecision.doNothing',
    ChatMessageJoinImportDecisionConsiderTopologyImport() =>
      'ChatMessageJoinImportDecision.considerTopologyImport',
    ChatMessageJoinImportDecisionBlockAndReportLedgerAhead() =>
      'ChatMessageJoinImportDecision.blockAndReportLedgerAhead',
  };
}

String chatMessageJoinImportSkipReason(ChatMessageJoinImportDecision decision) {
  return switch (decision) {
    ChatMessageJoinImportDecisionDoNothing() => 'decision doNothing',
    ChatMessageJoinImportDecisionBlockAndReportLedgerAhead() =>
      'decision blockAndReportLedgerAhead',
    ChatMessageJoinImportDecisionConsiderTopologyImport() =>
      'execution returned no result',
  };
}
