import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_import_decision.freezed.dart';

@freezed
sealed class ChatImportDecision with _$ChatImportDecision {
  const factory ChatImportDecision.doNothing() = ChatImportDecisionDoNothing;

  const factory ChatImportDecision.considerIncrementalImport() =
      ChatImportDecisionConsiderIncrementalImport;

  const factory ChatImportDecision.blockAndReportLedgerAhead() =
      ChatImportDecisionBlockAndReportLedgerAhead;
}
