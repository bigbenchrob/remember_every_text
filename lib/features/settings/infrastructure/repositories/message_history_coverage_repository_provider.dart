import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import 'message_history_coverage_repository.dart';

part 'message_history_coverage_repository_provider.g.dart';

@riverpod
Future<MessageHistoryCoverageRepository> messageHistoryCoverageRepository(
  MessageHistoryCoverageRepositoryRef ref,
) async {
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return MessageHistoryCoverageRepository(graphDb: graphDb);
}
