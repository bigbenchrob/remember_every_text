import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../infrastructure/import_database_provider.dart';
import '../../infrastructure/working_database_provider.dart';
import 'chat_projector.dart';

part 'chat_projector_provider.g.dart';

@riverpod
Future<ChatProjector> chatProjector(Ref ref) async {
  final importDatabase = await ref.watch(importDatabaseProvider.future);
  final workingDatabase = await ref.watch(workingDatabaseProvider.future);

  return ChatProjector(
    importDatabase: importDatabase,
    workingDatabase: workingDatabase,
  );
}
