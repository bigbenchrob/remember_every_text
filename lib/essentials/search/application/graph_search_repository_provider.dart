import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../db/feature_level_providers/persistent_database_providers.dart'
    show driftConversationGraphDatabaseProvider, overlayDatabaseProvider;
import '../infrastructure/repositories/graph_search_repository.dart';
import 'graph_message_search.dart';

part 'graph_search_repository_provider.g.dart';

@riverpod
Future<GraphSearchRepository> graphSearchRepository(
  GraphSearchRepositoryRef ref,
) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return SqliteGraphSearchRepository(
    graphDatabase: graphDatabase,
    overlayDatabase: overlayDatabase,
  );
}
