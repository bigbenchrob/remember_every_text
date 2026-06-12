import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db/feature_level_providers.dart';
import 'application/graph_message_search.dart';
import 'application/search_service.dart';
import 'infrastructure/repositories/graph_search_repository.dart';

part 'feature_level_providers.g.dart';

@riverpod
SearchService searchService(SearchServiceRef ref) {
  return SearchService(ref: ref);
}

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
