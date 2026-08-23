import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/onboarding/domain/onboarding_operation_snapshot.dart';

void main() {
  test('typed snapshot round-trips without display strings', () {
    final startedAt = DateTime.utc(2026, 8, 23, 12);
    var snapshot = OnboardingOperationSnapshot.running(
      operationId: OnboardingOperationId(
        '123e4567-e89b-42d3-a456-426614174000',
      ),
      processSessionId: OnboardingProcessSessionId(
        '123e4567-e89b-42d3-a456-426614174001',
      ),
      kind: OnboardingOperationKind.initialImport,
      stage: OnboardingOperationStage.environmentPreparation,
      observedAtUtc: startedAt,
    );
    snapshot = snapshot.transitionToStage(
      stage: OnboardingOperationStage.messageDataBuild,
      observedAtUtc: startedAt.add(const Duration(seconds: 1)),
    );
    snapshot = snapshot.observeProgress(
      observedAtUtc: startedAt.add(const Duration(seconds: 2)),
      substage: OnboardingOperationSubstage.importingMessages,
      progress: const OnboardingOperationProgress(
        completedWorkUnits: 25,
        totalWorkUnits: 100,
        lastCompletedSourceRowId: 912,
      ),
    );

    final restored = OnboardingOperationSnapshot.fromJson(snapshot.toJson());

    expect(restored.status, OnboardingOperationStatus.running);
    expect(restored.currentStage, OnboardingOperationStage.messageDataBuild);
    expect(restored.completedStages, <OnboardingOperationStage>[
      OnboardingOperationStage.environmentPreparation,
    ]);
    expect(restored.progress?.completedWorkUnits, 25);
    expect(
      restored.currentSubstage,
      OnboardingOperationSubstage.importingMessages,
    );
    expect(restored.progress?.lastCompletedSourceRowId, 912);
    expect(restored.progressRevision, 3);
    expect(restored.toJson().toString(), isNot(contains('Importing messages')));
  });

  test('interrupted and failed remain distinct durable states', () {
    final startedAt = DateTime.utc(2026, 8, 23, 12);
    final running = OnboardingOperationSnapshot.running(
      operationId: OnboardingOperationId(
        '123e4567-e89b-42d3-a456-426614174000',
      ),
      processSessionId: OnboardingProcessSessionId(
        '123e4567-e89b-42d3-a456-426614174001',
      ),
      kind: OnboardingOperationKind.initialImport,
      stage: OnboardingOperationStage.messageDataBuild,
      observedAtUtc: startedAt,
    );
    final interrupted = running.interrupt(
      observedAtUtc: startedAt.add(const Duration(seconds: 1)),
    );
    final failed = interrupted.fail(
      failure: OnboardingOperationFailure(
        category: OnboardingOperationFailureCategory.messageDataBuild,
        occurredAtUtc: startedAt.add(const Duration(seconds: 2)),
        summary: 'A bounded failure.',
        recoveryDisposition:
            OnboardingOperationRecoveryDisposition.retryFromSafeBoundary,
      ),
    );

    expect(interrupted.status, OnboardingOperationStatus.interrupted);
    expect(interrupted.failure, isNull);
    expect(failed.status, OnboardingOperationStatus.failed);
    expect(
      failed.failure?.category,
      OnboardingOperationFailureCategory.messageDataBuild,
    );
  });
}
