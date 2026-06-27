import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../message_extractor_provider.dart';
import '../source_database_opener_provider.dart';
import '../source_scoped_import_ledger_provider.dart';
import 'historical_messages_archive_source_folder_resolver_provider.dart';
import 'historical_messages_archive_source_registrar.dart';
import 'source_scoped_archive_import_service.dart';

part 'source_scoped_archive_import_service_provider.g.dart';

@riverpod
Future<SourceScopedArchiveImportService> sourceScopedArchiveImportService(
  Ref ref,
) async {
  final importLedger = await ref.watch(sourceScopedImportLedgerProvider.future);
  final sourceDatabaseOpener = ref.watch(sourceDatabaseOpenerProvider);

  return SourceScopedArchiveImportService(
    registrar: HistoricalMessagesArchiveSourceRegistrar(
      importLedger: importLedger,
      folderResolver: ref.watch(
        historicalMessagesArchiveSourceFolderResolverProvider,
      ),
    ),
    richTextExtractor: ref.watch(sourceScopedMessageExtractorProvider),
    sourceDatabaseOpener: sourceDatabaseOpener,
  );
}
