import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import './import_ledger_message_repository.dart';
import 'dev_databases/dev_import_database_provider.dart';

part 'import_ledger_message_repository_provider.g.dart';

@riverpod
Future<ImportLedgerMessageRepository> importLedgerMessageRepository(
  Ref ref,
) async {
  final ledgerDb = await ref.watch(devImportDatabaseProvider.future);
  return ImportLedgerMessageRepository(ledgerDb: ledgerDb);
}
