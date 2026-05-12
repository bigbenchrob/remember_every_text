import 'package:freezed_annotation/freezed_annotation.dart';

part 'import_decision.freezed.dart';

@freezed
sealed class ImportDecision with _$ImportDecision {
  const factory ImportDecision.doNothing() = ImportDecisionDoNothing;

  const factory ImportDecision.considerIncrementalImport() =
      ImportDecisionConsiderIncrementalImport;

  const factory ImportDecision.blockAndReportLedgerAhead() =
      ImportDecisionBlockAndReportLedgerAhead;
}
