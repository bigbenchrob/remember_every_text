/// The ordered graph units shared by archive import and archive removal.
///
/// This contract describes graph projection only. Import and removal retain
/// separate operation stages, observations, and execution algorithms.
enum SourceScopedArchiveGraphProjectionUnit {
  participants,
  conversations,
  messages,
  attachments,
  relationships,
}

final class SourceScopedArchiveGraphProjectionProgress {
  const SourceScopedArchiveGraphProjectionProgress({
    required this.activeUnit,
    required this.completedUnitCount,
    required this.totalUnitCount,
    this.completedWorkCount,
    this.totalWorkCount,
  });

  final SourceScopedArchiveGraphProjectionUnit activeUnit;
  final int completedUnitCount;
  final int totalUnitCount;
  final int? completedWorkCount;
  final int? totalWorkCount;
}
