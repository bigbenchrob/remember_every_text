import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_operation_snapshot.dart';
import 'package:remember_this_text/essentials/onboarding/infrastructure/persistence/overlay_onboarding_operation_snapshot_store.dart';

void main() {
  test(
    'stores snapshot in existing overlay settings without schema changes',
    () async {
      final database = OverlayDatabase(NativeDatabase.memory());
      final store = OverlayOnboardingOperationSnapshotStore(
        overlayDatabase: Future<OverlayDatabase>.value(database),
      );
      addTearDown(database.close);
      final snapshot = OnboardingOperationSnapshot.running(
        operationId: OnboardingOperationId(
          '123e4567-e89b-42d3-a456-426614174000',
        ),
        processSessionId: OnboardingProcessSessionId(
          '123e4567-e89b-42d3-a456-426614174001',
        ),
        kind: OnboardingOperationKind.initialImport,
        stage: OnboardingOperationStage.environmentPreparation,
        observedAtUtc: DateTime.utc(2026, 8, 23),
      );

      await store.save(snapshot);
      final restored = await store.load();

      expect(restored?.operationId, snapshot.operationId);
      expect(restored?.status, OnboardingOperationStatus.running);
      expect(
        await database.readOverlaySetting(
          OverlayOnboardingOperationSnapshotStore.settingKey,
        ),
        isNotEmpty,
      );
    },
  );
}
