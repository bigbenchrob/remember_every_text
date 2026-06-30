import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'message_graph_reader.dart';
import 'message_graph_repository_provider.dart';

part 'message_graph_reader_provider.g.dart';

@riverpod
Future<MessageGraphReader> messageGraphReader(Ref ref) async {
  final repository = await ref.watch(messageGraphRepositoryProvider.future);
  return MessageGraphReader(repository: repository);
}
