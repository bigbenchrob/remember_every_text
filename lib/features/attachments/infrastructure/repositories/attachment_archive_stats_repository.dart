import 'dart:io';

import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/attachment_archive_stats_reader.dart';
import '../../domain/entities/attachment_archive_stats.dart';

final class AttachmentArchiveStatsRepository
    implements AttachmentArchiveStatsReader {
  const AttachmentArchiveStatsRepository({
    required String archiveDirectoryPath,
    required OverlayDatabase overlayDatabase,
  }) : _archiveDirectoryPath = archiveDirectoryPath,
       _overlayDatabase = overlayDatabase;

  final String _archiveDirectoryPath;
  final OverlayDatabase _overlayDatabase;

  @override
  Future<AttachmentArchiveStats> readStats() async {
    var sizeBytes = 0;
    if (_isDirectory(_archiveDirectoryPath)) {
      final dir = Directory(_archiveDirectoryPath);
      await for (final entity in dir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File && _isRegularFile(entity.path)) {
          sizeBytes += await entity.length();
        }
      }
    }

    final countResult = await _overlayDatabase
        .customSelect('SELECT COUNT(*) AS cnt FROM archived_attachments')
        .getSingle();

    return AttachmentArchiveStats(
      recordCount: countResult.read<int>('cnt'),
      sizeBytes: sizeBytes,
    );
  }

  static bool _isDirectory(String path) {
    return FileSystemEntity.typeSync(path, followLinks: false) ==
        FileSystemEntityType.directory;
  }

  static bool _isRegularFile(String path) {
    return FileSystemEntity.typeSync(path, followLinks: false) ==
        FileSystemEntityType.file;
  }
}
