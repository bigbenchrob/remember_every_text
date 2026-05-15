import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/chat_snapshot_delta.dart';
import '../readers/import_ledger_chat_snapshot_provider.dart';
import '../readers/live_chat_db_chat_snapshot_provider.dart';
import 'chat_snapshot_delta_integrator.dart';

part 'chat_snapshot_delta_integrator_provider.g.dart';

@riverpod
Future<ChatSnapshotDelta> chatSnapshotDeltaIntegrator(Ref ref) async {
  final liveSnapshot = await ref.watch(liveChatDbChatSnapshotProvider.future);
  final ledgerSnapshot = await ref.watch(
    importLedgerChatSnapshotProvider.future,
  );

  return const ChatSnapshotDeltaIntegrator().integrate(
    source: liveSnapshot,
    ledger: ledgerSnapshot,
  );
}
