import '../../../domain/sealed_unions/import_decision.dart';
import '../../chats/models/chat_stage_report.dart';
import '../../handles/models/handle_stage_report.dart';
import '../../messages/models/comparative_validation_stage_report.dart';
import '../../messages/models/message_import_stage_report.dart';
import '../../messages/models/message_migration_stage_report.dart';
import '../models/pipeline_run_report.dart';

class PipelineOrchestrator {
  const PipelineOrchestrator({
    required Future<HandleStageReport> Function() runHandleStage,
    required Future<ChatStageReport> Function() runChatStage,
    required Future<MessageImportStageReport> Function() runMessageImportStage,
    required Future<MessageMigrationStageReport> Function()
    runMessageMigrationStage,
    required Future<ComparativeValidationStageReport> Function()
    runComparativeValidationStage,
    required Future<ImportDecision> Function() readCurrentImportDecision,
  }) : _runHandleStage = runHandleStage,
       _runChatStage = runChatStage,
       _runMessageImportStage = runMessageImportStage,
       _runMessageMigrationStage = runMessageMigrationStage,
       _runComparativeValidationStage = runComparativeValidationStage,
       _readCurrentImportDecision = readCurrentImportDecision;

  final Future<HandleStageReport> Function() _runHandleStage;
  final Future<ChatStageReport> Function() _runChatStage;
  final Future<MessageImportStageReport> Function() _runMessageImportStage;
  final Future<MessageMigrationStageReport> Function()
  _runMessageMigrationStage;
  final Future<ComparativeValidationStageReport> Function()
  _runComparativeValidationStage;
  final Future<ImportDecision> Function() _readCurrentImportDecision;

  Future<PipelineRunReport> runOnce() async {
    final startedAt = DateTime.now();

    // Manual stage order only. This is intentionally not descriptor-driven,
    // not graph-planned, and not topologically sorted yet.
    final handleStageReport = await _runHandleStage();
    final chatStageReport = await _runChatStage();
    final messageImportStageReport = await _runMessageImportStage();
    final messageMigrationStageReport = await _runMessageMigrationStage();
    final comparativeValidationStageReport =
        await _runComparativeValidationStage();

    final importDecisionAfterRun = messageImportStageReport.importResult == null
        ? messageImportStageReport.decision
        : await _readCurrentImportDecision();

    return PipelineRunReport(
      startedAt: startedAt,
      finishedAt: DateTime.now(),
      handleStageReport: handleStageReport,
      chatStageReport: chatStageReport,
      messageImportStageReport: messageImportStageReport,
      messageMigrationStageReport: messageMigrationStageReport,
      comparativeValidationStageReport: comparativeValidationStageReport,
      importDecisionAfterRun: importDecisionAfterRun,
    );
  }
}
