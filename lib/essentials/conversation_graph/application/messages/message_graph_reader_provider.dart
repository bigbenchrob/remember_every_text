import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../feature_level_providers.dart';
import 'message_graph_reader.dart';

part 'message_graph_reader_provider.g.dart';

@riverpod
Future<MessageGraphReader> messageGraphReader(Ref ref) async {
  final repository = await ref.watch(messageGraphRepositoryProvider.future);
  return MessageGraphReader(repository: repository);
}
