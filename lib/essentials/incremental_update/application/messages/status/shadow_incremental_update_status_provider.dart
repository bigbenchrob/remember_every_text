import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/message_migration_delta.dart';
import '../../../domain/models/snapshot_delta.dart';
import '../../../domain/sealed_unions/comparison_outcome.dart';
import '../../../domain/sealed_unions/import_decision.dart';
import '../../../domain/sealed_unions/message_migration_state.dart';
import '../../../domain/sealed_unions/migration_decision.dart';
import '../../../domain/sealed_unions/sync_state.dart';
import '../integrators/import_decision_integrator.dart';
import '../integrators/incremental_update_comparison_provider.dart';
import '../integrators/migration_decision_integrator.dart';
import '../integrators/migration_delta_integrator_provider.dart';
import '../integrators/migration_state_integrator.dart';
import '../integrators/snapshot_delta_integrator_provider.dart';
import '../integrators/sync_assessment_integrator.dart';
import '../orchestrators/comparative_validation_orchestrator_provider.dart';
import '../orchestrators/shadow_migration_refresh_orchestrator_provider.dart';
import '../orchestrators/sync_state_polling_orchestrator_provider.dart';

part 'shadow_incremental_update_status_provider.g.dart';

class ShadowIncrementalUpdateStatus {
  const ShadowIncrementalUpdateStatus({
    required this.pollingActive,
    required this.lastRefreshTime,
    required this.lastTransitionTime,
    required this.importDecision,
    required this.messageSyncState,
    required this.snapshotDelta,
    required this.migrationDecision,
    required this.messageMigrationState,
    required this.migrationDelta,
    required this.importComparisonOutcome,
    required this.migrationComparisonOutcome,
  });

  final bool pollingActive;
  final DateTime? lastRefreshTime;
  final DateTime? lastTransitionTime;
  final ImportDecision importDecision;
  final MessageSyncState messageSyncState;
  final MessageSnapshotDelta snapshotDelta;
  final MigrationDecision migrationDecision;
  final MessageMigrationState messageMigrationState;
  final MessageMigrationDelta migrationDelta;
  final ComparisonOutcome importComparisonOutcome;
  final ComparisonOutcome migrationComparisonOutcome;
}

@riverpod
Future<ShadowIncrementalUpdateStatus> shadowIncrementalUpdateStatus(
  Ref ref,
) async {
  final pollingOrchestrator = ref.watch(deltaRefreshOrchestratorProvider);
  final migrationOrchestrator = ref.watch(
    shadowMigrationRefreshOrchestratorProvider,
  );
  final comparisonOrchestrator = ref.watch(
    comparativeValidationOrchestratorProvider,
  );

  final snapshotDelta = await ref.watch(snapshotDeltaIntegratorProvider.future);
  final syncState = const MessageSyncAssessmentIntegrator().integrate(
    snapshotDelta,
  );
  final importDecision = ImportDecisionIntegrator().integrate(syncState);
  final migrationDelta = await ref.watch(messageMigrationDeltaProvider.future);
  final migrationState = const MessageMigrationStateIntegrator().integrate(
    migrationDelta,
  );
  final migrationDecision = const MigrationDecisionIntegrator().integrate(
    migrationState,
  );
  final comparisonReport = await ref.watch(
    incrementalUpdateComparisonProvider.future,
  );

  return ShadowIncrementalUpdateStatus(
    pollingActive: pollingOrchestrator.isPollingActive,
    lastRefreshTime: pollingOrchestrator.lastRefreshTime,
    lastTransitionTime: _latestDateTime([
      pollingOrchestrator.lastImportDecisionTransitionTime,
      migrationOrchestrator.lastMigrationDecisionTransitionTime,
      comparisonOrchestrator.lastComparisonTransitionTime,
    ]),
    importDecision: importDecision,
    messageSyncState: syncState,
    snapshotDelta: snapshotDelta,
    migrationDecision: migrationDecision,
    messageMigrationState: migrationState,
    migrationDelta: migrationDelta,
    importComparisonOutcome: comparisonReport.importComparison,
    migrationComparisonOutcome: comparisonReport.migrationComparison,
  );
}

DateTime? _latestDateTime(List<DateTime?> values) {
  DateTime? latest;
  for (final value in values) {
    if (value == null) {
      continue;
    }
    if (latest == null || value.isAfter(latest)) {
      latest = value;
    }
  }
  return latest;
}
