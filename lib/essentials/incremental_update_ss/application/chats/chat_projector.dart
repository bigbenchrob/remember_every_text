import 'package:sqflite/sqflite.dart';

import '../../infrastructure/import_database_provider.dart';
import '../../infrastructure/working_database_provider.dart';

class ChatProjectionResult {
  const ChatProjectionResult({
    required this.examinedChatCount,
    required this.insertedChatCount,
  });

  final int examinedChatCount;
  final int insertedChatCount;
}

class ChatProjector {
  const ChatProjector({
    required this.importDatabase,
    required this.workingDatabase,
  });

  final ImportDatabase importDatabase;
  final WorkingDatabase workingDatabase;

  Future<ChatProjectionResult> projectChats() async {
    final rows = await importDatabase.database.query(
      'chats',
      columns: <String>['ss_id', 'guid', 'service', 'last_read_message_at_utc'],
      orderBy: 'ss_id ASC',
    );

    var insertedChatCount = 0;
    await workingDatabase.database.transaction((txn) async {
      for (final row in rows) {
        final chatSsId = _requiredInt(row, 'ss_id');
        final participantCount = await _participantCount(txn, chatSsId);
        final insertedId = await txn.insert('chats', <String, Object?>{
          'ss_id': chatSsId,
          'guid': row['guid'],
          'service': row['service'],
          'is_group': participantCount > 1 ? 1 : 0,
          'last_read_message_at_utc': row['last_read_message_at_utc'],
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        if (insertedId != 0) {
          insertedChatCount += 1;
        }
      }
    });

    return ChatProjectionResult(
      examinedChatCount: rows.length,
      insertedChatCount: insertedChatCount,
    );
  }

  static Future<int> _participantCount(Transaction txn, int chatSsId) async {
    final rows = await txn.rawQuery(
      'SELECT COUNT(*) AS handle_count FROM chat_to_handle WHERE chat_ss_id = ?',
      <Object?>[chatSsId],
    );
    return rows.single['handle_count'] as int? ?? 0;
  }

  static int _requiredInt(Map<String, Object?> row, String field) {
    final value = row[field];
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    throw StateError('chats.$field is required');
  }
}
