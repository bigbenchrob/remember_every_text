import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../providers.dart';
import '../../../infrastructure/dev_databases/dev_import_database_provider.dart';
import '../../../infrastructure/import_ledger_chat_repository_provider.dart';
import 'chat_importer.dart';

part 'chat_importer_provider.g.dart';

@riverpod
Future<ChatImporter> chatImporter(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final shadowImportDb = await ref.watch(devImportDatabaseProvider.future);
  final importLedgerRepository = await ref.watch(
    importLedgerChatRepositoryProvider.future,
  );

  return ChatImporter(
    chatDbPath: pathsHelper.chatDBPath,
    shadowImportDb: shadowImportDb,
    importLedgerRepository: importLedgerRepository,
  );
}
