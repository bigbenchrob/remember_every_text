import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'shadow_migration_refresh_orchestrator.dart';

part 'shadow_migration_refresh_orchestrator_provider.g.dart';

@Riverpod(keepAlive: true)
ShadowMigrationRefreshOrchestrator shadowMigrationRefreshOrchestrator(Ref ref) {
  return ShadowMigrationRefreshOrchestrator(ref);
}
