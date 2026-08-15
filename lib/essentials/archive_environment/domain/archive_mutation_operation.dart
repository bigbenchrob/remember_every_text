/// Protected classes of mutation that can change an admitted archive.
enum ArchiveMutationOperation {
  liveGraphUpdate,
  graphBuild,
  onboardingImport,
  automaticRecovery,
  messageDataReset,
  historicalArchiveDryRun,
  historicalArchiveImport,
  historicalArchiveRemoval,
  attachmentReconciliation,
  attachmentClearing,
  destructiveMaintenance,
  localAccountIdentityReconciliation,
}

extension ArchiveMutationOperationPolicy on ArchiveMutationOperation {
  /// Whether reads must avoid reopening archive databases during the operation.
  bool get blocksDatabaseReopen {
    return switch (this) {
      ArchiveMutationOperation.messageDataReset ||
      ArchiveMutationOperation.historicalArchiveImport ||
      ArchiveMutationOperation.historicalArchiveRemoval ||
      ArchiveMutationOperation.destructiveMaintenance => true,
      _ => false,
    };
  }

  bool get requiresVerifiedCheckpoint {
    return switch (this) {
      ArchiveMutationOperation.messageDataReset ||
      ArchiveMutationOperation.historicalArchiveImport ||
      ArchiveMutationOperation.historicalArchiveRemoval ||
      ArchiveMutationOperation.attachmentClearing ||
      ArchiveMutationOperation.destructiveMaintenance => true,
      _ => false,
    };
  }
}
