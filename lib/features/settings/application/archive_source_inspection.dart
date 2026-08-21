enum ArchiveSourceInspectionStatus {
  missing,
  readable,
  readFailed,
  unavailable;

  String get label {
    return switch (this) {
      ArchiveSourceInspectionStatus.missing => 'Missing',
      ArchiveSourceInspectionStatus.readable => 'Found and readable',
      ArchiveSourceInspectionStatus.readFailed => 'Read failed',
      ArchiveSourceInspectionStatus.unavailable => 'Unavailable',
    };
  }
}

final class ArchiveSourceInspection {
  const ArchiveSourceInspection({
    required this.folderPath,
    required this.sourceLabel,
    required this.chatDbPath,
    required this.chatDbStatus,
    required this.attachmentsStatusLabel,
    required this.detail,
    required this.dryRunEstimate,
    this.totalMessages,
    this.totalChats,
    this.totalHandles,
    this.missingGuids,
    this.earliestMessageUtc,
    this.latestMessageUtc,
    this.dateRangeUnavailableReason,
  });

  final String folderPath;
  final String sourceLabel;
  final String chatDbPath;
  final ArchiveSourceInspectionStatus chatDbStatus;
  final String attachmentsStatusLabel;
  final String detail;
  final ArchiveSourceDryRunEstimate dryRunEstimate;
  final int? totalMessages;
  final int? totalChats;
  final int? totalHandles;
  final int? missingGuids;
  final String? earliestMessageUtc;
  final String? latestMessageUtc;
  final String? dateRangeUnavailableReason;

  String get chatDbStatusLabel => chatDbStatus.label;

  bool get isReadable {
    return chatDbStatus == ArchiveSourceInspectionStatus.readable;
  }
}

final class ArchiveSourceDryRunEstimate {
  const ArchiveSourceDryRunEstimate.available({
    required this.comparableGuidCount,
    required this.duplicateGuidCount,
    required this.newGuidCount,
  }) : unavailableReason = null;

  const ArchiveSourceDryRunEstimate.unavailable({
    required this.unavailableReason,
  }) : comparableGuidCount = 0,
       duplicateGuidCount = 0,
       newGuidCount = 0;

  final int comparableGuidCount;
  final int duplicateGuidCount;
  final int newGuidCount;
  final String? unavailableReason;

  bool get isAvailable {
    return unavailableReason == null;
  }
}

abstract interface class ArchiveSourceInspector {
  Future<ArchiveSourceInspection> inspectFolder({required String folderPath});
}
