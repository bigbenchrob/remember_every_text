import '../../../source_scoped_import/application/messages/message_importer.dart';
import '../../../source_scoped_import/application/messages/message_rich_text_enricher.dart';
import '../messages/message_projector.dart';

typedef GraphBuildStep = Future<void> Function();
typedef MessageImportStep = Future<MessageImportResult> Function();
typedef RichTextEnrichmentStep =
    Future<MessageRichTextEnrichmentResult> Function();
typedef MessageProjectionStep = Future<MessageProjectionResult> Function();

class ConversationGraphBuildReport {
  const ConversationGraphBuildReport({
    required this.startedAt,
    required this.finishedAt,
    required this.completedStageNames,
    required this.messageImportResult,
    required this.richTextEnrichmentResult,
    required this.messageProjectionResult,
  });

  final DateTime startedAt;
  final DateTime finishedAt;
  final List<String> completedStageNames;
  final MessageImportResult messageImportResult;
  final MessageRichTextEnrichmentResult richTextEnrichmentResult;
  final MessageProjectionResult messageProjectionResult;
}

class ConversationGraphBuildOrchestrator {
  const ConversationGraphBuildOrchestrator({
    required this.importChats,
    required this.importHandles,
    required this.importMessages,
    required this.enrichMissingText,
    required this.importChatMessageJoins,
    required this.importChatHandleJoins,
    required this.projectHandles,
    required this.projectChatHandleEdges,
    required this.projectChats,
    required this.projectMessages,
    required this.projectChatMessageEdges,
  });

  final GraphBuildStep importChats;
  final GraphBuildStep importHandles;
  final MessageImportStep importMessages;
  final RichTextEnrichmentStep enrichMissingText;
  final GraphBuildStep importChatMessageJoins;
  final GraphBuildStep importChatHandleJoins;
  final GraphBuildStep projectHandles;
  final GraphBuildStep projectChatHandleEdges;
  final GraphBuildStep projectChats;
  final MessageProjectionStep projectMessages;
  final GraphBuildStep projectChatMessageEdges;

  Future<ConversationGraphBuildReport> runOnce() async {
    final startedAt = DateTime.now().toUtc();
    final completedStageNames = <String>[];

    await importChats();
    completedStageNames.add('import_chats');

    await importHandles();
    completedStageNames.add('import_handles');

    final messageImportResult = await importMessages();
    completedStageNames.add('import_messages');

    final richTextEnrichmentResult = await enrichMissingText();
    completedStageNames.add('enrich_missing_text');

    await importChatMessageJoins();
    completedStageNames.add('import_chat_message_joins');

    await importChatHandleJoins();
    completedStageNames.add('import_chat_handle_joins');

    await projectHandles();
    completedStageNames.add('project_handles');

    await projectChatHandleEdges();
    completedStageNames.add('project_chat_handle_edges');

    await projectChats();
    completedStageNames.add('project_chats');

    final messageProjectionResult = await projectMessages();
    completedStageNames.add('project_messages');

    await projectChatMessageEdges();
    completedStageNames.add('project_chat_message_edges');

    return ConversationGraphBuildReport(
      startedAt: startedAt,
      finishedAt: DateTime.now().toUtc(),
      completedStageNames: List<String>.unmodifiable(completedStageNames),
      messageImportResult: messageImportResult,
      richTextEnrichmentResult: richTextEnrichmentResult,
      messageProjectionResult: messageProjectionResult,
    );
  }
}
