import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../features/attachments/feature_level_providers.dart'
    show graphAttachmentArchiveLookupProvider;
import '../../../db/feature_level_providers/persistent_database_providers.dart'
    show driftConversationGraphDatabaseProvider;
import '../../infrastructure/repositories/chat_summary_repository.dart';
import 'chat_summary_repository.dart';

part 'chat_summary_repository_provider.g.dart';

@riverpod
Future<ChatSummaryRepository> chatSummaryRepository(Ref ref) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final archiveLookup = await ref.watch(
    graphAttachmentArchiveLookupProvider.future,
  );
  return SqliteChatSummaryRepository(
    graphDatabase: graphDatabase,
    archiveLookup: archiveLookup,
  );
}
