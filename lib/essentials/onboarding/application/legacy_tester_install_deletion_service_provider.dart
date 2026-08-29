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
import '../infrastructure/persistence/sqlite_message_lens_installation_evidence_reader.dart';
import '../infrastructure/system/macos_application_relauncher.dart';
import 'complete_installation_erase_virgin_verifier.dart';
import 'legacy_tester_install_deletion_service.dart';

part 'legacy_tester_install_deletion_service_provider.g.dart';

@Riverpod(keepAlive: true)
LegacyTesterInstallDeletionService legacyTesterInstallDeletionService(Ref ref) {
  final authority = ref.watch(archiveAccessAuthorityProvider);
  return LegacyTesterInstallDeletionServiceImpl(
    authority: authority,
    runWithMutationAuthority: (action) {
      return ref
          .read(archiveMutationCoordinatorProvider.notifier)
          .runWithCapability(
            operation: ArchiveMutationOperation.legacyTesterInstallDeletion,
            ownerLabel: 'legacy-tester-install-deletion',
            action: action,
          );
    },
    resources: ref.read(archiveOwnedResourceRegistryProvider),
    store: const FileSystemCompleteInstallationEraseStore(),
    verifyVirginInstallation: () async {
      await const CompleteInstallationEraseVirginVerifier(
        evidenceReader: SqliteMessageLensInstallationEvidenceReader(),
      ).verify(archiveRootPath: authority.rootPath);
    },
    relauncher: const MacosApplicationRelauncher(),
  );
}
