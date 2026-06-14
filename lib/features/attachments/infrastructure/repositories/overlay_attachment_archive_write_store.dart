import 'package:drift/drift.dart';

import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/attachment_archive_write_store.dart';
import '../../application/attachment_recovery_hint_storage.dart';
import '../../domain/entities/attachment_recovery_metadata.dart';

class OverlayAttachmentArchiveWriteStore
    implements AttachmentArchiveWriteStore {
  const OverlayAttachmentArchiveWriteStore({
    required OverlayDatabase overlayDatabase,
  }) : _overlayDatabase = overlayDatabase;

  final OverlayDatabase _overlayDatabase;

  @override
  Future<bool> hasArchiveRecord({
    required String messageGuid,
    required int importAttachmentId,
  }) async {
    final existing =
        await (_overlayDatabase.select(_overlayDatabase.archivedAttachments)
              ..where(
                (t) =>
                    t.messageGuid.equals(messageGuid) &
                    t.importAttachmentId.equals(importAttachmentId),
              ))
            .getSingleOrNull();
    return existing != null;
  }

  @override
  Future<void> writeArchiveRecord(ArchivedAttachmentWrite record) {
    return _overlayDatabase
        .into(_overlayDatabase.archivedAttachments)
        .insert(
          ArchivedAttachmentsCompanion.insert(
            messageGuid: record.messageGuid,
            importAttachmentId: record.importAttachmentId,
            archiveRelativePath: record.archiveRelativePath,
            archivedAtUtc: record.archivedAtUtc,
            fileSizeBytes: record.fileSizeBytes,
            contentHash: Value(record.contentHash),
            originalLocalPath: Value(record.originalLocalPath),
          ),
        );
  }

  @override
  Future<List<ArchiveIntegrityEntry>> readIntegrityEntries() async {
    final rows = await _overlayDatabase
        .customSelect(
          'SELECT id, archive_relative_path, content_hash '
          'FROM archived_attachments',
        )
        .get();
    return rows
        .map(
          (row) => ArchiveIntegrityEntry(
            id: row.read<int>('id'),
            relativePath: row.read<String>('archive_relative_path'),
            contentHash: row.readNullable<String>('content_hash'),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<AttachmentRecoveryMetadata?> readRecoveryHint({
    required String messageGuid,
    required int importAttachmentId,
  }) async {
    final hintKey = attachmentRecoveryHintSettingKey(
      messageGuid: messageGuid,
      importAttachmentId: importAttachmentId,
    );
    return decodeAttachmentRecoveryHint(
      await _overlayDatabase.readOverlaySetting(hintKey),
    );
  }

  @override
  Future<void> writeRecoveryHint({
    required String messageGuid,
    required int importAttachmentId,
    required AttachmentRecoveryMetadata metadata,
  }) {
    final hintKey = attachmentRecoveryHintSettingKey(
      messageGuid: messageGuid,
      importAttachmentId: importAttachmentId,
    );
    return _overlayDatabase.writeOverlaySetting(
      settingKey: hintKey,
      settingValue: encodeAttachmentRecoveryHint(metadata),
    );
  }

  @override
  Future<void> clearRecoveryHint({
    required String messageGuid,
    required int importAttachmentId,
  }) {
    final hintKey = attachmentRecoveryHintSettingKey(
      messageGuid: messageGuid,
      importAttachmentId: importAttachmentId,
    );
    return (_overlayDatabase.delete(
      _overlayDatabase.overlaySettings,
    )..where((tbl) => tbl.key.equals(hintKey))).go();
  }
}
