import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../infrastructure/import_database_provider.dart';
import '../../infrastructure/working_database_provider.dart';
import 'chat_to_handle_projector.dart';

part 'chat_to_handle_projector_provider.g.dart';

@riverpod
Future<ChatToHandleProjector> chatToHandleProjector(Ref ref) async {
  final importDatabase = await ref.watch(importDatabaseProvider.future);
  final workingDatabase = await ref.watch(workingDatabaseProvider.future);

  return ChatToHandleProjector(
    importDatabase: importDatabase,
    workingDatabase: workingDatabase,
  );
}
