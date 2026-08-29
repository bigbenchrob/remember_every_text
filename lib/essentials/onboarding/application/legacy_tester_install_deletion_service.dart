import 'package:uuid/uuid.dart';

import '../../archive_environment/application/archive_owned_resource_registry_provider.dart';
import '../../archive_environment/application/complete_installation_erase_store.dart';
import '../../archive_environment/domain/archive_access_authority.dart';
import '../../archive_environment/domain/archive_instance_id.dart';
import '../../archive_environment/domain/archive_mutation_operation.dart';
import '../../archive_environment/domain/complete_installation_erase_transaction.dart';
import '../../archive_environment/feature_level_providers.dart'
    show ArchiveMutationCapability;
import 'application_relauncher.dart';

abstract interface class LegacyTesterInstallDeletionService {
  Future<void> deleteAndRelaunch();
}

final class LegacyTesterInstallDeletionServiceImpl
    implements LegacyTesterInstallDeletionService {
  LegacyTesterInstallDeletionServiceImpl({
    required this.authority,
    required this.runWithMutationAuthority,
    required this.resources,
    required this.store,
    required this.verifyVirginInstallation,
    required this.relauncher,
    Uuid uuid = const Uuid(),
    DateTime Function()? currentTime,
  }) : _uuid = uuid,
       _currentTime = currentTime ?? DateTime.now;

  final ArchiveAccessAuthority authority;
  final Future<void> Function(
    Future<void> Function(ArchiveMutationCapability capability) action,
  )
  runWithMutationAuthority;
  final ArchiveOwnedResourceRegistry resources;
  final CompleteInstallationEraseStore store;
  final Future<void> Function() verifyVirginInstallation;
  final ApplicationRelauncher relauncher;
  final Uuid _uuid;
  final DateTime Function() _currentTime;

  @override
  Future<void> deleteAndRelaunch() {
    if (authority.mode != ArchiveAccessMode.legacyTesterInstallDetected) {
      throw StateError(
        'Legacy tester deletion requires exact legacy startup admission.',
      );
    }

    return runWithMutationAuthority((capability) async {
      capability.requireOperation(
        ArchiveMutationOperation.legacyTesterInstallDeletion,
      );
      if (resources.openResourceCount != 0) {
        throw StateError(
          'Legacy tester deletion refuses to run after a persistent archive '
          'resource has opened.',
        );
      }

      final pending = await store.readPending(
        canonicalRootPath: authority.rootPath,
      );
      final transaction =
          pending ??
          CompleteInstallationEraseTransaction(
            formatVersion:
                CompleteInstallationEraseTransaction.currentFormatVersion,
            environment: authority.identity.environment,
            newArchiveInstanceId: ArchiveInstanceId(_uuid.v4()),
            createdAtUtc: _currentTime().toUtc(),
          );
      if (transaction.environment != authority.identity.environment) {
        throw StateError(
          'Pending archive replacement belongs to a different environment.',
        );
      }

      if (pending == null) {
        await store.begin(authority: authority, transaction: transaction);
      }
      await store.eraseOwnedState(authority: authority);
      await store.installVirginIdentity(
        authority: authority,
        transaction: transaction,
      );
      await verifyVirginInstallation();
      await store.complete(authority: authority);
      await relauncher.relaunchAfterArchiveReplacement();
    });
  }
}
