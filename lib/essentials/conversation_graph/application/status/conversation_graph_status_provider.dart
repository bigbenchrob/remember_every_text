import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/status/conversation_graph_status.dart';
import '../../infrastructure/repositories/conversation_graph_status_repository_provider.dart';

export '../../domain/status/conversation_graph_status.dart';

part 'conversation_graph_status_provider.g.dart';

@riverpod
Future<ConversationGraphStatus> conversationGraphStatus(Ref ref) async {
  return ref.watch(conversationGraphStatusSnapshotProvider.future);
}
