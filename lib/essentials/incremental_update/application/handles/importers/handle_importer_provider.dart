import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../providers.dart';
import '../../../infrastructure/dev_databases/dev_import_database_provider.dart';
import '../../../infrastructure/import_ledger_handle_repository_provider.dart';
import 'handle_importer.dart';

part 'handle_importer_provider.g.dart';

@riverpod
Future<HandleImporter> handleImporter(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final shadowImportDb = await ref.watch(devImportDatabaseProvider.future);
  final importLedgerRepository = await ref.watch(
    importLedgerHandleRepositoryProvider.future,
  );

  return HandleImporter(
    chatDbPath: pathsHelper.chatDBPath,
    shadowImportDb: shadowImportDb,
    importLedgerRepository: importLedgerRepository,
  );
}
