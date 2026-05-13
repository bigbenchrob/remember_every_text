import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dev_databases/dev_working_database_provider.dart';
import 'shadow_working_message_projection_repository.dart';

part 'shadow_working_message_projection_repository_provider.g.dart';

@riverpod
Future<ShadowWorkingMessageProjectionRepository>
shadowWorkingMessageProjectionRepository(Ref ref) async {
  final workingDb = await ref.watch(devWorkingDatabaseProvider.future);

  return ShadowWorkingMessageProjectionRepository(workingDb: workingDb);
}
