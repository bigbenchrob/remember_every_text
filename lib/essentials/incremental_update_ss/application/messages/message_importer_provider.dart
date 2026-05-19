import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../providers.dart';
import '../../infrastructure/import_database_provider.dart';
import 'message_importer.dart';

part 'message_importer_provider.g.dart';

@riverpod
Future<MessageImporter> messageImporter(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final importDatabase = await ref.watch(importDatabaseProvider.future);

  return MessageImporter(
    chatDbPath: pathsHelper.chatDBPath,
    importDatabase: importDatabase,
  );
}
