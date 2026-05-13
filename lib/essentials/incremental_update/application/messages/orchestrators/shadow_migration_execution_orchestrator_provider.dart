import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../executors/shadow_message_migration_executor_provider.dart';
import 'shadow_migration_execution_orchestrator.dart';

part 'shadow_migration_execution_orchestrator_provider.g.dart';

@riverpod
Future<ShadowMigrationExecutionOrchestrator>
shadowMigrationExecutionOrchestrator(Ref ref) async {
  final executor = await ref.watch(
    shadowMessageMigrationExecutorProvider.future,
  );

  return ShadowMigrationExecutionOrchestrator(executor: executor);
}
