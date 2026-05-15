import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/import_ledger_chat_repository_provider.dart';
import 'import_ledger_chat_snapshot_reader.dart';

part 'import_ledger_chat_snapshot_reader_provider.g.dart';

@riverpod
Future<ImportLedgerChatSnapshotReader> importLedgerChatSnapshotReader(
  Ref ref,
) async {
  final repository = await ref.watch(importLedgerChatRepositoryProvider.future);
  return ImportLedgerChatSnapshotReader(repository: repository);
}
