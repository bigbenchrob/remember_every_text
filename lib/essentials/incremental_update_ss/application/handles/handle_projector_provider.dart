import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../infrastructure/import_database_provider.dart';
import '../../infrastructure/working_database_provider.dart';
import 'handle_projector.dart';

part 'handle_projector_provider.g.dart';

@riverpod
Future<HandleProjector> handleProjector(Ref ref) async {
  final importDatabase = await ref.watch(importDatabaseProvider.future);
  final workingDatabase = await ref.watch(workingDatabaseProvider.future);

  return HandleProjector(
    importDatabase: importDatabase,
    workingDatabase: workingDatabase,
  );
}
