import 'dart:convert';

import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../../../essentials/source_scoped_import/domain/historical_archive_source_identity.dart';
import '../../application/historical_archive_sources.dart';

class HistoricalArchiveSourcesRepository implements HistoricalArchiveSources {
  const HistoricalArchiveSourcesRepository({
    required OverlayDatabase overlayDatabase,
  }) : _overlayDatabase = overlayDatabase;

  static const String _settingKey = 'historical_archive_sources/v1';

  final OverlayDatabase _overlayDatabase;

  @override
  Future<List<HistoricalArchiveSourceMetadata>> readKnownSources() async {
    final records = await _readRecords();
    return [
      for (final record in records)
        HistoricalArchiveSourceMetadata(
          identity: record.identity,
          sourceChatDb: record.sourceChatDb,
          folderPath: record.folderPath,
          sourceLabel: record.sourceLabel,
          chatDbStatusLabel: record.chatDbStatusLabel,
          attachmentsStatusLabel: record.attachmentsStatusLabel,
          totalMessages: record.totalMessages,
          earliestMessageUtc: record.earliestMessageUtc,
          latestMessageUtc: record.latestMessageUtc,
          preflightStatusLabel: record.preflightStatusLabel,
          dryRunNewMessages: record.dryRunNewMessages,
          dryRunDuplicateMessages: record.dryRunDuplicateMessages,
          lastImportFinishedAtUtc: record.lastImportFinishedAtUtc,
          lastImportSuccess: record.lastImportSuccess,
          lastImportError: record.lastImportError,
          lastImportedMessageCount: record.lastImportedMessageCount,
        ),
    ];
  }

  @override
  Future<void> upsertSourceMetadata(
    HistoricalArchiveSourceMetadataUpdate update,
  ) async {
    final identity = update.identity;
    final recordsBySource = {
      for (final record in await _readRecords()) record.identity.value: record,
    };
    recordsBySource[identity.value] = _ArchiveSourceRecord.fromUpdate(
      update,
      identity: identity,
    );

    final records = recordsBySource.values.toList()
      ..sort((left, right) => right.updatedAtUtc.compareTo(left.updatedAtUtc));

    await _overlayDatabase.writeOverlaySetting(
      settingKey: _settingKey,
      settingValue: jsonEncode([for (final record in records) record.toJson()]),
    );
  }

  Future<List<_ArchiveSourceRecord>> _readRecords() async {
    final rawValue = await _overlayDatabase.readOverlaySetting(_settingKey);
    if (rawValue == null || rawValue.trim().isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(rawValue);
    if (decoded is! List<Object?>) {
      return const [];
    }

    return [
      for (final item in decoded)
        if (item is Map<String, Object?>) _ArchiveSourceRecord.fromJson(item),
    ]..sort((left, right) => right.updatedAtUtc.compareTo(left.updatedAtUtc));
  }
}

final class _ArchiveSourceRecord {
  const _ArchiveSourceRecord({
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

  factory _ArchiveSourceRecord.fromUpdate(
    HistoricalArchiveSourceMetadataUpdate update, {
    required HistoricalArchiveSourceIdentity identity,
  }) {
    return _ArchiveSourceRecord(
      identity: identity,
      sourceChatDb: update.sourceChatDb,
      folderPath: update.folderPath,
      sourceLabel: update.sourceLabel,
      chatDbStatusLabel: update.chatDbStatusLabel,
      attachmentsStatusLabel: update.attachmentsStatusLabel,
      preflightStatusLabel: update.preflightStatusLabel,
      preflightDetail: update.preflightDetail,
      updatedAtUtc: update.updatedAtUtc,
      totalMessages: update.totalMessages,
      totalChats: update.totalChats,
      totalHandles: update.totalHandles,
      missingGuids: update.missingGuids,
      earliestMessageUtc: update.earliestMessageUtc,
      latestMessageUtc: update.latestMessageUtc,
      dryRunNewMessages: update.dryRunNewMessages,
      dryRunDuplicateMessages: update.dryRunDuplicateMessages,
      lastImportFinishedAtUtc: update.lastImportFinishedAtUtc,
      lastImportSuccess: update.lastImportSuccess,
      lastImportError: update.lastImportError,
      lastImportedMessageCount: update.lastImportedMessageCount,
    );
  }

  factory _ArchiveSourceRecord.fromJson(Map<String, Object?> json) {
    final sourceChatDb = _stringValue(json['sourceChatDb']);
    final persistedSourceKey = _nullableStringValue(json['sourceKey']);
    return _ArchiveSourceRecord(
      identity: persistedSourceKey == null
          ? HistoricalArchiveSourceIdentity.macMessagesFromChatDbPath(
              sourceChatDb,
            )
          : HistoricalArchiveSourceIdentity.fromPersistedValue(
              persistedSourceKey,
            ),
      sourceChatDb: sourceChatDb,
      folderPath: _stringValue(json['folderPath']),
      sourceLabel: _stringValue(json['sourceLabel']),
      chatDbStatusLabel: _stringValue(json['chatDbStatusLabel']),
      attachmentsStatusLabel: _stringValue(json['attachmentsStatusLabel']),
      preflightStatusLabel: _stringValue(json['preflightStatusLabel']),
      preflightDetail: _stringValue(json['preflightDetail']),
      updatedAtUtc: _stringValue(json['updatedAtUtc']),
      totalMessages: _intValue(json['totalMessages']),
      totalChats: _intValue(json['totalChats']),
      totalHandles: _intValue(json['totalHandles']),
      missingGuids: _intValue(json['missingGuids']),
      earliestMessageUtc: _nullableStringValue(json['earliestMessageUtc']),
      latestMessageUtc: _nullableStringValue(json['latestMessageUtc']),
      dryRunNewMessages: _intValue(json['dryRunNewMessages']),
      dryRunDuplicateMessages: _intValue(json['dryRunDuplicateMessages']),
      lastImportFinishedAtUtc: _nullableStringValue(
        json['lastImportFinishedAtUtc'],
      ),
      lastImportSuccess: _boolValue(json['lastImportSuccess']),
      lastImportError: _nullableStringValue(json['lastImportError']),
      lastImportedMessageCount: _intValue(json['lastImportedMessageCount']),
    );
  }

  final HistoricalArchiveSourceIdentity identity;
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

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'sourceKey': identity.value,
      'sourceChatDb': sourceChatDb,
      'folderPath': folderPath,
      'sourceLabel': sourceLabel,
      'chatDbStatusLabel': chatDbStatusLabel,
      'attachmentsStatusLabel': attachmentsStatusLabel,
      'preflightStatusLabel': preflightStatusLabel,
      'preflightDetail': preflightDetail,
      'totalMessages': totalMessages,
      'totalChats': totalChats,
      'totalHandles': totalHandles,
      'missingGuids': missingGuids,
      'earliestMessageUtc': earliestMessageUtc,
      'latestMessageUtc': latestMessageUtc,
      'dryRunNewMessages': dryRunNewMessages,
      'dryRunDuplicateMessages': dryRunDuplicateMessages,
      'lastImportFinishedAtUtc': lastImportFinishedAtUtc,
      'lastImportSuccess': lastImportSuccess,
      'lastImportError': lastImportError,
      'lastImportedMessageCount': lastImportedMessageCount,
      'updatedAtUtc': updatedAtUtc,
    };
  }
}

String _stringValue(Object? value) {
  return value is String ? value : '';
}

String? _nullableStringValue(Object? value) {
  return value is String && value.isNotEmpty ? value : null;
}

int? _intValue(Object? value) {
  return value is int ? value : null;
}

bool? _boolValue(Object? value) {
  return value is bool ? value : null;
}
