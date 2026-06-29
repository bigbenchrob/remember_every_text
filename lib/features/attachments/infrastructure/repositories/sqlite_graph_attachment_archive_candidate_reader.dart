import 'package:drift/drift.dart';

import '../../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../../../essentials/source_scoped_import/domain/known_sources.dart';
import '../../../../essentials/source_scoped_import/domain/source_scoped_row_sql.dart';
import '../../application/graph_attachment_archive_candidate_reader.dart';

class SqliteGraphAttachmentArchiveCandidateReader
    implements GraphAttachmentArchiveCandidateReader {
  const SqliteGraphAttachmentArchiveCandidateReader({
    required ConversationGraphDatabase graphDatabase,
    required OverlayDatabase overlayDatabase,
  }) : _graphDatabase = graphDatabase,
       _overlayDatabase = overlayDatabase;

  final ConversationGraphDatabase _graphDatabase;
  final OverlayDatabase _overlayDatabase;

  @override
  Future<List<GraphAttachmentArchiveCandidate>> readSourceRange({
    required int sourceId,
    required int startedAfterSourceRowId,
    required int lastSourceRowId,
  }) async {
    final rows = await _graphDatabase.selectRows(
      '''
      SELECT DISTINCT
        a.ss_id AS graph_attachment_id,
        m.guid AS message_guid,
        ${SourceScopedRowSql.sourceRowId('a.ss_id')}
          AS live_source_attachment_rowid,
        a.filename AS local_path,
        a.mime_type,
        NULL AS sha256_hex
      FROM messages m
      JOIN message_to_attachment mta ON mta.message_ss_id = m.ss_id
      JOIN attachments a ON a.ss_id = mta.attachment_ss_id
      WHERE ${SourceScopedRowSql.sourceId('m.ss_id')} = ?
        AND ${SourceScopedRowSql.sourceRowId('m.ss_id')} > ?
        AND ${SourceScopedRowSql.sourceRowId('m.ss_id')} <= ?
        AND ${SourceScopedRowSql.sourceId('a.ss_id')} = ?
        AND a.filename IS NOT NULL
        AND LENGTH(TRIM(a.filename)) > 0
      ORDER BY m.ss_id, a.ss_id
      ''',
      <Object?>[sourceId, startedAfterSourceRowId, lastSourceRowId, sourceId],
    );

    return rows.map(_candidateFromRow).toList(growable: false);
  }

  @override
  Future<GraphAttachmentSweepSelection> selectSweepCandidates({
    required int afterAttachmentId,
    required int limit,
    required int pageSize,
  }) async {
    final selectedRows = <GraphAttachmentArchiveCandidate>[];
    final selectedAttachmentIds = <int>{};
    var cursor = afterAttachmentId;
    var wrappedToStart = false;

    while (selectedRows.length < limit) {
      final rawRows = await _fetchGraphSweepRows(
        afterAttachmentId: cursor,
        limit: pageSize,
      );

      if (rawRows.isEmpty) {
        if (!wrappedToStart && afterAttachmentId > 0) {
          wrappedToStart = true;
          cursor = 0;
          continue;
        }

        return GraphAttachmentSweepSelection(rows: selectedRows, nextCursor: 0);
      }

      final candidates = rawRows.map(_candidateFromRow).toList(growable: false);
      final archivedKeys = await _loadArchivedKeysForRows(candidates);
      var lastProcessedAttachmentId = cursor;

      for (final candidate in candidates) {
        final graphAttachmentId = candidate.graphAttachmentId;
        lastProcessedAttachmentId =
            graphAttachmentId ?? lastProcessedAttachmentId;
        final archiveKey = candidate.archiveCompatibilityKey;
        if (archiveKey == null || archivedKeys.contains(archiveKey)) {
          continue;
        }

        if (graphAttachmentId != null &&
            selectedAttachmentIds.contains(graphAttachmentId)) {
          continue;
        }

        selectedRows.add(candidate);
        if (graphAttachmentId != null) {
          selectedAttachmentIds.add(graphAttachmentId);
        }
        if (selectedRows.length == limit) {
          break;
        }
      }

      cursor = lastProcessedAttachmentId;
      if (rawRows.length < pageSize) {
        if (selectedRows.length < limit &&
            !wrappedToStart &&
            afterAttachmentId > 0) {
          wrappedToStart = true;
          cursor = 0;
          continue;
        }

        return GraphAttachmentSweepSelection(
          rows: selectedRows,
          nextCursor: selectedRows.length < limit ? 0 : cursor,
        );
      }
    }

    return GraphAttachmentSweepSelection(
      rows: selectedRows,
      nextCursor: cursor,
    );
  }

  @override
  Future<List<GraphAttachmentArchiveCandidate>> readAllAvailableLive() async {
    final rows = await _graphDatabase.selectRows(
      '''
      SELECT
        a.ss_id AS graph_attachment_id,
        m.guid AS message_guid,
        ${SourceScopedRowSql.sourceRowId('a.ss_id')}
          AS live_source_attachment_rowid,
        a.filename AS local_path,
        a.mime_type,
        NULL AS sha256_hex
      FROM attachments a
      JOIN message_to_attachment mta ON mta.attachment_ss_id = a.ss_id
      JOIN messages m ON m.ss_id = mta.message_ss_id
      WHERE ${SourceScopedRowSql.sourceId('a.ss_id')} = ?
        AND a.filename IS NOT NULL
        AND LENGTH(TRIM(a.filename)) > 0
      ''',
      <Object?>[liveChatDbSourceId],
    );

    return rows.map(_candidateFromRow).toList(growable: false);
  }

  Future<List<Map<String, Object?>>> _fetchGraphSweepRows({
    required int afterAttachmentId,
    required int limit,
  }) {
    return _graphDatabase.selectRows(
      '''
          SELECT
            a.ss_id AS graph_attachment_id,
            m.guid AS message_guid,
            ${SourceScopedRowSql.sourceRowId('a.ss_id')}
              AS live_source_attachment_rowid,
            a.filename AS local_path,
            a.mime_type,
            NULL AS sha256_hex
          FROM attachments a
          JOIN message_to_attachment mta ON mta.attachment_ss_id = a.ss_id
          JOIN messages m ON m.ss_id = mta.message_ss_id
          WHERE a.ss_id > ?
            AND ${SourceScopedRowSql.sourceId('a.ss_id')} = ?
            AND a.filename IS NOT NULL
            AND LENGTH(TRIM(a.filename)) > 0
            AND a.mime_type LIKE 'image/%'
          ORDER BY a.ss_id
          LIMIT ?
      ''',
      <Object?>[afterAttachmentId, liveChatDbSourceId, limit],
    );
  }

  Future<Set<ArchiveCompatibilityKey>> _loadArchivedKeysForRows(
    List<GraphAttachmentArchiveCandidate> rows,
  ) async {
    final keyedRows = rows
        .map((row) => row.archiveCompatibilityKey)
        .whereType<ArchiveCompatibilityKey>()
        .toList(growable: false);

    if (keyedRows.isEmpty) {
      return <ArchiveCompatibilityKey>{};
    }

    final predicates = <String>[];
    final variables = <Variable<Object>>[];
    for (final archiveKey in keyedRows) {
      predicates.add('(message_guid = ? AND import_attachment_id = ?)');
      variables.add(Variable<String>(archiveKey.messageGuid));
      variables.add(Variable<int>(archiveKey.archiveCompatibilityAttachmentId));
    }

    final rowsResult = await _overlayDatabase
        .customSelect(
          'SELECT message_guid, import_attachment_id '
          'FROM archived_attachments '
          'WHERE ${predicates.join(' OR ')}',
          variables: variables,
        )
        .get();

    return rowsResult
        .map(
          (row) => ArchiveCompatibilityKey.fromStoredTuple(
            messageGuid: row.read<String>('message_guid'),
            importAttachmentId: row.read<int>('import_attachment_id'),
          ),
        )
        .toSet();
  }

  GraphAttachmentArchiveCandidate _candidateFromRow(Map<String, Object?> row) {
    return GraphAttachmentArchiveCandidate(
      graphAttachmentId: _readNullableInt(row, 'graph_attachment_id'),
      archiveCompatibilityKey: _archiveCompatibilityKeyFromRow(row),
      localPath: _readNullableString(row, 'local_path'),
      mimeType: _readNullableString(row, 'mime_type'),
      sha256Hex: _readNullableString(row, 'sha256_hex'),
    );
  }

  ArchiveCompatibilityKey? _archiveCompatibilityKeyFromRow(
    Map<String, Object?> row,
  ) {
    final liveSourceAttachmentRowId = _readNullableInt(
      row,
      'live_source_attachment_rowid',
    );
    if (liveSourceAttachmentRowId == null) {
      return null;
    }
    return ArchiveCompatibilityKey.fromStoredTuple(
      messageGuid: _readRequiredString(row, 'message_guid'),
      importAttachmentId: liveSourceAttachmentRowId,
    );
  }

  String _readRequiredString(Map<String, Object?> row, String key) {
    final value = _readNullableString(row, key);
    if (value == null) {
      throw StateError('Missing required string column $key');
    }
    return value;
  }

  String? _readNullableString(Map<String, Object?> row, String key) {
    final value = row[key];
    return value == null ? null : '$value';
  }

  int? _readNullableInt(Map<String, Object?> row, String key) {
    final value = row[key];
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value');
  }
}
