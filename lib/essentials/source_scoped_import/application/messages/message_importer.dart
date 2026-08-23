import 'dart:typed_data';

import '../../../../core/util/date_converter.dart';
import '../../domain/known_sources.dart';
import '../../domain/ports/import_ledger_port.dart';
import '../../domain/ports/source_database_port.dart';
import '../../domain/source_scoped_row_key.dart';
import '../source_import_work_progress.dart';

class MessageImportResult {
  const MessageImportResult({
    required this.startedAfterSourceRowId,
    required this.insertedMessageCount,
    required this.lastImportedSourceRowId,
  });

  final int startedAfterSourceRowId;
  final int insertedMessageCount;
  final int? lastImportedSourceRowId;
}

class MessageImporter {
  const MessageImporter({
    required this.chatDbPath,
    required this.importLedger,
    required this.sourceDatabaseOpener,
    this.sourceId = liveChatDbSourceId,
  });

  final String chatDbPath;
  final ImportLedger importLedger;
  final SourceDatabaseOpener sourceDatabaseOpener;
  final int sourceId;

  Future<MessageImportResult> importNewMessages({
    SourceImportWorkObserver? onProgress,
  }) async {
    final startedAfterSourceRowId =
        await importLedger.maxMessageSourceRowIdForSource(sourceId) ?? 0;

    final sourceDb = await sourceDatabaseOpener.openReadOnly(chatDbPath);

    try {
      final rows = await sourceDb.rawQuery(
        'SELECT ROWID AS source_rowid, * FROM message '
        'WHERE ROWID > ? ORDER BY ROWID ASC',
        <Object?>[startedAfterSourceRowId],
      );

      if (rows.isEmpty) {
        publishSourceImportProgress(
          observer: onProgress,
          unit: SourceImportWorkUnit.messages,
          completedWorkCount: 0,
          totalWorkCount: 0,
        );
        return MessageImportResult(
          startedAfterSourceRowId: startedAfterSourceRowId,
          insertedMessageCount: 0,
          lastImportedSourceRowId: null,
        );
      }

      final batchId = await importLedger.insertImportBatch(
        sourceId: sourceId,
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );

      var insertedMessageCount = 0;
      var completedMessageCount = 0;
      int? lastImportedSourceRowId;

      publishSourceImportProgress(
        observer: onProgress,
        unit: SourceImportWorkUnit.messages,
        completedWorkCount: 0,
        totalWorkCount: rows.length,
      );
      await importLedger.writeTransaction((txn) async {
        for (final row in rows) {
          int? sourceRowId;
          try {
            sourceRowId = _requiredInt(row, 'source_rowid');
            lastImportedSourceRowId = sourceRowId;
            final attributedBody = _nullableBlob(row, 'attributedBody');
            final messageSummaryInfo = _nullableBlob(
              row,
              'message_summary_info',
            );
            final payloadData = _nullableBlob(row, 'payload_data');

            final insertedId = await txn.insertIgnore('messages', <
              String,
              Object?
            >{
              'ss_id': SourceScopedRowKey.pack(
                sourceId: sourceId,
                sourceRowId: sourceRowId,
              ),
              'source_id': sourceId,
              'source_rowid': sourceRowId,
              'guid': _requiredString(row, 'guid'),
              'sender_handle_ss_id': _senderHandleSsId(row),
              'is_from_me': _boolInt(row, 'is_from_me'),
              'date_utc': DateConverter.appleToIsoString(row['date']),
              'date_read_utc': DateConverter.appleToIsoString(row['date_read']),
              'date_delivered_utc': DateConverter.appleToIsoString(
                row['date_delivered'],
              ),
              'text': _nullableString(row, 'text'),
              'attributed_body_blob': attributedBody,
              'associated_message_guid': _nullableString(
                row,
                'associated_message_guid',
              ),
              'raw_item_type': _nullableInt(row, 'item_type'),
              'raw_associated_message_type': _nullableInt(
                row,
                'associated_message_type',
              ),
              'thread_originator_guid': _nullableString(
                row,
                'thread_originator_guid',
              ),
              'error_code': _nullableInt(row, 'error'),
              'is_system_message': _boolIntOrZero(row, 'is_system_message'),
              'has_attributed_body_source': attributedBody == null ? 0 : 1,
              'has_message_summary_info': messageSummaryInfo == null ? 0 : 1,
              'has_payload_data_source': payloadData == null ? 0 : 1,
              'batch_id': batchId,
            });

            if (insertedId != 0) {
              insertedMessageCount += 1;
            }
          } on StateError catch (error) {
            throw SourceImportRecordException(
              unit: SourceImportWorkUnit.messages,
              sourceRowId: sourceRowId,
              reason: error.message,
            );
          }
          completedMessageCount += 1;
          publishSourceImportProgress(
            observer: onProgress,
            unit: SourceImportWorkUnit.messages,
            completedWorkCount: completedMessageCount,
            totalWorkCount: rows.length,
            lastCompletedSourceRowId: sourceRowId,
          );
        }
      });

      return MessageImportResult(
        startedAfterSourceRowId: startedAfterSourceRowId,
        insertedMessageCount: insertedMessageCount,
        lastImportedSourceRowId: lastImportedSourceRowId,
      );
    } finally {
      await sourceDb.close();
    }
  }

  int? _senderHandleSsId(Map<String, Object?> row) {
    final handleId = _nullableInt(row, 'handle_id');
    if (handleId == null || handleId <= 0) {
      return null;
    }
    return SourceScopedRowKey.pack(sourceId: sourceId, sourceRowId: handleId);
  }

  static int _boolInt(Map<String, Object?> row, String field) {
    final value = _requiredInt(row, field);
    return value == 0 ? 0 : 1;
  }

  static int _boolIntOrZero(Map<String, Object?> row, String field) {
    final value = _nullableInt(row, field);
    if (value == null) {
      return 0;
    }
    return value == 0 ? 0 : 1;
  }

  static String _requiredString(Map<String, Object?> row, String field) {
    final value = row[field];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    throw StateError('message.$field is required');
  }

  static int _requiredInt(Map<String, Object?> row, String field) {
    final value = _nullableInt(row, field);
    if (value == null) {
      throw StateError('message.$field is required');
    }
    return value;
  }

  static int? _nullableInt(Map<String, Object?> row, String field) {
    final value = row[field];
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    return null;
  }

  static String? _nullableString(Map<String, Object?> row, String field) {
    final value = row[field];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }

  static Uint8List? _nullableBlob(Map<String, Object?> row, String field) {
    final value = row[field];
    if (value is Uint8List) {
      return value;
    }
    if (value is List<int>) {
      return Uint8List.fromList(value);
    }
    return null;
  }
}
