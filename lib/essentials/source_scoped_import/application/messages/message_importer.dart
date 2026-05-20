import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';

import '../../../../core/util/date_converter.dart';
import '../../domain/known_sources.dart';
import '../../domain/source_scoped_row_key.dart';
import '../../infrastructure/import_database_provider.dart';

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
    required this.importDatabase,
    this.sourceId = liveChatDbSourceId,
  });

  final String chatDbPath;
  final ImportDatabase importDatabase;
  final int sourceId;

  Future<MessageImportResult> importNewMessages() async {
    final startedAfterSourceRowId =
        await importDatabase.maxMessageSourceRowIdForSource(sourceId) ?? 0;

    final sourceDb = await openDatabase(
      chatDbPath,
      readOnly: true,
      singleInstance: false,
    );

    try {
      final rows = await sourceDb.rawQuery(
        'SELECT ROWID AS source_rowid, * FROM message '
        'WHERE ROWID > ? ORDER BY ROWID ASC',
        <Object?>[startedAfterSourceRowId],
      );

      if (rows.isEmpty) {
        return MessageImportResult(
          startedAfterSourceRowId: startedAfterSourceRowId,
          insertedMessageCount: 0,
          lastImportedSourceRowId: null,
        );
      }

      final batchId = await importDatabase.insertImportBatch(
        sourceId: sourceId,
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );

      var insertedMessageCount = 0;
      int? lastImportedSourceRowId;

      await importDatabase.database.transaction((txn) async {
        for (final row in rows) {
          final sourceRowId = _requiredInt(row, 'source_rowid');
          lastImportedSourceRowId = sourceRowId;

          final insertedId = await txn.insert('messages', <String, Object?>{
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
            'attributed_body_blob': _nullableBlob(row, 'attributedBody'),
            'associated_message_guid': _nullableString(
              row,
              'associated_message_guid',
            ),
            'batch_id': batchId,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);

          if (insertedId != 0) {
            insertedMessageCount += 1;
          }
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
