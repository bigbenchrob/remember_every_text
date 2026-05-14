class LegacyIncrementalUpdateSnapshot {
  const LegacyIncrementalUpdateSnapshot({
    required this.liveMaxRowId,
    required this.importedMaxSourceRowId,
    required this.liveImportableMessageCount,
    required this.importedMessageCount,
    required this.importProbeDecision,
    required this.productionImportMaxMessageId,
    required this.productionWorkingMaxMessageId,
    required this.productionImportMessageCount,
    required this.productionWorkingMessageCount,
  });

  final int liveMaxRowId;
  final int? importedMaxSourceRowId;
  final int liveImportableMessageCount;
  final int importedMessageCount;
  final LegacyImportProbeDecision importProbeDecision;
  final int productionImportMaxMessageId;
  final int productionWorkingMaxMessageId;
  final int productionImportMessageCount;
  final int productionWorkingMessageCount;
}

class LegacyImportProbeDecision {
  const LegacyImportProbeDecision({
    required this.shouldSchedule,
    required this.reason,
  });

  final bool shouldSchedule;
  final String reason;
}
