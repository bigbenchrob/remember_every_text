import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../application/settings_cassette_spec/resolver_tools/spam_handles_repository.dart';
import 'graph_spam_handles_repository.dart';
import 'handle_visibility_store_provider.dart';

part 'spam_handles_repository_provider.g.dart';

@riverpod
Future<SpamHandlesRepository> spamHandlesRepository(
  SpamHandlesRepositoryRef ref,
) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final visibilityStore = await ref.watch(handleVisibilityStoreProvider.future);

  return GraphSpamHandlesRepository(
    graphDatabase: graphDatabase,
    visibilityStore: visibilityStore,
  );
}
