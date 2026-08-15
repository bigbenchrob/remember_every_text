import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../archive_environment/feature_level_providers.dart'
    show archiveDatabaseReopenBlockedProvider;

part 'db_maintenance_lock_provider.g.dart';

/// Compatibility read model for consumers that must not re-open databases
/// during destructive archive mutations.
///
/// Operation admission is owned exclusively by ArchiveMutationCoordinator.
/// This provider exposes only the derived read-suppression decision.
@riverpod
bool dbMaintenanceLock(Ref ref) {
  return ref.watch(archiveDatabaseReopenBlockedProvider);
}
