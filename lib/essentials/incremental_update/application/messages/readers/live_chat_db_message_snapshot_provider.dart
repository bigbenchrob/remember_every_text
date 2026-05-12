import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/live_chat_db_message_snapshot.dart';
import 'live_chat_db_message_snapshot_reader_provider.dart';

part 'live_chat_db_message_snapshot_provider.g.dart';

@riverpod
Future<LiveChatDbMessageSnapshot> liveChatDbMessageSnapshot(Ref ref) async {
  final reader = await ref.watch(
    liveChatDbMessageSnapshotReaderProvider.future,
  );
  return reader.read();
}
