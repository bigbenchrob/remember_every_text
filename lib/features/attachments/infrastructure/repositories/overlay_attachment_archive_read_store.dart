import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as path;

import '../../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
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
  Future<Map<ArchiveCompatibilityKey, AttachmentArchiveMetadataRecord>>
  readAllArchiveMetadata() async {
    final rows = await _overlayDb.customSelect('''
          SELECT message_guid, import_attachment_id, archive_relative_path,
                 file_size_bytes, content_hash, provenance
          FROM archived_attachments
          ''').get();
    final records =
        <ArchiveCompatibilityKey, AttachmentArchiveMetadataRecord>{};
    for (final row in rows) {
      final key = ArchiveCompatibilityKey.fromStoredTuple(
        messageGuid: row.read<String>('message_guid'),
        importAttachmentId: row.read<int>('import_attachment_id'),
      );
      final relativePath = row.read<String>('archive_relative_path');
      if (_boundedArchivePath(
            archiveDirectory: _archiveDirectory,
            relativePath: relativePath,
          ) ==
          null) {
        continue;
      }
      records[key] = AttachmentArchiveMetadataRecord(
        archiveRelativePath: relativePath,
        fileSizeBytes: row.read<int>('file_size_bytes'),
        contentHash: row.readNullable<String>('content_hash'),
      );
    }
    return records;
  }

  @override
  Future<AttachmentArchiveLookupRecord?> readArchiveRecord(
    ArchiveCompatibilityKey archiveKey,
  ) async {
    final archiveRows = await _overlayDb
        .customSelect(
          '''
          SELECT archive_relative_path, file_size_bytes, content_hash,
                 provenance
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
    final absolutePath = _boundedArchivePath(
      archiveDirectory: _archiveDirectory,
      relativePath: relativePath,
    );
    if (absolutePath == null) {
      return null;
    }

    return AttachmentArchiveLookupRecord(
      archiveRelativePath: relativePath,
      archiveAbsolutePath: absolutePath,
      archiveFileExists: _regularFileExists(absolutePath),
      fileSizeBytes: row.read<int>('file_size_bytes'),
      contentHash: row.readNullable<String>('content_hash'),
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

  static String? _boundedArchivePath({
    required String archiveDirectory,
    required String relativePath,
  }) {
    if (archiveDirectory.isEmpty ||
        relativePath.isEmpty ||
        path.isAbsolute(relativePath)) {
      return null;
    }

    final archiveRoot = path.normalize(path.absolute(archiveDirectory));
    final absolutePath = path.normalize(path.join(archiveRoot, relativePath));
    if (!path.isWithin(archiveRoot, absolutePath)) {
      return null;
    }

    return absolutePath;
  }

  static bool _regularFileExists(String filePath) {
    return FileSystemEntity.typeSync(filePath, followLinks: false) ==
        FileSystemEntityType.file;
  }
}
