import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../readers/legacy_incremental_update_snapshot_provider.dart';
import 'import_decision_integrator.dart';
import 'incremental_update_comparison_integrator.dart';
import 'migration_decision_integrator.dart';
import 'migration_delta_integrator_provider.dart';
import 'migration_state_integrator.dart';
import 'snapshot_delta_integrator_provider.dart';
import 'sync_assessment_integrator.dart';

part 'incremental_update_comparison_provider.g.dart';

@riverpod
Future<IncrementalUpdateComparisonReport> incrementalUpdateComparison(
  Ref ref,
) async {
  final legacySnapshot = await ref.watch(
    legacyIncrementalUpdateSnapshotProvider.future,
  );
  final shadowImportDelta = await ref.watch(
    snapshotDeltaIntegratorProvider.future,
  );
  final shadowSyncState = const MessageSyncAssessmentIntegrator().integrate(
    shadowImportDelta,
  );
  final shadowImportDecision = ImportDecisionIntegrator().integrate(
    shadowSyncState,
  );
  final shadowMigrationDelta = await ref.watch(
    messageMigrationDeltaProvider.future,
  );
  final shadowMigrationState = const MessageMigrationStateIntegrator()
      .integrate(shadowMigrationDelta);
  final shadowMigrationDecision = const MigrationDecisionIntegrator().integrate(
    shadowMigrationState,
  );

  return const IncrementalUpdateComparisonIntegrator().integrate(
    legacy: legacySnapshot,
    shadowImportDecision: shadowImportDecision,
    shadowImportDelta: shadowImportDelta,
    shadowMigrationDecision: shadowMigrationDecision,
    shadowMigrationDelta: shadowMigrationDelta,
  );
}
