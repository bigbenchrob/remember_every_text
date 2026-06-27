import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../providers.dart';
import '../source_database_opener_provider.dart';
import '../source_scoped_import_ledger_provider.dart';
import 'message_importer.dart';

part 'message_importer_provider.g.dart';

@riverpod
Future<MessageImporter> messageImporter(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final importLedger = await ref.watch(sourceScopedImportLedgerProvider.future);
  final sourceDatabaseOpener = ref.watch(sourceDatabaseOpenerProvider);

  return MessageImporter(
    chatDbPath: pathsHelper.chatDBPath,
    importLedger: importLedger,
    sourceDatabaseOpener: sourceDatabaseOpener,
  );
}
