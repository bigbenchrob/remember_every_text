import 'package:flutter/foundation.dart';

import '../../../domain/models/message_import_blocker.dart';
import '../../../domain/models/message_import_prerequisite_assessment.dart';
import '../../../domain/models/snapshot_delta.dart';
import '../../../domain/sealed_unions/import_decision.dart';
import '../../../domain/sealed_unions/prerequisite_aware_message_import_decision.dart';
import '../../../domain/sealed_unions/sync_state.dart';
import '../executors/message_importer.dart';

enum MessageImportStageExecutionOutcome { skipped, blocked, executed }

@immutable
final class MessageImportStageReport {
  MessageImportStageReport({
    required this.startedAt,
    required this.finishedAt,
    required this.preExecutionDelta,
    required this.preExecutionState,
    required this.decision,
    required this.prerequisiteAssessment,
    required this.prerequisiteAwareDecision,
    required this.executionOutcome,
    this.importResult,
    this.postExecutionDelta,
    this.postExecutionState,
    List<String> diagnosticEvents = const <String>[],
  }) : diagnosticEvents = List.unmodifiable(diagnosticEvents);

  final DateTime startedAt;
  final DateTime finishedAt;
  final MessageSnapshotDelta preExecutionDelta;
  final MessageSyncState preExecutionState;
  final ImportDecision decision;
  final MessageImportPrerequisiteAssessment prerequisiteAssessment;
  final PrerequisiteAwareMessageImportDecision prerequisiteAwareDecision;
  final MessageImportStageExecutionOutcome executionOutcome;
  final MessageImportResult? importResult;
  final MessageSnapshotDelta? postExecutionDelta;
  final MessageSyncState? postExecutionState;
  final List<String> diagnosticEvents;
}

String formatMessageImportDecision(ImportDecision decision) {
  return switch (decision) {
    ImportDecisionDoNothing() => 'ImportDecision.doNothing',
    ImportDecisionConsiderIncrementalImport() =>
      'ImportDecision.considerIncrementalImport',
    ImportDecisionBlockAndReportLedgerAhead() =>
      'ImportDecision.blockAndReportLedgerAhead',
  };
}

String messageImportSkipReason(ImportDecision decision) {
  return switch (decision) {
    ImportDecisionDoNothing() => 'decision doNothing',
    ImportDecisionBlockAndReportLedgerAhead() =>
      'decision blockAndReportLedgerAhead',
    ImportDecisionConsiderIncrementalImport() => 'execution returned no result',
  };
}

String formatPrerequisiteAwareMessageImportDecision(
  PrerequisiteAwareMessageImportDecision decision,
) {
  return switch (decision) {
    PrerequisiteAwareMessageImportDecisionDoNothing() =>
      'PrerequisiteAwareMessageImportDecision.doNothing',
    PrerequisiteAwareMessageImportDecisionConsiderIncrementalImport() =>
      'PrerequisiteAwareMessageImportDecision.considerIncrementalImport',
    PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisites(
      :final blockers,
    ) =>
      'PrerequisiteAwareMessageImportDecision.blockedPendingPrerequisites(${formatMessageImportBlockers(blockers)})',
    PrerequisiteAwareMessageImportDecisionBlockAndReportLedgerAhead() =>
      'PrerequisiteAwareMessageImportDecision.blockAndReportLedgerAhead',
  };
}

String formatMessageImportBlockers(List<MessageImportBlocker> blockers) {
  if (blockers.isEmpty) {
    return '[]';
  }

  return '[${blockers.map((blocker) => blocker.name).join(', ')}]';
}
