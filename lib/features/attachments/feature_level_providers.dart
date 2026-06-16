import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/db/feature_level_providers.dart';
import '../../essentials/source_scoped_import/feature_level_providers.dart';
import '../../providers.dart';
import 'application/attachment_archive_file_operations.dart';
import 'application/attachment_archive_file_store.dart';
import 'application/attachment_archive_read_store.dart';
import 'application/attachment_archive_settings_store.dart';
import 'application/attachment_archive_stats_reader.dart';
import 'application/attachment_archive_write_store.dart';
import 'application/attachment_file_access.dart';
import 'application/cross_snapshot_mapper.dart';
import 'application/current_attachment_snapshot_lookup.dart';
import 'application/current_messages_attachment_path_lookup.dart';
import 'application/graph_attachment_archive_candidate_reader.dart';
import 'application/graph_attachment_archive_lookup.dart';
import 'application/historical_snapshot_reader.dart';
import 'application/recovered_attachment_archive_writer.dart';
import 'application/video_thumbnail_cache.dart';
import 'infrastructure/repositories/attachment_archive_stats_repository.dart';
import 'infrastructure/repositories/filesystem_attachment_archive_file_operations.dart';
import 'infrastructure/repositories/filesystem_attachment_archive_file_store.dart';
import 'infrastructure/repositories/graph_cross_snapshot_mapper.dart';
import 'infrastructure/repositories/local_attachment_file_access.dart';
import 'infrastructure/repositories/overlay_archive_compatibility_lookup.dart';
import 'infrastructure/repositories/overlay_attachment_archive_read_store.dart';
import 'infrastructure/repositories/overlay_attachment_archive_settings_store.dart';
import 'infrastructure/repositories/overlay_attachment_archive_write_store.dart';
import 'infrastructure/repositories/overlay_recovered_attachment_archive_writer.dart';
import 'infrastructure/repositories/source_database_attachment_path_lookup.dart';
import 'infrastructure/repositories/source_scoped_attachment_snapshot_lookup.dart';
import 'infrastructure/repositories/sqlite_graph_attachment_archive_candidate_reader.dart';
import 'infrastructure/repositories/sqlite_historical_snapshot_reader.dart';
import 'infrastructure/services/video_thumbnail_cache_service.dart';

export 'application/archive_compatibility_key.dart';
export 'application/archive_settings_provider.dart';
export 'application/attachment_archive_service_provider.dart';
export 'application/attachment_archive_write_store.dart';
export 'application/attachment_file_access.dart';
export 'application/attachment_resolver_provider.dart';
export 'application/deterministic_recovery_provider.dart';
export 'application/graph_attachment_archive_candidate_reader.dart';
export 'application/graph_attachment_archive_lookup.dart';
export 'application/video_thumbnail_cache.dart';

part 'feature_level_providers.g.dart';

@riverpod
String attachmentArchiveDirectoryPath(AttachmentArchiveDirectoryPathRef ref) {
  return ref.watch(attachmentArchiveDirectoryProvider);
}

@riverpod
AttachmentFileAccess attachmentFileAccess(AttachmentFileAccessRef ref) {
  return const LocalAttachmentFileAccess();
}

@riverpod
AttachmentArchiveFileOperations attachmentArchiveFileOperations(
  AttachmentArchiveFileOperationsRef ref,
) {
  return const FilesystemAttachmentArchiveFileOperations();
}

@riverpod
AttachmentArchiveFileStore attachmentArchiveFileStore(
  AttachmentArchiveFileStoreRef ref,
) {
  return const FilesystemAttachmentArchiveFileStore();
}

@riverpod
Future<AttachmentArchiveSettingsStore> attachmentArchiveSettingsStore(
  AttachmentArchiveSettingsStoreRef ref,
) async {
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return OverlayAttachmentArchiveSettingsStore(overlayDb: overlayDb);
}

@riverpod
Future<AttachmentArchiveReadStore> attachmentArchiveReadStore(
  AttachmentArchiveReadStoreRef ref,
) async {
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return OverlayAttachmentArchiveReadStore(
    overlayDb: overlayDb,
    archiveDirectory: ref.watch(attachmentArchiveDirectoryProvider),
  );
}

@riverpod
Future<AttachmentArchiveWriteStore> attachmentArchiveWriteStore(
  AttachmentArchiveWriteStoreRef ref,
) async {
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return OverlayAttachmentArchiveWriteStore(overlayDatabase: overlayDb);
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

@Riverpod(keepAlive: true)
VideoThumbnailCache videoThumbnailCache(VideoThumbnailCacheRef ref) {
  return VideoThumbnailCacheService();
}

@riverpod
Future<GraphAttachmentArchiveLookup> graphAttachmentArchiveLookup(
  GraphAttachmentArchiveLookupRef ref,
) async {
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return OverlayArchiveCompatibilityLookup(
    graphDatabase: graphDb,
    overlayDatabase: overlayDb,
    archiveDirectory: ref.watch(attachmentArchiveDirectoryProvider),
  );
}

@riverpod
Future<GraphAttachmentArchiveCandidateReader>
graphAttachmentArchiveCandidateReader(
  GraphAttachmentArchiveCandidateReaderRef ref,
) async {
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return SqliteGraphAttachmentArchiveCandidateReader(
    graphDatabase: graphDb,
    overlayDatabase: overlayDb,
  );
}

@riverpod
Future<CrossSnapshotMapper> crossSnapshotMapper(
  CrossSnapshotMapperRef ref,
) async {
  final attachmentLookup = await ref.watch(
    currentAttachmentSnapshotLookupProvider.future,
  );
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return GraphCrossSnapshotMapper(
    attachmentLookup: attachmentLookup,
    graphDb: graphDb,
  );
}

@riverpod
Future<CurrentAttachmentSnapshotLookup> currentAttachmentSnapshotLookup(
  CurrentAttachmentSnapshotLookupRef ref,
) async {
  final importLedgerDb = await ref.watch(
    sourceScopedImportDatabaseProvider.future,
  );
  return SourceScopedAttachmentSnapshotLookup(importLedgerDb: importLedgerDb);
}

@riverpod
Future<RecoveredAttachmentArchiveWriter> recoveredAttachmentArchiveWriter(
  RecoveredAttachmentArchiveWriterRef ref,
) async {
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return OverlayRecoveredAttachmentArchiveWriter(
    overlayDb: overlayDb,
    archiveDir: ref.watch(attachmentArchiveDirectoryProvider),
  );
}

@riverpod
HistoricalSnapshotReaderFactory historicalSnapshotReaderFactory(
  HistoricalSnapshotReaderFactoryRef ref,
) {
  return const SqliteHistoricalSnapshotReaderFactory();
}

@riverpod
Future<CurrentMessagesAttachmentPathLookup> currentMessagesAttachmentPathLookup(
  CurrentMessagesAttachmentPathLookupRef ref,
) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  return SourceDatabaseAttachmentPathLookup(
    databasePath: pathsHelper.chatDBPath,
    sourceDatabaseOpener: ref.watch(sourceDatabaseOpenerProvider),
  );
}
