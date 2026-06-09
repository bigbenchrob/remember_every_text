import '../../../source_scoped_import/application/archives/source_scoped_archive_import_service.dart';
import '../attachments/attachment_projection_repository.dart';
import '../attachments/attachment_projector.dart';
import '../chat_handle_joins/chat_to_handle_projection_repository.dart';
import '../chat_handle_joins/chat_to_handle_projector.dart';
import '../chat_message_joins/chat_to_message_projection_repository.dart';
import '../chat_message_joins/chat_to_message_projector.dart';
import '../chats/chat_projection_repository.dart';
import '../chats/chat_projector.dart';
import '../handles/handle_projection_repository.dart';
import '../handles/handle_projector.dart';
import '../message_attachment_joins/message_to_attachment_projection_repository.dart';
import '../message_attachment_joins/message_to_attachment_projector.dart';
import '../messages/message_projection_repository.dart';
import '../messages/message_projector.dart';

final class SourceScopedArchiveGraphProjectionResult {
  const SourceScopedArchiveGraphProjectionResult({
    required this.handles,
    required this.chatHandleEdges,
    required this.chats,
    required this.messages,
    required this.attachments,
    required this.chatMessageEdges,
    required this.messageAttachmentEdges,
  });

  final HandleProjectionResult handles;
  final ChatToHandleProjectionResult chatHandleEdges;
  final ChatProjectionResult chats;
  final MessageProjectionResult messages;
  final AttachmentProjectionResult attachments;
  final ChatToMessageProjectionResult chatMessageEdges;
  final MessageToAttachmentProjectionResult messageAttachmentEdges;

  int get insertedGraphNodeCount {
    return handles.insertedHandleCount +
        chats.insertedChatCount +
        messages.insertedMessageCount +
        attachments.insertedAttachmentCount;
  }

  int get insertedGraphEdgeCount {
    return chatHandleEdges.insertedEdgeCount +
        chatMessageEdges.insertedEdgeCount +
        messageAttachmentEdges.insertedEdgeCount;
  }
}

final class SourceScopedArchiveGraphImportResult {
  const SourceScopedArchiveGraphImportResult({
    required this.importResult,
    required this.projectionResult,
  });

  final SourceScopedArchiveImportResult importResult;
  final SourceScopedArchiveGraphProjectionResult projectionResult;
}

class SourceScopedArchiveGraphImportService {
  const SourceScopedArchiveGraphImportService({
    required this.importService,
    required this.handleProjector,
    required this.chatToHandleProjector,
    required this.chatProjector,
    required this.messageProjector,
    required this.attachmentProjector,
    required this.chatToMessageProjector,
    required this.messageToAttachmentProjector,
  });

  final SourceScopedArchiveImportService importService;
  final HandleProjector handleProjector;
  final ChatToHandleProjector chatToHandleProjector;
  final ChatProjector chatProjector;
  final MessageProjector messageProjector;
  final AttachmentProjector attachmentProjector;
  final ChatToMessageProjector chatToMessageProjector;
  final MessageToAttachmentProjector messageToAttachmentProjector;

  Future<SourceScopedArchiveGraphImportResult> importAndProject({
    required String folderPath,
    String? sourceLabel,
  }) async {
    final importResult = await importService.importSourceFacts(
      folderPath: folderPath,
      sourceLabel: sourceLabel,
    );

    final handles = await handleProjector.projectHandles();
    final chatHandleEdges = await chatToHandleProjector.projectEdges();
    final chats = await chatProjector.projectChats();
    final messages = await messageProjector.projectMessages();
    final attachments = await attachmentProjector.projectAttachments();
    final chatMessageEdges = await chatToMessageProjector.projectEdges();
    final messageAttachmentEdges = await messageToAttachmentProjector
        .projectEdges();

    return SourceScopedArchiveGraphImportResult(
      importResult: importResult,
      projectionResult: SourceScopedArchiveGraphProjectionResult(
        handles: handles,
        chatHandleEdges: chatHandleEdges,
        chats: chats,
        messages: messages,
        attachments: attachments,
        chatMessageEdges: chatMessageEdges,
        messageAttachmentEdges: messageAttachmentEdges,
      ),
    );
  }
}
