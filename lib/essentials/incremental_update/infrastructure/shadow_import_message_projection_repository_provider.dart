import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dev_databases/dev_import_database_provider.dart';
import 'shadow_import_message_projection_repository.dart';

part 'shadow_import_message_projection_repository_provider.g.dart';

@riverpod
Future<ShadowImportMessageProjectionRepository>
shadowImportMessageProjectionRepository(Ref ref) async {
  final importDb = await ref.watch(devImportDatabaseProvider.future);

  return ShadowImportMessageProjectionRepository(importDb: importDb);
}
