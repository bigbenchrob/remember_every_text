import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/dev_databases/dev_import_database_provider.dart';
import '../../../infrastructure/dev_databases/dev_working_database_provider.dart';
import 'shadow_message_migration_executor.dart';

part 'shadow_message_migration_executor_provider.g.dart';

@riverpod
Future<ShadowMessageMigrationExecutor> shadowMessageMigrationExecutor(
  Ref ref,
) async {
  final shadowImportDb = await ref.watch(devImportDatabaseProvider.future);
  final shadowWorkingDb = await ref.watch(devWorkingDatabaseProvider.future);

  return ShadowMessageMigrationExecutor(
    shadowImportDb: shadowImportDb,
    shadowWorkingDb: shadowWorkingDb,
  );
}
