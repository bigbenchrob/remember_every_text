import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../importers/handle_importer_provider.dart';
import 'handle_import_execution_orchestrator.dart';

part 'handle_import_execution_orchestrator_provider.g.dart';

@riverpod
Future<HandleImportExecutionOrchestrator> handleImportExecutionOrchestrator(
  Ref ref,
) async {
  final importer = await ref.watch(handleImporterProvider.future);

  return HandleImportExecutionOrchestrator(importer: importer);
}
