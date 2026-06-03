import '../../../source_scoped_import/application/messages/message_importer.dart';
import '../../../source_scoped_import/application/messages/message_rich_text_enricher.dart';
import '../contacts/contact_projection_repository.dart';
import '../messages/message_projection_repository.dart';

typedef GraphBuildStep = Future<void> Function();
typedef MessageImportStep = Future<MessageImportResult> Function();
typedef MessageImportAwareGraphBuildStep =
    Future<void> Function(MessageImportResult messageImportResult);
typedef RichTextEnrichmentStep =
    Future<MessageRichTextEnrichmentResult> Function(
      MessageImportResult messageImportResult,
    );
typedef MessageProjectionStep =
    Future<MessageProjectionResult> Function(
      MessageImportResult messageImportResult,
    );

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

class ConversationGraphBuildOrchestrator {
  const ConversationGraphBuildOrchestrator({
    required this.importChats,
    required this.importHandles,
    required this.importContacts,
    required this.importMessages,
    required this.enrichMissingText,
    required this.importAttachments,
    required this.importChatMessageJoins,
    required this.importChatHandleJoins,
    required this.importMessageAttachmentJoins,
    required this.projectHandles,
    required this.projectContacts,
    required this.projectChatHandleEdges,
    required this.projectChats,
    required this.projectMessages,
    required this.projectAttachments,
    required this.projectChatMessageEdges,
    required this.projectMessageAttachmentEdges,
  });

  final GraphBuildStep importChats;
  final GraphBuildStep importHandles;
  final GraphBuildStep importContacts;
  final MessageImportStep importMessages;
  final RichTextEnrichmentStep enrichMissingText;
  final GraphBuildStep importAttachments;
  final GraphBuildStep importChatMessageJoins;
  final GraphBuildStep importChatHandleJoins;
  final GraphBuildStep importMessageAttachmentJoins;
  final GraphBuildStep projectHandles;
  final Future<ContactProjectionResult> Function() projectContacts;
  final GraphBuildStep projectChatHandleEdges;
  final GraphBuildStep projectChats;
  final MessageProjectionStep projectMessages;
  final GraphBuildStep projectAttachments;
  final MessageImportAwareGraphBuildStep projectChatMessageEdges;
  final MessageImportAwareGraphBuildStep projectMessageAttachmentEdges;

  Future<ConversationGraphBuildReport> runOnce() async {
    final startedAt = DateTime.now().toUtc();
    final completedStageNames = <String>[];
    final stageTimings = <ConversationGraphBuildStageTiming>[];

    Future<void> runStage(String name, GraphBuildStep step) async {
      final stageStartedAt = DateTime.now().toUtc();
      await step();
      final stageFinishedAt = DateTime.now().toUtc();
      completedStageNames.add(name);
      stageTimings.add(
        ConversationGraphBuildStageTiming(
          stageName: name,
          startedAt: stageStartedAt,
          finishedAt: stageFinishedAt,
        ),
      );
    }

    Future<T> runValueStage<T>(String name, Future<T> Function() step) async {
      final stageStartedAt = DateTime.now().toUtc();
      final result = await step();
      final stageFinishedAt = DateTime.now().toUtc();
      completedStageNames.add(name);
      stageTimings.add(
        ConversationGraphBuildStageTiming(
          stageName: name,
          startedAt: stageStartedAt,
          finishedAt: stageFinishedAt,
        ),
      );
      return result;
    }

    await runStage('import_chats', importChats);

    await runStage('import_handles', importHandles);

    await runStage('import_contacts', importContacts);

    final messageImportResult = await runValueStage(
      'import_messages',
      importMessages,
    );

    final richTextEnrichmentResult = await runValueStage(
      'enrich_missing_text',
      () => enrichMissingText(messageImportResult),
    );

    await runStage('import_attachments', importAttachments);

    await runStage('import_chat_message_joins', importChatMessageJoins);

    await runStage('import_chat_handle_joins', importChatHandleJoins);

    await runStage(
      'import_message_attachment_joins',
      importMessageAttachmentJoins,
    );

    await runStage('project_handles', projectHandles);

    await runValueStage('project_contacts', projectContacts);

    await runStage('project_chat_handle_edges', projectChatHandleEdges);

    await runStage('project_chats', projectChats);

    final messageProjectionResult = await runValueStage(
      'project_messages',
      () => projectMessages(messageImportResult),
    );

    await runStage('project_attachments', projectAttachments);

    await runStage(
      'project_chat_message_edges',
      () => projectChatMessageEdges(messageImportResult),
    );

    await runStage(
      'project_message_attachment_edges',
      () => projectMessageAttachmentEdges(messageImportResult),
    );

    return ConversationGraphBuildReport(
      startedAt: startedAt,
      finishedAt: DateTime.now().toUtc(),
      completedStageNames: List<String>.unmodifiable(completedStageNames),
      stageTimings: List<ConversationGraphBuildStageTiming>.unmodifiable(
        stageTimings,
      ),
      messageImportResult: messageImportResult,
      richTextEnrichmentResult: richTextEnrichmentResult,
      messageProjectionResult: messageProjectionResult,
    );
  }
}
