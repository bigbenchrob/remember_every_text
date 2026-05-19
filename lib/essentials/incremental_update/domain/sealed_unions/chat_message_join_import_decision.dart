import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_join_import_decision.freezed.dart';

@freezed
sealed class ChatMessageJoinImportDecision
    with _$ChatMessageJoinImportDecision {
  const factory ChatMessageJoinImportDecision.doNothing() =
      ChatMessageJoinImportDecisionDoNothing;

  const factory ChatMessageJoinImportDecision.considerTopologyImport() =
      ChatMessageJoinImportDecisionConsiderTopologyImport;

  const factory ChatMessageJoinImportDecision.blockAndReportLedgerAhead() =
      ChatMessageJoinImportDecisionBlockAndReportLedgerAhead;
}
