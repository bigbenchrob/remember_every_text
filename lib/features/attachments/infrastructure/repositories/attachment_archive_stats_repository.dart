import 'dart:io';

import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../domain/entities/attachment_archive_stats.dart';

final class AttachmentArchiveStatsRepository {
  const AttachmentArchiveStatsRepository({
    required String archiveDirectoryPath,
    required OverlayDatabase overlayDatabase,
  }) : _archiveDirectoryPath = archiveDirectoryPath,
       _overlayDatabase = overlayDatabase;

  final String _archiveDirectoryPath;
  final OverlayDatabase _overlayDatabase;

  Future<AttachmentArchiveStats> readStats() async {
    var sizeBytes = 0;
    final dir = Directory(_archiveDirectoryPath);
    if (dir.existsSync()) {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
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
}
