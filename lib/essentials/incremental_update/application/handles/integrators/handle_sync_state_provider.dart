import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/sealed_unions/handle_sync_state.dart';
import 'handle_snapshot_delta_integrator_provider.dart';
import 'handle_sync_state_integrator.dart';

part 'handle_sync_state_provider.g.dart';

@riverpod
Future<HandleSyncState> handleSyncState(Ref ref) async {
  final delta = await ref.watch(handleSnapshotDeltaIntegratorProvider.future);
  return const HandleSyncStateIntegrator().integrate(delta);
}
