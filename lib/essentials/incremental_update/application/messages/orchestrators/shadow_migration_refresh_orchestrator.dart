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

  Future<MigrationDecision> refreshOnce() async {
    _ref.invalidate(shadowImportProjectionSnapshotProvider);
    _ref.invalidate(shadowWorkingProjectionSnapshotProvider);

    final decision = await _ref.read(migrationDecisionProvider.future);
    if (decision != _lastObservedDecision) {
      final state = await _ref.read(messageMigrationStateProvider.future);
      final delta = await _ref.read(messageMigrationDeltaProvider.future);
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
    await executionOrchestrator.runForDecision(decision);

    return decision;
  }
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
