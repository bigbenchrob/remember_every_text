import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/messages/infrastructure/repositories/graph_recovered_message_projectability_repository.dart';

void main() {
  group('GraphRecoveredMessageProjectabilityRepository', () {
    late ConversationGraphDatabase graphDb;
    late GraphRecoveredMessageProjectabilityRepository repository;

    setUp(() async {
      graphDb = ConversationGraphDatabase(NativeDatabase.memory());
      await graphDb.selectRows('SELECT COUNT(*) AS c FROM messages');
      repository = GraphRecoveredMessageProjectabilityRepository(
        graphDb: graphDb,
      );
    });

    tearDown(() async {
      await graphDb.close();
    });

    test('returns only candidate messages with chat topology', () async {
      final projectableMessageId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 42,
      );
      final orphanMessageId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 43,
      );

      await graphDb.executeSql(
        '''
        INSERT INTO chat_to_message (chat_ss_id, message_ss_id)
        VALUES (?, ?)
        ''',
        [
          SourceScopedRowKey.pack(sourceId: liveChatDbSourceId, sourceRowId: 7),
          projectableMessageId,
        ],
      );

      final projectableIds = await repository.readProjectableMessageIds([
        projectableMessageId,
        orphanMessageId,
      ]);

      expect(projectableIds, {projectableMessageId});
    });
  });
}
