import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart'
    show driftConversationGraphDatabaseProvider;
import '../../infrastructure/repositories/message_graph_repository.dart';
import 'message_graph_repository.dart';

part 'message_graph_repository_provider.g.dart';

@riverpod
Future<MessageGraphRepository> messageGraphRepository(Ref ref) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return SqliteMessageGraphRepository(graphDatabase: graphDatabase);
}
