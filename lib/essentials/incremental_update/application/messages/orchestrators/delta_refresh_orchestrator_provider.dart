import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'delta_refresh_orchestrator.dart';

part 'delta_refresh_orchestrator_provider.g.dart';

@Riverpod(keepAlive: true)
DeltaRefreshOrchestrator deltaRefreshOrchestrator(Ref ref) {
  final orchestrator = DeltaRefreshOrchestrator(ref);
  ref.onDispose(orchestrator.dispose);
  return orchestrator;
}
