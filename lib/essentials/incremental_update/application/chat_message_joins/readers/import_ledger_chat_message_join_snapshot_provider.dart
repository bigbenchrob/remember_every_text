import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/chat_message_join_snapshot.dart';
import 'import_ledger_chat_message_join_snapshot_reader_provider.dart';

part 'import_ledger_chat_message_join_snapshot_provider.g.dart';

@riverpod
Future<ChatMessageJoinSnapshot> importLedgerChatMessageJoinSnapshot(
  Ref ref,
) async {
  final reader = await ref.watch(
    importLedgerChatMessageJoinSnapshotReaderProvider.future,
  );
  return reader.read();
}
