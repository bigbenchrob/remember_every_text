import '../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';

class GraphAttachmentArchiveCandidate {
  const GraphAttachmentArchiveCandidate({
    required this.graphAttachmentId,
    required this.archiveCompatibilityKey,
    required this.localPath,
    required this.mimeType,
    required this.sha256Hex,
  });

  final int? graphAttachmentId;
  final ArchiveCompatibilityKey? archiveCompatibilityKey;
  final String? localPath;
  final String? mimeType;
  final String? sha256Hex;
}

class GraphAttachmentSweepSelection {
  const GraphAttachmentSweepSelection({
    required this.rows,
    required this.nextCursor,
  });

  final List<GraphAttachmentArchiveCandidate> rows;
  final int nextCursor;
}

abstract interface class GraphAttachmentArchiveCandidateReader {
  Future<List<GraphAttachmentArchiveCandidate>> readSourceRange({
    required int sourceId,
    required int startedAfterSourceRowId,
    required int lastSourceRowId,
  });

  /// Selects unarchived live attachments with a declared MIME type.
  ///
  /// NULL or blank MIME rows are opaque payloads and remain outside delayed
  /// retry until their preservation semantics are explicitly defined.
  Future<GraphAttachmentSweepSelection> selectSweepCandidates({
    required int afterAttachmentId,
    required int limit,
    required int pageSize,
  });

  Future<List<GraphAttachmentArchiveCandidate>> readAllAvailableLive();
}
