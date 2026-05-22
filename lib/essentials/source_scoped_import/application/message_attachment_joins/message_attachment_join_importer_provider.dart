import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../providers.dart';
import '../../infrastructure/import_database_provider.dart';
import 'message_attachment_join_importer.dart';

part 'message_attachment_join_importer_provider.g.dart';

@riverpod
Future<MessageAttachmentJoinImporter> messageAttachmentJoinImporter(
  Ref ref,
) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final importDatabase = await ref.watch(importDatabaseProvider.future);

  return MessageAttachmentJoinImporter(
    chatDbPath: pathsHelper.chatDBPath,
    importDatabase: importDatabase,
  );
}
