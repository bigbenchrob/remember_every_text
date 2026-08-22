final class CurrentMessagesSourceCoverageEvidence {
  CurrentMessagesSourceCoverageEvidence({
    required Set<int> sourceRowIds,
    required this.earliestMessageDate,
    required this.latestMessageDate,
  }) : sourceRowIds = Set<int>.unmodifiable(sourceRowIds);

  final Set<int> sourceRowIds;
  final DateTime? earliestMessageDate;
  final DateTime? latestMessageDate;

  int get totalRowCount => sourceRowIds.length;
}

abstract interface class CurrentMessagesSourceCoverageReader {
  Future<CurrentMessagesSourceCoverageEvidence> read({
    required String databasePath,
  });
}
