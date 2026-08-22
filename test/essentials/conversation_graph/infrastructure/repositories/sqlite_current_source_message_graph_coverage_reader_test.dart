import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/current_source_message_graph_coverage_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/sqlite_current_source_message_graph_coverage_reader.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';

void main() {
  test('classifies source 1 and excludes 8,882 historical rows', () async {
    final database = ConversationGraphDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final linkedId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 1,
    );
    final recoveredId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 2,
    );
    await database.executeSql('''
      INSERT INTO messages (ss_id, guid, is_from_me)
      VALUES ($linkedId, 'current-linked', 0),
             ($recoveredId, 'current-recovered', 1)
    ''');
    await database.executeSql('''
      INSERT INTO chat_to_message (chat_ss_id, message_ss_id)
      VALUES (${SourceScopedRowKey.pack(sourceId: liveChatDbSourceId, sourceRowId: 50)}, $linkedId)
    ''');
    await _insertHistoricalRows(database, count: 8882);

    final evidence = await SqliteCurrentSourceMessageGraphCoverageReader(
      graphDatabase: database,
    ).read();

    expect(evidence.placementBySourceRowId, {
      1: CurrentSourceMessageGraphPlacement.conversationLinked,
      2: CurrentSourceMessageGraphPlacement.recoveredUnlinked,
    });
  });
}

Future<void> _insertHistoricalRows(
  ConversationGraphDatabase database, {
  required int count,
}) async {
  const batchSize = 400;
  for (var start = 1; start <= count; start += batchSize) {
    final candidateEnd = start + batchSize - 1;
    final end = candidateEnd < count ? candidateEnd : count;
    final values = <String>[];
    for (var sourceRowId = start; sourceRowId <= end; sourceRowId++) {
      final scopedId = SourceScopedRowKey.pack(
        sourceId: 3,
        sourceRowId: sourceRowId,
      );
      values.add("($scopedId, 'historical-$sourceRowId', 0)");
    }
    await database.executeSql('''
      INSERT INTO messages (ss_id, guid, is_from_me)
      VALUES ${values.join(',')}
    ''');
  }
}
