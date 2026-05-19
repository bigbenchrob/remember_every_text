import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/chat_message_join_snapshot_delta.dart';
import '../readers/import_ledger_chat_message_join_snapshot_provider.dart';
import '../readers/live_chat_db_chat_message_join_snapshot_provider.dart';
import 'chat_message_join_snapshot_delta_integrator.dart';

part 'chat_message_join_snapshot_delta_integrator_provider.g.dart';

@riverpod
Future<ChatMessageJoinSnapshotDelta> chatMessageJoinSnapshotDeltaIntegrator(
  Ref ref,
) async {
  final source = await ref.watch(
    liveChatDbChatMessageJoinSnapshotProvider.future,
  );
  final ledger = await ref.watch(
    importLedgerChatMessageJoinSnapshotProvider.future,
  );

  return const ChatMessageJoinSnapshotDeltaIntegrator().integrate(
    source: source,
    ledger: ledger,
  );
}
