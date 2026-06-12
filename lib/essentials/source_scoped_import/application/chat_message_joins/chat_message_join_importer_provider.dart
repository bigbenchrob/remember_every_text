import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../providers.dart';
import '../../feature_level_providers.dart';
import 'chat_message_join_importer.dart';

part 'chat_message_join_importer_provider.g.dart';

@riverpod
Future<ChatMessageJoinImporter> chatMessageJoinImporter(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final importLedger = await ref.watch(sourceScopedImportLedgerProvider.future);
  final sourceDatabaseOpener = ref.watch(sourceDatabaseOpenerProvider);

  return ChatMessageJoinImporter(
    chatDbPath: pathsHelper.chatDBPath,
    importLedger: importLedger,
    sourceDatabaseOpener: sourceDatabaseOpener,
  );
}
