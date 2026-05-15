import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/chat_snapshot.dart';
import 'live_chat_db_chat_snapshot_reader_provider.dart';

part 'live_chat_db_chat_snapshot_provider.g.dart';

@riverpod
Future<ChatSnapshot> liveChatDbChatSnapshot(Ref ref) async {
  final reader = await ref.watch(liveChatDbChatSnapshotReaderProvider.future);
  return reader.read();
}
