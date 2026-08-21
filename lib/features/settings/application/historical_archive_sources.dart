import '../../../essentials/source_scoped_import/domain/historical_archive_source_identity.dart';

final class HistoricalArchiveSourceMetadata {
  const HistoricalArchiveSourceMetadata({
    required this.identity,
    required this.sourceChatDb,
    required this.folderPath,
    required this.sourceLabel,
    required this.chatDbStatusLabel,
    required this.attachmentsStatusLabel,
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

  final HistoricalArchiveSourceIdentity identity;
  final String sourceChatDb;
  final String folderPath;
  final String sourceLabel;
  final String chatDbStatusLabel;
  final String attachmentsStatusLabel;
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

  String get sourceKey => identity.value;
}

final class HistoricalArchiveImportedSourceMatch {
  const HistoricalArchiveImportedSourceMatch({
    required this.identity,
    required this.sourceId,
    required this.importedMessageCount,
  });

  final HistoricalArchiveSourceIdentity identity;
  final int sourceId;
  final int importedMessageCount;

  String get sourceKey => identity.value;
}

abstract interface class HistoricalArchiveImportedSourceLookup {
  Future<HistoricalArchiveImportedSourceMatch?> findImportedSource({
    required HistoricalArchiveSourceIdentity identity,
  });
}

final class HistoricalArchiveSourceMetadataUpdate {
  const HistoricalArchiveSourceMetadataUpdate({
    required this.identity,
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

  final HistoricalArchiveSourceIdentity identity;
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
