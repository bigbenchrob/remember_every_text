import '../domain/archive_access_authority.dart';
import '../domain/complete_installation_erase_transaction.dart';

abstract interface class CompleteInstallationEraseStore {
  Future<void> begin({
    required ArchiveAccessAuthority authority,
    required CompleteInstallationEraseTransaction transaction,
  });

  Future<void> eraseOwnedState({required ArchiveAccessAuthority authority});

  Future<void> installVirginIdentity({
    required ArchiveAccessAuthority authority,
    required CompleteInstallationEraseTransaction transaction,
  });

  Future<void> complete({required ArchiveAccessAuthority authority});

  Future<CompleteInstallationEraseTransaction?> readPending({
    required String canonicalRootPath,
  });
}
