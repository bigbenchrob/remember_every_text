import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../paths/feature_level_providers.dart';
import '../source_database_opener_provider.dart';
import '../source_scoped_import_ledger_provider.dart';
import 'chat_handle_join_importer.dart';

part 'chat_handle_join_importer_provider.g.dart';

@riverpod
Future<ChatHandleJoinImporter> chatHandleJoinImporter(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final importLedger = await ref.watch(sourceScopedImportLedgerProvider.future);
  final sourceDatabaseOpener = ref.watch(sourceDatabaseOpenerProvider);

  return ChatHandleJoinImporter(
    chatDbPath: pathsHelper.chatDBPath,
    importLedger: importLedger,
    sourceDatabaseOpener: sourceDatabaseOpener,
  );
}
