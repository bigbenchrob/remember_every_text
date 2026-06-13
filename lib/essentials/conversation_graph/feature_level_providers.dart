import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/attachments/infrastructure/repositories/overlay_archive_compatibility_lookup.dart';
import '../../providers.dart';
import '../db/feature_level_providers.dart';
import '../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../source_scoped_import/domain/known_sources.dart';
import '../source_scoped_import/feature_level_providers.dart';
import 'application/archives/graph_projection_resetter.dart';
import 'application/attachments/attachment_projection_repository.dart';
import 'application/chat_handle_joins/chat_to_handle_projection_repository.dart';
import 'application/chat_message_joins/chat_to_message_projection_repository.dart';
import 'application/chat_summaries/chat_summary_repository.dart';
import 'application/chats/chat_projection_repository.dart';
import 'application/contacts/contact_graph_repository.dart';
import 'application/contacts/contact_projection_repository.dart';
import 'application/conversation_favourites/conversation_favourites_store.dart';
import 'application/conversations/conversation_repository.dart';
import 'application/handles/handle_projection_repository.dart';
import 'application/health/graph_health_repository.dart';
import 'application/message_attachment_joins/message_to_attachment_projection_repository.dart';
import 'application/messages/message_graph_repository.dart';
import 'application/messages/message_projection_repository.dart';
import 'domain/status/conversation_graph_status.dart';
import 'infrastructure/repositories/attachment_projection_repository.dart';
import 'infrastructure/repositories/chat_projection_repository.dart';
import 'infrastructure/repositories/chat_summary_repository.dart';
import 'infrastructure/repositories/chat_to_handle_projection_repository.dart';
import 'infrastructure/repositories/chat_to_message_projection_repository.dart';
import 'infrastructure/repositories/contact_graph_repository.dart';
import 'infrastructure/repositories/contact_projection_repository.dart';
import 'infrastructure/repositories/conversation_graph_status_repository.dart';
import 'infrastructure/repositories/conversation_repository.dart';
import 'infrastructure/repositories/drift_graph_projection_resetter.dart';
import 'infrastructure/repositories/graph_health_repository.dart';
import 'infrastructure/repositories/handle_projection_repository.dart';
import 'infrastructure/repositories/message_graph_repository.dart';
import 'infrastructure/repositories/message_projection_repository.dart';
import 'infrastructure/repositories/message_to_attachment_projection_repository.dart';
import 'infrastructure/repositories/overlay_conversation_favourites_store.dart';

part 'feature_level_providers.g.dart';

@riverpod
Future<AttachmentProjectionRepository> attachmentProjectionRepository(
  Ref ref,
) async {
  final importDatabase = await ref.watch(
    sourceScopedImportDatabaseProvider.future,
  );
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return SqliteAttachmentProjectionRepository(
    importDatabase: importDatabase,
    graphDatabase: graphDatabase,
  );
}

@riverpod
Future<ChatProjectionRepository> chatProjectionRepository(Ref ref) async {
  final importDatabase = await ref.watch(
    sourceScopedImportDatabaseProvider.future,
  );
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return SqliteChatProjectionRepository(
    importDatabase: importDatabase,
    graphDatabase: graphDatabase,
  );
}

@riverpod
Future<ChatSummaryRepository> chatSummaryRepository(Ref ref) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  final archiveDirectory = ref.watch(attachmentArchiveDirectoryProvider);
  return SqliteChatSummaryRepository(
    graphDatabase: graphDatabase,
    archiveLookup: OverlayArchiveCompatibilityLookup(
      graphDatabase: graphDatabase,
      overlayDatabase: overlayDatabase,
      archiveDirectory: archiveDirectory,
    ),
  );
}

@riverpod
Future<ChatToHandleProjectionRepository> chatToHandleProjectionRepository(
  Ref ref,
) async {
  final importDatabase = await ref.watch(
    sourceScopedImportDatabaseProvider.future,
  );
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return SqliteChatToHandleProjectionRepository(
    importDatabase: importDatabase,
    graphDatabase: graphDatabase,
  );
}

@riverpod
Future<ChatToMessageProjectionRepository> chatToMessageProjectionRepository(
  Ref ref,
) async {
  final importDatabase = await ref.watch(
    sourceScopedImportDatabaseProvider.future,
  );
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return SqliteChatToMessageProjectionRepository(
    importDatabase: importDatabase,
    graphDatabase: graphDatabase,
  );
}

@riverpod
Future<ContactGraphRepository> contactGraphRepository(Ref ref) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return SqliteContactGraphRepository(graphDatabase: graphDatabase);
}

@riverpod
Future<ContactProjectionRepository> contactProjectionRepository(Ref ref) async {
  final importDatabase = await ref.watch(
    sourceScopedImportDatabaseProvider.future,
  );
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return SqliteContactProjectionRepository(
    importDatabase: importDatabase,
    graphDatabase: graphDatabase,
  );
}

@riverpod
Future<ConversationFavouritesStore> conversationFavouritesStore(Ref ref) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return OverlayConversationFavouritesStore(overlayDatabase: overlayDatabase);
}

@riverpod
Future<ConversationGraphStatus> conversationGraphStatusSnapshot(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final importDatabase = await ref.watch(
    sourceScopedImportDatabaseProvider.future,
  );
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return const ConversationGraphStatusRepository().readStatus(
    chatDbPath: pathsHelper.chatDBPath,
    importDatabase: importDatabase,
    graphDatabase: graphDatabase,
    importDatabaseName: sourceScopedImportDatabaseFileName,
    graphDatabaseName: conversationGraphDatabaseFileName,
    sourceId: liveChatDbSourceId,
  );
}

@riverpod
Future<ConversationRepository> conversationRepository(Ref ref) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return SqliteConversationRepository(graphDatabase: graphDatabase);
}

@riverpod
Future<GraphProjectionResetter> graphProjectionResetter(Ref ref) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return DriftGraphProjectionResetter(graphDatabase: graphDatabase);
}

@riverpod
Future<HandleProjectionRepository> handleProjectionRepository(Ref ref) async {
  final importDatabase = await ref.watch(
    sourceScopedImportDatabaseProvider.future,
  );
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return SqliteHandleProjectionRepository(
    importDatabase: importDatabase,
    graphDatabase: graphDatabase,
  );
}

@riverpod
Future<GraphHealthRepository> graphHealthRepository(Ref ref) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  final archiveDirectory = ref.watch(attachmentArchiveDirectoryProvider);
  return SqliteGraphHealthRepository(
    graphDatabase: graphDatabase,
    overlayDatabase: overlayDatabase,
    attachmentArchiveDirectory: archiveDirectory,
    historicalMessageLensDataFolderPath:
        historicalMessageLensDataFolderPathForGraphHealth,
    recoveredMessagesFolderPath: recoveredMessagesFolderPathForGraphHealth,
    recoveredMessagesAttachmentsFolderName:
        recoveredMessagesAttachmentsFolderNameForGraphHealth,
  );
}

@riverpod
Future<MessageGraphRepository> messageGraphRepository(Ref ref) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return SqliteMessageGraphRepository(graphDatabase: graphDatabase);
}

@riverpod
Future<MessageProjectionRepository> messageProjectionRepository(Ref ref) async {
  final importDatabase = await ref.watch(
    sourceScopedImportDatabaseProvider.future,
  );
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return SqliteMessageProjectionRepository(
    importDatabase: importDatabase,
    graphDatabase: graphDatabase,
  );
}

@riverpod
Future<MessageToAttachmentProjectionRepository>
messageToAttachmentProjectionRepository(Ref ref) async {
  final importDatabase = await ref.watch(
    sourceScopedImportDatabaseProvider.future,
  );
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return SqliteMessageToAttachmentProjectionRepository(
    importDatabase: importDatabase,
    graphDatabase: graphDatabase,
  );
}

const historicalMessageLensDataFolderPathForGraphHealth =
    '/Volumes/WD_ELEMENTS/DATA_FOLDER_WITH_ALL_RECENT_IMAGES_WAS_RENAMED/'
    'com.bigbenchsoftware.MessageLens';

const recoveredMessagesFolderPathForGraphHealth =
    '/Volumes/WD_ELEMENTS/DO_NOT_LOSE/iMessages_backup/'
    'Messages-bkp-2026-03-29';

const recoveredMessagesAttachmentsFolderNameForGraphHealth =
    'Attachments-2026-03-29';
