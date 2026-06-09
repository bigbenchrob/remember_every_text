import 'dart:io';

import 'package:path/path.dart' as path;

import '../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../source_scoped_import/application/archives/historical_messages_archive_source_registrar.dart';
import '../../../source_scoped_import/infrastructure/import_database_provider.dart';
import '../attachments/attachment_projector.dart';
import '../chat_handle_joins/chat_to_handle_projector.dart';
import '../chat_message_joins/chat_to_message_projector.dart';
import '../chats/chat_projector.dart';
import '../contacts/contact_projector.dart';
import '../handles/handle_projector.dart';
import '../message_attachment_joins/message_to_attachment_projector.dart';
import '../messages/message_projector.dart';

final class SourceScopedArchiveGraphRemovalResult {
  const SourceScopedArchiveGraphRemovalResult({
    required this.sourceId,
    required this.deletionResult,
    required this.graphReprojected,
  });

  final int? sourceId;
  final SourceScopedImportSourceDeletionResult? deletionResult;
  final bool graphReprojected;

  bool get sourceWasRegistered => sourceId != null;

  int get deletedSourceFactCount {
    return deletionResult?.deletedSourceFactCount ?? 0;
  }

  int get deletedTopologyEdgeCount {
    return deletionResult?.deletedTopologyEdgeCount ?? 0;
  }
}

class SourceScopedArchiveGraphRemovalService {
  const SourceScopedArchiveGraphRemovalService({
    required this.importDatabase,
    required this.graphDatabase,
    required this.handleProjector,
    required this.contactProjector,
    required this.chatToHandleProjector,
    required this.chatProjector,
    required this.messageProjector,
    required this.attachmentProjector,
    required this.chatToMessageProjector,
    required this.messageToAttachmentProjector,
  });

  final ImportDatabase importDatabase;
  final ConversationGraphDatabase graphDatabase;
  final HandleProjector handleProjector;
  final ContactProjector contactProjector;
  final ChatToHandleProjector chatToHandleProjector;
  final ChatProjector chatProjector;
  final MessageProjector messageProjector;
  final AttachmentProjector attachmentProjector;
  final ChatToMessageProjector chatToMessageProjector;
  final MessageToAttachmentProjector messageToAttachmentProjector;

  Future<SourceScopedArchiveGraphRemovalResult> removeArchiveSource({
    required String folderPath,
  }) async {
    final chatDbPath = _chatDbPathForFolder(folderPath);
    final sourceKey = HistoricalMessagesArchiveSourceRegistrar.buildSourceKey(
      chatDbPath: chatDbPath,
    );
    final sourceId = await importDatabase.sourceIdForKey(sourceKey);
    if (sourceId == null) {
      return const SourceScopedArchiveGraphRemovalResult(
        sourceId: null,
        deletionResult: null,
        graphReprojected: false,
      );
    }

    final deletionResult = await importDatabase.deleteRowsForSource(
      sourceId: sourceId,
    );
    if (deletionResult.deletedSourceFactCount == 0 &&
        deletionResult.deletedTopologyEdgeCount == 0) {
      return SourceScopedArchiveGraphRemovalResult(
        sourceId: sourceId,
        deletionResult: deletionResult,
        graphReprojected: false,
      );
    }

    await graphDatabase.clearProjectionRows();
    await _projectRemainingImportFacts();

    return SourceScopedArchiveGraphRemovalResult(
      sourceId: sourceId,
      deletionResult: deletionResult,
      graphReprojected: true,
    );
  }

  Future<void> _projectRemainingImportFacts() async {
    await handleProjector.projectHandles();
    await contactProjector.projectContacts();
    await chatToHandleProjector.projectEdges();
    await chatProjector.projectChats();
    await messageProjector.projectMessages();
    await attachmentProjector.projectAttachments();
    await chatToMessageProjector.projectEdges();
    await messageToAttachmentProjector.projectEdges();
  }

  static String _chatDbPathForFolder(String folderPath) {
    final trimmed = folderPath.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(folderPath, 'folderPath', 'must not be empty');
    }

    final normalizedFolderPath = Directory(trimmed).absolute.path;
    final chatDbPath = path.join(normalizedFolderPath, 'chat.db');
    if (!File(chatDbPath).existsSync()) {
      throw FileSystemException(
        'Historical Messages archive folder must contain chat.db',
        chatDbPath,
      );
    }
    return chatDbPath;
  }
}
