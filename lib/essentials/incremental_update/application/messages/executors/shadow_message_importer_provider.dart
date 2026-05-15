import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../providers.dart';
import '../../../infrastructure/dev_databases/dev_import_database_provider.dart';
import '../../../infrastructure/import_ledger_message_repository_provider.dart';
import 'shadow_message_importer.dart';

part 'shadow_message_importer_provider.g.dart';

@riverpod
Future<ShadowMessageImporter> shadowMessageImporter(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final shadowImportDb = await ref.watch(devImportDatabaseProvider.future);
  final importLedgerRepository = await ref.watch(
    importLedgerMessageRepositoryProvider.future,
  );

  return ShadowMessageImporter(
    chatDbPath: pathsHelper.chatDBPath,
    shadowImportDb: shadowImportDb,
    importLedgerRepository: importLedgerRepository,
  );
}
