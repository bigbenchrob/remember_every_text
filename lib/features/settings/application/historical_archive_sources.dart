final class HistoricalArchiveSourceMetadata {
  const HistoricalArchiveSourceMetadata({
    required this.sourceLabel,
    required this.totalMessages,
    required this.earliestMessageUtc,
    required this.latestMessageUtc,
    required this.preflightStatusLabel,
    required this.dryRunNewMessages,
    required this.dryRunDuplicateMessages,
    required this.lastImportFinishedAtUtc,
    required this.lastImportSuccess,
    required this.lastImportError,
    required this.lastImportedMessageCount,
  });

  final String sourceLabel;
  final int? totalMessages;
  final String? earliestMessageUtc;
  final String? latestMessageUtc;
  final String preflightStatusLabel;
  final int? dryRunNewMessages;
  final int? dryRunDuplicateMessages;
  final String? lastImportFinishedAtUtc;
  final bool? lastImportSuccess;
  final String? lastImportError;
  final int? lastImportedMessageCount;
}

final class HistoricalArchiveSourceMetadataUpdate {
  const HistoricalArchiveSourceMetadataUpdate({
    required this.sourceChatDb,
    required this.folderPath,
    required this.sourceLabel,
    required this.chatDbStatusLabel,
    required this.attachmentsStatusLabel,
    required this.preflightStatusLabel,
    required this.preflightDetail,
    required this.updatedAtUtc,
    this.totalMessages,
    this.totalChats,
    this.totalHandles,
    this.missingGuids,
    this.earliestMessageUtc,
    this.latestMessageUtc,
    this.dryRunNewMessages,
    this.dryRunDuplicateMessages,
    this.lastImportFinishedAtUtc,
    this.lastImportSuccess,
    this.lastImportError,
    this.lastImportedMessageCount,
  });

  final String sourceChatDb;
  final String folderPath;
  final String sourceLabel;
  final String chatDbStatusLabel;
  final String attachmentsStatusLabel;
  final String preflightStatusLabel;
  final String preflightDetail;
  final String updatedAtUtc;
  final int? totalMessages;
  final int? totalChats;
  final int? totalHandles;
  final int? missingGuids;
  final String? earliestMessageUtc;
  final String? latestMessageUtc;
  final int? dryRunNewMessages;
  final int? dryRunDuplicateMessages;
  final String? lastImportFinishedAtUtc;
  final bool? lastImportSuccess;
  final String? lastImportError;
  final int? lastImportedMessageCount;
}

abstract interface class HistoricalArchiveSources {
  Future<List<HistoricalArchiveSourceMetadata>> readKnownSources();

  Future<void> upsertSourceMetadata(
    HistoricalArchiveSourceMetadataUpdate update,
  );
}
