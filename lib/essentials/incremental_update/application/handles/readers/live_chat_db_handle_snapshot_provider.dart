import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/handle_snapshot.dart';
import 'live_chat_db_handle_snapshot_reader_provider.dart';

part 'live_chat_db_handle_snapshot_provider.g.dart';

@riverpod
Future<HandleSnapshot> liveChatDbHandleSnapshot(Ref ref) async {
  final reader = await ref.watch(liveChatDbHandleSnapshotReaderProvider.future);
  return reader.read();
}
