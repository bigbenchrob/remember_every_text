import '../../../source_scoped_import/application/messages/message_importer.dart';
import '../../../source_scoped_import/application/messages/message_rich_text_enricher.dart';
import '../contacts/contact_projector.dart';
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
  final GraphBuildStep projectChatMessageEdges;
  final GraphBuildStep projectMessageAttachmentEdges;

  Future<ConversationGraphBuildReport> runOnce() async {
    final startedAt = DateTime.now().toUtc();
    final completedStageNames = <String>[];

    await importChats();
    completedStageNames.add('import_chats');

    await importHandles();
    completedStageNames.add('import_handles');

    await importContacts();
    completedStageNames.add('import_contacts');

    final messageImportResult = await importMessages();
    completedStageNames.add('import_messages');

    final richTextEnrichmentResult = await enrichMissingText();
    completedStageNames.add('enrich_missing_text');

    await importAttachments();
    completedStageNames.add('import_attachments');

    await importChatMessageJoins();
    completedStageNames.add('import_chat_message_joins');

    await importChatHandleJoins();
    completedStageNames.add('import_chat_handle_joins');

    await importMessageAttachmentJoins();
    completedStageNames.add('import_message_attachment_joins');

    await projectHandles();
    completedStageNames.add('project_handles');

    await projectContacts();
    completedStageNames.add('project_contacts');

    await projectChatHandleEdges();
    completedStageNames.add('project_chat_handle_edges');

    await projectChats();
    completedStageNames.add('project_chats');

    final messageProjectionResult = await projectMessages();
    completedStageNames.add('project_messages');

    await projectAttachments();
    completedStageNames.add('project_attachments');

    await projectChatMessageEdges();
    completedStageNames.add('project_chat_message_edges');

    await projectMessageAttachmentEdges();
    completedStageNames.add('project_message_attachment_edges');

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
