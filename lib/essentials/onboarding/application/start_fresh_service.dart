import '../../archive_environment/domain/archive_mutation_operation.dart';
import '../../archive_environment/feature_level_providers.dart'
    show ArchiveMutationCapability;
import '../../presence/domain/repositories/presence_schedule_run_maintenance.dart';
import '../domain/message_lens_installation_state.dart';
import 'message_data_reset_service.dart';
import 'message_lens_installation_evidence_reader.dart';
import 'message_lens_installation_state_classifier.dart';
import 'onboarding_failure_store.dart';
import 'onboarding_operation_snapshot_controller.dart';

final class StartFreshResult {
  const StartFreshResult({required this.verifiedState});

  final MessageLensInstallationState verifiedState;
}

abstract interface class StartFreshService {
  Future<StartFreshResult> startFresh();
}

final class StartFreshServiceImpl implements StartFreshService {
  const StartFreshServiceImpl({
    required this.archiveRootPath,
    required this.requiredSourcesScheduleId,
    required this.readCurrentState,
    required this.runWithMutationAuthority,
    required this.messageDataResetService,
    required this.operationController,
    required this.failureStore,
    required this.presenceRepository,
    required this.evidenceReader,
    required this.classifier,
    required this.refreshAfterReset,
  });

  final String archiveRootPath;
  final int requiredSourcesScheduleId;
  final Future<MessageLensInstallationState> Function() readCurrentState;
  final Future<StartFreshResult> Function(
    Future<StartFreshResult> Function(ArchiveMutationCapability capability)
    action,
  )
  runWithMutationAuthority;
  final MessageDataResetService messageDataResetService;
  final OnboardingOperationSnapshotController operationController;
  final OnboardingFailureStore failureStore;
  final PresenceScheduleRunMaintenance presenceRepository;
  final MessageLensInstallationEvidenceReader evidenceReader;
  final MessageLensInstallationStateClassifier classifier;
  final void Function() refreshAfterReset;

  @override
  Future<StartFreshResult> startFresh() async {
    final currentState = await readCurrentState();
    if (!currentState.mayStartFresh) {
      throw StateError(
        'Start Fresh is unavailable for ${currentState.kind.name}: '
        '${currentState.reason}',
      );
    }

    return runWithMutationAuthority((capability) async {
      capability.requireOperation(ArchiveMutationOperation.startFresh);

      // Clear intent evidence first. Every later step is idempotent, so a
      // process interruption converges to completed durable data or an
      // abandoned installation that can safely request Start Fresh again.
      await operationController.resetToIdle();
      await failureStore.clearSourceImportFailure();
      await failureStore.clearGraphProjectionFailure();

      if (await presenceRepository.definitionExists(
        requiredSourcesScheduleId,
      )) {
        await presenceRepository.supersedeRunFromBeginning(
          requiredSourcesScheduleId,
        );
      }

      await messageDataResetService.resetDerivedDataForStartFresh(capability);

      final verifiedState = classifier.classify(
        evidenceReader.read(
          archiveRootPath: archiveRootPath,
          operationSnapshot: operationController.current,
        ),
      );
      if (verifiedState.kind != MessageLensInstallationStateKind.virgin) {
        throw StateError(
          'Start Fresh did not establish the virgin installation contract: '
          '${verifiedState.kind.name} (${verifiedState.reason})',
        );
      }

      refreshAfterReset();
      return StartFreshResult(verifiedState: verifiedState);
    });
  }
}
