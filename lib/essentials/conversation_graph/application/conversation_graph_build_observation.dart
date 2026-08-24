import '../../source_scoped_import/domain/source_import_anomaly_counts.dart';

enum ConversationGraphBuildSuboperation {
  importChats,
  importHandles,
  importContacts,
  importContactEmailChannels,
  importContactPhoneChannels,
  importMessages,
  extractRichText,
  persistRichText,
  importAttachments,
  importChatMessageRelationships,
  importChatHandleRelationships,
  importMessageAttachmentRelationships,
  projectHandles,
  projectContacts,
  projectChatHandleRelationships,
  projectConversations,
  projectMessages,
  projectAttachments,
  projectChatMessageRelationships,
  projectMessageAttachmentRelationships,
}

enum ConversationGraphBuildObservationKind { started, progress, completed }

final class ConversationGraphBuildObservation {
  const ConversationGraphBuildObservation({
    required this.suboperation,
    required this.kind,
    this.completedWorkCount,
    this.totalWorkCount,
    this.lastCompletedSourceRowId,
    this.anomalyCounts = SourceImportAnomalyCounts.empty,
  }) : assert((completedWorkCount == null) == (totalWorkCount == null));

  final ConversationGraphBuildSuboperation suboperation;
  final ConversationGraphBuildObservationKind kind;
  final int? completedWorkCount;
  final int? totalWorkCount;
  final int? lastCompletedSourceRowId;
  final SourceImportAnomalyCounts anomalyCounts;

  int get preservedUnnormalizedCount =>
      anomalyCounts.preservedUnnormalizedHandleCount;
}

typedef ConversationGraphBuildObserver =
    void Function(ConversationGraphBuildObservation observation);
