import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dev_databases/dev_import_database_provider.dart';
import 'import_ledger_chat_message_join_repository.dart';

part 'import_ledger_chat_message_join_repository_provider.g.dart';

@riverpod
Future<ImportLedgerChatMessageJoinRepository>
importLedgerChatMessageJoinRepository(Ref ref) async {
  final ledgerDb = await ref.watch(devImportDatabaseProvider.future);
  return ImportLedgerChatMessageJoinRepository(ledgerDb: ledgerDb);
}
