import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers/persistent_database_providers.dart'
    show overlayDatabaseProvider;
import '../infrastructure/repositories/historical_archive_sources_repository.dart';
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
