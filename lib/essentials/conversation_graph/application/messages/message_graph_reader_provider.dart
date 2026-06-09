import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../infrastructure/repositories/message_graph_repository.dart';
import 'message_graph_reader.dart';

part 'message_graph_reader_provider.g.dart';

@riverpod
Future<MessageGraphReader> messageGraphReader(Ref ref) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return MessageGraphReader(
    repository: SqliteMessageGraphRepository(graphDatabase: graphDatabase),
  );
}
