import '../../../../core/util/date_converter.dart';
import '../../domain/known_sources.dart';
import '../../domain/ports/import_ledger_port.dart';
import '../../domain/ports/source_database_port.dart';
import '../../domain/source_scoped_row_key.dart';

class ChatImportResult {
  const ChatImportResult({
    required this.examinedChatCount,
    required this.insertedChatCount,
  });

  final int examinedChatCount;
  final int insertedChatCount;
}

class ChatImporter {
  const ChatImporter({
    required this.chatDbPath,
    required this.importLedger,
    required this.sourceDatabaseOpener,
    this.sourceId = liveChatDbSourceId,
  });

  final String chatDbPath;
  final ImportLedger importLedger;
  final SourceDatabaseOpener sourceDatabaseOpener;
  final int sourceId;

  Future<ChatImportResult> importChats() async {
    final sourceDb = await sourceDatabaseOpener.openReadOnly(chatDbPath);

    try {
      final rows = await sourceDb.rawQuery(
        'SELECT ROWID AS source_rowid, * FROM chat ORDER BY ROWID ASC',
      );
      final batchId = await importLedger.insertImportBatch(
        sourceId: sourceId,
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );

      var insertedChatCount = 0;
      await importLedger.writeTransaction((txn) async {
        for (final row in rows) {
          final sourceRowId = _requiredInt(row, 'source_rowid');
          final guid = _requiredString(row, 'guid');
          final insertedId = await txn.insertIgnore('chats', <String, Object?>{
            'ss_id': SourceScopedRowKey.pack(
              sourceId: sourceId,
              sourceRowId: sourceRowId,
            ),
            'source_id': sourceId,
            'source_rowid': sourceRowId,
            'guid': guid,
            'service':
                _nullableString(row, 'service_name') ??
                _nullableString(row, 'service'),
            'group_id': _nullableString(row, 'group_id'),
            'original_group_id': _nullableString(row, 'original_group_id'),
            'last_read_message_at_utc': DateConverter.appleToIsoString(
              row['last_read_message_timestamp'],
            ),
            'batch_id': batchId,
          });

          if (insertedId != 0) {
            insertedChatCount += 1;
          }
        }
      });

      return ChatImportResult(
        examinedChatCount: rows.length,
        insertedChatCount: insertedChatCount,
      );
    } finally {
      await sourceDb.close();
    }
  }

  static int _requiredInt(Map<String, Object?> row, String field) {
    final value = row[field];
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    throw StateError('chat.$field is required');
  }

  static String? _nullableString(Map<String, Object?> row, String field) {
    final value = row[field];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }

  static String _requiredString(Map<String, Object?> row, String field) {
    final value = _nullableString(row, field);
    if (value == null) {
      throw StateError('chat.$field is required');
    }
    return value;
  }
}
