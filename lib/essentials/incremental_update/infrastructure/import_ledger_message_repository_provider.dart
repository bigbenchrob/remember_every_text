import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../db/feature_level_providers.dart';
import './import_ledger_message_repository.dart';

part 'import_ledger_message_repository_provider.g.dart';

@riverpod
Future<ImportLedgerMessageRepository> importLedgerMessageRepository(
  Ref ref,
) async {
  final ledgerDb = await ref.watch(sqfliteImportDatabaseProvider.future);
  return ImportLedgerMessageRepository(ledgerDb: ledgerDb);
}
