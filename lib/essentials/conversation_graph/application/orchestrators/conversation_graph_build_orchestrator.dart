import '../../../source_scoped_import/application/attachments/attachment_importer.dart';
import '../../../source_scoped_import/application/messages/message_importer.dart';
import '../../../source_scoped_import/application/messages/message_rich_text_enricher.dart';
import '../../../source_scoped_import/application/source_import_work_progress.dart';
import '../contacts/contact_projection_repository.dart';
import '../conversation_graph_build_observation.dart';
import '../conversation_graph_build_report.dart';
import '../messages/message_projection_repository.dart';
import '../projection_work_progress.dart';

typedef GraphBuildStep = Future<void> Function();
typedef SourceImportGraphBuildStep =
    Future<void> Function(SourceImportWorkObserver? onProgress);
typedef MessageImportStep =
    Future<MessageImportResult> Function(SourceImportWorkObserver? onProgress);
typedef AttachmentImportStep =
    Future<AttachmentImportResult> Function(
      SourceImportWorkObserver? onProgress,
    );
typedef MessageImportAwareSourceStep =
    Future<void> Function(
      MessageImportResult messageImportResult,
      SourceImportWorkObserver? onProgress,
    );
typedef MessageImportAwareGraphBuildStep =
    Future<void> Function(MessageImportResult messageImportResult);
typedef AttachmentProjectionStep =
    Future<void> Function(
      MessageImportResult messageImportResult,
      AttachmentImportResult attachmentImportResult,
      GraphProjectionWorkObserver? onProgress,
    );
typedef RichTextEnrichmentStep =
    Future<MessageRichTextEnrichmentResult> Function(
      MessageImportResult messageImportResult,
      SourceImportWorkObserver? onProgress,
    );
typedef MessageProjectionStep =
    Future<MessageProjectionResult> Function(
      MessageImportResult messageImportResult,
      GraphProjectionWorkObserver? onProgress,
    );
typedef GraphProjectionStep =
    Future<void> Function(GraphProjectionWorkObserver? onProgress);

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

  final SourceImportGraphBuildStep importChats;
  final SourceImportGraphBuildStep importHandles;
  final SourceImportGraphBuildStep importContacts;
  final MessageImportStep importMessages;
  final RichTextEnrichmentStep enrichMissingText;
  final AttachmentImportStep importAttachments;
  final MessageImportAwareSourceStep importChatMessageJoins;
  final SourceImportGraphBuildStep importChatHandleJoins;
  final MessageImportAwareSourceStep importMessageAttachmentJoins;
  final GraphBuildStep projectHandles;
  final Future<ContactProjectionResult> Function() projectContacts;
  final GraphBuildStep projectChatHandleEdges;
  final GraphProjectionStep projectChats;
  final MessageProjectionStep projectMessages;
  final AttachmentProjectionStep projectAttachments;
  final MessageImportAwareGraphBuildStep projectChatMessageEdges;
  final MessageImportAwareGraphBuildStep projectMessageAttachmentEdges;

  Future<ConversationGraphBuildReport> runOnce({
    ConversationGraphBuildObserver? onObservation,
  }) async {
    final startedAt = DateTime.now().toUtc();
    final completedStageNames = <String>[];
    final stageTimings = <ConversationGraphBuildStageTiming>[];
    var preservedUnnormalizedCount = 0;

    Future<void> runStage(
      String name,
      ConversationGraphBuildSuboperation suboperation,
      GraphBuildStep step,
    ) async {
      final stageStartedAt = DateTime.now().toUtc();
      _publishTransition(
        onObservation,
        suboperation,
        ConversationGraphBuildObservationKind.started,
      );
      await step();
      _publishTransition(
        onObservation,
        suboperation,
        ConversationGraphBuildObservationKind.completed,
      );
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

    Future<T> runValueStage<T>(
      String name,
      ConversationGraphBuildSuboperation suboperation,
      Future<T> Function() step,
    ) async {
      final stageStartedAt = DateTime.now().toUtc();
      _publishTransition(
        onObservation,
        suboperation,
        ConversationGraphBuildObservationKind.started,
      );
      final result = await step();
      _publishTransition(
        onObservation,
        suboperation,
        ConversationGraphBuildObservationKind.completed,
      );
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

    SourceImportWorkObserver sourceObserver(
      ConversationGraphBuildSuboperation defaultSuboperation,
    ) {
      return (progress) {
        if (progress.preservedUnnormalizedCount > preservedUnnormalizedCount) {
          preservedUnnormalizedCount = progress.preservedUnnormalizedCount;
        }
        final suboperation = _suboperationForSourceUnit(progress.unit);
        onObservation?.call(
          ConversationGraphBuildObservation(
            suboperation: suboperation ?? defaultSuboperation,
            kind: ConversationGraphBuildObservationKind.progress,
            completedWorkCount: progress.completedWorkCount,
            totalWorkCount: progress.totalWorkCount,
            lastCompletedSourceRowId: progress.lastCompletedSourceRowId,
            preservedUnnormalizedCount: preservedUnnormalizedCount,
          ),
        );
      };
    }

    GraphProjectionWorkObserver graphObserver(
      ConversationGraphBuildSuboperation suboperation,
    ) {
      return (progress) {
        if (progress.completedWorkCount != progress.totalWorkCount &&
            progress.completedWorkCount % 1000 != 0) {
          return;
        }
        onObservation?.call(
          ConversationGraphBuildObservation(
            suboperation: suboperation,
            kind: ConversationGraphBuildObservationKind.progress,
            completedWorkCount: progress.completedWorkCount,
            totalWorkCount: progress.totalWorkCount,
            preservedUnnormalizedCount: preservedUnnormalizedCount,
          ),
        );
      };
    }

    await runStage(
      'import_chats',
      ConversationGraphBuildSuboperation.importChats,
      () => importChats(
        sourceObserver(ConversationGraphBuildSuboperation.importChats),
      ),
    );

    await runStage(
      'import_handles',
      ConversationGraphBuildSuboperation.importHandles,
      () => importHandles(
        sourceObserver(ConversationGraphBuildSuboperation.importHandles),
      ),
    );

    await runStage(
      'import_contacts',
      ConversationGraphBuildSuboperation.importContacts,
      () => importContacts(
        sourceObserver(ConversationGraphBuildSuboperation.importContacts),
      ),
    );

    final messageImportResult = await runValueStage(
      'import_messages',
      ConversationGraphBuildSuboperation.importMessages,
      () => importMessages(
        sourceObserver(ConversationGraphBuildSuboperation.importMessages),
      ),
    );

    final richTextEnrichmentResult = await runValueStage(
      'enrich_missing_text',
      ConversationGraphBuildSuboperation.extractRichText,
      () => enrichMissingText(
        messageImportResult,
        sourceObserver(ConversationGraphBuildSuboperation.extractRichText),
      ),
    );

    final attachmentImportResult = await runValueStage(
      'import_attachments',
      ConversationGraphBuildSuboperation.importAttachments,
      () => importAttachments(
        sourceObserver(ConversationGraphBuildSuboperation.importAttachments),
      ),
    );

    await runStage(
      'import_chat_message_joins',
      ConversationGraphBuildSuboperation.importChatMessageRelationships,
      () => importChatMessageJoins(
        messageImportResult,
        sourceObserver(
          ConversationGraphBuildSuboperation.importChatMessageRelationships,
        ),
      ),
    );

    await runStage(
      'import_chat_handle_joins',
      ConversationGraphBuildSuboperation.importChatHandleRelationships,
      () => importChatHandleJoins(
        sourceObserver(
          ConversationGraphBuildSuboperation.importChatHandleRelationships,
        ),
      ),
    );

    await runStage(
      'import_message_attachment_joins',
      ConversationGraphBuildSuboperation.importMessageAttachmentRelationships,
      () => importMessageAttachmentJoins(
        messageImportResult,
        sourceObserver(
          ConversationGraphBuildSuboperation
              .importMessageAttachmentRelationships,
        ),
      ),
    );

    await runStage(
      'project_handles',
      ConversationGraphBuildSuboperation.projectHandles,
      projectHandles,
    );

    await runValueStage(
      'project_contacts',
      ConversationGraphBuildSuboperation.projectContacts,
      projectContacts,
    );

    await runStage(
      'project_chat_handle_edges',
      ConversationGraphBuildSuboperation.projectChatHandleRelationships,
      projectChatHandleEdges,
    );

    await runStage(
      'project_chats',
      ConversationGraphBuildSuboperation.projectConversations,
      () => projectChats(
        graphObserver(ConversationGraphBuildSuboperation.projectConversations),
      ),
    );

    final messageProjectionResult = await runValueStage(
      'project_messages',
      ConversationGraphBuildSuboperation.projectMessages,
      () => projectMessages(
        messageImportResult,
        graphObserver(ConversationGraphBuildSuboperation.projectMessages),
      ),
    );

    await runStage(
      'project_attachments',
      ConversationGraphBuildSuboperation.projectAttachments,
      () => projectAttachments(
        messageImportResult,
        attachmentImportResult,
        graphObserver(ConversationGraphBuildSuboperation.projectAttachments),
      ),
    );

    await runStage(
      'project_chat_message_edges',
      ConversationGraphBuildSuboperation.projectChatMessageRelationships,
      () => projectChatMessageEdges(messageImportResult),
    );

    await runStage(
      'project_message_attachment_edges',
      ConversationGraphBuildSuboperation.projectMessageAttachmentRelationships,
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

void _publishTransition(
  ConversationGraphBuildObserver? observer,
  ConversationGraphBuildSuboperation suboperation,
  ConversationGraphBuildObservationKind kind,
) {
  observer?.call(
    ConversationGraphBuildObservation(suboperation: suboperation, kind: kind),
  );
}

ConversationGraphBuildSuboperation? _suboperationForSourceUnit(
  SourceImportWorkUnit unit,
) {
  return switch (unit) {
    SourceImportWorkUnit.chats =>
      ConversationGraphBuildSuboperation.importChats,
    SourceImportWorkUnit.handles =>
      ConversationGraphBuildSuboperation.importHandles,
    SourceImportWorkUnit.contacts =>
      ConversationGraphBuildSuboperation.importContacts,
    SourceImportWorkUnit.contactEmailChannels =>
      ConversationGraphBuildSuboperation.importContactEmailChannels,
    SourceImportWorkUnit.contactPhoneChannels =>
      ConversationGraphBuildSuboperation.importContactPhoneChannels,
    SourceImportWorkUnit.messages =>
      ConversationGraphBuildSuboperation.importMessages,
    SourceImportWorkUnit.richTextExtraction =>
      ConversationGraphBuildSuboperation.extractRichText,
    SourceImportWorkUnit.richTextPersistence =>
      ConversationGraphBuildSuboperation.persistRichText,
    SourceImportWorkUnit.attachments =>
      ConversationGraphBuildSuboperation.importAttachments,
    SourceImportWorkUnit.chatMessageRelationships =>
      ConversationGraphBuildSuboperation.importChatMessageRelationships,
    SourceImportWorkUnit.chatHandleRelationships =>
      ConversationGraphBuildSuboperation.importChatHandleRelationships,
    SourceImportWorkUnit.messageAttachmentRelationships =>
      ConversationGraphBuildSuboperation.importMessageAttachmentRelationships,
  };
}
