import 'package:freezed_annotation/freezed_annotation.dart';

part 'comparison_outcome.freezed.dart';

@freezed
sealed class ComparisonOutcome with _$ComparisonOutcome {
  const factory ComparisonOutcome.match({
    required String legacy,
    required String shadow,
  }) = ComparisonOutcomeMatch;

  const factory ComparisonOutcome.mismatch({
    required String legacy,
    required String shadow,
    required String reason,
  }) = ComparisonOutcomeMismatch;

  const factory ComparisonOutcome.phaseSkew({
    required String legacy,
    required String shadow,
    required String reason,
  }) = ComparisonOutcomePhaseSkew;

  const factory ComparisonOutcome.notComparable({
    required String legacy,
    required String shadow,
    required String reason,
  }) = ComparisonOutcomeNotComparable;
}
