import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db/feature_level_providers.dart';
import 'application/orchestrator/handles_migration_service.dart';
import 'domain/i_repositories/legacy_projection_status_repository.dart';
import 'infrastructure/repositories/drift_legacy_projection_status_repository.dart';

part 'feature_level_providers.g.dart';

/// Provides the orchestrator-backed migration pipeline for identities,
/// chats, messages, and related tables.
@riverpod
HandlesMigrationService handlesMigrationService(Ref ref) {
  return HandlesMigrationService(ref: ref);
}

@riverpod
LegacyProjectionStatusRepository legacyProjectionStatusRepository(Ref ref) {
  return DriftLegacyProjectionStatusRepository(
    openWorkingDatabase: () => ref.read(driftWorkingDatabaseProvider.future),
  );
}
