import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'sync_state_polling_orchestrator.dart';

part 'sync_state_polling_orchestrator_provider.g.dart';

@Riverpod(keepAlive: true)
SyncStatePollingOrchestrator deltaRefreshOrchestrator(Ref ref) {
  final orchestrator = SyncStatePollingOrchestrator(ref);
  ref.onDispose(orchestrator.dispose);
  return orchestrator;
}
