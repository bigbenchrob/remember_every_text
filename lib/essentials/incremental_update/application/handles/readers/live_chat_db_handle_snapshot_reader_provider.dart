import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/chat_db_handle_repository_provider.dart';
import 'live_chat_db_handle_snapshot_reader.dart';

part 'live_chat_db_handle_snapshot_reader_provider.g.dart';

@riverpod
Future<LiveChatDbHandleSnapshotReader> liveChatDbHandleSnapshotReader(
  Ref ref,
) async {
  final repository = await ref.watch(chatDbHandleRepositoryProvider.future);
  return LiveChatDbHandleSnapshotReader(repository: repository);
}
