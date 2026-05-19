import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/sealed_unions/chat_message_join_sync_state.dart';
import 'chat_message_join_snapshot_delta_integrator_provider.dart';
import 'chat_message_join_sync_state_integrator.dart';

part 'chat_message_join_sync_state_provider.g.dart';

@riverpod
Future<ChatMessageJoinSyncState> chatMessageJoinSyncState(Ref ref) async {
  final delta = await ref.watch(
    chatMessageJoinSnapshotDeltaIntegratorProvider.future,
  );
  return const ChatMessageJoinSyncStateIntegrator().integrate(delta);
}
