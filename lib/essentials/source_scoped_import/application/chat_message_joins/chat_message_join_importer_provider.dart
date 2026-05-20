import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../providers.dart';
import '../../infrastructure/import_database_provider.dart';
import 'chat_message_join_importer.dart';

part 'chat_message_join_importer_provider.g.dart';

@riverpod
Future<ChatMessageJoinImporter> chatMessageJoinImporter(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final importDatabase = await ref.watch(importDatabaseProvider.future);

  return ChatMessageJoinImporter(
    chatDbPath: pathsHelper.chatDBPath,
    importDatabase: importDatabase,
  );
}
