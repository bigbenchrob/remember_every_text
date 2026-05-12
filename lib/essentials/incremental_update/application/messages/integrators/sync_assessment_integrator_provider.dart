import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/sealed_unions/sync_state.dart';
import 'snapshot_delta_integrator_provider.dart';
import 'sync_assessment_integrator.dart';

part 'sync_assessment_integrator_provider.g.dart';

@riverpod
Future<MessageSyncState> messageSyncState(Ref ref) async {
  final snapshotDelta = await ref.watch(snapshotDeltaIntegratorProvider.future);
  const integrator = MessageSyncAssessmentIntegrator();
  return integrator.integrate(snapshotDelta);
}
