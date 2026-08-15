import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider;
import '../../infrastructure/repositories/filesystem_conversation_graph_status_log_writer.dart';
import 'conversation_graph_status_log_writer.dart';

part 'conversation_graph_status_log_writer_provider.g.dart';

@riverpod
ConversationGraphStatusLogWriter conversationGraphStatusLogWriter(Ref ref) {
  final authority = ref.watch(archiveAccessAuthorityProvider);
  return FilesystemConversationGraphStatusLogWriter(
    logsDirectory: Directory(
      authority.resolvePath('application_logs/conversation_graph_status'),
    ),
  );
}
