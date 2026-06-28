import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart'
    show driftConversationGraphDatabaseProvider;
import '../../../essentials/logging/feature_level_providers.dart'
    show appLoggerProvider;
import '../infrastructure/repositories/archive_source_inspection_repository.dart';
import 'archive_source_inspection.dart';

part 'archive_source_inspector_provider.g.dart';

@riverpod
Future<ArchiveSourceInspector> archiveSourceInspector(Ref ref) async {
  final logger = ref.read(appLoggerProvider.notifier);
  try {
    final graphDb = await ref.watch(
      driftConversationGraphDatabaseProvider.future,
    );
    return ArchiveSourceInspectionRepository(
      graphDb: graphDb,
      onInspectionFailure: (folderPath, error, stackTrace) {
        logger.warn(
          'ArchiveSourceInspector: failed to inspect selected folder',
          source: 'ArchiveSourceInspectionRepository',
          context: <String, Object?>{
            'folderPath': folderPath,
            'error': error.toString(),
            'stackTrace': stackTrace.toString(),
          },
        );
      },
    );
  } catch (error, stackTrace) {
    ref
        .read(appLoggerProvider.notifier)
        .warn(
          'ArchiveSourceInspector: continuing without conversation graph database',
          source: 'SettingsFeatureProviders',
          context: <String, Object?>{
            'error': error.toString(),
            'stackTrace': stackTrace.toString(),
          },
        );
  }

  return ArchiveSourceInspectionRepository(
    graphDb: null,
    onInspectionFailure: (folderPath, error, stackTrace) {
      logger.warn(
        'ArchiveSourceInspector: failed to inspect selected folder',
        source: 'ArchiveSourceInspectionRepository',
        context: <String, Object?>{
          'folderPath': folderPath,
          'error': error.toString(),
          'stackTrace': stackTrace.toString(),
        },
      );
    },
  );
}
