import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/db/feature_level_providers.dart'
    show driftConversationGraphDatabaseProvider;
import '../../../infrastructure/repositories/graph_spam_handles_repository.dart';
import 'handle_visibility_store_provider.dart';
import 'spam_handles_repository.dart';

part 'spam_handles_repository_provider.g.dart';

@riverpod
Future<SpamHandlesRepository> spamHandlesRepository(Ref ref) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final visibilityStore = await ref.watch(handleVisibilityStoreProvider.future);

  return GraphSpamHandlesRepository(
    graphDatabase: graphDatabase,
    visibilityStore: visibilityStore,
  );
}
