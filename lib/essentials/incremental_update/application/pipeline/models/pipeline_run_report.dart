import 'package:flutter/foundation.dart';

import '../../../domain/sealed_unions/import_decision.dart';
import '../../chat_message_joins/models/chat_message_join_stage_report.dart';
import '../../chats/models/chat_stage_report.dart';
import '../../handles/models/handle_stage_report.dart';
import '../../messages/models/comparative_validation_stage_report.dart';
import '../../messages/models/message_import_stage_report.dart';
import '../../messages/models/message_migration_stage_report.dart';

@immutable
final class PipelineRunReport {
  PipelineRunReport({
    required this.startedAt,
    required this.finishedAt,
    required this.handleStageReport,
    required this.chatStageReport,
    required this.messageImportStageReport,
    required this.chatMessageJoinStageReport,
    required this.messageMigrationStageReport,
    required this.comparativeValidationStageReport,
    required this.importDecisionAfterRun,
  }) : orderedStageReports = List.unmodifiable(<Object>[
         handleStageReport,
         chatStageReport,
         messageImportStageReport,
         chatMessageJoinStageReport,
         messageMigrationStageReport,
         comparativeValidationStageReport,
       ]),
       diagnosticEvents = List.unmodifiable(<String>[
         ...handleStageReport.diagnosticEvents,
         ...chatStageReport.diagnosticEvents,
         ...messageImportStageReport.diagnosticEvents,
         ...chatMessageJoinStageReport.diagnosticEvents,
         ...messageMigrationStageReport.diagnosticEvents,
         ...comparativeValidationStageReport.diagnosticEvents,
       ]);

  final DateTime startedAt;
  final DateTime finishedAt;
  final HandleStageReport handleStageReport;
  final ChatStageReport chatStageReport;
  final MessageImportStageReport messageImportStageReport;
  final ChatMessageJoinStageReport chatMessageJoinStageReport;
  final MessageMigrationStageReport messageMigrationStageReport;
  final ComparativeValidationStageReport comparativeValidationStageReport;
  final ImportDecision importDecisionAfterRun;
  final List<Object> orderedStageReports;
  final List<String> diagnosticEvents;
}
