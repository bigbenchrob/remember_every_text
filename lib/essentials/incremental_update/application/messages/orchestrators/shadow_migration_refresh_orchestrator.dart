import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/sealed_unions/migration_decision.dart';
import '../integrators/migration_decision_provider.dart';
import '../integrators/migration_delta_integrator_provider.dart';
import '../integrators/migration_state_integrator_provider.dart';
import '../readers/shadow_import_projection_snapshot_provider.dart';
import '../readers/shadow_working_projection_snapshot_provider.dart';
import 'shadow_migration_execution_orchestrator_provider.dart';

class ShadowMigrationRefreshOrchestrator {
  ShadowMigrationRefreshOrchestrator(this._ref);

  final Ref _ref;
  MigrationDecision? _lastObservedDecision;
  DateTime? _lastMigrationDecisionTransitionTime;

  DateTime? get lastMigrationDecisionTransitionTime =>
      _lastMigrationDecisionTransitionTime;

  Future<MigrationDecision> refreshOnce({List<String>? tickEvents}) async {
    _ref.invalidate(shadowImportProjectionSnapshotProvider);
    _ref.invalidate(shadowWorkingProjectionSnapshotProvider);
    tickEvents?.add('migration reader refresh started');

    final decision = await _ref.read(migrationDecisionProvider.future);
    final delta = await _ref.read(messageMigrationDeltaProvider.future);
    tickEvents?.add(
      'migration delta observed: '
      'messageIdDelta=${delta.messageIdDelta}, '
      'messageCountDelta=${delta.messageCountDelta}',
    );
    tickEvents?.add(
      'migration decision observed: ${_formatMigrationDecision(decision)}',
    );
    if (decision != _lastObservedDecision) {
      _lastMigrationDecisionTransitionTime = DateTime.now();
      final state = await _ref.read(messageMigrationStateProvider.future);
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

    final executionOrchestrator = await _ref.read(
      shadowMigrationExecutionOrchestratorProvider.future,
    );
    final result = await executionOrchestrator.runForDecision(decision);
    if (result != null) {
      tickEvents?.add(
        'shadow migration executed: '
        'insertedMessageCount=${result.insertedMessageCount}',
      );
      _ref.invalidate(shadowImportProjectionSnapshotProvider);
      _ref.invalidate(shadowWorkingProjectionSnapshotProvider);
      return _ref.read(migrationDecisionProvider.future);
    }

    tickEvents?.add(
      'shadow migration skipped: ${_migrationSkipReason(decision)}',
    );
    return decision;
  }
}

String _formatMigrationDecision(MigrationDecision decision) {
  return switch (decision) {
    MigrationDecisionDoNothing() => 'MigrationDecision.doNothing',
    MigrationDecisionConsiderShadowMigration() =>
      'MigrationDecision.considerShadowMigration',
    MigrationDecisionBlockAndReportProjectionAhead() =>
      'MigrationDecision.blockAndReportProjectionAhead',
  };
}

String _migrationSkipReason(MigrationDecision decision) {
  return switch (decision) {
    MigrationDecisionDoNothing() => 'decision doNothing',
    MigrationDecisionBlockAndReportProjectionAhead() =>
      'decision blockAndReportProjectionAhead',
    MigrationDecisionConsiderShadowMigration() =>
      'execution returned no result',
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
