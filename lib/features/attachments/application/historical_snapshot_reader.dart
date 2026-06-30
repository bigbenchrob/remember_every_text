/// A single historical message↔attachment record from the snapshot.
class HistoricalAttachmentRecord {
  const HistoricalAttachmentRecord({
    required this.histMessageGuid,
    required this.histAttachmentGuid,
    required this.histLocalPath,
    required this.resolvedFilePath,
    required this.fileFound,
    required this.histTransferName,
    required this.histMimeType,
    required this.histUti,
    required this.histFileSize,
    required this.histIsOutgoing,
  });

  final String histMessageGuid;
  final String? histAttachmentGuid;
  final String? histLocalPath;
  final String? resolvedFilePath;
  final bool fileFound;
  final String? histTransferName;
  final String? histMimeType;
  final String? histUti;
  final int? histFileSize;
  final bool histIsOutgoing;
}

/// Summary of a snapshot enumeration pass.
class SnapshotEnumerationResult {
  const SnapshotEnumerationResult({
    required this.records,
    required this.totalHistoricalPairs,
    required this.filesFound,
    required this.filesMissing,
    required this.nullPathRecords,
    required this.walDetected,
    required this.shmDetected,
  });

  final List<HistoricalAttachmentRecord> records;
  final int totalHistoricalPairs;
  final int filesFound;
  final int filesMissing;
  final int nullPathRecords;
  final bool walDetected;
  final bool shmDetected;
}

/// Validation result returned before enumeration begins.
class SnapshotValidationResult {
  const SnapshotValidationResult({
    required this.isValid,
    required this.errorMessage,
    required this.walDetected,
    required this.shmDetected,
  });

  final bool isValid;
  final String? errorMessage;
  final bool walDetected;
  final bool shmDetected;
}

/// Reads a historical Messages snapshot and enumerates deterministic
/// message↔attachment relationships.
abstract interface class HistoricalSnapshotReader {
  SnapshotValidationResult validate();

  SnapshotEnumerationResult? enumerate({
    void Function(int processed)? onProgress,
    bool Function()? isCancelled,
  });
}

abstract interface class HistoricalSnapshotReaderFactory {
  HistoricalSnapshotReader create({
    required String chatDbPath,
    required String attachmentsFolderPath,
  });
}
