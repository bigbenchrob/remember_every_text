import '../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../source_scoped_import/domain/known_sources.dart';
import '../../../source_scoped_import/domain/source_scoped_row_sql.dart';
import '../../application/messages/current_source_message_graph_coverage_reader.dart';

final class SqliteCurrentSourceMessageGraphCoverageReader
    implements CurrentSourceMessageGraphCoverageReader {
  const SqliteCurrentSourceMessageGraphCoverageReader({
    required ConversationGraphDatabase graphDatabase,
  }) : _graphDatabase = graphDatabase;

  final ConversationGraphDatabase _graphDatabase;

  @override
  Future<CurrentSourceMessageGraphCoverageEvidence> read() async {
    final rows = await _graphDatabase.selectRows(
      _currentSourceCoverageSql,
      const <Object?>[liveChatDbSourceId],
    );
    final placements = <int, CurrentSourceMessageGraphPlacement>{};
    for (final row in rows) {
      final sourceRowId = _requiredPositiveInt(row, 'source_row_id');
      final placement = switch (_requiredInt(row, 'is_conversation_linked')) {
        1 => CurrentSourceMessageGraphPlacement.conversationLinked,
        0 => CurrentSourceMessageGraphPlacement.recoveredUnlinked,
        _ => throw StateError(
          'Current-source graph coverage returned an invalid placement.',
        ),
      };
      if (placements.containsKey(sourceRowId)) {
        throw StateError(
          'Current-source graph coverage observed duplicate row identity '
          '$sourceRowId.',
        );
      }
      placements[sourceRowId] = placement;
    }
    return CurrentSourceMessageGraphCoverageEvidence(
      placementBySourceRowId: placements,
    );
  }

  static final String _currentSourceCoverageSql =
      '''
    WITH linked_message_ids AS (
      SELECT DISTINCT message_ss_id
      FROM chat_to_message
    )
    SELECT
      ${SourceScopedRowSql.sourceRowId('m.ss_id')} AS source_row_id,
      CASE WHEN linked.message_ss_id IS NULL THEN 0 ELSE 1 END
        AS is_conversation_linked
    FROM messages AS m
    LEFT JOIN linked_message_ids AS linked
      ON linked.message_ss_id = m.ss_id
    WHERE ${SourceScopedRowSql.sourceId('m.ss_id')} = ?
    ORDER BY source_row_id ASC
  ''';
}

int _requiredInt(Map<String, Object?> row, String key) {
  final value = row[key];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  throw StateError('$key must be an integer.');
}

int _requiredPositiveInt(Map<String, Object?> row, String key) {
  final value = _requiredInt(row, key);
  if (value <= 0) {
    throw StateError('$key must be positive.');
  }
  return value;
}
