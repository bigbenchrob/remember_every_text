import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/import_ledger_chat_message_join_repository_provider.dart';
import 'import_ledger_chat_message_join_snapshot_reader.dart';

part 'import_ledger_chat_message_join_snapshot_reader_provider.g.dart';

@riverpod
Future<ImportLedgerChatMessageJoinSnapshotReader>
importLedgerChatMessageJoinSnapshotReader(Ref ref) async {
  final repository = await ref.watch(
    importLedgerChatMessageJoinRepositoryProvider.future,
  );
  return ImportLedgerChatMessageJoinSnapshotReader(repository: repository);
}
