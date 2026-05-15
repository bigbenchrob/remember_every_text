import 'package:freezed_annotation/freezed_annotation.dart';

part 'handle_import_decision.freezed.dart';

@freezed
sealed class HandleImportDecision with _$HandleImportDecision {
  const factory HandleImportDecision.doNothing() =
      HandleImportDecisionDoNothing;

  const factory HandleImportDecision.considerIncrementalImport() =
      HandleImportDecisionConsiderIncrementalImport;

  const factory HandleImportDecision.blockAndReportLedgerAhead() =
      HandleImportDecisionBlockAndReportLedgerAhead;
}
