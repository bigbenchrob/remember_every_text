enum CurrentSourceMessageGraphPlacement {
  conversationLinked,
  recoveredUnlinked,
}

final class CurrentSourceMessageGraphCoverageEvidence {
  CurrentSourceMessageGraphCoverageEvidence({
    required Map<int, CurrentSourceMessageGraphPlacement>
    placementBySourceRowId,
  }) : placementBySourceRowId =
           Map<int, CurrentSourceMessageGraphPlacement>.unmodifiable(
             placementBySourceRowId,
           );

  final Map<int, CurrentSourceMessageGraphPlacement> placementBySourceRowId;
}

abstract interface class CurrentSourceMessageGraphCoverageReader {
  Future<CurrentSourceMessageGraphCoverageEvidence> read();
}
