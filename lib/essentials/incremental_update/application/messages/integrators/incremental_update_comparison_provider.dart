import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../readers/legacy_incremental_update_snapshot_provider.dart';
import 'import_decision_provider.dart';
import 'incremental_update_comparison_integrator.dart';
import 'migration_decision_provider.dart';
import 'migration_delta_integrator_provider.dart';

part 'incremental_update_comparison_provider.g.dart';

@riverpod
Future<IncrementalUpdateComparisonReport> incrementalUpdateComparison(
  Ref ref,
) async {
  final legacySnapshot = await ref.watch(
    legacyIncrementalUpdateSnapshotProvider.future,
  );
  final shadowImportDecision = await ref.watch(importDecisionProvider.future);
  final shadowMigrationDecision = await ref.watch(
    migrationDecisionProvider.future,
  );
  final shadowMigrationDelta = await ref.watch(
    messageMigrationDeltaProvider.future,
  );

  return const IncrementalUpdateComparisonIntegrator().integrate(
    legacy: legacySnapshot,
    shadowImportDecision: shadowImportDecision,
    shadowMigrationDecision: shadowMigrationDecision,
    shadowMigrationDelta: shadowMigrationDelta,
  );
}
