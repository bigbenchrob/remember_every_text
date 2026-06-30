import '../domain/entities/attachment_archive_stats.dart';

abstract interface class AttachmentArchiveStatsReader {
  Future<AttachmentArchiveStats> readStats();
}
