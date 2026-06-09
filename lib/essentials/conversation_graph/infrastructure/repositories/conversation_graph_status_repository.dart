import 'package:sqflite/sqflite.dart';

import '../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../source_scoped_import/infrastructure/import_database_provider.dart';
import '../../domain/status/conversation_graph_status.dart';

final class ConversationGraphStatusRepository {
  const ConversationGraphStatusRepository();

  Future<ConversationGraphStatus> readStatus({
    required String chatDbPath,
    required ImportDatabase importDatabase,
    required ConversationGraphDatabase graphDatabase,
    required String importDatabaseName,
    required String graphDatabaseName,
    required int sourceId,
  }) async {
    final sourceSnapshot = await _readSourceMessageSnapshot(chatDbPath);
    final sourceChatCount = await _readSourceTableCount(
      chatDbPath: chatDbPath,
      tableName: 'chat',
      alias: 'chat_count',
    );
    final sourceHandleCount = await _readSourceTableCount(
      chatDbPath: chatDbPath,
      tableName: 'handle',
      alias: 'handle_count',
    );
    final sourceAttachmentCount = await _readSourceTableCount(
      chatDbPath: chatDbPath,
      tableName: 'attachment',
      alias: 'attachment_count',
    );
    final ledgerSnapshot = await _readLedgerMessageSnapshot(
      importDatabase,
      sourceId,
    );
    final graphMessageSnapshot = await _readGraphMessageSnapshot(graphDatabase);
    final graphSnapshot = await _readGraphSnapshot(
      importDatabase,
      graphDatabase,
    );

    return ConversationGraphStatus(
      chatDbPath: chatDbPath,
      importDatabaseName: importDatabaseName,
      graphDatabaseName: graphDatabaseName,
      sourceId: sourceId,
      sourceMessageCount: sourceSnapshot.count,
      sourceMaxRowId: sourceSnapshot.maxRowId,
      ledgerMessageCount: ledgerSnapshot.count,
      ledgerMaxSourceRowId: ledgerSnapshot.maxRowId,
      ledgerMessagesNeedingEnrichment: ledgerSnapshot.needingEnrichmentCount,
      ledgerMessagesStillWithoutText: ledgerSnapshot.withoutTextCount,
      graphMessageCount: graphMessageSnapshot.count,
      associatedMessageEdgeCount:
          graphMessageSnapshot.associatedMessageEdgeCount,
      sourceChatCount: sourceChatCount,
      importChatCount: graphSnapshot.importChatCount,
      graphChatCount: graphSnapshot.graphChatCount,
      sourceHandleCount: sourceHandleCount,
      importHandleCount: graphSnapshot.importHandleCount,
      graphHandleCount: graphSnapshot.graphHandleCount,
      importTopologyEdgeCount: graphSnapshot.importTopologyEdgeCount,
      graphTopologyEdgeCount: graphSnapshot.graphTopologyEdgeCount,
      duplicateGraphTopologyEdgeCount:
          graphSnapshot.duplicateGraphTopologyEdgeCount,
      importChatToHandleEdgeCount: graphSnapshot.importChatToHandleEdgeCount,
      graphChatToHandleEdgeCount: graphSnapshot.graphChatToHandleEdgeCount,
      duplicateGraphChatToHandleEdgeCount:
          graphSnapshot.duplicateGraphChatToHandleEdgeCount,
      sourceAttachmentCount: sourceAttachmentCount,
      importAttachmentCount: graphSnapshot.importAttachmentCount,
      graphAttachmentCount: graphSnapshot.graphAttachmentCount,
      importMessageToAttachmentEdgeCount:
          graphSnapshot.importMessageToAttachmentEdgeCount,
      graphMessageToAttachmentEdgeCount:
          graphSnapshot.graphMessageToAttachmentEdgeCount,
      duplicateGraphMessageToAttachmentEdgeCount:
          graphSnapshot.duplicateGraphMessageToAttachmentEdgeCount,
    );
  }

  Future<_MessageSnapshot> _readSourceMessageSnapshot(String chatDbPath) async {
    final db = await openDatabase(
      chatDbPath,
      readOnly: true,
      singleInstance: false,
    );

    try {
      final rows = await db.rawQuery(
        'SELECT COUNT(*) AS message_count, '
        'COALESCE(MAX(ROWID), 0) AS max_rowid FROM message',
      );
      final row = rows.single;

      return _MessageSnapshot(
        count: _readInt(row['message_count']),
        maxRowId: _readInt(row['max_rowid']),
        needingEnrichmentCount: 0,
        withoutTextCount: 0,
      );
    } finally {
      await db.close();
    }
  }

  Future<int> _readSourceTableCount({
    required String chatDbPath,
    required String tableName,
    required String alias,
  }) async {
    final db = await openDatabase(
      chatDbPath,
      readOnly: true,
      singleInstance: false,
    );

    try {
      final rows = await db.rawQuery(
        'SELECT COUNT(*) AS $alias FROM $tableName',
      );
      return _readInt(rows.single[alias]);
    } finally {
      await db.close();
    }
  }

  Future<_MessageSnapshot> _readLedgerMessageSnapshot(
    ImportDatabase importDatabase,
    int sourceId,
  ) async {
    final rows = await importDatabase.database.rawQuery(
      '''
      SELECT
        COUNT(*) AS message_count,
        COALESCE(MAX(source_rowid), 0) AS max_rowid,
        SUM(CASE WHEN text IS NULL AND attributed_body_blob IS NOT NULL
          THEN 1 ELSE 0 END) AS needing_enrichment_count,
        SUM(CASE WHEN text IS NULL OR text = '' THEN 1 ELSE 0 END)
          AS without_text_count
      FROM messages
      WHERE source_id = ?
      ''',
      <Object?>[sourceId],
    );
    final row = rows.single;

    return _MessageSnapshot(
      count: _readInt(row['message_count']),
      maxRowId: _readInt(row['max_rowid']),
      needingEnrichmentCount: _readInt(row['needing_enrichment_count']),
      withoutTextCount: _readInt(row['without_text_count']),
    );
  }

  Future<_GraphMessageSnapshot> _readGraphMessageSnapshot(
    ConversationGraphDatabase graphDatabase,
  ) async {
    final rows = await graphDatabase.selectRows(
      'SELECT COUNT(*) AS message_count, '
      'COUNT(associated_message_ss_id) AS associated_message_edge_count '
      'FROM messages',
    );
    final row = rows.single;

    return _GraphMessageSnapshot(
      count: _readInt(row['message_count']),
      associatedMessageEdgeCount: _readInt(
        row['associated_message_edge_count'],
      ),
    );
  }

  Future<_GraphSnapshot> _readGraphSnapshot(
    ImportDatabase importDatabase,
    ConversationGraphDatabase graphDatabase,
  ) async {
    final importChatRows = await importDatabase.database.rawQuery(
      'SELECT COUNT(*) AS chat_count FROM chats',
    );
    final graphChatRows = await graphDatabase.selectRows(
      'SELECT COUNT(*) AS chat_count FROM chats',
    );
    final importHandleRows = await importDatabase.database.rawQuery(
      'SELECT COUNT(*) AS handle_count FROM handles',
    );
    final graphHandleRows = await graphDatabase.selectRows(
      'SELECT COUNT(*) AS handle_count FROM handles',
    );
    final importEdgeRows = await importDatabase.database.rawQuery(
      'SELECT COUNT(*) AS edge_count FROM chat_to_message',
    );
    final graphEdgeRows = await graphDatabase.selectRows(
      'SELECT COUNT(*) AS edge_count FROM chat_to_message',
    );
    final duplicateEdgeRows = await graphDatabase.selectRows('''
      SELECT COUNT(*) AS duplicate_edge_count
      FROM (
        SELECT chat_ss_id, message_ss_id
        FROM chat_to_message
        GROUP BY chat_ss_id, message_ss_id
        HAVING COUNT(*) > 1
      )
    ''');
    final importChatToHandleRows = await importDatabase.database.rawQuery(
      'SELECT COUNT(*) AS edge_count FROM chat_to_handle',
    );
    final graphChatToHandleRows = await graphDatabase.selectRows(
      'SELECT COUNT(*) AS edge_count FROM chat_to_handle',
    );
    final duplicateChatToHandleRows = await graphDatabase.selectRows('''
      SELECT COUNT(*) AS duplicate_edge_count
      FROM (
        SELECT chat_ss_id, handle_ss_id
        FROM chat_to_handle
        GROUP BY chat_ss_id, handle_ss_id
        HAVING COUNT(*) > 1
      )
    ''');
    final importAttachmentRows = await importDatabase.database.rawQuery(
      'SELECT COUNT(*) AS attachment_count FROM attachments',
    );
    final graphAttachmentRows = await graphDatabase.selectRows(
      'SELECT COUNT(*) AS attachment_count FROM attachments',
    );
    final importMessageToAttachmentRows = await importDatabase.database
        .rawQuery('SELECT COUNT(*) AS edge_count FROM message_to_attachment');
    final graphMessageToAttachmentRows = await graphDatabase.selectRows(
      'SELECT COUNT(*) AS edge_count FROM message_to_attachment',
    );
    final duplicateMessageToAttachmentRows = await graphDatabase.selectRows('''
      SELECT COUNT(*) AS duplicate_edge_count
      FROM (
        SELECT message_ss_id, attachment_ss_id
        FROM message_to_attachment
        GROUP BY message_ss_id, attachment_ss_id
        HAVING COUNT(*) > 1
      )
      ''');

    return _GraphSnapshot(
      importChatCount: _readInt(importChatRows.single['chat_count']),
      graphChatCount: _readInt(graphChatRows.single['chat_count']),
      importHandleCount: _readInt(importHandleRows.single['handle_count']),
      graphHandleCount: _readInt(graphHandleRows.single['handle_count']),
      importTopologyEdgeCount: _readInt(importEdgeRows.single['edge_count']),
      graphTopologyEdgeCount: _readInt(graphEdgeRows.single['edge_count']),
      duplicateGraphTopologyEdgeCount: _readInt(
        duplicateEdgeRows.single['duplicate_edge_count'],
      ),
      importChatToHandleEdgeCount: _readInt(
        importChatToHandleRows.single['edge_count'],
      ),
      graphChatToHandleEdgeCount: _readInt(
        graphChatToHandleRows.single['edge_count'],
      ),
      duplicateGraphChatToHandleEdgeCount: _readInt(
        duplicateChatToHandleRows.single['duplicate_edge_count'],
      ),
      importAttachmentCount: _readInt(
        importAttachmentRows.single['attachment_count'],
      ),
      graphAttachmentCount: _readInt(
        graphAttachmentRows.single['attachment_count'],
      ),
      importMessageToAttachmentEdgeCount: _readInt(
        importMessageToAttachmentRows.single['edge_count'],
      ),
      graphMessageToAttachmentEdgeCount: _readInt(
        graphMessageToAttachmentRows.single['edge_count'],
      ),
      duplicateGraphMessageToAttachmentEdgeCount: _readInt(
        duplicateMessageToAttachmentRows.single['duplicate_edge_count'],
      ),
    );
  }
}

int _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.round();
  }
  return 0;
}

class _MessageSnapshot {
  const _MessageSnapshot({
    required this.count,
    required this.maxRowId,
    required this.needingEnrichmentCount,
    required this.withoutTextCount,
  });

  final int count;
  final int maxRowId;
  final int needingEnrichmentCount;
  final int withoutTextCount;
}

class _GraphMessageSnapshot {
  const _GraphMessageSnapshot({
    required this.count,
    required this.associatedMessageEdgeCount,
  });

  final int count;
  final int associatedMessageEdgeCount;
}

class _GraphSnapshot {
  const _GraphSnapshot({
    required this.importChatCount,
    required this.graphChatCount,
    required this.importHandleCount,
    required this.graphHandleCount,
    required this.importTopologyEdgeCount,
    required this.graphTopologyEdgeCount,
    required this.duplicateGraphTopologyEdgeCount,
    required this.importChatToHandleEdgeCount,
    required this.graphChatToHandleEdgeCount,
    required this.duplicateGraphChatToHandleEdgeCount,
    required this.importAttachmentCount,
    required this.graphAttachmentCount,
    required this.importMessageToAttachmentEdgeCount,
    required this.graphMessageToAttachmentEdgeCount,
    required this.duplicateGraphMessageToAttachmentEdgeCount,
  });

  final int importChatCount;
  final int graphChatCount;
  final int importHandleCount;
  final int graphHandleCount;
  final int importTopologyEdgeCount;
  final int graphTopologyEdgeCount;
  final int duplicateGraphTopologyEdgeCount;
  final int importChatToHandleEdgeCount;
  final int graphChatToHandleEdgeCount;
  final int duplicateGraphChatToHandleEdgeCount;
  final int importAttachmentCount;
  final int graphAttachmentCount;
  final int importMessageToAttachmentEdgeCount;
  final int graphMessageToAttachmentEdgeCount;
  final int duplicateGraphMessageToAttachmentEdgeCount;
}
