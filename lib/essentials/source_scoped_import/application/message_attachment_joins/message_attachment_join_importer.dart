import 'package:sqflite/sqflite.dart';

import '../../domain/known_sources.dart';
import '../../domain/source_scoped_row_key.dart';
import '../../infrastructure/import_database_provider.dart';

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
    required this.importDatabase,
    this.sourceId = liveChatDbSourceId,
  });

  final String chatDbPath;
  final ImportDatabase importDatabase;
  final int sourceId;

  Future<MessageAttachmentJoinImportResult> importJoins() async {
    final sourceDb = await openDatabase(
      chatDbPath,
      readOnly: true,
      singleInstance: false,
    );

    try {
      final rows = await sourceDb.rawQuery(
        'SELECT message_id, attachment_id '
        'FROM message_attachment_join '
        'ORDER BY message_id ASC, attachment_id ASC',
      );

      if (rows.isEmpty) {
        return const MessageAttachmentJoinImportResult(
          examinedJoinCount: 0,
          insertedJoinCount: 0,
        );
      }

      final batchId = await importDatabase.insertImportBatch(
        sourceId: sourceId,
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );

      var insertedJoinCount = 0;
      await importDatabase.database.transaction((txn) async {
        for (final row in rows) {
          final sourceMessageRowId = _requiredInt(row, 'message_id');
          final sourceAttachmentRowId = _requiredInt(row, 'attachment_id');
          final insertedId = await txn
              .insert('message_to_attachment', <String, Object?>{
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
              }, conflictAlgorithm: ConflictAlgorithm.ignore);

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
