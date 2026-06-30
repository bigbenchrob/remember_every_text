import '../../source_scoped_import/application/messages/message_importer.dart';
import '../../source_scoped_import/application/messages/message_rich_text_enricher.dart';
import 'messages/message_projection_repository.dart';

class ConversationGraphBuildStageTiming {
  const ConversationGraphBuildStageTiming({
    required this.stageName,
    required this.startedAt,
    required this.finishedAt,
  });

  final String stageName;
  final DateTime startedAt;
  final DateTime finishedAt;

  int get durationMs => finishedAt.difference(startedAt).inMilliseconds;
}

class ConversationGraphBuildReport {
  const ConversationGraphBuildReport({
    required this.startedAt,
    required this.finishedAt,
    required this.completedStageNames,
    required this.stageTimings,
    required this.messageImportResult,
    required this.richTextEnrichmentResult,
    required this.messageProjectionResult,
  });

  final DateTime startedAt;
  final DateTime finishedAt;
  final List<String> completedStageNames;
  final List<ConversationGraphBuildStageTiming> stageTimings;
  final MessageImportResult messageImportResult;
  final MessageRichTextEnrichmentResult richTextEnrichmentResult;
  final MessageProjectionResult messageProjectionResult;
}
