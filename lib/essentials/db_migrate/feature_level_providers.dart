import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'application/migration/ledger_to_working_migration_service.dart';

part 'feature_level_providers.g.dart';

/// Provides the ledger-to-working database migration orchestrator.
@riverpod
LedgerToWorkingMigrationService ledgerToWorkingMigrationService(Ref ref) {
  return LedgerToWorkingMigrationService(ref: ref);
}
