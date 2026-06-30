import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../infrastructure/repositories/filesystem_conversation_graph_status_log_writer.dart';
import 'conversation_graph_status_log_writer.dart';

part 'conversation_graph_status_log_writer_provider.g.dart';

@riverpod
ConversationGraphStatusLogWriter conversationGraphStatusLogWriter(Ref ref) {
  return const FilesystemConversationGraphStatusLogWriter();
}
