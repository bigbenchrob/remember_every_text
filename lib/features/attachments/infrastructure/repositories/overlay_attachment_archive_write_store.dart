import 'package:drift/drift.dart';
import 'package:path/path.dart' as path;

import '../../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';
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
  Future<bool> hasArchiveRecord(ArchiveCompatibilityKey archiveKey) async {
    final existing =
        await (_overlayDatabase.select(_overlayDatabase.archivedAttachments)
              ..where(
                (t) =>
                    t.messageGuid.equals(archiveKey.messageGuid) &
                    t.importAttachmentId.equals(archiveKey.importAttachmentId),
              ))
            .getSingleOrNull();
    return existing != null;
  }

  @override
  Future<void> writeArchiveRecord(ArchivedAttachmentWrite record) async {
    if (!_isSafeArchiveRelativePath(record.archiveRelativePath)) {
      throw StateError('Archive relative path must stay inside the archive.');
    }

    await _overlayDatabase
        .into(_overlayDatabase.archivedAttachments)
        .insert(
          ArchivedAttachmentsCompanion.insert(
            messageGuid: record.archiveKey.messageGuid,
            importAttachmentId: record.archiveKey.importAttachmentId,
            archiveRelativePath: record.archiveRelativePath,
            archivedAtUtc: record.archivedAtUtc,
            fileSizeBytes: record.fileSizeBytes,
            contentHash: Value(record.contentHash),
            provenance: Value(record.provenance),
            originalLocalPath: Value(record.originalLocalPath),
          ),
        );
  }

  @override
  Future<void> reconcileArchiveRecord(ArchivedAttachmentWrite record) async {
    if (!_isSafeArchiveRelativePath(record.archiveRelativePath)) {
      throw StateError('Archive relative path must stay inside the archive.');
    }

    await _overlayDatabase.transaction(() async {
      final existing =
          await (_overlayDatabase.select(_overlayDatabase.archivedAttachments)
                ..where(
                  (t) =>
                      t.messageGuid.equals(record.archiveKey.messageGuid) &
                      t.importAttachmentId.equals(
                        record.archiveKey.importAttachmentId,
                      ),
                ))
              .getSingleOrNull();
      if (existing == null) {
        await writeArchiveRecord(record);
        return;
      }

      await (_overlayDatabase.update(
        _overlayDatabase.archivedAttachments,
      )..where((t) => t.id.equals(existing.id))).write(
        ArchivedAttachmentsCompanion(
          archiveRelativePath: Value(record.archiveRelativePath),
          archivedAtUtc: Value(record.archivedAtUtc),
          fileSizeBytes: Value(record.fileSizeBytes),
          contentHash: Value(record.contentHash),
          provenance: Value(record.provenance),
          originalLocalPath: Value(record.originalLocalPath),
        ),
      );
    });
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
  Future<AttachmentRecoveryMetadata?> readRecoveryHint(
    ArchiveCompatibilityKey archiveKey,
  ) async {
    final hintKey = attachmentRecoveryHintSettingKey(archiveKey: archiveKey);
    return decodeAttachmentRecoveryHint(
      await _overlayDatabase.readOverlaySetting(hintKey),
    );
  }

  @override
  Future<void> writeRecoveryHint({
    required ArchiveCompatibilityKey archiveKey,
    required AttachmentRecoveryMetadata metadata,
  }) {
    final hintKey = attachmentRecoveryHintSettingKey(archiveKey: archiveKey);
    return _overlayDatabase.writeOverlaySetting(
      settingKey: hintKey,
      settingValue: encodeAttachmentRecoveryHint(metadata),
    );
  }

  @override
  Future<void> clearRecoveryHint(ArchiveCompatibilityKey archiveKey) {
    final hintKey = attachmentRecoveryHintSettingKey(archiveKey: archiveKey);
    return (_overlayDatabase.delete(
      _overlayDatabase.overlaySettings,
    )..where((tbl) => tbl.key.equals(hintKey))).go();
  }

  static bool _isSafeArchiveRelativePath(String relativePath) {
    if (relativePath.isEmpty || path.isAbsolute(relativePath)) {
      return false;
    }

    final normalized = path.normalize(relativePath);
    return normalized != '.' &&
        normalized != '..' &&
        !normalized.startsWith('../');
  }
}
