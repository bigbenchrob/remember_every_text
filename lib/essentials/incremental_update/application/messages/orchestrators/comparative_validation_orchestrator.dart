import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/sealed_unions/comparison_outcome.dart';
import '../integrators/incremental_update_comparison_integrator.dart';
import '../integrators/incremental_update_comparison_provider.dart';
import '../readers/legacy_incremental_update_snapshot_provider.dart';

/// Runs read-only comparative validation between the legacy production
/// incremental-update system and the shadow incremental-update architecture.
///
/// This orchestrator exists because the comparison is an imperative observation
/// event: on each shadow polling cycle, we want to sample production facts and
/// shadow conclusions at the same point in time, then print an explainable
/// match/mismatch/phase-skew report. It must not influence either system's
/// execution. Production still owns production import/migration; shadow still
/// owns only shadow import/migration.
class ComparativeValidationOrchestrator {
  ComparativeValidationOrchestrator(this._ref);

  final Ref _ref;
  DateTime? get lastComparisonTransitionTime => _lastComparisonTransitionTime;
  ComparisonOutcome? _lastImportComparison;
  ComparisonOutcome? _lastMigrationComparison;
  DateTime? _lastComparisonTransitionTime;

  Future<IncrementalUpdateComparisonReport> refreshOnce() async {
    // Production state is external reality for this comparison. Invalidate the
    // reader snapshot so each comparison samples current production facts.
    _ref.invalidate(legacyIncrementalUpdateSnapshotProvider);

    // The comparison provider composes:
    // legacy production facts + shadow semantic/policy state → comparison
    // outcome. The orchestrator only triggers and reports that result.
    final report = await _ref.read(incrementalUpdateComparisonProvider.future);
    if (report.importComparison != _lastImportComparison ||
        report.migrationComparison != _lastMigrationComparison) {
      _lastComparisonTransitionTime = DateTime.now();
    }
    _lastImportComparison = report.importComparison;
    _lastMigrationComparison = report.migrationComparison;

    // Keep import and migration comparisons separate so a mismatch in one phase
    // does not hide an agreement, phase skew, or unknown state in the other.
    debugPrint(
      _formatComparison('incremental import', report.importComparison),
    );
    debugPrint(
      _formatComparison('migration projection', report.migrationComparison),
    );

    return report;
  }

  String _formatComparison(String scope, ComparisonOutcome outcome) {
    // The sealed union keeps the logging vocabulary explicit. In particular,
    // PHASE SKEW is intentionally distinct from MISMATCH: it means the systems
    // appear to be sampled at different valid points in their async pipelines,
    // not that their architecture-level conclusions fundamentally disagree.
    return switch (outcome) {
      ComparisonOutcomeMatch(:final legacy, :final shadow) =>
        '[comparison][$scope]\n'
            'MATCH:\n'
            '  legacy=$legacy\n'
            '  shadow=$shadow',
      ComparisonOutcomeMismatch(:final legacy, :final shadow, :final reason) =>
        '[comparison][$scope]\n'
            'MISMATCH:\n'
            '  legacy=$legacy\n'
            '  shadow=$shadow\n'
            '  reason=$reason',
      ComparisonOutcomePhaseSkew(:final legacy, :final shadow, :final reason) =>
        '[comparison][$scope]\n'
            'PHASE SKEW:\n'
            '  legacy=$legacy\n'
            '  shadow=$shadow\n'
            '  reason=$reason',
      ComparisonOutcomeNotComparable(
        :final legacy,
        :final shadow,
        :final reason,
      ) =>
        '[comparison][$scope]\n'
            'UNKNOWN:\n'
            '  legacy=$legacy\n'
            '  shadow=$shadow\n'
            '  reason=$reason',
    };
  }
}
