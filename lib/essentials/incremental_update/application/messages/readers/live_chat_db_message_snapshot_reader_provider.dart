import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/chat_db_message_repository_provider.dart';
import './live_chat_db_message_snapshot_reader.dart';

part 'live_chat_db_message_snapshot_reader_provider.g.dart';

@riverpod
Future<LiveChatDbMessageSnapshotReader> liveChatDbMessageSnapshotReader(
  Ref ref,
) async {
  final repository = await ref.watch(chatDbMessageRepositoryProvider.future);
  final reader = LiveChatDbMessageSnapshotReader(repository: repository);
  return reader;
}
