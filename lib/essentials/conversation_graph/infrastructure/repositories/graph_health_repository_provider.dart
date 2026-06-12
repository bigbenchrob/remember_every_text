import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../application/health/graph_health_repository.dart';
import 'graph_health_repository.dart';

part 'graph_health_repository_provider.g.dart';

const _recoveredMessagesFolderPath =
    '/Volumes/WD_ELEMENTS/DO_NOT_LOSE/iMessages_backup/'
    'Messages-bkp-2026-03-29';
const _recoveredMessagesAttachmentsFolderName = 'Attachments-2026-03-29';
const _historicalMessageLensDataFolderPath =
    '/Volumes/WD_ELEMENTS/DATA_FOLDER_WITH_ALL_RECENT_IMAGES_WAS_RENAMED/'
    'com.bigbenchsoftware.MessageLens';

@riverpod
Future<GraphHealthRepository> graphHealthRepository(
  GraphHealthRepositoryRef ref,
) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  final archiveDirectory = ref.watch(attachmentArchiveDirectoryProvider);
  return SqliteGraphHealthRepository(
    graphDatabase: graphDatabase,
    overlayDatabase: overlayDatabase,
    attachmentArchiveDirectory: archiveDirectory,
    historicalMessageLensDataFolderPath: _historicalMessageLensDataFolderPath,
    recoveredMessagesFolderPath: _recoveredMessagesFolderPath,
    recoveredMessagesAttachmentsFolderName:
        _recoveredMessagesAttachmentsFolderName,
  );
}
