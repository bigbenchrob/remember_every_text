import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../importers/chat_message_join_importer_provider.dart';
import 'chat_message_join_import_execution_orchestrator.dart';

part 'chat_message_join_import_execution_orchestrator_provider.g.dart';

@riverpod
Future<ChatMessageJoinImportExecutionOrchestrator>
chatMessageJoinImportExecutionOrchestrator(Ref ref) async {
  final importer = await ref.watch(chatMessageJoinImporterProvider.future);

  return ChatMessageJoinImportExecutionOrchestrator(importer: importer);
}
