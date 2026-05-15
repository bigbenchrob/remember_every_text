import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/handle_snapshot_delta.dart';
import '../readers/import_ledger_handle_snapshot_provider.dart';
import '../readers/live_chat_db_handle_snapshot_provider.dart';
import 'handle_snapshot_delta_integrator.dart';

part 'handle_snapshot_delta_integrator_provider.g.dart';

@riverpod
Future<HandleSnapshotDelta> handleSnapshotDeltaIntegrator(Ref ref) async {
  final liveSnapshot = await ref.watch(liveChatDbHandleSnapshotProvider.future);
  final ledgerSnapshot = await ref.watch(
    importLedgerHandleSnapshotProvider.future,
  );

  return const HandleSnapshotDeltaIntegrator().integrate(
    source: liveSnapshot,
    ledger: ledgerSnapshot,
  );
}
