import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../executors/shadow_message_import_executor_provider.dart';
import 'shadow_import_execution_orchestrator.dart';

part 'shadow_import_execution_orchestrator_provider.g.dart';

@riverpod
Future<ShadowImportExecutionOrchestrator> shadowImportExecutionOrchestrator(
  Ref ref,
) async {
  final executor = await ref.watch(shadowMessageImportExecutorProvider.future);

  return ShadowImportExecutionOrchestrator(executor: executor);
}
