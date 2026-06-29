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
    if (_isSymlink(archiveDirectoryPath)) {
      throw StateError('Attachment archive directory must not be a symlink.');
    }
    await Directory(archiveDirectoryPath).create(recursive: true);
  }

  @override
  Future<ArchivedAttachmentFileWrite?> writeArchiveEntry({
    required String archiveDirectoryPath,
    required String sourcePath,
    required ArchiveCompatibilityKey archiveKey,
    required String? sha256Hex,
  }) async {
    if (_isSymlink(archiveDirectoryPath)) {
      throw StateError('Attachment archive directory must not be a symlink.');
    }

    final sourceFile = File(sourcePath);
    if (!_isRegularFile(sourcePath)) {
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
    if (_isSymlink(destinationFile.path) ||
        _isDirectory(destinationFile.path)) {
      throw StateError(
        'Attachment archive destination must be a regular file path.',
      );
    }

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
