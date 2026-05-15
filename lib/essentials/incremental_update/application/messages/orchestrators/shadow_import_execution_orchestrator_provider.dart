import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../executors/shadow_message_importer_provider.dart';
import 'shadow_import_execution_orchestrator.dart';

part 'shadow_import_execution_orchestrator_provider.g.dart';

@riverpod
Future<ShadowImportExecutionOrchestrator> shadowImportExecutionOrchestrator(
  Ref ref,
) async {
  final importer = await ref.watch(shadowMessageImporterProvider.future);

  return ShadowImportExecutionOrchestrator(importer: importer);
}
