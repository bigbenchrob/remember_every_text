import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers.dart';
import '../../db/feature_level_providers.dart';
import 'legacy_incremental_update_state_repository.dart';

part 'legacy_incremental_update_state_repository_provider.g.dart';

@riverpod
Future<LegacyIncrementalUpdateStateRepository>
legacyIncrementalUpdateStateRepository(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final importDb = await ref.watch(sqfliteImportDatabaseProvider.future);
  final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);

  return LegacyIncrementalUpdateStateRepository(
    chatDbPath: pathsHelper.chatDBPath,
    importDb: importDb,
    workingDb: workingDb,
  );
}
