import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/sealed_unions/chat_sync_state.dart';
import 'chat_snapshot_delta_integrator_provider.dart';
import 'chat_sync_state_integrator.dart';

part 'chat_sync_state_provider.g.dart';

@riverpod
Future<ChatSyncState> chatSyncState(Ref ref) async {
  final delta = await ref.watch(chatSnapshotDeltaIntegratorProvider.future);
  return const ChatSyncStateIntegrator().integrate(delta);
}
