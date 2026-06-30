import '../../domain/known_sources.dart';
import '../../domain/ports/import_ledger_port.dart';
import '../../domain/ports/source_database_port.dart';
import '../../domain/source_scoped_row_key.dart';

class MessageAttachmentJoinImportResult {
  const MessageAttachmentJoinImportResult({
    required this.examinedJoinCount,
    required this.insertedJoinCount,
  });

  final int examinedJoinCount;
  final int insertedJoinCount;
}

class MessageAttachmentJoinImporter {
  const MessageAttachmentJoinImporter({
    required this.chatDbPath,
    required this.importLedger,
    required this.sourceDatabaseOpener,
    this.sourceId = liveChatDbSourceId,
  });

  final String chatDbPath;
  final ImportLedger importLedger;
  final SourceDatabaseOpener sourceDatabaseOpener;
  final int sourceId;

  Future<MessageAttachmentJoinImportResult> importJoins() async {
    return _importJoinsWhere(whereClause: null, whereArgs: const <Object?>[]);
  }

  Future<MessageAttachmentJoinImportResult> importJoinsAfterSourceMessageRowId({
    required int startedAfterSourceRowId,
  }) {
    return _importJoinsWhere(
      whereClause: 'WHERE message_id > ?',
      whereArgs: <Object?>[startedAfterSourceRowId],
    );
  }

  Future<MessageAttachmentJoinImportResult> _importJoinsWhere({
    required String? whereClause,
    required List<Object?> whereArgs,
  }) async {
    final sourceDb = await sourceDatabaseOpener.openReadOnly(chatDbPath);

    try {
      final rows = await sourceDb.rawQuery(
        'SELECT message_id, attachment_id '
        'FROM message_attachment_join '
        '${whereClause ?? ''} '
        'ORDER BY message_id ASC, attachment_id ASC',
        whereArgs,
      );

      if (rows.isEmpty) {
        return const MessageAttachmentJoinImportResult(
          examinedJoinCount: 0,
          insertedJoinCount: 0,
        );
      }

      final batchId = await importLedger.insertImportBatch(
        sourceId: sourceId,
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );

      var insertedJoinCount = 0;
      await importLedger.writeTransaction((txn) async {
        for (final row in rows) {
          final sourceMessageRowId = _requiredInt(row, 'message_id');
          final sourceAttachmentRowId = _requiredInt(row, 'attachment_id');
          final insertedId = await txn
              .insertIgnore('message_to_attachment', <String, Object?>{
                'message_source_id': sourceId,
                'attachment_source_id': sourceId,
                'source_message_rowid': sourceMessageRowId,
                'source_attachment_rowid': sourceAttachmentRowId,
                'message_ss_id': SourceScopedRowKey.pack(
                  sourceId: sourceId,
                  sourceRowId: sourceMessageRowId,
                ),
                'attachment_ss_id': SourceScopedRowKey.pack(
                  sourceId: sourceId,
                  sourceRowId: sourceAttachmentRowId,
                ),
                'batch_id': batchId,
              });

          if (insertedId != 0) {
            insertedJoinCount += 1;
          }
        }
      });

      return MessageAttachmentJoinImportResult(
        examinedJoinCount: rows.length,
        insertedJoinCount: insertedJoinCount,
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
    throw StateError('message_attachment_join.$field is required');
  }
}
