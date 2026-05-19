import 'package:sqflite/sqflite.dart';

import '../../infrastructure/import_database_provider.dart';
import '../../infrastructure/working_database_provider.dart';

class MessageProjectionResult {
  const MessageProjectionResult({
    required this.examinedMessageCount,
    required this.insertedMessageCount,
  });

  final int examinedMessageCount;
  final int insertedMessageCount;
}

class MessageProjector {
  const MessageProjector({
    required this.importDatabase,
    required this.workingDatabase,
  });

  final ImportDatabase importDatabase;
  final WorkingDatabase workingDatabase;

  Future<MessageProjectionResult> projectMessages() async {
    final rows = await importDatabase.database.query(
      'messages',
      columns: <String>[
        'ss_id',
        'source_id',
        'guid',
        'sender_handle_ss_id',
        'is_from_me',
        'date_utc',
        'text',
        'associated_message_guid',
      ],
      orderBy: 'ss_id ASC',
    );

    var insertedMessageCount = 0;
    await workingDatabase.database.transaction((txn) async {
      for (final row in rows) {
        final associatedMessageSsId = await _resolveAssociatedMessageSsId(row);
        final insertedId = await txn.insert('messages', <String, Object?>{
          'ss_id': row['ss_id'],
          'guid': row['guid'],
          'sender_handle_ss_id': row['sender_handle_ss_id'],
          'is_from_me': row['is_from_me'],
          'date_utc': row['date_utc'],
          'text': row['text'],
          'associated_message_ss_id': associatedMessageSsId,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);

        if (insertedId != 0) {
          insertedMessageCount += 1;
        }
      }
    });

    return MessageProjectionResult(
      examinedMessageCount: rows.length,
      insertedMessageCount: insertedMessageCount,
    );
  }

  Future<int?> _resolveAssociatedMessageSsId(Map<String, Object?> row) async {
    final associatedGuid = row['associated_message_guid'];
    if (associatedGuid is! String || associatedGuid.isEmpty) {
      return null;
    }

    final sourceId = row['source_id'];
    if (sourceId is! int) {
      return null;
    }

    final rows = await importDatabase.database.query(
      'messages',
      columns: <String>['ss_id'],
      where: 'source_id = ? AND guid = ?',
      whereArgs: <Object?>[sourceId, associatedGuid],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return rows.single['ss_id'] as int?;
  }
}
