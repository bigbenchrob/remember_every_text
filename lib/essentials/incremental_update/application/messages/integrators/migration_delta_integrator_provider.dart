import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/message_migration_delta.dart';
import '../readers/shadow_import_projection_snapshot_provider.dart';
import '../readers/shadow_working_projection_snapshot_provider.dart';
import 'migration_delta_integrator.dart';

part 'migration_delta_integrator_provider.g.dart';

@riverpod
Future<MessageMigrationDelta> messageMigrationDelta(Ref ref) async {
  final ledgerSnapshot = await ref.watch(
    shadowImportProjectionSnapshotProvider.future,
  );
  final projectionSnapshot = await ref.watch(
    shadowWorkingProjectionSnapshotProvider.future,
  );

  return const MessageMigrationDeltaIntegrator().integrate(
    ledger: ledgerSnapshot,
    projection: projectionSnapshot,
  );
}
