import '../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../domain/models/chat_message_join_snapshot.dart';
import '../domain/models/source_identity.dart';

class ImportLedgerChatMessageJoinRepository {
  const ImportLedgerChatMessageJoinRepository({
    required SqfliteImportDatabase ledgerDb,
    SourceIdentity source = liveChatDbSourceIdentity,
  }) : _ledgerDb = ledgerDb,
       _source = source;

  final SqfliteImportDatabase _ledgerDb;
  final SourceIdentity _source;

  Future<ChatMessageJoinSnapshot> readChatMessageJoinSnapshot() async {
    final hasTopologyLedger = await _tableExists('chat_message_joins');
    if (!hasTopologyLedger) {
      return const ChatMessageJoinSnapshot(
        maxRowId: 0,
        totalJoinCount: 0,
        maxMessageRowId: 0,
        maxChatRowId: 0,
        sourceScopedObservationAvailable: false,
      );
    }

    final maxRowId = await _readInt(
      '''
      SELECT MAX(source_rowid) AS value
      FROM chat_message_joins
      WHERE source_id = ?;
      ''',
      <Object?>[_source.sourceId],
    );
    final totalJoinCount = await _readInt(
      '''
      SELECT COUNT(*) AS value
      FROM chat_message_joins
      WHERE source_id = ?
      AND source_rowid IS NOT NULL;
      ''',
      <Object?>[_source.sourceId],
    );
    final maxMessageRowId = await _readInt(
      '''
      SELECT MAX(source_message_rowid) AS value
      FROM chat_message_joins
      WHERE source_id = ?;
      ''',
      <Object?>[_source.sourceId],
    );
    final maxChatRowId = await _readInt(
      '''
      SELECT MAX(source_chat_rowid) AS value
      FROM chat_message_joins
      WHERE source_id = ?;
      ''',
      <Object?>[_source.sourceId],
    );

    return ChatMessageJoinSnapshot(
      maxRowId: maxRowId,
      totalJoinCount: totalJoinCount,
      maxMessageRowId: maxMessageRowId,
      maxChatRowId: maxChatRowId,
      sourceScopedObservationAvailable: true,
    );
  }

  Future<bool> _tableExists(String table) async {
    final rows = await _ledgerDb.rawQuery(
      '''
      SELECT 1
      FROM sqlite_master
      WHERE type = 'table'
      AND name = ?
      LIMIT 1;
      ''',
      <Object?>[table],
    );
    return rows.isNotEmpty;
  }

  Future<int> _readInt(String sql, List<Object?> args) async {
    final rows = await _ledgerDb.rawQuery(sql, args);
    if (rows.isEmpty) {
      throw StateError('Query returned no rows.');
    }

    final value = rows.first['value'];
    if (value == null) {
      return 0;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }

    throw FormatException('Expected integer query value, got $value.');
  }
}
