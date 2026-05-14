import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/sealed_unions/comparison_outcome.dart';
import '../integrators/incremental_update_comparison_provider.dart';
import '../readers/legacy_incremental_update_snapshot_provider.dart';

class ComparativeValidationOrchestrator {
  const ComparativeValidationOrchestrator(this._ref);

  final Ref _ref;

  Future<void> refreshOnce() async {
    _ref.invalidate(legacyIncrementalUpdateSnapshotProvider);
    final report = await _ref.read(incrementalUpdateComparisonProvider.future);

    debugPrint(
      _formatComparison('incremental import', report.importComparison),
    );
    debugPrint(
      _formatComparison('migration projection', report.migrationComparison),
    );
  }

  String _formatComparison(String scope, ComparisonOutcome outcome) {
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
