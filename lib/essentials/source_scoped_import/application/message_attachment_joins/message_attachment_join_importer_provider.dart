import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../providers.dart';
import '../source_database_opener_provider.dart';
import '../source_scoped_import_ledger_provider.dart';
import 'message_attachment_join_importer.dart';

part 'message_attachment_join_importer_provider.g.dart';

@riverpod
Future<MessageAttachmentJoinImporter> messageAttachmentJoinImporter(
  Ref ref,
) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final importLedger = await ref.watch(sourceScopedImportLedgerProvider.future);
  final sourceDatabaseOpener = ref.watch(sourceDatabaseOpenerProvider);

  return MessageAttachmentJoinImporter(
    chatDbPath: pathsHelper.chatDBPath,
    importLedger: importLedger,
    sourceDatabaseOpener: sourceDatabaseOpener,
  );
}
