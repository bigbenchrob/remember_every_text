import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import '../../../essentials/source_scoped_import/feature_level_providers.dart'
    show
        historicalMessagesArchiveSourceFolderResolverProvider,
        sourceScopedImportLedgerProvider;
import '../infrastructure/repositories/historical_archive_sources_repository.dart';
import '../infrastructure/repositories/import_ledger_historical_archive_imported_source_lookup.dart';
import 'historical_archive_sources.dart';

part 'historical_archive_sources_provider.g.dart';

@riverpod
Future<HistoricalArchiveSources> historicalArchiveSources(Ref ref) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return HistoricalArchiveSourcesRepository(overlayDatabase: overlayDatabase);
}

@riverpod
Future<List<HistoricalArchiveSourceMetadata>> historicalArchiveSourceMetadata(
  Ref ref,
) async {
  final sources = await ref.watch(historicalArchiveSourcesProvider.future);
  return sources.readKnownSources();
}

@riverpod
Future<HistoricalArchiveImportedSourceLookup>
historicalArchiveImportedSourceLookup(Ref ref) async {
  final importLedger = await ref.watch(sourceScopedImportLedgerProvider.future);
  final folderResolver = ref.watch(
    historicalMessagesArchiveSourceFolderResolverProvider,
  );
  return ImportLedgerHistoricalArchiveImportedSourceLookup(
    importLedger: importLedger,
    folderResolver: folderResolver,
  );
}
