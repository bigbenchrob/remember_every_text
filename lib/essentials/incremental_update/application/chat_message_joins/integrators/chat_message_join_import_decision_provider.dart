import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/sealed_unions/chat_message_join_import_decision.dart';
import 'chat_message_join_import_decision_integrator.dart';
import 'chat_message_join_sync_state_provider.dart';

part 'chat_message_join_import_decision_provider.g.dart';

@riverpod
Future<ChatMessageJoinImportDecision> chatMessageJoinImportDecision(
  Ref ref,
) async {
  final state = await ref.watch(chatMessageJoinSyncStateProvider.future);
  return const ChatMessageJoinImportDecisionIntegrator().integrate(state);
}
