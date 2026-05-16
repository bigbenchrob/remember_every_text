import 'package:flutter/foundation.dart';

import '../../../domain/models/handle_snapshot_delta.dart';
import '../../../domain/sealed_unions/handle_import_decision.dart';
import '../../../domain/sealed_unions/handle_sync_state.dart';
import '../importers/handle_importer.dart';

enum HandleStageExecutionOutcome { skipped, blocked, executed }

@immutable
final class HandleStageReport {
  HandleStageReport({
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
  final HandleSnapshotDelta preExecutionDelta;
  final HandleSyncState preExecutionState;
  final HandleImportDecision decision;
  final HandleStageExecutionOutcome executionOutcome;
  final HandleImportResult? importResult;
  final HandleSnapshotDelta? postExecutionDelta;
  final HandleSyncState? postExecutionState;
  final List<String> diagnosticEvents;
}

String formatHandleImportDecision(HandleImportDecision decision) {
  return switch (decision) {
    HandleImportDecisionDoNothing() => 'HandleImportDecision.doNothing',
    HandleImportDecisionConsiderIncrementalImport() =>
      'HandleImportDecision.considerIncrementalImport',
    HandleImportDecisionBlockAndReportLedgerAhead() =>
      'HandleImportDecision.blockAndReportLedgerAhead',
  };
}

String handleImportSkipReason(HandleImportDecision decision) {
  return switch (decision) {
    HandleImportDecisionDoNothing() => 'decision doNothing',
    HandleImportDecisionBlockAndReportLedgerAhead() =>
      'decision blockAndReportLedgerAhead',
    HandleImportDecisionConsiderIncrementalImport() =>
      'execution returned no result',
  };
}
