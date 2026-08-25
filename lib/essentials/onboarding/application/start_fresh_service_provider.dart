import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../archive_environment/domain.dart' show ArchiveMutationOperation;
import '../../archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider, archiveMutationCoordinatorProvider;
import '../../presence/feature_level_providers.dart'
    show presenceScheduleMaintenanceRepositoryProvider;
import '../infrastructure/persistence/sqlite_message_lens_installation_evidence_reader.dart';
import 'message_data_reset_service.dart';
import 'message_lens_installation_state_classifier.dart';
import 'message_lens_installation_state_provider.dart';
import 'onboarding_environment_report_provider.dart';
import 'onboarding_failure_storage_provider.dart';
import 'onboarding_gate_provider.dart';
import 'onboarding_operation_snapshot_provider.dart';
import 'required_sources_readiness_schedule.dart';
import 'required_sources_readiness_scheduler_provider.dart';
import 'start_fresh_service.dart';

part 'start_fresh_service_provider.g.dart';

@Riverpod(keepAlive: true)
Future<StartFreshService> startFreshService(Ref ref) async {
  final operationController = await ref.watch(
    onboardingOperationControllerProvider.future,
  );
  final presenceRepository = await ref.watch(
    presenceScheduleMaintenanceRepositoryProvider.future,
  );
  final authority = ref.watch(archiveAccessAuthorityProvider);

  return StartFreshServiceImpl(
    archiveRootPath: authority.rootPath,
    requiredSourcesScheduleId: requiredSourcesReadinessScheduleId,
    readCurrentState: () {
      ref.invalidate(messageLensInstallationStateProvider);
      return ref.read(messageLensInstallationStateProvider.future);
    },
    runWithMutationAuthority: (action) {
      return ref
          .read(archiveMutationCoordinatorProvider.notifier)
          .runWithCapability(
            operation: ArchiveMutationOperation.startFresh,
            ownerLabel: 'onboarding-start-fresh',
            action: action,
          );
    },
    messageDataResetService: ref.watch(messageDataResetServiceProvider),
    operationController: operationController,
    failureStore: ref.watch(onboardingFailureStorageProvider),
    presenceRepository: presenceRepository,
    evidenceReader: const SqliteMessageLensInstallationEvidenceReader(),
    classifier: const MessageLensInstallationStateClassifier(),
    refreshAfterReset: () {
      ref.invalidate(messageLensInstallationStateProvider);
      ref.invalidate(requiredSourcesReadinessSchedulerProvider);
      ref.invalidate(requiredSourcesReadinessAcceptedProvider);
      ref.invalidate(onboardingEnvironmentReportProvider);
      ref.read(onboardingGateProvider.notifier).refreshEnvironment();
    },
  );
}
