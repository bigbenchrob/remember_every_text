import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

import '../../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import '../../application/attachment_archive_file_store.dart';

class FilesystemAttachmentArchiveFileStore
    implements AttachmentArchiveFileStore {
  const FilesystemAttachmentArchiveFileStore();

  @override
  String expandHomePath(String rawPath) {
    if (rawPath.startsWith('~/')) {
      final home = Platform.environment['HOME'] ?? '';
      if (home.isNotEmpty) {
        return rawPath.replaceFirst('~', home);
      }
    }
    return rawPath;
  }

  @override
  bool fileExists(String path) {
    return File(path).existsSync();
  }

  @override
  Future<void> ensureArchiveDirectory(String archiveDirectoryPath) async {
    await Directory(archiveDirectoryPath).create(recursive: true);
  }

  @override
  Future<ArchivedAttachmentFileWrite?> writeArchiveEntry({
    required String archiveDirectoryPath,
    required String sourcePath,
    required ArchiveCompatibilityKey archiveKey,
    required String? sha256Hex,
  }) async {
    final sourceFile = File(sourcePath);
    if (!sourceFile.existsSync()) {
      return null;
    }

    final contentHash = sha256Hex ?? await _computeSha256(sourceFile);
    final extension = path.extension(sourcePath).toLowerCase();
    final String relativePath;
    if (contentHash != null && contentHash.length >= 2) {
      final prefix = contentHash.substring(0, 2);
      relativePath = '$prefix/$contentHash$extension';
    } else {
      relativePath =
          '_by_id/${archiveKey.archiveCompatibilityAttachmentId}$extension';
    }

    final destinationFile = File(path.join(archiveDirectoryPath, relativePath));
    await destinationFile.parent.create(recursive: true);
    await sourceFile.copy(destinationFile.path);

    return ArchivedAttachmentFileWrite(
      sourcePath: sourcePath,
      relativePath: relativePath,
      fileSizeBytes: await destinationFile.length(),
      contentHash: contentHash,
    );
  }

  @override
  Future<ArchiveIntegrityFileCheck> checkIntegrity({
    required String archiveDirectoryPath,
    required String relativePath,
    required String? storedHash,
  }) async {
    final file = File(path.join(archiveDirectoryPath, relativePath));
    if (!file.existsSync()) {
      return const ArchiveIntegrityFileCheck(
        fileExists: false,
        hashMatches: null,
        actualHash: null,
      );
    }

    if (storedHash == null || storedHash.isEmpty) {
      return const ArchiveIntegrityFileCheck(
        fileExists: true,
        hashMatches: null,
        actualHash: null,
      );
    }

    final actualHash = await _computeSha256(file);
    return ArchiveIntegrityFileCheck(
      fileExists: true,
      hashMatches: actualHash == storedHash,
      actualHash: actualHash,
    );
  }

  static Future<String?> _computeSha256(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return sha256.convert(bytes).toString();
    } on Exception {
      return null;
    }
  }
}
