import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'message_snapshot_delta_refresh_orchestrator.dart';

part 'message_snapshot_delta_refresh_orchestrator_provider.g.dart';

@riverpod
MessageSnapshotDeltaRefreshOrchestrator messageSnapshotDeltaRefreshOrchestrator(
  Ref ref,
) {
  return MessageSnapshotDeltaRefreshOrchestrator(ref);
}
