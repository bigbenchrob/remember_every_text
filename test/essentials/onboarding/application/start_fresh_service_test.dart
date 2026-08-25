import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/archive_environment/application/archive_mutation_coordinator_provider.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_mutation_operation.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart'
    show admittedArchiveAccessAuthorityProvider;
import 'package:remember_this_text/essentials/onboarding/application/message_data_reset_service.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_lens_installation_evidence_reader.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_lens_installation_state_classifier.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_failure_store.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_operation_snapshot_controller.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_operation_snapshot_store.dart';
import 'package:remember_this_text/essentials/onboarding/application/start_fresh_service.dart';
import 'package:remember_this_text/essentials/onboarding/domain/message_lens_installation_state.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_operation_snapshot.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/schedule_run.dart';
import 'package:remember_this_text/essentials/presence/domain/repositories/presence_schedule_run_maintenance.dart';

import '../../../test_support/test_archive_fixture.dart';

void main() {
  test('Start Fresh runs under authority and verifies virgin state', () async {
    final fixture = await TestArchiveFixture.create(
      prefix: 'start_fresh_service_test_',
    );
    addTearDown(fixture.dispose);
    final container = ProviderContainer(
      overrides: [
        admittedArchiveAccessAuthorityProvider.overrideWithValue(
          fixture.authority,
        ),
      ],
    );
    addTearDown(container.dispose);

    final snapshotStore = _MemorySnapshotStore();
    final operationController = OnboardingOperationSnapshotController(
      store: snapshotStore,
      processSessionId: OnboardingProcessSessionId(
        '123e4567-e89b-42d3-a456-426614174021',
      ),
    );
    await operationController.initialize();
    addTearDown(operationController.dispose);
    final resetService = _FakeResetService();
    final failureStore = _FakeFailureStore();
    const evidenceReader = _VirginEvidenceReader();
    var refreshCount = 0;

    final service = StartFreshServiceImpl(
      archiveRootPath: fixture.root.path,
      requiredSourcesScheduleId: 42,
      readCurrentState: () async {
        return const MessageLensInstallationState(
          kind: MessageLensInstallationStateKind.abandoned,
          reason: 'test abandoned state',
        );
      },
      runWithMutationAuthority: (action) {
        return container
            .read(archiveMutationCoordinatorProvider.notifier)
            .runWithCapability<StartFreshResult>(
              operation: ArchiveMutationOperation.startFresh,
              ownerLabel: 'test-start-fresh',
              action: action,
            );
      },
      messageDataResetService: resetService,
      operationController: operationController,
      failureStore: failureStore,
      presenceRepository: const _MissingDefinitionMaintenance(),
      evidenceReader: evidenceReader,
      classifier: const MessageLensInstallationStateClassifier(),
      refreshAfterReset: () {
        refreshCount += 1;
      },
    );

    final result = await service.startFresh();

    expect(result.verifiedState.kind, MessageLensInstallationStateKind.virgin);
    expect(resetService.callCount, 1);
    expect(failureStore.importClearCount, 1);
    expect(failureStore.graphClearCount, 1);
    expect(snapshotStore.saved.single.status, OnboardingOperationStatus.idle);
    expect(refreshCount, 1);
    expect(
      container.read(archiveMutationCoordinatorProvider).isLocked,
      isFalse,
    );
  });

  test('completed installation cannot invoke Start Fresh', () async {
    final snapshotStore = _MemorySnapshotStore();
    final operationController = OnboardingOperationSnapshotController(
      store: snapshotStore,
      processSessionId: OnboardingProcessSessionId(
        '123e4567-e89b-42d3-a456-426614174022',
      ),
    );
    await operationController.initialize();
    addTearDown(operationController.dispose);
    final resetService = _FakeResetService();

    final service = StartFreshServiceImpl(
      archiveRootPath: '/not-used',
      requiredSourcesScheduleId: 42,
      readCurrentState: () async {
        return const MessageLensInstallationState(
          kind: MessageLensInstallationStateKind.completed,
          reason: 'healthy',
        );
      },
      runWithMutationAuthority: (_) async {
        throw StateError('authority must not be requested');
      },
      messageDataResetService: resetService,
      operationController: operationController,
      failureStore: _FakeFailureStore(),
      presenceRepository: const _MissingDefinitionMaintenance(),
      evidenceReader: const _VirginEvidenceReader(),
      classifier: const MessageLensInstallationStateClassifier(),
      refreshAfterReset: () {},
    );

    await expectLater(service.startFresh(), throwsStateError);
    expect(resetService.callCount, 0);
  });

  test(
    'completed installation can invoke only the advanced reset entry point',
    () async {
      final fixture = await TestArchiveFixture.create(
        prefix: 'advanced_start_fresh_service_test_',
      );
      addTearDown(fixture.dispose);
      final container = ProviderContainer(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWithValue(
            fixture.authority,
          ),
        ],
      );
      addTearDown(container.dispose);
      final operationController = OnboardingOperationSnapshotController(
        store: _MemorySnapshotStore(),
        processSessionId: OnboardingProcessSessionId(
          '123e4567-e89b-42d3-a456-426614174025',
        ),
      );
      await operationController.initialize();
      addTearDown(operationController.dispose);
      final resetService = _FakeResetService();

      final service = StartFreshServiceImpl(
        archiveRootPath: fixture.root.path,
        requiredSourcesScheduleId: 42,
        readCurrentState: () async {
          return const MessageLensInstallationState(
            kind: MessageLensInstallationStateKind.completed,
            reason: 'healthy completed installation',
          );
        },
        runWithMutationAuthority: (action) {
          return container
              .read(archiveMutationCoordinatorProvider.notifier)
              .runWithCapability<StartFreshResult>(
                operation: ArchiveMutationOperation.startFresh,
                ownerLabel: 'test-advanced-start-fresh',
                action: action,
              );
        },
        messageDataResetService: resetService,
        operationController: operationController,
        failureStore: _FakeFailureStore(),
        presenceRepository: const _MissingDefinitionMaintenance(),
        evidenceReader: const _VirginEvidenceReader(),
        classifier: const MessageLensInstallationStateClassifier(),
        refreshAfterReset: () {},
      );

      final result = await service.startFresh(
        entryPoint: StartFreshEntryPoint.completedInstallationAdvancedReset,
      );

      expect(
        result.verifiedState.kind,
        MessageLensInstallationStateKind.virgin,
      );
      expect(resetService.callCount, 1);
    },
  );

  test(
    'failed derived reset releases authority and remains retryable',
    () async {
      final fixture = await TestArchiveFixture.create(
        prefix: 'start_fresh_retry_test_',
      );
      addTearDown(fixture.dispose);
      final container = ProviderContainer(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWithValue(
            fixture.authority,
          ),
        ],
      );
      addTearDown(container.dispose);
      final operationController = OnboardingOperationSnapshotController(
        store: _MemorySnapshotStore(),
        processSessionId: OnboardingProcessSessionId(
          '123e4567-e89b-42d3-a456-426614174023',
        ),
      );
      await operationController.initialize();
      addTearDown(operationController.dispose);
      final resetService = _FakeResetService()..failure = StateError('disk');

      final service = StartFreshServiceImpl(
        archiveRootPath: fixture.root.path,
        requiredSourcesScheduleId: 42,
        readCurrentState: () async {
          return const MessageLensInstallationState(
            kind: MessageLensInstallationStateKind.abandoned,
            reason: 'test abandoned state',
          );
        },
        runWithMutationAuthority: (action) {
          return container
              .read(archiveMutationCoordinatorProvider.notifier)
              .runWithCapability<StartFreshResult>(
                operation: ArchiveMutationOperation.startFresh,
                ownerLabel: 'test-start-fresh-retry',
                action: action,
              );
        },
        messageDataResetService: resetService,
        operationController: operationController,
        failureStore: _FakeFailureStore(),
        presenceRepository: const _MissingDefinitionMaintenance(),
        evidenceReader: const _VirginEvidenceReader(),
        classifier: const MessageLensInstallationStateClassifier(),
        refreshAfterReset: () {},
      );

      await expectLater(service.startFresh(), throwsStateError);
      expect(
        container.read(archiveMutationCoordinatorProvider).isLocked,
        false,
      );

      resetService.failure = null;
      final result = await service.startFresh();
      expect(
        result.verifiedState.kind,
        MessageLensInstallationStateKind.virgin,
      );
      expect(resetService.callCount, 2);
    },
  );
}

final class _MemorySnapshotStore implements OnboardingOperationSnapshotStore {
  final saved = <OnboardingOperationSnapshot>[];

  @override
  Future<OnboardingOperationSnapshot?> load() async => null;

  @override
  Future<void> save(OnboardingOperationSnapshot snapshot) async {
    saved.add(snapshot);
  }
}

final class _FakeResetService implements MessageDataResetService {
  int callCount = 0;
  Object? failure;

  @override
  Future<void> resetDerivedDataForStartFresh(
    ArchiveMutationCapability capability,
  ) async {
    capability.requireOperation(ArchiveMutationOperation.startFresh);
    callCount += 1;
    final currentFailure = failure;
    if (currentFailure != null) {
      throw currentFailure;
    }
  }

  @override
  Future<void> resetDerivedData() async {
    throw UnsupportedError('not used');
  }
}

final class _FakeFailureStore implements OnboardingFailureStore {
  int importClearCount = 0;
  int graphClearCount = 0;

  @override
  Future<void> clearSourceImportFailure() async {
    importClearCount += 1;
  }

  @override
  Future<void> clearGraphProjectionFailure() async {
    graphClearCount += 1;
  }

  @override
  Future<OnboardingPipelineFailure?> loadSourceImportFailure() async => null;

  @override
  Future<PersistedOnboardingSourceImportFailure?>
  loadSourceImportFailureEntry() async => null;

  @override
  Future<OnboardingPipelineFailure?> loadGraphProjectionFailure() async => null;

  @override
  Future<PersistedOnboardingGraphProjectionFailure?>
  loadGraphProjectionFailureEntry() async => null;

  @override
  Future<void> saveImportFailure({
    required String message,
    int batchId = 0,
    DateTime? recordedAt,
    List<String> warnings = const [],
  }) async {
    throw UnsupportedError('not used');
  }

  @override
  Future<void> saveGraphProjectionFailure({
    required String message,
    int batchId = 0,
    DateTime? recordedAt,
  }) async {
    throw UnsupportedError('not used');
  }
}

final class _VirginEvidenceReader
    implements MessageLensInstallationEvidenceReader {
  const _VirginEvidenceReader();

  @override
  MessageLensInstallationEvidence read({
    required String archiveRootPath,
    required OnboardingOperationSnapshot operationSnapshot,
  }) {
    return MessageLensInstallationEvidence(
      sourceScopedImport: const InstallationDatabaseEvidence.absent(),
      conversationGraph: const InstallationDatabaseEvidence.absent(),
      overlay: const InstallationDatabaseEvidence.absent(),
      presence: const InstallationDatabaseEvidence.absent(),
      hasRetiredDerivedArtifacts: false,
      operationSnapshot: operationSnapshot,
    );
  }
}

final class _MissingDefinitionMaintenance
    implements PresenceScheduleRunMaintenance {
  const _MissingDefinitionMaintenance();

  @override
  Future<bool> definitionExists(int scheduleDefinitionId) async => false;

  @override
  Future<ScheduleRun> supersedeRunFromBeginning(int scheduleDefinitionId) {
    throw UnsupportedError('not used');
  }
}
