import 'package:drift/drift.dart';

import '../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../db/infrastructure/data_sources/local/working/working_database.dart';
import '../domain/models/source_identity.dart';
import '../domain/models/topology_projection_preview.dart';

class TopologyProjectionPreviewRepository {
  const TopologyProjectionPreviewRepository({
    required SqfliteImportDatabase ledgerDb,
    required WorkingDatabase workingDb,
    SourceIdentity source = liveChatDbSourceIdentity,
  }) : _ledgerDb = ledgerDb,
       _workingDb = workingDb,
       _source = source;

  final SqfliteImportDatabase _ledgerDb;
  final WorkingDatabase _workingDb;
  final SourceIdentity _source;

  Future<List<TopologyProjectionPreviewFact>> readPreviewFacts({
    int limit = 250,
  }) async {
    final topologyRows = await _ledgerDb.rawQuery(
      '''
      SELECT
        cmj.source_id,
        cmj.source_kind,
        cmj.source_rowid AS source_join_rowid,
        cmj.source_chat_rowid,
        cmj.source_message_rowid,
        m.id AS ledger_message_id,
        m.guid AS ledger_message_guid,
        c.id AS ledger_chat_id,
        c.guid AS ledger_chat_guid
      FROM chat_message_joins cmj
      LEFT JOIN messages m
        ON m.source_id = cmj.source_id
       AND m.source_rowid = cmj.source_message_rowid
      LEFT JOIN chats c
        ON c.source_id = cmj.source_id
       AND c.source_rowid = cmj.source_chat_rowid
      WHERE cmj.source_id = ?
      ORDER BY cmj.source_rowid ASC
      LIMIT ?;
      ''',
      <Object?>[_source.sourceId, limit],
    );

    final facts = <TopologyProjectionPreviewFact>[];
    for (final row in topologyRows) {
      final ledgerMessageGuid = _readNullableString(row, 'ledger_message_guid');
      final ledgerChatGuid = _readNullableString(row, 'ledger_chat_guid');

      facts.add(
        TopologyProjectionPreviewFact(
          sourceId: _readRequiredString(row, 'source_id'),
          sourceKind: _readRequiredString(row, 'source_kind'),
          sourceJoinRowId: _readRequiredInt(row, 'source_join_rowid'),
          sourceChatRowId: _readRequiredInt(row, 'source_chat_rowid'),
          sourceMessageRowId: _readRequiredInt(row, 'source_message_rowid'),
          ledgerMessageId: _readNullableInt(row, 'ledger_message_id'),
          ledgerMessageGuid: ledgerMessageGuid,
          ledgerChatId: _readNullableInt(row, 'ledger_chat_id'),
          ledgerChatGuid: ledgerChatGuid,
          workingMessageIds: await _readWorkingMessageIds(ledgerMessageGuid),
          workingChatIds: await _readWorkingChatIds(ledgerChatGuid),
        ),
      );
    }

    return List<TopologyProjectionPreviewFact>.unmodifiable(facts);
  }

  Future<List<int>> _readWorkingMessageIds(String? guid) async {
    if (guid == null || guid.trim().isEmpty) {
      return const <int>[];
    }

    final rows = await _workingDb
        .customSelect(
          '''
          SELECT id
          FROM messages
          WHERE guid = ?;
          ''',
          variables: <Variable<Object>>[Variable<String>(guid)],
        )
        .get();
    return _readIdList(rows);
  }

  Future<List<int>> _readWorkingChatIds(String? guid) async {
    if (guid == null || guid.trim().isEmpty) {
      return const <int>[];
    }

    final rows = await _workingDb
        .customSelect(
          '''
          SELECT id
          FROM chats
          WHERE guid = ?;
          ''',
          variables: <Variable<Object>>[Variable<String>(guid)],
        )
        .get();
    return _readIdList(rows);
  }

  List<int> _readIdList(List<QueryRow> rows) {
    return List<int>.unmodifiable(
      rows.map((row) => _readRequiredInt(row.data, 'id')),
    );
  }

  int _readRequiredInt(Map<String, Object?> row, String column) {
    final value = row[column];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }

    throw FormatException('Expected integer value for $column, got $value.');
  }

  int? _readNullableInt(Map<String, Object?> row, String column) {
    final value = row[column];
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }

    throw FormatException('Expected integer value for $column, got $value.');
  }

  String _readRequiredString(Map<String, Object?> row, String column) {
    final value = _readNullableString(row, column);
    if (value == null || value.isEmpty) {
      throw FormatException('Expected non-empty string value for $column.');
    }
    return value;
  }

  String? _readNullableString(Map<String, Object?> row, String column) {
    final value = row[column];
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value;
    }
    return value.toString();
  }
}
