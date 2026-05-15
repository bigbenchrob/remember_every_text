import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/sealed_unions/handle_import_decision.dart';
import 'handle_import_decision_integrator.dart';
import 'handle_sync_state_provider.dart';

part 'handle_import_decision_provider.g.dart';

@riverpod
Future<HandleImportDecision> handleImportDecision(Ref ref) async {
  final state = await ref.watch(handleSyncStateProvider.future);
  return const HandleImportDecisionIntegrator().integrate(state);
}
