import 'package:flutter/foundation.dart';

import '../../../domain/models/message_migration_delta.dart';
import '../../../domain/sealed_unions/message_migration_state.dart';
import '../../../domain/sealed_unions/migration_decision.dart';
import '../executors/shadow_message_migration_executor.dart';

enum MessageMigrationStageExecutionOutcome { skipped, blocked, executed }

@immutable
final class MessageMigrationStageReport {
  MessageMigrationStageReport({
    required this.startedAt,
    required this.finishedAt,
    required this.preExecutionDelta,
    required this.preExecutionState,
    required this.decision,
    required this.executionOutcome,
    this.migrationResult,
    this.postExecutionDelta,
    this.postExecutionState,
    List<String> diagnosticEvents = const <String>[],
  }) : diagnosticEvents = List.unmodifiable(diagnosticEvents);

  final DateTime startedAt;
  final DateTime finishedAt;
  final MessageMigrationDelta preExecutionDelta;
  final MessageMigrationState preExecutionState;
  final MigrationDecision decision;
  final MessageMigrationStageExecutionOutcome executionOutcome;
  final ShadowMessageMigrationResult? migrationResult;
  final MessageMigrationDelta? postExecutionDelta;
  final MessageMigrationState? postExecutionState;
  final List<String> diagnosticEvents;
}

String formatMigrationDecision(MigrationDecision decision) {
  return switch (decision) {
    MigrationDecisionDoNothing() => 'MigrationDecision.doNothing',
    MigrationDecisionConsiderShadowMigration() =>
      'MigrationDecision.considerShadowMigration',
    MigrationDecisionBlockAndReportProjectionAhead() =>
      'MigrationDecision.blockAndReportProjectionAhead',
  };
}

String migrationSkipReason(MigrationDecision decision) {
  return switch (decision) {
    MigrationDecisionDoNothing() => 'decision doNothing',
    MigrationDecisionBlockAndReportProjectionAhead() =>
      'decision blockAndReportProjectionAhead',
    MigrationDecisionConsiderShadowMigration() =>
      'execution returned no result',
  };
}
