import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../feature_level_providers.dart';
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
    ),
    richTextExtractor: ref.watch(sourceScopedMessageExtractorProvider),
    sourceDatabaseOpener: sourceDatabaseOpener,
  );
}
