import '../../../source_scoped_import/application/archives/historical_messages_archive_source_folder_resolver.dart';
import '../../../source_scoped_import/domain/ports/import_ledger_port.dart';
import '../attachments/attachment_projector.dart';
import '../chat_handle_joins/chat_to_handle_projector.dart';
import '../chat_message_joins/chat_to_message_projector.dart';
import '../chats/chat_projector.dart';
import '../contacts/contact_projector.dart';
import '../handles/handle_projector.dart';
import '../message_attachment_joins/message_to_attachment_projector.dart';
import '../messages/message_projector.dart';
import 'graph_projection_resetter.dart';

enum SourceScopedArchiveGraphRemovalStage {
  removingImportedFacts,
  rebuildingConversationGraph,
}

enum SourceScopedArchiveGraphRemovalStageTransition {
  started,
  completed,
  skipped,
}

final class SourceScopedArchiveGraphRemovalObservation {
  const SourceScopedArchiveGraphRemovalObservation({
    required this.stage,
    required this.transition,
  });

  final SourceScopedArchiveGraphRemovalStage stage;
  final SourceScopedArchiveGraphRemovalStageTransition transition;
}

typedef SourceScopedArchiveGraphRemovalObserver =
    void Function(SourceScopedArchiveGraphRemovalObservation observation);

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
    required this.importLedger,
    required this.graphProjectionResetter,
    required this.handleProjector,
    required this.contactProjector,
    required this.chatToHandleProjector,
    required this.chatProjector,
    required this.messageProjector,
    required this.attachmentProjector,
    required this.chatToMessageProjector,
    required this.messageToAttachmentProjector,
    required this.folderResolver,
  });

  final ImportLedger importLedger;
  final GraphProjectionResetter graphProjectionResetter;
  final HandleProjector handleProjector;
  final ContactProjector contactProjector;
  final ChatToHandleProjector chatToHandleProjector;
  final ChatProjector chatProjector;
  final MessageProjector messageProjector;
  final AttachmentProjector attachmentProjector;
  final ChatToMessageProjector chatToMessageProjector;
  final MessageToAttachmentProjector messageToAttachmentProjector;
  final HistoricalMessagesArchiveSourceFolderResolver folderResolver;

  Future<SourceScopedArchiveGraphRemovalResult> removeArchiveSource({
    required String folderPath,
    SourceScopedArchiveGraphRemovalObserver? onObservation,
  }) async {
    _publish(
      onObservation,
      stage: SourceScopedArchiveGraphRemovalStage.removingImportedFacts,
      transition: SourceScopedArchiveGraphRemovalStageTransition.started,
    );
    final sourceKey = folderResolver.resolveFolder(folderPath).sourceKey;
    final sourceId = await importLedger.sourceIdForKey(sourceKey);
    if (sourceId == null) {
      _publish(
        onObservation,
        stage: SourceScopedArchiveGraphRemovalStage.removingImportedFacts,
        transition: SourceScopedArchiveGraphRemovalStageTransition.completed,
      );
      _publish(
        onObservation,
        stage: SourceScopedArchiveGraphRemovalStage.rebuildingConversationGraph,
        transition: SourceScopedArchiveGraphRemovalStageTransition.skipped,
      );
      return const SourceScopedArchiveGraphRemovalResult(
        sourceId: null,
        deletionResult: null,
        graphReprojected: false,
      );
    }

    final deletionResult = await importLedger.deleteRowsForSource(
      sourceId: sourceId,
    );
    _publish(
      onObservation,
      stage: SourceScopedArchiveGraphRemovalStage.removingImportedFacts,
      transition: SourceScopedArchiveGraphRemovalStageTransition.completed,
    );
    if (deletionResult.deletedSourceFactCount == 0 &&
        deletionResult.deletedTopologyEdgeCount == 0) {
      _publish(
        onObservation,
        stage: SourceScopedArchiveGraphRemovalStage.rebuildingConversationGraph,
        transition: SourceScopedArchiveGraphRemovalStageTransition.skipped,
      );
      return SourceScopedArchiveGraphRemovalResult(
        sourceId: sourceId,
        deletionResult: deletionResult,
        graphReprojected: false,
      );
    }

    _publish(
      onObservation,
      stage: SourceScopedArchiveGraphRemovalStage.rebuildingConversationGraph,
      transition: SourceScopedArchiveGraphRemovalStageTransition.started,
    );
    await graphProjectionResetter.clearProjectionRows();
    await _projectRemainingImportFacts();
    _publish(
      onObservation,
      stage: SourceScopedArchiveGraphRemovalStage.rebuildingConversationGraph,
      transition: SourceScopedArchiveGraphRemovalStageTransition.completed,
    );

    return SourceScopedArchiveGraphRemovalResult(
      sourceId: sourceId,
      deletionResult: deletionResult,
      graphReprojected: true,
    );
  }

  static void _publish(
    SourceScopedArchiveGraphRemovalObserver? observer, {
    required SourceScopedArchiveGraphRemovalStage stage,
    required SourceScopedArchiveGraphRemovalStageTransition transition,
  }) {
    observer?.call(
      SourceScopedArchiveGraphRemovalObservation(
        stage: stage,
        transition: transition,
      ),
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
}
