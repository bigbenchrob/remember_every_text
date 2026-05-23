import '../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../source_scoped_import/infrastructure/import_database_provider.dart';
import '../../application/chats/chat_projection_repository.dart';

class SqliteChatProjectionRepository implements ChatProjectionRepository {
  const SqliteChatProjectionRepository({
    required this.importDatabase,
    required this.workingDatabase,
  });

  final ImportDatabase importDatabase;
  final ConversationGraphDatabase workingDatabase;

  @override
  Future<ChatProjectionResult> projectChats() async {
    final rows = await importDatabase.database.query(
      'chats',
      columns: <String>['ss_id', 'guid', 'service', 'last_read_message_at_utc'],
      orderBy: 'ss_id ASC',
    );

    var insertedChatCount = 0;
    await workingDatabase.transaction(() async {
      for (final row in rows) {
        final chatSsId = _requiredInt(row, 'ss_id');
        final participantCount = await _participantCount(
          workingDatabase,
          chatSsId,
        );
        final insertedCount = await workingDatabase.executeAndReadChanges(
          '''
          INSERT OR IGNORE INTO chats (
            ss_id,
            guid,
            service,
            is_group,
            last_read_message_at_utc
          ) VALUES (?, ?, ?, ?, ?)
          ''',
          <Object?>[
            chatSsId,
            row['guid'],
            row['service'],
            if (participantCount > 1) 1 else 0,
            row['last_read_message_at_utc'],
          ],
        );
        if (insertedCount != 0) {
          insertedChatCount += 1;
        }
      }
    });

    return ChatProjectionResult(
      examinedChatCount: rows.length,
      insertedChatCount: insertedChatCount,
    );
  }

  static Future<int> _participantCount(
    ConversationGraphDatabase database,
    int chatSsId,
  ) async {
    final rows = await database.selectRows(
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
