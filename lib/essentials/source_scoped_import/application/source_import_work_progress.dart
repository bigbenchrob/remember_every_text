const sourceImportProgressObservationStride = 1000;

enum SourceImportWorkUnit {
  chats,
  handles,
  contacts,
  contactEmailChannels,
  contactPhoneChannels,
  messages,
  richTextExtraction,
  richTextPersistence,
  attachments,
  chatMessageRelationships,
  chatHandleRelationships,
  messageAttachmentRelationships,
}

final class SourceImportWorkProgress {
  const SourceImportWorkProgress({
    required this.unit,
    required this.completedWorkCount,
    required this.totalWorkCount,
    this.lastCompletedSourceRowId,
    this.preservedUnnormalizedCount = 0,
  }) : assert(completedWorkCount >= 0),
       assert(totalWorkCount >= 0),
       assert(completedWorkCount <= totalWorkCount),
       assert(preservedUnnormalizedCount >= 0),
       assert(preservedUnnormalizedCount <= completedWorkCount);

  final SourceImportWorkUnit unit;
  final int completedWorkCount;
  final int totalWorkCount;
  final int? lastCompletedSourceRowId;
  final int preservedUnnormalizedCount;
}

typedef SourceImportWorkObserver =
    void Function(SourceImportWorkProgress progress);

/// Bounded technical context for a source record that could not be imported.
///
/// This deliberately carries no source payload. Import remains fail-closed;
/// the exception only preserves the domain and source ROWID needed to locate
/// the malformed record safely.
final class SourceImportRecordException implements Exception {
  const SourceImportRecordException({
    required this.unit,
    required this.reason,
    this.sourceRowId,
  });

  final SourceImportWorkUnit unit;
  final int? sourceRowId;
  final String reason;

  @override
  String toString() {
    final rowContext = sourceRowId == null
        ? ''
        : ' at source ROWID $sourceRowId';
    return 'Source import ${unit.name}$rowContext failed: $reason';
  }
}

bool shouldPublishSourceImportProgress({
  required int completedWorkCount,
  required int totalWorkCount,
}) {
  return completedWorkCount == 0 ||
      completedWorkCount == totalWorkCount ||
      completedWorkCount % sourceImportProgressObservationStride == 0;
}

void publishSourceImportProgress({
  required SourceImportWorkObserver? observer,
  required SourceImportWorkUnit unit,
  required int completedWorkCount,
  required int totalWorkCount,
  int? lastCompletedSourceRowId,
  int preservedUnnormalizedCount = 0,
}) {
  if (observer == null ||
      !shouldPublishSourceImportProgress(
        completedWorkCount: completedWorkCount,
        totalWorkCount: totalWorkCount,
      )) {
    return;
  }
  observer(
    SourceImportWorkProgress(
      unit: unit,
      completedWorkCount: completedWorkCount,
      totalWorkCount: totalWorkCount,
      lastCompletedSourceRowId: lastCompletedSourceRowId,
      preservedUnnormalizedCount: preservedUnnormalizedCount,
    ),
  );
}
