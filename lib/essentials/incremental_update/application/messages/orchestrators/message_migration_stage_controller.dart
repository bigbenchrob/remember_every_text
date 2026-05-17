import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/models/message_migration_delta.dart';
import '../../../domain/sealed_unions/message_migration_state.dart';
import '../../../domain/sealed_unions/migration_decision.dart';
import '../integrators/migration_decision_provider.dart';
import '../integrators/migration_delta_integrator_provider.dart';
import '../integrators/migration_state_integrator_provider.dart';
import '../models/message_migration_stage_report.dart';
import '../readers/shadow_import_projection_snapshot_provider.dart';
import '../readers/shadow_working_projection_snapshot_provider.dart';
import 'shadow_migration_execution_orchestrator_provider.dart';

class MessageMigrationStageController {
  MessageMigrationStageController(this._ref);

  final Ref _ref;
  MigrationDecision? _lastObservedDecision;
  DateTime? _lastMigrationDecisionTransitionTime;

  DateTime? get lastMigrationDecisionTransitionTime =>
      _lastMigrationDecisionTransitionTime;

  Future<MessageMigrationStageReport> refreshAndMaybeExecute() async {
    final startedAt = DateTime.now();
    final diagnosticEvents = <String>[];

    _ref.invalidate(shadowImportProjectionSnapshotProvider);
    _ref.invalidate(shadowWorkingProjectionSnapshotProvider);
    diagnosticEvents.add('migration reader refresh started');

    final decision = await _ref.read(migrationDecisionProvider.future);
    final preExecutionDelta = await _ref.read(
      messageMigrationDeltaProvider.future,
    );
    diagnosticEvents.add(
      'migration delta observed: '
      'messageIdDelta=${preExecutionDelta.messageIdDelta}, '
      'messageCountDelta=${preExecutionDelta.messageCountDelta}',
    );
    diagnosticEvents.add(
      'migration decision observed: ${formatMigrationDecision(decision)}',
    );

    final preExecutionState = await _ref.read(
      messageMigrationStateProvider.future,
    );
    _logTransitionIfNeeded(
      decision: decision,
      state: preExecutionState,
      delta: preExecutionDelta,
    );

    final executionOrchestrator = await _ref.read(
      shadowMigrationExecutionOrchestratorProvider.future,
    );
    final result = await executionOrchestrator.runForDecision(decision);

    if (result != null) {
      diagnosticEvents.add(
        'shadow migration executed: '
        'insertedMessageCount=${result.insertedMessageCount}',
      );
      _ref.invalidate(shadowImportProjectionSnapshotProvider);
      _ref.invalidate(shadowWorkingProjectionSnapshotProvider);

      final postExecutionDelta = await _ref.read(
        messageMigrationDeltaProvider.future,
      );
      final postExecutionState = await _ref.read(
        messageMigrationStateProvider.future,
      );

      return MessageMigrationStageReport(
        startedAt: startedAt,
        finishedAt: DateTime.now(),
        preExecutionDelta: preExecutionDelta,
        preExecutionState: preExecutionState,
        decision: decision,
        executionOutcome: MessageMigrationStageExecutionOutcome.executed,
        migrationResult: result,
        postExecutionDelta: postExecutionDelta,
        postExecutionState: postExecutionState,
        diagnosticEvents: diagnosticEvents,
      );
    }

    diagnosticEvents.add(
      'shadow migration skipped: ${migrationSkipReason(decision)}',
    );

    return MessageMigrationStageReport(
      startedAt: startedAt,
      finishedAt: DateTime.now(),
      preExecutionDelta: preExecutionDelta,
      preExecutionState: preExecutionState,
      decision: decision,
      executionOutcome: _skippedOutcomeForDecision(decision),
      diagnosticEvents: diagnosticEvents,
    );
  }

  void _logTransitionIfNeeded({
    required MigrationDecision decision,
    required MessageMigrationState state,
    required MessageMigrationDelta delta,
  }) {
    if (decision != _lastObservedDecision) {
      _lastMigrationDecisionTransitionTime = DateTime.now();
      debugPrint(
        'Shadow migration decision transition: \n'
        'Previous: ${_extractSemanticMigrationDecisionMeaning(_lastObservedDecision)}, '
        'Current: ${_extractSemanticMigrationDecisionMeaning(decision)}\n'
        'decision=$decision, '
        'state=$state, '
        'messageIdDelta=${delta.messageIdDelta}, '
        'messageCountDelta=${delta.messageCountDelta}',
      );
    }
    _lastObservedDecision = decision;
  }
}

MessageMigrationStageExecutionOutcome _skippedOutcomeForDecision(
  MigrationDecision decision,
) {
  return switch (decision) {
    MigrationDecisionDoNothing() =>
      MessageMigrationStageExecutionOutcome.skipped,
    MigrationDecisionBlockAndReportProjectionAhead() =>
      MessageMigrationStageExecutionOutcome.blocked,
    MigrationDecisionConsiderShadowMigration() =>
      MessageMigrationStageExecutionOutcome.skipped,
  };
}

String _extractSemanticMigrationDecisionMeaning(MigrationDecision? decision) {
  return switch (decision) {
    null => 'No previous migration decision observed.',
    MigrationDecisionDoNothing() => 'doNothing',
    MigrationDecisionConsiderShadowMigration() => 'considerShadowMigration',
    MigrationDecisionBlockAndReportProjectionAhead() =>
      'blockAndReportProjectionAhead',
  };
}
