import 'package:drift/drift.dart' as drift;

import '../../../../core/util/date_converter.dart';
import '../../domain/base_table_migrator.dart';
import '../../domain/row_progress_reporter.dart';
import '../../infrastructure/sqlite/migration_context_sqlite.dart';

String _unixSecondsToWorkingTimestamp(String columnName) {
  return DateConverter.unixSecondsToIsoTextSqlExpression(columnName);
}

class _MessageChunkDiagnostics {
  const _MessageChunkDiagnostics({
    required this.selectedCount,
    required this.firstId,
    required this.lastId,
    required this.firstGuid,
    required this.lastGuid,
    required this.firstSourceId,
    required this.lastSourceId,
    required this.firstSourceKind,
    required this.lastSourceKind,
    required this.sourceIdDistribution,
    required this.sourceKindDistribution,
    required this.containsArchiveOwnedRows,
    required this.containsLatestArchiveBatchRows,
  });

  final int selectedCount;
  final int firstId;
  final int lastId;
  final String firstGuid;
  final String lastGuid;
  final int? firstSourceId;
  final int? lastSourceId;
  final String firstSourceKind;
  final String lastSourceKind;
  final Map<String, int> sourceIdDistribution;
  final Map<String, int> sourceKindDistribution;
  final bool containsArchiveOwnedRows;
  final bool containsLatestArchiveBatchRows;

  factory _MessageChunkDiagnostics.fromRows(
    List<drift.QueryRow> rows, {
    required int? latestHistoricalArchiveBatchId,
  }) {
    final first = rows.first.data;
    final last = rows.last.data;
    final sourceIdDistribution = <String, int>{};
    final sourceKindDistribution = <String, int>{};
    var containsArchiveOwnedRows = false;
    var containsLatestArchiveBatchRows = false;

    for (final row in rows) {
      final data = row.data;
      final sourceId = _asNullableInt(data['source_id']);
      final sourceKind = _asSourceKind(data['source_kind']);
      final lastImportBatchId = _asNullableInt(data['last_import_batch_id']);

      _incrementCount(sourceIdDistribution, sourceId?.toString() ?? 'null');
      _incrementCount(sourceKindDistribution, sourceKind);

      if (sourceKind == 'historical_archive') {
        containsArchiveOwnedRows = true;
      }

      if (latestHistoricalArchiveBatchId != null &&
          lastImportBatchId == latestHistoricalArchiveBatchId) {
        containsLatestArchiveBatchRows = true;
      }
    }

    return _MessageChunkDiagnostics(
      selectedCount: rows.length,
      firstId: _asNullableInt(first['id']) ?? 0,
      lastId: _asNullableInt(last['id']) ?? 0,
      firstGuid: '${first['guid'] ?? ''}',
      lastGuid: '${last['guid'] ?? ''}',
      firstSourceId: _asNullableInt(first['source_id']),
      lastSourceId: _asNullableInt(last['source_id']),
      firstSourceKind: _asSourceKind(first['source_kind']),
      lastSourceKind: _asSourceKind(last['source_kind']),
      sourceIdDistribution: sourceIdDistribution,
      sourceKindDistribution: sourceKindDistribution,
      containsArchiveOwnedRows: containsArchiveOwnedRows,
      containsLatestArchiveBatchRows: containsLatestArchiveBatchRows,
    );
  }
}

int? _asNullableInt(Object? value) {
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

String _asSourceKind(Object? value) {
  final raw = '$value';
  if (raw.isEmpty || raw == 'null') {
    return 'unknown';
  }
  return raw;
}

void _incrementCount(Map<String, int> counts, String key) {
  counts[key] = (counts[key] ?? 0) + 1;
}

String _formatChunkDistribution(Map<String, int> counts) {
  if (counts.isEmpty) {
    return '{}';
  }

  final entries = counts.entries.toList()
    ..sort((left, right) => left.key.compareTo(right.key));
  return '{${entries.map((entry) => '${entry.key}:${entry.value}').join(', ')}}';
}

Future<T> _runTimedMessagesPhase<T>({
  required IMigrationContext ctx,
  required String phaseName,
  required Future<T> Function() action,
}) async {
  final startedAt = DateTime.now().toUtc();
  ctx.log(
    '[messages] phase=$phaseName start_at_utc=${startedAt.toIso8601String()}',
  );

  try {
    final result = await action();
    final finishedAt = DateTime.now().toUtc();
    final duration = finishedAt.difference(startedAt);
    ctx.log(
      '[messages] phase=$phaseName end_at_utc=${finishedAt.toIso8601String()} '
      'duration_ms=${duration.inMilliseconds}',
    );
    return result;
  } catch (error) {
    final failedAt = DateTime.now().toUtc();
    final duration = failedAt.difference(startedAt);
    ctx.log(
      '[messages] phase=$phaseName failed_at_utc=${failedAt.toIso8601String()} '
      'duration_ms=${duration.inMilliseconds} error=$error',
    );
    rethrow;
  }
}

class MessagesMigrator extends BaseTableMigrator with RowProgressReporter {
  MessagesMigrator();

  static const _attachAlias = 'import_messages';
  static const _copyChunkSize = 1000;
  static const List<String> _allowedItemTypes = <String>[
    'text',
    'attachment-only',
    'sticker',
    'reaction-carrier',
    'system',
    'unknown',
  ];

  /// Cached row count, populated during [validatePrereqs] so that the UI can
  /// render a determinate progress bar from the very first phase. Reset to
  /// null between runs so a stale total is never reported.
  int? _expectedJoinableMessageCount;

  @override
  String get name => 'messages';

  @override
  List<String> get dependsOn => const ['chats', 'handles'];

  @override
  Future<void> validatePrereqs(IMigrationContext ctx) async {
    final joinableMessages = await _countJoinableMessages(ctx);
    _expectedJoinableMessageCount = joinableMessages;
    ctx.log('[messages] joinable import count = $joinableMessages');

    // Emit a determinate "0 of N" progress event as soon as the total is
    // known. This eliminates the indeterminate progress bar that would
    // otherwise render during validatePrereqs and the early portion of copy.
    if (joinableMessages > 0) {
      reportRowProgress(
        processed: 0,
        total: joinableMessages,
        currentItem: 'Validating message prerequisites…',
      );
    }

    if (joinableMessages == 0) {
      ctx.log(
        '[messages] no messages with matching chats found; skipping copy',
      );
      return;
    }

    final projectedChats = await count(ctx.workingDb, 'chats');
    await expectTrueOrThrow(
      ok: projectedChats > 0,
      errorCode: 'MESSAGES_REQUIRES_CHATS',
      message:
          'messages: import has $joinableMessages rows but working database has no chats',
    );

    final projectedHandles = await count(ctx.workingDb, 'handles_canonical');
    await expectTrueOrThrow(
      ok: projectedHandles > 0,
      errorCode: 'MESSAGES_REQUIRES_HANDLES',
      message:
          'messages: import has $joinableMessages rows but working database has no canonical handles',
    );
  }

  @override
  Future<void> copy(IMigrationContext ctx) async {
    if (ctx.dryRun) {
      ctx.log('[messages] dry run – skipping copy');
      return;
    }

    final inserted = await _withAttachedImport(ctx, () async {
      final totalRows = await _countJoinableMessagesFromAttachedImport(ctx);
      if (totalRows <= 0) {
        return 0;
      }

      reportRowProgress(
        processed: 0,
        total: totalRows,
        currentItem: 'Scanning import message item types…',
      );

      final unsupportedTypes = await ctx.workingDb.customSelect('''
        SELECT COALESCE(m.item_type, '<<NULL>>') AS item_type, COUNT(*) AS c
        FROM $_attachAlias.messages m
        WHERE m.guid IS NOT NULL
          AND LENGTH(TRIM(m.guid)) > 0
          AND (m.item_type IS NULL OR m.item_type NOT IN (
            ${_allowedItemTypes.map((type) => "'$type'").join(', ')}
          ))
        GROUP BY m.item_type
      ''').get();

      if (unsupportedTypes.isNotEmpty) {
        for (final row in unsupportedTypes) {
          final data = row.data;
          final rawType = data['item_type'] as String?;
          final count = _coerceToInt(data['c']);
          final label = rawType == '<<NULL>>' ? 'NULL' : rawType;
          ctx.log(
            '[messages] mapping unsupported item_type $label for $count messages to "unknown"',
          );
        }
      }

      final missingHandles = await ctx.workingDb.customSelect('''
        SELECT COUNT(*) AS c
        FROM $_attachAlias.messages m
        WHERE m.sender_handle_id IS NOT NULL
          AND NOT EXISTS (
            SELECT 1
            FROM handles_canonical_to_alias map
            JOIN handles_canonical h ON h.id = map.canonical_handle_id
            WHERE map.source_handle_id = m.sender_handle_id
          );
      ''').get();
      final missingHandlesCount = _extractCount(missingHandles, 'c');
      if (missingHandlesCount > 0) {
        ctx.log(
          '[messages] $missingHandlesCount messages reference missing handles; sender_handle_id will be null',
        );
      }

      // Use INSERT OR IGNORE in incremental mode to avoid expensive REPLACE
      // operations on existing rows (which would trigger cascading FK checks)
      final insertClause = ctx.incrementalMode
          ? 'INSERT OR IGNORE'
          : 'INSERT OR REPLACE';
      final latestHistoricalArchiveBatchId =
          await _latestHistoricalArchiveBatchIdFromAttachedImport(ctx);
      ctx.log(
        '[messages] latest_historical_archive_batch_id=${latestHistoricalArchiveBatchId ?? 'none'}',
      );
      var insertedCount = 0;
      var processedRows = 0;
      while (processedRows < totalRows) {
        final chunkOffset = processedRows;
        final chunkStartedAt = DateTime.now().toUtc();
        ctx.log(
          '[messages][chunk] offset=$chunkOffset limit=$_copyChunkSize '
          'stage=before_select',
        );

        final selectStartedAt = DateTime.now().toUtc();
        final chunkRows = await _selectJoinableMessageChunk(
          ctx,
          limit: _copyChunkSize,
          offset: chunkOffset,
        );
        final selectDurationMs = DateTime.now()
            .toUtc()
            .difference(selectStartedAt)
            .inMilliseconds;
        if (chunkRows.isEmpty) {
          ctx.log(
            '[messages][chunk] offset=$chunkOffset limit=$_copyChunkSize '
            'stage=after_select selected_count=0 select_duration_ms=$selectDurationMs',
          );
          break;
        }

        final chunkDiagnostics = _MessageChunkDiagnostics.fromRows(
          chunkRows,
          latestHistoricalArchiveBatchId: latestHistoricalArchiveBatchId,
        );
        final ordinalStart = chunkOffset + 1;
        final ordinalEnd = chunkOffset + chunkRows.length;
        ctx.log(
          '[messages][chunk] offset=$chunkOffset limit=$_copyChunkSize '
          'stage=after_select selected_count=${chunkDiagnostics.selectedCount} '
          'ordinal_start=$ordinalStart ordinal_end=$ordinalEnd '
          'first_id=${chunkDiagnostics.firstId} last_id=${chunkDiagnostics.lastId} '
          'first_guid=${chunkDiagnostics.firstGuid} last_guid=${chunkDiagnostics.lastGuid} '
          'first_source_id=${chunkDiagnostics.firstSourceId ?? 'null'} '
          'last_source_id=${chunkDiagnostics.lastSourceId ?? 'null'} '
          'first_source_kind=${chunkDiagnostics.firstSourceKind} '
          'last_source_kind=${chunkDiagnostics.lastSourceKind} '
          'source_id_distribution=${_formatChunkDistribution(chunkDiagnostics.sourceIdDistribution)} '
          'source_kind_distribution=${_formatChunkDistribution(chunkDiagnostics.sourceKindDistribution)} '
          'contains_archive_owned_rows=${chunkDiagnostics.containsArchiveOwnedRows} '
          'contains_latest_archive_batch_rows=${chunkDiagnostics.containsLatestArchiveBatchRows} '
          'latest_historical_archive_batch_id=${latestHistoricalArchiveBatchId ?? 'none'} '
          'select_duration_ms=$selectDurationMs',
        );

        final chunkIds = <int>[
          for (final row in chunkRows) row.read<int>('id'),
        ];
        final lastGuid = chunkRows.last.read<String>('guid');

        ctx.log(
          '[messages][chunk] offset=$chunkOffset limit=$_copyChunkSize '
          'stage=before_insert first_id=${chunkDiagnostics.firstId} '
          'last_id=${chunkDiagnostics.lastId} first_guid=${chunkDiagnostics.firstGuid} '
          'last_guid=${chunkDiagnostics.lastGuid}',
        );

        final insertStartedAt = DateTime.now().toUtc();

        await ctx.workingDb.customStatement(
          _chunkedInsertStatement(
            insertClause: insertClause,
            chunkIds: chunkIds,
          ),
        );

        final insertDurationMs = DateTime.now()
            .toUtc()
            .difference(insertStartedAt)
            .inMilliseconds;
        ctx.log(
          '[messages][chunk] offset=$chunkOffset limit=$_copyChunkSize '
          'stage=after_insert insert_duration_ms=$insertDurationMs',
        );

        ctx.log(
          '[messages][chunk] offset=$chunkOffset limit=$_copyChunkSize '
          'stage=before_changes',
        );

        final changesStartedAt = DateTime.now().toUtc();

        final rows = await ctx.workingDb
            .customSelect('SELECT changes() AS c')
            .get();
        final changesDurationMs = DateTime.now()
            .toUtc()
            .difference(changesStartedAt)
            .inMilliseconds;
        final changesCount = _extractCount(rows, 'c');
        ctx.log(
          '[messages][chunk] offset=$chunkOffset limit=$_copyChunkSize '
          'stage=after_changes changes_count=$changesCount '
          'changes_duration_ms=$changesDurationMs',
        );

        insertedCount += changesCount;
        processedRows += chunkRows.length;

        reportRowProgress(
          processed: processedRows,
          total: totalRows,
          currentItem: lastGuid,
        );

        final chunkElapsedMs = DateTime.now()
            .toUtc()
            .difference(chunkStartedAt)
            .inMilliseconds;
        ctx.log(
          '[messages][chunk] offset=$chunkOffset limit=$_copyChunkSize '
          'stage=chunk_complete processed_rows=$processedRows total_rows=$totalRows '
          'chunk_elapsed_ms=$chunkElapsedMs',
        );
      }

      // Backfill missing sender_handle_id for messages that now have a mapping
      // This fixes rows that were skipped by INSERT OR IGNORE in previous runs
      // but had NULL sender_handle_id due to missing mappings at that time.
      reportRowProgress(
        processed: totalRows,
        total: totalRows,
        currentItem: 'Backfilling sender handles…',
      );
      await _runTimedMessagesPhase<void>(
        ctx: ctx,
        phaseName: 'backfill_sender_handles',
        action: () => ctx.workingDb.customStatement('''
          UPDATE messages
          SET sender_handle_id = (
            SELECT map.canonical_handle_id
            FROM $_attachAlias.messages m
            JOIN handles_canonical_to_alias map ON map.source_handle_id = m.sender_handle_id
            WHERE m.guid = messages.guid
          )
          WHERE sender_handle_id IS NULL 
            AND is_from_me = 0
            AND EXISTS (
              SELECT 1
              FROM $_attachAlias.messages m
              JOIN handles_canonical_to_alias map ON map.source_handle_id = m.sender_handle_id
              WHERE m.guid = messages.guid
            );
        '''),
      );

      final backfilledRows = await ctx.workingDb
          .customSelect('SELECT changes() AS c')
          .get();
      final backfilledCount = _extractCount(backfilledRows, 'c');
      if (backfilledCount > 0) {
        ctx.log(
          '[messages] backfilled $backfilledCount existing incoming messages with canonical sender handles',
        );
      }

      reportRowProgress(
        processed: totalRows,
        total: totalRows,
        currentItem: 'Updating per-chat metadata…',
      );

      await _runTimedMessagesPhase<void>(
        ctx: ctx,
        phaseName: 'update_chat_metadata',
        action: () => ctx.workingDb.customStatement('''
          WITH candidate AS (
            SELECT
              m.chat_id,
              m.id,
              m.sender_handle_id,
              COALESCE(
                NULLIF(TRIM(m.sent_at_utc), ''),
                NULLIF(TRIM(m.delivered_at_utc), ''),
                NULLIF(TRIM(m.read_at_utc), '')
              ) AS resolved_timestamp,
              m.text AS preview
            FROM messages m
          ), scored AS (
            SELECT
              chat_id,
              id,
              sender_handle_id,
              resolved_timestamp,
              preview,
              COALESCE(
                strftime(
                  '%s',
                  REPLACE(REPLACE(resolved_timestamp, 'T', ' '), 'Z', '')
                ),
                id
              ) AS resolved_score
            FROM candidate
          ), ranked AS (
            SELECT
              chat_id,
              sender_handle_id,
              resolved_timestamp,
              preview,
              ROW_NUMBER() OVER (
                PARTITION BY chat_id
                ORDER BY resolved_score DESC, id DESC
              ) AS rn
            FROM scored
          )
          UPDATE chats
          SET
            last_message_at_utc = (
              SELECT CASE
                WHEN r.resolved_timestamp IS NOT NULL AND r.resolved_timestamp != ''
                  THEN r.resolved_timestamp
                ELSE NULL
              END
              FROM ranked r
              WHERE r.chat_id = chats.id AND r.rn = 1
            ),
            last_sender_handle_id = (
              SELECT r.sender_handle_id
              FROM ranked r
              WHERE r.chat_id = chats.id AND r.rn = 1
            ),
            last_message_preview = (
              SELECT CASE
                WHEN r.preview IS NULL THEN NULL
                WHEN LENGTH(TRIM(r.preview)) = 0 THEN NULL
                WHEN LENGTH(TRIM(r.preview)) <= 160 THEN TRIM(r.preview)
                ELSE SUBSTR(TRIM(r.preview), 1, 157) || '...'
              END
              FROM ranked r
              WHERE r.chat_id = chats.id AND r.rn = 1
            )
          WHERE EXISTS (
            SELECT 1 FROM ranked r WHERE r.chat_id = chats.id AND r.rn = 1
          );
        '''),
      );

      // Ensure all statements are fully executed before returning
      await ctx.workingDb.customSelect('SELECT changes() AS c').get();

      return insertedCount;
    });

    ctx.log('[messages] inserted $inserted rows');
  }

  @override
  Future<void> postValidate(IMigrationContext ctx) async {
    final expected = await _countJoinableMessages(ctx);
    final projected = await count(ctx.workingDb, 'messages');
    ctx.log('[messages] expected=$expected projected=$projected');

    // Keep the progress bar at 100% (determinate) during postValidate so the
    // UI never falls back to an indeterminate stripe between copy completion
    // and the final succeeded event.
    final progressTotal = expected > 0
        ? expected
        : (_expectedJoinableMessageCount ?? 0);
    if (progressTotal > 0) {
      reportRowProgress(
        processed: progressTotal,
        total: progressTotal,
        currentItem: 'Validating projected message rows…',
      );
    }

    await _runTimedMessagesPhase<void>(
      ctx: ctx,
      phaseName: 'post_validate',
      action: () async {
        if (expected == 0) {
          await expectTrueOrThrow(
            ok: projected == 0,
            errorCode: 'MESSAGES_UNEXPECTED_ROWS',
            message:
                'messages: working has $projected rows but import had none',
          );
          return;
        }

        if (ctx.incrementalMode) {
          // In incremental mode, projected should be >= expected (existing + new)
          await expectTrueOrThrow(
            ok: projected >= expected,
            errorCode: 'MESSAGES_INCREMENTAL_UNDERCOUNT',
            message:
                'messages: working has $projected rows but expected >= $expected',
          );
        } else {
          // In full mode, counts must match exactly
          await expectTrueOrThrow(
            ok: projected == expected,
            errorCode: 'MESSAGES_ROW_MISMATCH',
            message:
                'messages: working has $projected rows but expected $expected',
          );
        }

        final remainingResolvableIncoming =
            await _countResolvableIncomingMessages(ctx);
        await expectTrueOrThrow(
          ok: remainingResolvableIncoming == 0,
          errorCode: 'MESSAGES_SENDER_HANDLE_BACKFILL_INCOMPLETE',
          message:
              'messages: working still has $remainingResolvableIncoming resolvable incoming rows with null sender_handle_id',
        );
      },
    );
  }

  Future<int> _countJoinableMessages(IMigrationContext ctx) async {
    final importSqlite = await ctx.importDb.database;
    final rows = await importSqlite.rawQuery(
      'SELECT COUNT(*) AS c '
      'FROM messages m '
      'JOIN chats c ON c.id = m.chat_id '
      'WHERE m.guid IS NOT NULL AND LENGTH(TRIM(m.guid)) > 0',
    );
    if (rows.isEmpty) {
      return 0;
    }
    return _coerceToInt(rows.first['c']);
  }

  Future<int> _countJoinableMessagesFromAttachedImport(
    IMigrationContext ctx,
  ) async {
    final rows = await ctx.workingDb
        .customSelect(
          'SELECT COUNT(*) AS c '
          'FROM $_attachAlias.messages m '
          'JOIN $_attachAlias.chats import_chats ON import_chats.id = m.chat_id '
          'WHERE m.guid IS NOT NULL AND LENGTH(TRIM(m.guid)) > 0',
        )
        .get();
    return _extractCount(rows, 'c');
  }

  Future<List<drift.QueryRow>> _selectJoinableMessageChunk(
    IMigrationContext ctx, {
    required int limit,
    required int offset,
  }) {
    return ctx.workingDb
        .customSelect(
          'SELECT '
          'm.id AS id, '
          'm.guid AS guid, '
          'm.source_id AS source_id, '
          'm.last_import_batch_id AS last_import_batch_id, '
          "COALESCE(ls.source_kind, ib.chat_source_kind, 'unknown') AS source_kind "
          'FROM $_attachAlias.messages m '
          'JOIN $_attachAlias.chats import_chats ON import_chats.id = m.chat_id '
          'LEFT JOIN $_attachAlias.ledger_sources ls ON ls.id = m.source_id '
          'LEFT JOIN $_attachAlias.import_batches ib ON ib.id = m.last_import_batch_id '
          'WHERE m.guid IS NOT NULL AND LENGTH(TRIM(m.guid)) > 0 '
          'ORDER BY m.id ASC '
          'LIMIT ? OFFSET ?',
          variables: <drift.Variable<Object>>[
            drift.Variable.withInt(limit),
            drift.Variable.withInt(offset),
          ],
        )
        .get();
  }

  Future<int?> _latestHistoricalArchiveBatchIdFromAttachedImport(
    IMigrationContext ctx,
  ) async {
    final rows = await ctx.workingDb
        .customSelect(
          'SELECT MAX(id) AS c '
          'FROM $_attachAlias.import_batches '
          "WHERE chat_source_kind = 'historical_archive' "
          "AND (status IS NULL OR status != 'cancelled')",
        )
        .get();

    if (rows.isEmpty) {
      return null;
    }

    return _asNullableInt(rows.first.data['c']);
  }

  String _chunkedInsertStatement({
    required String insertClause,
    required List<int> chunkIds,
  }) {
    final idList = chunkIds.join(', ');
    return '''
      $insertClause INTO messages (
        id,
        guid,
        chat_id,
        sender_handle_id,
        is_from_me,
        sent_at_utc,
        delivered_at_utc,
        read_at_utc,
        status,
        text,
        raw_item_type,
        raw_associated_message_type,
        semantic_kind,
        is_sparse_artifact,
        has_attributed_body_source,
        has_message_summary_info,
        has_payload_data_source,
        item_type,
        is_system_message,
        error_code,
        has_attachments,
        reply_to_guid,
        associated_message_guid,
        thread_originator_guid,
        system_type,
        reaction_carrier,
        balloon_bundle_id,
        payload_json,
        reaction_summary_json,
        is_starred,
        is_deleted_local,
        updated_at_utc,
        batch_id
      )
      SELECT
        m.id,
        m.guid,
        m.chat_id,
        CASE
          WHEN map.canonical_handle_id IS NULL THEN NULL
          ELSE map.canonical_handle_id
        END AS sender_handle_id,
        m.is_from_me,
        ${_unixSecondsToWorkingTimestamp('m.date_utc')},
        ${_unixSecondsToWorkingTimestamp('m.date_delivered_utc')},
        ${_unixSecondsToWorkingTimestamp('m.date_read_utc')},
        'unknown' AS status,
        m.text,
        m.raw_item_type,
        m.raw_associated_message_type,
        CASE
          WHEN COALESCE(m.is_system_message, 0) = 1 OR m.item_type = 'system' THEN 'system'
          WHEN COALESCE(m.has_message_summary_info, 0) = 1 THEN 'edited-or-unsent'
          WHEN m.item_type = 'reaction-carrier'
            OR m.associated_message_guid IS NOT NULL
            OR COALESCE(m.raw_associated_message_type, 0) != 0 THEN 'associated'
          WHEN m.item_type = 'balloon'
            OR COALESCE(m.has_payload_data_source, 0) = 1
            OR COALESCE(LENGTH(TRIM(m.balloon_bundle_id)), 0) > 0 THEN 'balloon-or-app'
          WHEN m.item_type = 'attachment-only' THEN 'attachment-only'
          WHEN COALESCE(m.has_attributed_body_source, 0) = 1 THEN 'rich-text'
          WHEN COALESCE(LENGTH(TRIM(m.text)), 0) > 0 THEN 'plain-text'
          WHEN COALESCE(m.raw_item_type, -1) >= 0 THEN 'sparse-artifact'
          ELSE 'unknown-variant'
        END AS semantic_kind,
        CASE
          WHEN COALESCE(LENGTH(TRIM(m.text)), 0) = 0
            AND COALESCE(m.has_attributed_body_source, 0) = 0
            AND COALESCE(m.has_message_summary_info, 0) = 0
            AND COALESCE(m.has_payload_data_source, 0) = 0
            AND NOT EXISTS (
              SELECT 1 FROM $_attachAlias.message_attachments ma
              WHERE ma.message_id = m.id
            )
          THEN 1 ELSE 0
        END AS is_sparse_artifact,
        COALESCE(m.has_attributed_body_source, 0),
        COALESCE(m.has_message_summary_info, 0),
        COALESCE(m.has_payload_data_source, 0),
        CASE m.item_type
          WHEN 'text' THEN 'text'
          WHEN 'attachment-only' THEN 'attachment-only'
          WHEN 'sticker' THEN 'sticker'
          WHEN 'reaction-carrier' THEN 'reaction-carrier'
          WHEN 'system' THEN 'system'
          WHEN 'unknown' THEN 'unknown'
          WHEN 'balloon' THEN 'balloon'
          ELSE 'unknown'
        END AS item_type,
        COALESCE(m.is_system_message, 0),
        m.error_code,
        CASE
          WHEN EXISTS (
            SELECT 1 FROM $_attachAlias.message_attachments ma
            WHERE ma.message_id = m.id
          ) THEN 1 ELSE 0
        END AS has_attachments,
        m.associated_message_guid,
        m.associated_message_guid,
        m.thread_originator_guid,
        NULL,
        CASE WHEN m.item_type = 'reaction-carrier' THEN 1 ELSE 0 END,
        m.balloon_bundle_id,
        m.payload_json,
        NULL,
        0,
        0,
        NULL,
        m.batch_id
      FROM $_attachAlias.messages m
      JOIN chats c ON c.id = m.chat_id
      LEFT JOIN handles_canonical_to_alias map
        ON map.source_handle_id = m.sender_handle_id
      WHERE m.id IN ($idList);
    ''';
  }

  Future<int> _countResolvableIncomingMessages(IMigrationContext ctx) {
    return _withAttachedImport(ctx, () async {
      final rows = await ctx.workingDb.customSelect('''
        SELECT COUNT(*) AS c
        FROM messages working_messages
        WHERE working_messages.sender_handle_id IS NULL
          AND working_messages.is_from_me = 0
          AND EXISTS (
            SELECT 1
            FROM $_attachAlias.messages import_messages
            JOIN handles_canonical_to_alias map
              ON map.source_handle_id = import_messages.sender_handle_id
            WHERE import_messages.guid = working_messages.guid
          )
      ''').get();

      return _extractCount(rows, 'c');
    });
  }

  Future<T> _withAttachedImport<T>(
    IMigrationContext ctx,
    Future<T> Function() run,
  ) async {
    final importSqlite = await ctx.importDb.database;
    final escapedPath = importSqlite.path.replaceAll("'", "''");
    await ctx.workingDb.customStatement(
      "ATTACH DATABASE '$escapedPath' AS $_attachAlias",
    );
    try {
      return await ctx.workingDb.transaction<T>(() => run());
    } finally {
      await _detachImportWithRetry(ctx);
    }
  }

  Future<void> _detachImportWithRetry(IMigrationContext ctx) async {
    const maxAttempts = 5;
    var attempt = 0;
    while (true) {
      attempt += 1;
      try {
        await ctx.workingDb.customStatement('DETACH DATABASE $_attachAlias');
        return;
      } catch (error) {
        final message = error.toString();
        final isLocked =
            message.contains('database is locked') ||
            message.contains('SQLITE_LOCKED') ||
            message.contains('SQLITE_BUSY');
        if (!isLocked || attempt >= maxAttempts) {
          rethrow;
        }
        await Future<void>.delayed(Duration(milliseconds: 150 * attempt));
      }
    }
  }

  int _extractCount(List<dynamic> rows, String key) {
    if (rows.isEmpty) {
      return 0;
    }
    final first = rows.first;
    if (first is Map<String, Object?>) {
      return _coerceToInt(first[key]);
    }
    final data = (first as dynamic).data as Map<String, Object?>;
    return _coerceToInt(data[key]);
  }

  int _coerceToInt(Object? value) {
    if (value == null) {
      return 0;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is BigInt) {
      return value.toInt();
    }
    return int.parse(value.toString());
  }
}
