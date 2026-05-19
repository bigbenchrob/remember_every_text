import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../chat_message_joins/orchestrators/chat_message_join_stage_controller_provider.dart';
import '../../chats/orchestrators/chat_stage_controller_provider.dart';
import '../../handles/orchestrators/handle_stage_controller_provider.dart';
import '../../messages/integrators/import_decision_provider.dart';
import '../../messages/orchestrators/comparative_validation_stage_controller_provider.dart';
import '../../messages/orchestrators/message_import_stage_controller_provider.dart';
import '../../messages/orchestrators/message_migration_stage_controller_provider.dart';
import 'pipeline_orchestrator.dart';

part 'pipeline_orchestrator_provider.g.dart';

@riverpod
PipelineOrchestrator pipelineOrchestrator(Ref ref) {
  return PipelineOrchestrator(
    runHandleStage: () =>
        ref.read(handleStageControllerProvider).refreshAndMaybeExecute(),
    runChatStage: () =>
        ref.read(chatStageControllerProvider).refreshAndMaybeExecute(),
    runMessageImportStage: () =>
        ref.read(messageImportStageControllerProvider).refreshAndMaybeExecute(),
    runChatMessageJoinStage: () => ref
        .read(chatMessageJoinStageControllerProvider)
        .refreshAndMaybeExecute(),
    runMessageMigrationStage: () => ref
        .read(messageMigrationStageControllerProvider)
        .refreshAndMaybeExecute(),
    runComparativeValidationStage: () => ref
        .read(comparativeValidationStageControllerProvider)
        .refreshAndReport(),
    readCurrentImportDecision: () => ref.read(importDecisionProvider.future),
  );
}
