import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/sealed_unions/chat_import_decision.dart';
import 'chat_import_decision_integrator.dart';
import 'chat_sync_state_provider.dart';

part 'chat_import_decision_provider.g.dart';

@riverpod
Future<ChatImportDecision> chatImportDecision(Ref ref) async {
  final state = await ref.watch(chatSyncStateProvider.future);
  return const ChatImportDecisionIntegrator().integrate(state);
}
