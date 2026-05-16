import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../importers/chat_importer_provider.dart';
import 'chat_import_execution_orchestrator.dart';

part 'chat_import_execution_orchestrator_provider.g.dart';

@riverpod
Future<ChatImportExecutionOrchestrator> chatImportExecutionOrchestrator(
  Ref ref,
) async {
  final importer = await ref.watch(chatImporterProvider.future);

  return ChatImportExecutionOrchestrator(importer: importer);
}
