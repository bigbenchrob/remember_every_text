abstract interface class RetainedArchiveMetadataStore {
  Future<void> upsertHistoricalArchiveSource({
    required String sourceChatDb,
    required String folderPath,
    required String sourceLabel,
    required String chatDbStatusLabel,
    required String attachmentsStatusLabel,
    required String preflightStatusLabel,
    required String preflightDetail,
    required String updatedAtUtc,
    int? totalMessages,
    int? totalChats,
    int? totalHandles,
    int? missingGuids,
    String? earliestMessageUtc,
    String? latestMessageUtc,
    int? dryRunNewMessages,
    int? dryRunDuplicateMessages,
    String? lastImportFinishedAtUtc,
    bool? lastImportSuccess,
    String? lastImportError,
    int? lastImportedMessageCount,
  });

  Future<List<HistoricalArchiveSourceRecord>> listHistoricalArchiveSources();

  Future<void> close();
}

final class HistoricalArchiveSourceRecord {
  const HistoricalArchiveSourceRecord({
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
  final String updatedAtUtc;
}
