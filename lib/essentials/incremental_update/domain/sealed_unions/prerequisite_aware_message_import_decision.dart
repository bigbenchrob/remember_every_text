import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/message_import_blocker.dart';

part 'prerequisite_aware_message_import_decision.freezed.dart';

@freezed
sealed class PrerequisiteAwareMessageImportDecision
    with _$PrerequisiteAwareMessageImportDecision {
  const factory PrerequisiteAwareMessageImportDecision.doNothing() =
      PrerequisiteAwareMessageImportDecisionDoNothing;

  const factory PrerequisiteAwareMessageImportDecision.considerIncrementalImport() =
      PrerequisiteAwareMessageImportDecisionConsiderIncrementalImport;

  const factory PrerequisiteAwareMessageImportDecision.blockedPendingPrerequisites({
    required List<MessageImportBlocker> blockers,
  }) = PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisites;

  const factory PrerequisiteAwareMessageImportDecision.blockAndReportLedgerAhead() =
      PrerequisiteAwareMessageImportDecisionBlockAndReportLedgerAhead;
}
