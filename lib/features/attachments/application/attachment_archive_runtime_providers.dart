import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers/persistent_database_providers.dart'
    show attachmentArchiveDirectoryProvider, overlayDatabaseProvider;
import '../infrastructure/repositories/attachment_archive_stats_repository.dart';
import '../infrastructure/repositories/filesystem_attachment_archive_file_operations.dart';
import '../infrastructure/repositories/overlay_attachment_archive_settings_store.dart';
import 'attachment_archive_file_operations.dart';
import 'attachment_archive_settings_store.dart';
import 'attachment_archive_stats_reader.dart';

part 'attachment_archive_runtime_providers.g.dart';

@riverpod
String attachmentArchiveDirectoryPath(AttachmentArchiveDirectoryPathRef ref) {
  return ref.watch(attachmentArchiveDirectoryProvider);
}

@riverpod
AttachmentArchiveFileOperations attachmentArchiveFileOperations(
  AttachmentArchiveFileOperationsRef ref,
) {
  return const FilesystemAttachmentArchiveFileOperations();
}

@riverpod
Future<AttachmentArchiveSettingsStore> attachmentArchiveSettingsStore(
  AttachmentArchiveSettingsStoreRef ref,
) async {
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return OverlayAttachmentArchiveSettingsStore(overlayDb: overlayDb);
}

@riverpod
Future<AttachmentArchiveStatsReader> attachmentArchiveStatsReader(
  AttachmentArchiveStatsReaderRef ref,
) async {
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return AttachmentArchiveStatsRepository(
    archiveDirectoryPath: ref.watch(attachmentArchiveDirectoryProvider),
    overlayDatabase: overlayDb,
  );
}
