import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

import '../../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../application/archive_source_inspection.dart';

final class ArchiveSourceDateRange {
  const ArchiveSourceDateRange({
    required this.earliestMessageUtc,
    required this.latestMessageUtc,
    required this.unavailableReason,
  });

  final String? earliestMessageUtc;
  final String? latestMessageUtc;
  final String? unavailableReason;
}

class ArchiveSourceInspectionRepository implements ArchiveSourceInspector {
  const ArchiveSourceInspectionRepository({
    required ConversationGraphDatabase? graphDb,
    void Function(String folderPath, Object error, StackTrace stackTrace)?
    onInspectionFailure,
  }) : _graphDb = graphDb,
       _onInspectionFailure = onInspectionFailure;

  final ConversationGraphDatabase? _graphDb;
  final void Function(String folderPath, Object error, StackTrace stackTrace)?
  _onInspectionFailure;

  @override
  Future<ArchiveSourceInspection> inspectFolder({
    required String folderPath,
  }) async {
    final selectedDirectory = Directory(folderPath);
    final sourceLabel = path.basename(folderPath);
    final chatDbPath = path.join(folderPath, 'chat.db');
    final attachmentsPath = path.join(folderPath, 'Attachments');
    final attachmentsDirectory = Directory(attachmentsPath);

    if (!selectedDirectory.existsSync()) {
      return ArchiveSourceInspection(
        folderPath: folderPath,
        sourceLabel: sourceLabel,
        chatDbPath: chatDbPath,
        chatDbStatusLabel: 'Missing',
        attachmentsStatusLabel: 'Missing',
        isReadable: false,
        detail: 'The selected folder no longer exists.',
        dryRunEstimate: const ArchiveSourceDryRunEstimate.unavailable(
          unavailableReason: 'source folder is missing.',
        ),
      );
    }

    if (!File(chatDbPath).existsSync()) {
      return ArchiveSourceInspection(
        folderPath: folderPath,
        sourceLabel: sourceLabel,
        chatDbPath: chatDbPath,
        chatDbStatusLabel: 'Missing',
        attachmentsStatusLabel: attachmentsDirectory.existsSync()
            ? 'Found'
            : 'Not found',
        isReadable: false,
        detail: 'The selected folder does not contain chat.db.',
        dryRunEstimate: const ArchiveSourceDryRunEstimate.unavailable(
          unavailableReason: 'source chat.db is missing.',
        ),
      );
    }

    try {
      final database = sqlite3.open(chatDbPath, mode: OpenMode.readOnly);
      try {
        database.execute('PRAGMA query_only = ON;');
        database.execute('PRAGMA busy_timeout = 3000;');

        final totalMessages = _readCount(
          database,
          'SELECT COUNT(*) AS total_count FROM message',
        );
        final totalChats = _readCount(
          database,
          'SELECT COUNT(*) AS total_count FROM chat',
        );
        final totalHandles = _readCount(
          database,
          'SELECT COUNT(*) AS total_count FROM handle',
        );
        final missingGuids = _readCount(
          database,
          "SELECT COUNT(*) AS total_count FROM message WHERE guid IS NULL OR TRIM(guid) = ''",
        );
        final dateRange = _readArchiveDateRange(database);
        final dryRunEstimate = await _estimateDryRunAgainstConversationGraph(
          sourceDatabase: database,
          graphDb: _graphDb,
        );

        return ArchiveSourceInspection(
          folderPath: folderPath,
          sourceLabel: sourceLabel,
          chatDbPath: chatDbPath,
          chatDbStatusLabel: 'Found and readable',
          attachmentsStatusLabel: attachmentsDirectory.existsSync()
              ? 'Found'
              : 'Not found',
          isReadable: true,
          detail: dryRunEstimate.isAvailable
              ? 'Source checks succeeded and GUID-based dry-run estimates are now visible. Archive import can run when the evidence looks correct.'
              : 'Source checks succeeded, but conversation graph dry-run comparison is unavailable right now. Archive import can still run if the source evidence looks correct.',
          dryRunEstimate: dryRunEstimate,
          totalMessages: totalMessages,
          totalChats: totalChats,
          totalHandles: totalHandles,
          missingGuids: missingGuids,
          earliestMessageUtc: dateRange.earliestMessageUtc,
          latestMessageUtc: dateRange.latestMessageUtc,
          dateRangeUnavailableReason: dateRange.unavailableReason,
        );
      } finally {
        database.dispose();
      }
    } catch (error, stackTrace) {
      _onInspectionFailure?.call(folderPath, error, stackTrace);
      return ArchiveSourceInspection(
        folderPath: folderPath,
        sourceLabel: sourceLabel,
        chatDbPath: chatDbPath,
        chatDbStatusLabel: 'Read failed',
        attachmentsStatusLabel: attachmentsDirectory.existsSync()
            ? 'Found'
            : 'Not found',
        isReadable: false,
        detail: 'MessageLens could not safely read chat.db: $error',
        dryRunEstimate: ArchiveSourceDryRunEstimate.unavailable(
          unavailableReason: 'source chat.db could not be read safely: $error',
        ),
      );
    }
  }
}

int _readCount(Database database, String sql) {
  final result = database.select(sql);
  if (result.isEmpty) {
    return 0;
  }

  return _readIntegerValue(result.first['total_count']);
}

int _readIntegerValue(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse('$value') ?? 0;
}

ArchiveSourceDateRange _readArchiveDateRange(Database database) {
  try {
    final result = database.select(
      'SELECT MIN(date) AS earliest_date, MAX(date) AS latest_date FROM message',
    );
    if (result.isEmpty) {
      return const ArchiveSourceDateRange(
        earliestMessageUtc: null,
        latestMessageUtc: null,
        unavailableReason: null,
      );
    }

    final row = result.first;
    return ArchiveSourceDateRange(
      earliestMessageUtc: _archiveTimestampToUtcIsoString(row['earliest_date']),
      latestMessageUtc: _archiveTimestampToUtcIsoString(row['latest_date']),
      unavailableReason: null,
    );
  } catch (error) {
    return ArchiveSourceDateRange(
      earliestMessageUtc: null,
      latestMessageUtc: null,
      unavailableReason:
          'date range could not be read from source message table: $error',
    );
  }
}

String? _archiveTimestampToUtcIsoString(Object? value) {
  if (value == null) {
    return null;
  }

  final rawValue = value is int
      ? value
      : value is num
      ? value.toInt()
      : int.tryParse('$value');
  if (rawValue == null) {
    return null;
  }

  const appleEpochDifferenceSeconds = 978307200;
  final isNanoseconds = rawValue.abs() >= 1000000000000;
  final utcDateTime = isNanoseconds
      ? DateTime.fromMicrosecondsSinceEpoch(
          (rawValue / 1000).round() +
              appleEpochDifferenceSeconds * Duration.microsecondsPerSecond,
          isUtc: true,
        )
      : DateTime.fromMillisecondsSinceEpoch(
          (rawValue + appleEpochDifferenceSeconds) * 1000,
          isUtc: true,
        );
  return utcDateTime.toUtc().toIso8601String();
}

Future<ArchiveSourceDryRunEstimate> _estimateDryRunAgainstConversationGraph({
  required Database sourceDatabase,
  required ConversationGraphDatabase? graphDb,
}) async {
  if (graphDb == null) {
    return const ArchiveSourceDryRunEstimate.unavailable(
      unavailableReason:
          'conversation graph comparison is unavailable because the graph database could not be opened.',
    );
  }

  final comparableGuidCount = _readCount(
    sourceDatabase,
    'SELECT COUNT(DISTINCT guid) AS total_count FROM message WHERE guid IS NOT NULL AND LENGTH(TRIM(guid)) > 0',
  );

  if (comparableGuidCount == 0) {
    return const ArchiveSourceDryRunEstimate.available(
      comparableGuidCount: 0,
      duplicateGuidCount: 0,
      newGuidCount: 0,
    );
  }

  try {
    var duplicateGuidCount = 0;
    const sourceChunkSize = 400;

    for (var offset = 0; ; offset += sourceChunkSize) {
      final rows = sourceDatabase.select(
        'SELECT DISTINCT guid FROM message '
        'WHERE guid IS NOT NULL AND LENGTH(TRIM(guid)) > 0 ORDER BY guid LIMIT $sourceChunkSize OFFSET $offset',
      );
      if (rows.isEmpty) {
        break;
      }

      final sourceGuids = <String>[
        for (final row in rows)
          if (_readTrimmedString(row['guid']) case final guid?) guid,
      ];

      duplicateGuidCount += await _countMatchingGraphGuids(
        graphDb: graphDb,
        sourceGuids: sourceGuids,
      );
    }

    return ArchiveSourceDryRunEstimate.available(
      comparableGuidCount: comparableGuidCount,
      duplicateGuidCount: duplicateGuidCount,
      newGuidCount: comparableGuidCount - duplicateGuidCount,
    );
  } catch (error) {
    return ArchiveSourceDryRunEstimate.unavailable(
      unavailableReason:
          'conversation graph comparison failed while estimating duplicate GUIDs: $error',
    );
  }
}

Future<int> _countMatchingGraphGuids({
  required ConversationGraphDatabase graphDb,
  required List<String> sourceGuids,
}) async {
  if (sourceGuids.isEmpty) {
    return 0;
  }

  final placeholders = List.filled(sourceGuids.length, '?').join(', ');
  final rows = await graphDb.selectRows(
    'SELECT COUNT(*) AS total_count FROM messages WHERE guid IN ($placeholders)',
    sourceGuids,
  );

  return _readIntegerValue(rows.single['total_count']);
}

String? _readTrimmedString(Object? value) {
  if (value == null) {
    return null;
  }

  final text = '$value'.trim();
  if (text.isEmpty) {
    return null;
  }

  return text;
}
