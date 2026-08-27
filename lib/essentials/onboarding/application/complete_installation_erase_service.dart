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

abstract interface class CompleteInstallationEraseService {
  Future<void> eraseAndRelaunch();
}

final class CompleteInstallationEraseServiceImpl
    implements CompleteInstallationEraseService {
  CompleteInstallationEraseServiceImpl({
    required this.authority,
    required this.runWithMutationAuthority,
    required this.resources,
    required this.store,
    required this.stopBackgroundWork,
    required this.invalidatePersistentProviders,
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
  final void Function() stopBackgroundWork;
  final void Function() invalidatePersistentProviders;
  final Future<void> Function() verifyVirginInstallation;
  final ApplicationRelauncher relauncher;
  final Uuid _uuid;
  final DateTime Function() _currentTime;

  @override
  Future<void> eraseAndRelaunch() {
    return runWithMutationAuthority((capability) async {
      capability.requireOperation(
        ArchiveMutationOperation.completeInstallationErase,
      );
      final transaction = CompleteInstallationEraseTransaction(
        formatVersion:
            CompleteInstallationEraseTransaction.currentFormatVersion,
        environment: authority.identity.environment,
        newArchiveInstanceId: ArchiveInstanceId(_uuid.v4()),
        createdAtUtc: _currentTime().toUtc(),
      );

      stopBackgroundWork();
      await resources.closeAll();
      invalidatePersistentProviders();
      await store.begin(authority: authority, transaction: transaction);
      await store.eraseOwnedState(authority: authority);
      await store.installVirginIdentity(
        authority: authority,
        transaction: transaction,
      );
      await verifyVirginInstallation();
      await store.complete(authority: authority);
      await relauncher.relaunchAfterCompleteInstallationErase();
    });
  }
}
