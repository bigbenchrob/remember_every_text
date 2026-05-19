import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dev_databases/dev_import_database_provider.dart';
import 'dev_databases/dev_working_database_provider.dart';
import 'topology_projection_preview_repository.dart';

part 'topology_projection_preview_repository_provider.g.dart';

@riverpod
Future<TopologyProjectionPreviewRepository> topologyProjectionPreviewRepository(
  Ref ref,
) async {
  final ledgerDb = await ref.watch(devImportDatabaseProvider.future);
  final workingDb = await ref.watch(devWorkingDatabaseProvider.future);
  return TopologyProjectionPreviewRepository(
    ledgerDb: ledgerDb,
    workingDb: workingDb,
  );
}
