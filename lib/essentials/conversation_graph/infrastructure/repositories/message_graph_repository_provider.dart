import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../application/messages/message_graph_repository.dart';
import 'message_graph_repository.dart';

part 'message_graph_repository_provider.g.dart';

@riverpod
Future<MessageGraphRepository> messageGraphRepository(
  MessageGraphRepositoryRef ref,
) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return SqliteMessageGraphRepository(graphDatabase: graphDatabase);
}
