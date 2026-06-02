import 'dart:io';

import 'package:drift/drift.dart';

import '../../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../../../essentials/source_scoped_import/domain/known_sources.dart';
import '../../../../essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import '../../application/graph_attachment_archive_lookup.dart';

/// Resolves graph attachment identity against existing archive overlay rows.
///
/// The current archive table is still keyed by the legacy pair
/// `(message_guid, import_attachment_id)`. For live `chat.db` rows,
/// `import_attachment_id` is the source attachment ROWID and can be derived
/// from `attachment_ss_id`.
///
/// This is an explicit compatibility bridge. It must not become the model for
/// non-live sources because the legacy key does not carry source scope.
class OverlayArchiveCompatibilityLookup
    implements GraphAttachmentArchiveLookup {
  const OverlayArchiveCompatibilityLookup({
    required this.graphDatabase,
    required this.overlayDatabase,
    required this.archiveDirectory,
  });

  final ConversationGraphDatabase graphDatabase;
  final OverlayDatabase overlayDatabase;
  final String archiveDirectory;

  @override
  Future<GraphAttachmentArchiveRecord?> readArchiveRecord({
    required int messageSsId,
    required int attachmentSsId,
  }) async {
    if (archiveDirectory.isEmpty) {
      return null;
    }

    final attachmentSourceId = SourceScopedRowKey.unpackSourceId(
      attachmentSsId,
    );
    if (attachmentSourceId != liveChatDbSourceId) {
      return null;
    }

    final messageRows = await graphDatabase.selectRows(
      '''
      SELECT m.guid AS message_guid
      FROM message_to_attachment mta
      JOIN messages m ON m.ss_id = mta.message_ss_id
      WHERE mta.message_ss_id = ?
        AND mta.attachment_ss_id = ?
      LIMIT 1
      ''',
      <Object?>[messageSsId, attachmentSsId],
    );
    if (messageRows.isEmpty) {
      return null;
    }

    final messageGuid = messageRows.single['message_guid'];
    if (messageGuid is! String || messageGuid.isEmpty) {
      return null;
    }

    final legacyImportAttachmentId = SourceScopedRowKey.unpackSourceRowId(
      attachmentSsId,
    );
    final archiveRows = await overlayDatabase
        .customSelect(
          '''
          SELECT archive_relative_path
          FROM archived_attachments
          WHERE message_guid = ? AND import_attachment_id = ?
          LIMIT 1
          ''',
          variables: [
            Variable<String>(messageGuid),
            Variable<int>(legacyImportAttachmentId),
          ],
        )
        .get();
    if (archiveRows.isEmpty) {
      return null;
    }

    final relativePath = archiveRows.single.read<String>(
      'archive_relative_path',
    );
    final absolutePath = '$archiveDirectory/$relativePath';
    return GraphAttachmentArchiveRecord(
      archiveRelativePath: relativePath,
      archiveAbsolutePath: absolutePath,
      archiveFileExists: File(absolutePath).existsSync(),
      legacyImportAttachmentId: legacyImportAttachmentId,
    );
  }
}
