import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db_importers/feature_level_providers.dart';
import '../../infrastructure/import_database_provider.dart';
import 'historical_messages_archive_source_registrar.dart';
import 'source_scoped_archive_import_service.dart';

part 'source_scoped_archive_import_service_provider.g.dart';

@riverpod
Future<SourceScopedArchiveImportService> sourceScopedArchiveImportService(
  Ref ref,
) async {
  final importDatabase = await ref.watch(importDatabaseProvider.future);

  return SourceScopedArchiveImportService(
    registrar: HistoricalMessagesArchiveSourceRegistrar(
      importDatabase: importDatabase,
    ),
    richTextExtractor: ref.watch(dbImportMessageExtractorProvider),
  );
}
