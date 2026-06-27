import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart'
    show
        attachmentArchiveDirectoryProvider,
        driftConversationGraphDatabaseProvider,
        overlayDatabaseProvider,
        sourceScopedImportDatabaseProvider;
import '../../../essentials/paths/feature_level_providers.dart';
import '../../../essentials/source_scoped_import/feature_level_providers.dart'
    show sourceDatabaseOpenerProvider;
import '../infrastructure/repositories/overlay_archive_compatibility_lookup.dart';
import '../infrastructure/repositories/source_database_attachment_path_lookup.dart';
import '../infrastructure/repositories/source_scoped_attachment_snapshot_lookup.dart';
import '../infrastructure/repositories/sqlite_graph_attachment_archive_candidate_reader.dart';
import 'current_attachment_snapshot_lookup.dart';
import 'current_messages_attachment_path_lookup.dart';
import 'graph_attachment_archive_candidate_reader.dart';
import 'graph_attachment_archive_lookup.dart';

part 'graph_attachment_archive_providers.g.dart';

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
Future<CurrentAttachmentSnapshotLookup> currentAttachmentSnapshotLookup(
  CurrentAttachmentSnapshotLookupRef ref,
) async {
  final importLedgerDb = await ref.watch(
    sourceScopedImportDatabaseProvider.future,
  );
  return SourceScopedAttachmentSnapshotLookup(importLedgerDb: importLedgerDb);
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
