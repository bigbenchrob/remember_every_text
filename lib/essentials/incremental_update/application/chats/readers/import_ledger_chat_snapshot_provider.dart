import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/chat_snapshot.dart';
import 'import_ledger_chat_snapshot_reader_provider.dart';

part 'import_ledger_chat_snapshot_provider.g.dart';

@riverpod
Future<ChatSnapshot> importLedgerChatSnapshot(Ref ref) async {
  final reader = await ref.watch(importLedgerChatSnapshotReaderProvider.future);
  return reader.read();
}
