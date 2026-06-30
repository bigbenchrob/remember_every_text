import 'dart:io';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:path/path.dart' as path;

import '../../application/attachment_archive_file_operations.dart';

class FilesystemAttachmentArchiveFileOperations
    implements AttachmentArchiveFileOperations {
  const FilesystemAttachmentArchiveFileOperations();

  @override
  Future<void> resetArchiveDirectory(String archiveDirectoryPath) async {
    if (FileSystemEntity.typeSync(archiveDirectoryPath, followLinks: false) ==
        FileSystemEntityType.link) {
      throw StateError('Attachment archive directory must not be a symlink.');
    }

    final directory = Directory(archiveDirectoryPath);
    if (directory.existsSync()) {
      await directory.delete(recursive: true);
    }
    await directory.create(recursive: true);
  }

  @override
  Future<int?> exportArchiveDirectory(String archiveDirectoryPath) async {
    if (_isSymlink(archiveDirectoryPath)) {
      throw StateError('Attachment archive directory must not be a symlink.');
    }

    final sourceDirectory = Directory(archiveDirectoryPath);
    if (!sourceDirectory.existsSync()) {
      return 0;
    }

    final destinationPath = await FileSelectorPlatform.instance
        .getDirectoryPathWithOptions(
          const FileDialogOptions(confirmButtonText: 'Export Here'),
        );

    if (destinationPath == null) {
      return null;
    }

    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final exportDirectory = Directory(
      path.join(destinationPath, '$timestamp-messagelens-archive'),
    );
    await exportDirectory.create(recursive: true);

    var filesCopied = 0;
    await for (final entity in sourceDirectory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is File) {
        final relativePath = path.relative(
          entity.path,
          from: archiveDirectoryPath,
        );
        final destinationFile = File(
          path.join(exportDirectory.path, relativePath),
        );
        await destinationFile.parent.create(recursive: true);
        await entity.copy(destinationFile.path);
        filesCopied++;
      }
    }

    return filesCopied;
  }

  static bool _isSymlink(String filePath) {
    return FileSystemEntity.typeSync(filePath, followLinks: false) ==
        FileSystemEntityType.link;
  }
}
