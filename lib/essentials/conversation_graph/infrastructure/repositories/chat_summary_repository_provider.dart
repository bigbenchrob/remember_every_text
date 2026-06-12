import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../features/attachments/infrastructure/repositories/overlay_archive_compatibility_lookup.dart';
import '../../../db/feature_level_providers.dart';
import '../../application/chat_summaries/chat_summary_repository.dart';
import 'chat_summary_repository.dart';

part 'chat_summary_repository_provider.g.dart';

@riverpod
Future<ChatSummaryRepository> chatSummaryRepository(
  ChatSummaryRepositoryRef ref,
) async {
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
