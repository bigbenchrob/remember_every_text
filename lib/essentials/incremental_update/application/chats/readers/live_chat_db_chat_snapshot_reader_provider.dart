import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/chat_db_chat_repository_provider.dart';
import 'live_chat_db_chat_snapshot_reader.dart';

part 'live_chat_db_chat_snapshot_reader_provider.g.dart';

@riverpod
Future<LiveChatDbChatSnapshotReader> liveChatDbChatSnapshotReader(
  Ref ref,
) async {
  final repository = await ref.watch(chatDbChatRepositoryProvider.future);
  return LiveChatDbChatSnapshotReader(repository: repository);
}
