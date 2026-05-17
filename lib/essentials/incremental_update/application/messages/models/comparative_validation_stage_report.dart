import 'package:flutter/foundation.dart';

import '../../../domain/sealed_unions/comparison_outcome.dart';

enum ComparativeValidationStageExecutionOutcome { noMutation }

@immutable
final class ComparativeValidationStageReport {
  ComparativeValidationStageReport({
    required this.startedAt,
    required this.finishedAt,
    required this.importComparison,
    required this.migrationComparison,
    this.executionOutcome =
        ComparativeValidationStageExecutionOutcome.noMutation,
    List<String> diagnosticEvents = const <String>[],
  }) : diagnosticEvents = List.unmodifiable(diagnosticEvents);

  final DateTime startedAt;
  final DateTime finishedAt;
  final ComparisonOutcome importComparison;
  final ComparisonOutcome migrationComparison;
  final ComparativeValidationStageExecutionOutcome executionOutcome;
  final List<String> diagnosticEvents;
}

String formatComparisonOutcome(ComparisonOutcome outcome) {
  return switch (outcome) {
    ComparisonOutcomeMatch(:final legacy, :final shadow) =>
      'MATCH legacy=$legacy shadow=$shadow',
    ComparisonOutcomePhaseSkew(:final legacy, :final shadow, :final reason) =>
      'PHASE SKEW legacy=$legacy shadow=$shadow reason=$reason',
    ComparisonOutcomeMismatch(:final legacy, :final shadow, :final reason) =>
      'MISMATCH legacy=$legacy shadow=$shadow reason=$reason',
    ComparisonOutcomeNotComparable(
      :final legacy,
      :final shadow,
      :final reason,
    ) =>
      'NOT COMPARABLE legacy=$legacy shadow=$shadow reason=$reason',
  };
}
