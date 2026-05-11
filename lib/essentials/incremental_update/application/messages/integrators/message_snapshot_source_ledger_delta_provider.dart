import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/message_snapshot_source_ledger_delta.dart';
import '../readers/import_ledger_message_snapshot_reader_provider.dart';
import '../readers/live_chat_db_message_snapshot_reader_provider.dart';
import 'message_snapshot_source_ledger_delta_integrator.dart';

part 'message_snapshot_source_ledger_delta_provider.g.dart';

@riverpod
Future<MessageSnapshotSourceLedgerDelta> messageSnapshotSourceLedgerDelta(
  Ref ref,
) async {
  final liveReader = await ref.watch(
    liveChatDbMessageSnapshotReaderProvider.future,
  );

  final ledgerReader = await ref.watch(
    importLedgerMessageSnapshotReaderProvider.future,
  );

  final liveSnapshot = await liveReader.read();
  final ledgerSnapshot = await ledgerReader.read();

  return const MessageSnapshotSourceLedgerDeltaIntegrator().integrate(
    source: liveSnapshot,
    ledger: ledgerSnapshot,
  );
}
