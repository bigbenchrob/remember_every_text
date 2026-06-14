class GraphAttachmentArchiveCandidate {
  const GraphAttachmentArchiveCandidate({
    required this.graphAttachmentId,
    required this.messageGuid,
    required this.importAttachmentId,
    required this.localPath,
    required this.mimeType,
    required this.sha256Hex,
  });

  final int? graphAttachmentId;
  final String messageGuid;
  final int? importAttachmentId;
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

  Future<GraphAttachmentSweepSelection> selectSweepCandidates({
    required int afterAttachmentId,
    required int limit,
    required int pageSize,
  });

  Future<List<GraphAttachmentArchiveCandidate>> readAllAvailableLive();
}
