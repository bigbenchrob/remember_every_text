import 'dart:io';

import 'package:drift/drift.dart';

import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../../../essentials/retained_archive/domain/archive_compatibility_key.dart';
import '../../application/attachment_archive_read_store.dart';
import '../../application/attachment_recovery_hint_storage.dart';
import '../../domain/entities/attachment_recovery_metadata.dart';

class OverlayAttachmentArchiveReadStore implements AttachmentArchiveReadStore {
  const OverlayAttachmentArchiveReadStore({
    required OverlayDatabase overlayDb,
    required String archiveDirectory,
  }) : _overlayDb = overlayDb,
       _archiveDirectory = archiveDirectory;

  final OverlayDatabase _overlayDb;
  final String _archiveDirectory;

  @override
  Future<AttachmentArchiveLookupRecord?> readArchiveRecord(
    ArchiveCompatibilityKey archiveKey,
  ) async {
    final archiveRows = await _overlayDb
        .customSelect(
          '''
          SELECT archive_relative_path, provenance
          FROM archived_attachments
          WHERE message_guid = ? AND import_attachment_id = ?
          LIMIT 1
          ''',
          variables: [
            Variable<String>(archiveKey.messageGuid),
            Variable<int>(archiveKey.importAttachmentId),
          ],
        )
        .get();

    if (archiveRows.isEmpty) {
      return null;
    }

    final row = archiveRows.single;
    final relativePath = row.read<String>('archive_relative_path');
    final absolutePath = '$_archiveDirectory/$relativePath';
    return AttachmentArchiveLookupRecord(
      archiveRelativePath: relativePath,
      archiveAbsolutePath: absolutePath,
      archiveFileExists: File(absolutePath).existsSync(),
      provenance: row.readNullable<String>('provenance'),
    );
  }

  @override
  Future<AttachmentRecoveryMetadata?> readRecoveryHint(
    ArchiveCompatibilityKey archiveKey,
  ) async {
    return decodeAttachmentRecoveryHint(
      await _overlayDb.readOverlaySetting(
        attachmentRecoveryHintSettingKey(archiveKey: archiveKey),
      ),
    );
  }
}
