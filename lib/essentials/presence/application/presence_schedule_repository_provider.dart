import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../db/feature_level_providers.dart' show presenceDatabaseProvider;
import '../domain/repositories/presence_schedule_repository.dart';
import '../domain/repositories/presence_schedule_run_maintenance.dart';
import '../domain/services/fda_settings_opening_authority.dart';
import '../domain/services/test_agent_resolver.dart';
import '../infrastructure/repositories/drift_presence_schedule_repository.dart';

part 'presence_schedule_repository_provider.g.dart';

@Riverpod(keepAlive: true)
Future<PresenceScheduleRepository> presenceScheduleRepository(
  Ref ref,
  TestAgentResolver testAgentResolver,
  FdaSettingsOpeningAuthority fdaSettingsOpeningAuthority,
) async {
  final database = await ref.watch(presenceDatabaseProvider.future);
  return DriftPresenceScheduleRepository(
    database: database,
    testAgentResolver: testAgentResolver,
    fdaSettingsOpeningAuthority: fdaSettingsOpeningAuthority,
  );
}

/// Repository composition for archive-owned maintenance of Schedule runs.
@Riverpod(keepAlive: true)
Future<PresenceScheduleRunMaintenance> presenceScheduleMaintenanceRepository(
  Ref ref,
) async {
  final database = await ref.watch(presenceDatabaseProvider.future);
  return DriftPresenceScheduleRepository(database: database);
}
