import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../paths/feature_level_providers.dart' show pathsHelperProvider;
import '../source_database_opener_provider.dart';
import '../source_scoped_import_ledger_provider.dart';
import 'chat_importer.dart';

part 'chat_importer_provider.g.dart';

@riverpod
Future<ChatImporter> chatImporter(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final importLedger = await ref.watch(sourceScopedImportLedgerProvider.future);
  final sourceDatabaseOpener = ref.watch(sourceDatabaseOpenerProvider);

  return ChatImporter(
    chatDbPath: pathsHelper.chatDBPath,
    importLedger: importLedger,
    sourceDatabaseOpener: sourceDatabaseOpener,
  );
}
