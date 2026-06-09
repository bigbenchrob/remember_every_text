import '../../../db_importers/domain/ports/message_extractor_port.dart';
import '../attachments/attachment_importer.dart';
import '../chat_handle_joins/chat_handle_join_importer.dart';
import '../chat_message_joins/chat_message_join_importer.dart';
import '../chats/chat_importer.dart';
import '../handles/handle_importer.dart';
import '../message_attachment_joins/message_attachment_join_importer.dart';
import '../messages/message_importer.dart';
import '../messages/message_rich_text_enricher.dart';
import 'historical_messages_archive_source_registrar.dart';

final class SourceScopedArchiveImportResult {
  const SourceScopedArchiveImportResult({
    required this.registration,
    required this.messages,
    required this.chats,
    required this.handles,
    required this.attachments,
    required this.chatMessageEdges,
    required this.chatHandleEdges,
    required this.messageAttachmentEdges,
    required this.textEnrichment,
  });

  final HistoricalMessagesArchiveSourceRegistration registration;
  final MessageImportResult messages;
  final ChatImportResult chats;
  final HandleImportResult handles;
  final AttachmentImportResult attachments;
  final ChatMessageJoinImportResult chatMessageEdges;
  final ChatHandleJoinImportResult chatHandleEdges;
  final MessageAttachmentJoinImportResult messageAttachmentEdges;
  final MessageRichTextEnrichmentResult textEnrichment;

  int get insertedSourceFactCount {
    return messages.insertedMessageCount +
        chats.insertedChatCount +
        handles.insertedHandleCount +
        attachments.insertedAttachmentCount;
  }

  int get insertedTopologyEdgeCount {
    return chatMessageEdges.insertedJoinCount +
        chatHandleEdges.insertedJoinCount +
        messageAttachmentEdges.insertedJoinCount;
  }
}

class SourceScopedArchiveImportService {
  const SourceScopedArchiveImportService({
    required this.registrar,
    required this.richTextExtractor,
  });

  final HistoricalMessagesArchiveSourceRegistrar registrar;
  final MessageExtractorPort richTextExtractor;

  Future<SourceScopedArchiveImportResult> importSourceFacts({
    required String folderPath,
    String? sourceLabel,
  }) async {
    final registration = await registrar.registerFolder(
      folderPath: folderPath,
      sourceLabel: sourceLabel,
    );
    final sourceId = registration.sourceId;
    final chatDbPath = registration.chatDbPath;
    final importDatabase = registrar.importDatabase;

    final handles = await HandleImporter(
      chatDbPath: chatDbPath,
      importDatabase: importDatabase,
      sourceId: sourceId,
    ).importNewHandles();
    final chats = await ChatImporter(
      chatDbPath: chatDbPath,
      importDatabase: importDatabase,
      sourceId: sourceId,
    ).importChats();
    final messages = await MessageImporter(
      chatDbPath: chatDbPath,
      importDatabase: importDatabase,
      sourceId: sourceId,
    ).importNewMessages();
    final attachments = await AttachmentImporter(
      chatDbPath: chatDbPath,
      importDatabase: importDatabase,
      sourceId: sourceId,
    ).importAttachments();
    final chatHandleEdges = await ChatHandleJoinImporter(
      chatDbPath: chatDbPath,
      importDatabase: importDatabase,
      sourceId: sourceId,
    ).importJoins();
    final chatMessageEdges = await ChatMessageJoinImporter(
      chatDbPath: chatDbPath,
      importDatabase: importDatabase,
      sourceId: sourceId,
    ).importJoins();
    final messageAttachmentEdges = await MessageAttachmentJoinImporter(
      chatDbPath: chatDbPath,
      importDatabase: importDatabase,
      sourceId: sourceId,
    ).importJoins();
    final textEnrichment = await MessageRichTextEnricher(
      chatDbPath: chatDbPath,
      importDatabase: importDatabase,
      extractor: richTextExtractor,
    ).enrichMissingTextForSource(sourceId: sourceId);

    return SourceScopedArchiveImportResult(
      registration: registration,
      messages: messages,
      chats: chats,
      handles: handles,
      attachments: attachments,
      chatMessageEdges: chatMessageEdges,
      chatHandleEdges: chatHandleEdges,
      messageAttachmentEdges: messageAttachmentEdges,
      textEnrichment: textEnrichment,
    );
  }
}
