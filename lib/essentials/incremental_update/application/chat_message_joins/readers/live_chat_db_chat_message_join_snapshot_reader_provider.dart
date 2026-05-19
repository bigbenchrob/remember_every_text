import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/chat_db_chat_message_join_repository_provider.dart';
import 'live_chat_db_chat_message_join_snapshot_reader.dart';

part 'live_chat_db_chat_message_join_snapshot_reader_provider.g.dart';

@riverpod
Future<LiveChatDbChatMessageJoinSnapshotReader>
liveChatDbChatMessageJoinSnapshotReader(Ref ref) async {
  final repository = await ref.watch(
    chatDbChatMessageJoinRepositoryProvider.future,
  );
  return LiveChatDbChatMessageJoinSnapshotReader(repository: repository);
}
