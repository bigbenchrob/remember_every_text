import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/cross_snapshot_mapping.dart';
import '../../application/recovered_attachment_archive_writer.dart';

class OverlayRecoveredAttachmentArchiveWriter
    implements RecoveredAttachmentArchiveWriter {
  const OverlayRecoveredAttachmentArchiveWriter({
    required OverlayDatabase overlayDb,
    required String archiveDir,
  }) : _overlayDb = overlayDb,
       _archiveDir = archiveDir;

  final OverlayDatabase _overlayDb;
  final String _archiveDir;

  @override
  Future<int?> archive(MappedAttachmentRecord record) async {
    if (_isSymlink(_archiveDir)) {
      throw StateError('Attachment archive directory must not be a symlink.');
    }
    if (!_isRegularFile(record.resolvedFilePath)) {
      throw StateError('Recovered attachment source must be a regular file.');
    }

    final archiveKey = record.currentArchiveCompatibilityKey;
    final existing =
        await (_overlayDb.select(_overlayDb.archivedAttachments)..where(
              (t) =>
                  t.messageGuid.equals(archiveKey.messageGuid) &
                  t.importAttachmentId.equals(archiveKey.importAttachmentId),
            ))
            .getSingleOrNull();

    if (existing != null) {
      return null;
    }

    final sourceFile = File(record.resolvedFilePath);
    final bytes = await sourceFile.readAsBytes();
    final contentHash = sha256.convert(bytes).toString();

    final ext = p.extension(record.resolvedFilePath).toLowerCase();
    final prefix = contentHash.substring(0, 2);
    final relativePath = '$prefix/$contentHash$ext';
    final destFile = File('$_archiveDir/$relativePath');
    if (_isSymlink(destFile.path) || _isDirectory(destFile.path)) {
      throw StateError(
        'Recovered attachment archive destination must be a regular file path.',
      );
    }

    if (!destFile.existsSync()) {
      await destFile.parent.create(recursive: true);
      await sourceFile.copy(destFile.path);

      final verifyBytes = await destFile.readAsBytes();
      final verifyHash = sha256.convert(verifyBytes).toString();
      if (verifyHash != contentHash) {
        await destFile.delete();
        throw StateError(
          'Archive integrity check failed: hash mismatch after copy',
        );
      }
    }

    final fileSize = await destFile.length();

    await _overlayDb
        .into(_overlayDb.archivedAttachments)
        .insert(
          ArchivedAttachmentsCompanion.insert(
            messageGuid: archiveKey.messageGuid,
            importAttachmentId: archiveKey.importAttachmentId,
            archiveRelativePath: relativePath,
            archivedAtUtc: DateTime.now().toUtc().toIso8601String(),
            fileSizeBytes: fileSize,
            contentHash: Value(contentHash),
            provenance: const Value('imported_historical_snapshot'),
            originalLocalPath: Value(record.histLocalPath ?? ''),
          ),
        );

    return fileSize;
  }

  static bool _isRegularFile(String filePath) {
    return FileSystemEntity.typeSync(filePath, followLinks: false) ==
        FileSystemEntityType.file;
  }

  static bool _isDirectory(String filePath) {
    return FileSystemEntity.typeSync(filePath, followLinks: false) ==
        FileSystemEntityType.directory;
  }

  static bool _isSymlink(String filePath) {
    return FileSystemEntity.typeSync(filePath, followLinks: false) ==
        FileSystemEntityType.link;
  }
}
