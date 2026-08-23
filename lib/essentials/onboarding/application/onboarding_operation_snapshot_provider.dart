import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../db/feature_level_providers.dart' show overlayDatabaseProvider;
import '../domain/onboarding_operation_snapshot.dart';
import '../infrastructure/persistence/overlay_onboarding_operation_snapshot_store.dart';
import 'onboarding_operation_snapshot_controller.dart';

part 'onboarding_operation_snapshot_provider.g.dart';

@Riverpod(keepAlive: true)
OnboardingProcessSessionId onboardingProcessSessionId(Ref ref) {
  return OnboardingProcessSessionId(const Uuid().v4());
}

@Riverpod(keepAlive: true)
Future<OnboardingOperationSnapshotController> onboardingOperationController(
  Ref ref,
) async {
  final controller = OnboardingOperationSnapshotController(
    store: OverlayOnboardingOperationSnapshotStore(
      overlayDatabase: ref.watch(overlayDatabaseProvider.future),
    ),
    processSessionId: ref.watch(onboardingProcessSessionIdProvider),
  );
  await controller.initialize();
  ref.onDispose(controller.dispose);
  return controller;
}

@Riverpod(keepAlive: true)
Stream<OnboardingOperationSnapshot> onboardingOperationSnapshot(
  Ref ref,
) async* {
  final controller = await ref.watch(
    onboardingOperationControllerProvider.future,
  );
  yield controller.current;
  yield* controller.changes;
}
