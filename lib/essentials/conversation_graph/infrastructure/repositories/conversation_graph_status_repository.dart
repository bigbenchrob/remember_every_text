import 'package:sqflite/sqflite.dart';

import '../../../db/application/read_only_sql_guard.dart';
import '../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../source_scoped_import/domain/ports/import_ledger_port.dart';
import '../../domain/status/conversation_graph_status.dart';

final class ConversationGraphStatusRepository {
  const ConversationGraphStatusRepository();

  Future<ConversationGraphStatus> readStatus({
    required String chatDbPath,
    required ImportLedger importLedger,
    required ConversationGraphDatabase graphDatabase,
    required String importLedgerDatabaseLabel,
    required String graphDatabaseLabel,
    required int sourceId,
  }) async {
    final sourceSnapshot = await _readSourceSnapshot(chatDbPath);
    final ledgerSnapshot = await importLedger.messageStatusForSource(sourceId);
    final graphMessageSnapshot = await _readGraphMessageSnapshot(graphDatabase);
    final graphSnapshot = await _readGraphSnapshot(importLedger, graphDatabase);

    return ConversationGraphStatus(
      chatDbPath: chatDbPath,
      importLedgerDatabaseLabel: importLedgerDatabaseLabel,
      graphDatabaseLabel: graphDatabaseLabel,
      sourceId: sourceId,
      sourceMessageCount: sourceSnapshot.message.count,
      sourceMaxRowId: sourceSnapshot.message.maxRowId,
      ledgerMessageCount: ledgerSnapshot.count,
      ledgerMaxSourceRowId: ledgerSnapshot.maxSourceRowId,
      ledgerMessagesNeedingEnrichment: ledgerSnapshot.needingEnrichmentCount,
      ledgerMessagesStillWithoutText: ledgerSnapshot.withoutTextCount,
      graphMessageCount: graphMessageSnapshot.count,
      associatedMessageEdgeCount:
          graphMessageSnapshot.associatedMessageEdgeCount,
      sourceChatCount: sourceSnapshot.chatCount,
      importChatCount: graphSnapshot.importChatCount,
      graphChatCount: graphSnapshot.graphChatCount,
      sourceHandleCount: sourceSnapshot.handleCount,
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
      sourceAttachmentCount: sourceSnapshot.attachmentCount,
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

  Future<_SourceSnapshot> _readSourceSnapshot(String chatDbPath) async {
    final db = await openDatabase(
      chatDbPath,
      readOnly: true,
      singleInstance: false,
    );

    try {
      await db.execute('PRAGMA query_only = ON');
      await db.execute('PRAGMA busy_timeout = 3000');
      final messageRows = await _readSourceRows(
        db,
        'SELECT COUNT(*) AS message_count, '
        'COALESCE(MAX(ROWID), 0) AS max_rowid FROM message',
      );
      final chatRows = await _readSourceRows(
        db,
        'SELECT COUNT(*) AS chat_count FROM chat',
      );
      final handleRows = await _readSourceRows(
        db,
        'SELECT COUNT(*) AS handle_count FROM handle',
      );
      final attachmentRows = await _readSourceRows(
        db,
        'SELECT COUNT(*) AS attachment_count FROM attachment',
      );
      final messageRow = messageRows.single;

      return _SourceSnapshot(
        message: _MessageSnapshot(
          count: _readInt(messageRow['message_count']),
          maxRowId: _readInt(messageRow['max_rowid']),
          needingEnrichmentCount: 0,
          withoutTextCount: 0,
        ),
        chatCount: _readInt(chatRows.single['chat_count']),
        handleCount: _readInt(handleRows.single['handle_count']),
        attachmentCount: _readInt(attachmentRows.single['attachment_count']),
      );
    } finally {
      await db.close();
    }
  }

  Future<List<Map<String, Object?>>> _readSourceRows(
    Database database,
    String sql,
  ) {
    assertReadOnlySql(sql, boundary: 'Conversation graph source status query');
    return database.rawQuery(sql);
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
    ImportLedger importLedger,
    ConversationGraphDatabase graphDatabase,
  ) async {
    final importSnapshot = await importLedger.projectionStatusSnapshot();
    final graphChatRows = await graphDatabase.selectRows(
      'SELECT COUNT(*) AS chat_count FROM chats',
    );
    final graphHandleRows = await graphDatabase.selectRows(
      'SELECT COUNT(*) AS handle_count FROM handles',
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
    final graphAttachmentRows = await graphDatabase.selectRows(
      'SELECT COUNT(*) AS attachment_count FROM attachments',
    );
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
      importChatCount: importSnapshot.chatCount,
      graphChatCount: _readInt(graphChatRows.single['chat_count']),
      importHandleCount: importSnapshot.handleCount,
      graphHandleCount: _readInt(graphHandleRows.single['handle_count']),
      importTopologyEdgeCount: importSnapshot.chatToMessageEdgeCount,
      graphTopologyEdgeCount: _readInt(graphEdgeRows.single['edge_count']),
      duplicateGraphTopologyEdgeCount: _readInt(
        duplicateEdgeRows.single['duplicate_edge_count'],
      ),
      importChatToHandleEdgeCount: importSnapshot.chatToHandleEdgeCount,
      graphChatToHandleEdgeCount: _readInt(
        graphChatToHandleRows.single['edge_count'],
      ),
      duplicateGraphChatToHandleEdgeCount: _readInt(
        duplicateChatToHandleRows.single['duplicate_edge_count'],
      ),
      importAttachmentCount: importSnapshot.attachmentCount,
      graphAttachmentCount: _readInt(
        graphAttachmentRows.single['attachment_count'],
      ),
      importMessageToAttachmentEdgeCount:
          importSnapshot.messageToAttachmentEdgeCount,
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

class _SourceSnapshot {
  const _SourceSnapshot({
    required this.message,
    required this.chatCount,
    required this.handleCount,
    required this.attachmentCount,
  });

  final _MessageSnapshot message;
  final int chatCount;
  final int handleCount;
  final int attachmentCount;
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
