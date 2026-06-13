import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/attachments/infrastructure/repositories/overlay_archive_compatibility_lookup.dart';
import '../db/feature_level_providers.dart';
import 'application/chat_summaries/chat_summary_repository.dart';
import 'application/contacts/contact_graph_repository.dart';
import 'application/conversations/conversation_repository.dart';
import 'application/health/graph_health_repository.dart';
import 'application/messages/message_graph_repository.dart';
import 'infrastructure/repositories/chat_summary_repository.dart';
import 'infrastructure/repositories/contact_graph_repository.dart';
import 'infrastructure/repositories/conversation_repository.dart';
import 'infrastructure/repositories/graph_health_repository.dart';
import 'infrastructure/repositories/message_graph_repository.dart';

part 'feature_level_providers.g.dart';

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
Future<ContactGraphRepository> contactGraphRepository(Ref ref) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return SqliteContactGraphRepository(graphDatabase: graphDatabase);
}

@riverpod
Future<ConversationRepository> conversationRepository(Ref ref) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return SqliteConversationRepository(graphDatabase: graphDatabase);
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

const historicalMessageLensDataFolderPathForGraphHealth =
    '/Volumes/WD_ELEMENTS/DATA_FOLDER_WITH_ALL_RECENT_IMAGES_WAS_RENAMED/'
    'com.bigbenchsoftware.MessageLens';

const recoveredMessagesFolderPathForGraphHealth =
    '/Volumes/WD_ELEMENTS/DO_NOT_LOSE/iMessages_backup/'
    'Messages-bkp-2026-03-29';

const recoveredMessagesAttachmentsFolderNameForGraphHealth =
    'Attachments-2026-03-29';
