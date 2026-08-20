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
import '../projection_work_progress.dart';

enum SourceScopedArchiveGraphImportStage {
  importingSourceFacts,
  projectingConversationGraph,
}

enum SourceScopedArchiveGraphImportStageTransition {
  started,
  progressed,
  completed,
}

enum SourceScopedArchiveGraphProjectionUnit {
  participants,
  conversations,
  messages,
  attachments,
  relationships,
}

final class SourceScopedArchiveGraphProjectionProgress {
  const SourceScopedArchiveGraphProjectionProgress({
    required this.activeUnit,
    required this.completedUnitCount,
    required this.totalUnitCount,
    this.completedWorkCount,
    this.totalWorkCount,
  });

  final SourceScopedArchiveGraphProjectionUnit activeUnit;
  final int completedUnitCount;
  final int totalUnitCount;
  final int? completedWorkCount;
  final int? totalWorkCount;
}

final class SourceScopedArchiveGraphImportObservation {
  const SourceScopedArchiveGraphImportObservation({
    required this.stage,
    required this.transition,
    this.projectionProgress,
  });

  final SourceScopedArchiveGraphImportStage stage;
  final SourceScopedArchiveGraphImportStageTransition transition;
  final SourceScopedArchiveGraphProjectionProgress? projectionProgress;
}

typedef SourceScopedArchiveGraphImportObserver =
    void Function(SourceScopedArchiveGraphImportObservation observation);

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
    SourceScopedArchiveGraphImportObserver? onObservation,
  }) async {
    // Observations expose boundaries already owned by this service. They never
    // authorize, sequence, or otherwise control the import.
    onObservation?.call(
      const SourceScopedArchiveGraphImportObservation(
        stage: SourceScopedArchiveGraphImportStage.importingSourceFacts,
        transition: SourceScopedArchiveGraphImportStageTransition.started,
      ),
    );
    final importResult = await importService.importSourceFacts(
      folderPath: folderPath,
      sourceLabel: sourceLabel,
    );
    onObservation?.call(
      const SourceScopedArchiveGraphImportObservation(
        stage: SourceScopedArchiveGraphImportStage.importingSourceFacts,
        transition: SourceScopedArchiveGraphImportStageTransition.completed,
      ),
    );

    onObservation?.call(
      const SourceScopedArchiveGraphImportObservation(
        stage: SourceScopedArchiveGraphImportStage.projectingConversationGraph,
        transition: SourceScopedArchiveGraphImportStageTransition.started,
      ),
    );
    _observeProjectionUnit(
      onObservation,
      unit: SourceScopedArchiveGraphProjectionUnit.participants,
      completedUnitCount: 0,
    );
    final handles = await handleProjector.projectHandles();
    final chatHandleEdges = await chatToHandleProjector.projectEdges();
    _observeProjectionUnit(
      onObservation,
      unit: SourceScopedArchiveGraphProjectionUnit.conversations,
      completedUnitCount: 1,
    );
    final chats = await chatProjector.projectChats(
      onProgress: (progress) {
        _observeProjectionWork(
          onObservation,
          unit: SourceScopedArchiveGraphProjectionUnit.conversations,
          completedUnitCount: 1,
          progress: progress,
        );
      },
    );
    _observeProjectionUnit(
      onObservation,
      unit: SourceScopedArchiveGraphProjectionUnit.messages,
      completedUnitCount: 2,
    );
    final messages = await messageProjector.projectMessages(
      onProgress: (progress) {
        _observeProjectionWork(
          onObservation,
          unit: SourceScopedArchiveGraphProjectionUnit.messages,
          completedUnitCount: 2,
          progress: progress,
        );
      },
    );
    _observeProjectionUnit(
      onObservation,
      unit: SourceScopedArchiveGraphProjectionUnit.attachments,
      completedUnitCount: 3,
    );
    final attachments = await attachmentProjector.projectAttachments(
      onProgress: (progress) {
        _observeProjectionWork(
          onObservation,
          unit: SourceScopedArchiveGraphProjectionUnit.attachments,
          completedUnitCount: 3,
          progress: progress,
        );
      },
    );
    _observeProjectionUnit(
      onObservation,
      unit: SourceScopedArchiveGraphProjectionUnit.relationships,
      completedUnitCount: 4,
    );
    final chatMessageEdges = await chatToMessageProjector.projectEdges();
    final messageAttachmentEdges = await messageToAttachmentProjector
        .projectEdges();
    onObservation?.call(
      const SourceScopedArchiveGraphImportObservation(
        stage: SourceScopedArchiveGraphImportStage.projectingConversationGraph,
        transition: SourceScopedArchiveGraphImportStageTransition.completed,
      ),
    );

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

  void _observeProjectionUnit(
    SourceScopedArchiveGraphImportObserver? observer, {
    required SourceScopedArchiveGraphProjectionUnit unit,
    required int completedUnitCount,
  }) {
    observer?.call(
      SourceScopedArchiveGraphImportObservation(
        stage: SourceScopedArchiveGraphImportStage.projectingConversationGraph,
        transition: SourceScopedArchiveGraphImportStageTransition.progressed,
        projectionProgress: SourceScopedArchiveGraphProjectionProgress(
          activeUnit: unit,
          completedUnitCount: completedUnitCount,
          totalUnitCount: SourceScopedArchiveGraphProjectionUnit.values.length,
        ),
      ),
    );
  }

  void _observeProjectionWork(
    SourceScopedArchiveGraphImportObserver? observer, {
    required SourceScopedArchiveGraphProjectionUnit unit,
    required int completedUnitCount,
    required GraphProjectionWorkProgress progress,
  }) {
    observer?.call(
      SourceScopedArchiveGraphImportObservation(
        stage: SourceScopedArchiveGraphImportStage.projectingConversationGraph,
        transition: SourceScopedArchiveGraphImportStageTransition.progressed,
        projectionProgress: SourceScopedArchiveGraphProjectionProgress(
          activeUnit: unit,
          completedUnitCount: completedUnitCount,
          totalUnitCount: SourceScopedArchiveGraphProjectionUnit.values.length,
          completedWorkCount: progress.completedWorkCount,
          totalWorkCount: progress.totalWorkCount,
        ),
      ),
    );
  }
}
