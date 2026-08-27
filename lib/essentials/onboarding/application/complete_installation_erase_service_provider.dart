import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../archive_environment/domain/archive_mutation_operation.dart';
import '../../archive_environment/feature_level_providers.dart'
    show
        archiveAccessAuthorityProvider,
        archiveMutationCoordinatorProvider,
        archiveOwnedResourceRegistryProvider;
import '../../archive_environment/infrastructure.dart'
    show FileSystemCompleteInstallationEraseStore;
import '../../conversation_graph/feature_level_providers.dart'
    show chatDbChangeMonitorProvider;
import '../../db/feature_level_providers.dart'
    show
        driftConversationGraphDatabaseProvider,
        overlayDatabaseProvider,
        presenceDatabaseProvider,
        sourceScopedImportDatabaseProvider;
import '../../logging/feature_level_providers.dart' show appLoggerProvider;
import '../infrastructure/persistence/sqlite_message_lens_installation_evidence_reader.dart';
import '../infrastructure/system/macos_application_relauncher.dart';
import 'complete_installation_erase_service.dart';
import 'complete_installation_erase_virgin_verifier.dart';

part 'complete_installation_erase_service_provider.g.dart';

@Riverpod(keepAlive: true)
CompleteInstallationEraseService completeInstallationEraseService(Ref ref) {
  final authority = ref.watch(archiveAccessAuthorityProvider);
  return CompleteInstallationEraseServiceImpl(
    authority: authority,
    runWithMutationAuthority: (action) {
      return ref
          .read(archiveMutationCoordinatorProvider.notifier)
          .runWithCapability(
            operation: ArchiveMutationOperation.completeInstallationErase,
            ownerLabel: 'complete-installation-erase',
            action: action,
          );
    },
    resources: ref.read(archiveOwnedResourceRegistryProvider),
    store: const FileSystemCompleteInstallationEraseStore(),
    stopBackgroundWork: () {
      ref.invalidate(chatDbChangeMonitorProvider);
    },
    invalidatePersistentProviders: () {
      ref.invalidate(sourceScopedImportDatabaseProvider);
      ref.invalidate(driftConversationGraphDatabaseProvider);
      ref.invalidate(overlayDatabaseProvider);
      ref.invalidate(presenceDatabaseProvider);
      ref.invalidate(appLoggerProvider);
    },
    verifyVirginInstallation: () async {
      await const CompleteInstallationEraseVirginVerifier(
        evidenceReader: SqliteMessageLensInstallationEvidenceReader(),
      ).verify(archiveRootPath: authority.rootPath);
    },
    relauncher: const MacosApplicationRelauncher(),
  );
}
