import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../providers.dart';
import '../../feature_level_providers.dart';
import 'handle_importer.dart';

part 'handle_importer_provider.g.dart';

@riverpod
Future<HandleImporter> handleImporter(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final importLedger = await ref.watch(sourceScopedImportLedgerProvider.future);
  final sourceDatabaseOpener = ref.watch(sourceDatabaseOpenerProvider);

  return HandleImporter(
    chatDbPath: pathsHelper.chatDBPath,
    importLedger: importLedger,
    sourceDatabaseOpener: sourceDatabaseOpener,
  );
}
