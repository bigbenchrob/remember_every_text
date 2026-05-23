import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../../providers.dart';
import '../../../../db/feature_level_providers.dart';
import '../../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../../source_scoped_import/domain/known_sources.dart';
import '../../../../source_scoped_import/infrastructure/import_database_provider.dart';

part 'incremental_update_status_provider.g.dart';

class IncrementalUpdateStatus {
  const IncrementalUpdateStatus({
    required this.chatDbPath,
    required this.importDatabaseName,
    required this.workingDatabaseName,
    required this.sourceId,
    required this.sourceMessageCount,
    required this.sourceMaxRowId,
    required this.ledgerMessageCount,
    required this.ledgerMaxSourceRowId,
    required this.ledgerMessagesNeedingEnrichment,
    required this.ledgerMessagesStillWithoutText,
    required this.workingMessageCount,
    required this.associatedMessageEdgeCount,
    required this.sourceChatCount,
    required this.importChatCount,
    required this.workingChatCount,
    required this.sourceHandleCount,
    required this.importHandleCount,
    required this.workingHandleCount,
    required this.importTopologyEdgeCount,
    required this.workingTopologyEdgeCount,
    required this.duplicateWorkingTopologyEdgeCount,
    required this.importChatToHandleEdgeCount,
    required this.workingChatToHandleEdgeCount,
    required this.duplicateWorkingChatToHandleEdgeCount,
    required this.sourceAttachmentCount,
    required this.importAttachmentCount,
    required this.workingAttachmentCount,
    required this.importMessageToAttachmentEdgeCount,
    required this.workingMessageToAttachmentEdgeCount,
    required this.duplicateWorkingMessageToAttachmentEdgeCount,
  });

  final String chatDbPath;
  final String importDatabaseName;
  final String workingDatabaseName;
  final int sourceId;
  final int sourceMessageCount;
  final int sourceMaxRowId;
  final int ledgerMessageCount;
  final int ledgerMaxSourceRowId;
  final int ledgerMessagesNeedingEnrichment;
  final int ledgerMessagesStillWithoutText;
  final int workingMessageCount;
  final int associatedMessageEdgeCount;
  final int sourceChatCount;
  final int importChatCount;
  final int workingChatCount;
  final int sourceHandleCount;
  final int importHandleCount;
  final int workingHandleCount;
  final int importTopologyEdgeCount;
  final int workingTopologyEdgeCount;
  final int duplicateWorkingTopologyEdgeCount;
  final int importChatToHandleEdgeCount;
  final int workingChatToHandleEdgeCount;
  final int duplicateWorkingChatToHandleEdgeCount;
  final int sourceAttachmentCount;
  final int importAttachmentCount;
  final int workingAttachmentCount;
  final int importMessageToAttachmentEdgeCount;
  final int workingMessageToAttachmentEdgeCount;
  final int duplicateWorkingMessageToAttachmentEdgeCount;

  int get rowIdDelta => sourceMaxRowId - ledgerMaxSourceRowId;
  int get messageCountDelta => sourceMessageCount - ledgerMessageCount;

  String get cursorState {
    if (rowIdDelta == 0) {
      return 'current';
    }
    if (rowIdDelta > 0) {
      return 'source ahead';
    }
    return 'ledger ahead';
  }
}

@riverpod
Future<IncrementalUpdateStatus> incrementalUpdateStatus(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final importDatabase = await ref.watch(importDatabaseProvider.future);
  final workingDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  final sourceSnapshot = await _readSourceMessageSnapshot(
    pathsHelper.chatDBPath,
  );
  final sourceChatCount = await _readSourceChatCount(pathsHelper.chatDBPath);
  final sourceHandleCount = await _readSourceHandleCount(
    pathsHelper.chatDBPath,
  );
  final sourceAttachmentCount = await _readSourceAttachmentCount(
    pathsHelper.chatDBPath,
  );
  final ledgerSnapshot = await _readLedgerMessageSnapshot(
    importDatabase,
    liveChatDbSourceId,
  );
  final workingSnapshot = await _readWorkingMessageSnapshot(workingDatabase);
  final graphSnapshot = await _readGraphSnapshot(
    importDatabase,
    workingDatabase,
  );

  return IncrementalUpdateStatus(
    chatDbPath: pathsHelper.chatDBPath,
    importDatabaseName: importDatabaseFileName,
    workingDatabaseName: conversationGraphDatabaseFileName,
    sourceId: liveChatDbSourceId,
    sourceMessageCount: sourceSnapshot.count,
    sourceMaxRowId: sourceSnapshot.maxRowId,
    ledgerMessageCount: ledgerSnapshot.count,
    ledgerMaxSourceRowId: ledgerSnapshot.maxRowId,
    ledgerMessagesNeedingEnrichment: ledgerSnapshot.needingEnrichmentCount,
    ledgerMessagesStillWithoutText: ledgerSnapshot.withoutTextCount,
    workingMessageCount: workingSnapshot.count,
    associatedMessageEdgeCount: workingSnapshot.associatedMessageEdgeCount,
    sourceChatCount: sourceChatCount,
    importChatCount: graphSnapshot.importChatCount,
    workingChatCount: graphSnapshot.workingChatCount,
    sourceHandleCount: sourceHandleCount,
    importHandleCount: graphSnapshot.importHandleCount,
    workingHandleCount: graphSnapshot.workingHandleCount,
    importTopologyEdgeCount: graphSnapshot.importTopologyEdgeCount,
    workingTopologyEdgeCount: graphSnapshot.workingTopologyEdgeCount,
    duplicateWorkingTopologyEdgeCount:
        graphSnapshot.duplicateWorkingTopologyEdgeCount,
    importChatToHandleEdgeCount: graphSnapshot.importChatToHandleEdgeCount,
    workingChatToHandleEdgeCount: graphSnapshot.workingChatToHandleEdgeCount,
    duplicateWorkingChatToHandleEdgeCount:
        graphSnapshot.duplicateWorkingChatToHandleEdgeCount,
    sourceAttachmentCount: sourceAttachmentCount,
    importAttachmentCount: graphSnapshot.importAttachmentCount,
    workingAttachmentCount: graphSnapshot.workingAttachmentCount,
    importMessageToAttachmentEdgeCount:
        graphSnapshot.importMessageToAttachmentEdgeCount,
    workingMessageToAttachmentEdgeCount:
        graphSnapshot.workingMessageToAttachmentEdgeCount,
    duplicateWorkingMessageToAttachmentEdgeCount:
        graphSnapshot.duplicateWorkingMessageToAttachmentEdgeCount,
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

Future<int> _readSourceChatCount(String chatDbPath) async {
  final db = await openDatabase(
    chatDbPath,
    readOnly: true,
    singleInstance: false,
  );

  try {
    final rows = await db.rawQuery('SELECT COUNT(*) AS chat_count FROM chat');
    return _readInt(rows.single['chat_count']);
  } finally {
    await db.close();
  }
}

Future<int> _readSourceHandleCount(String chatDbPath) async {
  final db = await openDatabase(
    chatDbPath,
    readOnly: true,
    singleInstance: false,
  );

  try {
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS handle_count FROM handle',
    );
    return _readInt(rows.single['handle_count']);
  } finally {
    await db.close();
  }
}

Future<int> _readSourceAttachmentCount(String chatDbPath) async {
  final db = await openDatabase(
    chatDbPath,
    readOnly: true,
    singleInstance: false,
  );

  try {
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS attachment_count FROM attachment',
    );
    return _readInt(rows.single['attachment_count']);
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

Future<_WorkingMessageSnapshot> _readWorkingMessageSnapshot(
  ConversationGraphDatabase workingDatabase,
) async {
  final rows = await workingDatabase.selectRows(
    'SELECT COUNT(*) AS message_count, '
    'COUNT(associated_message_ss_id) AS associated_message_edge_count '
    'FROM messages',
  );
  final row = rows.single;

  return _WorkingMessageSnapshot(
    count: _readInt(row['message_count']),
    associatedMessageEdgeCount: _readInt(row['associated_message_edge_count']),
  );
}

Future<_GraphSnapshot> _readGraphSnapshot(
  ImportDatabase importDatabase,
  ConversationGraphDatabase workingDatabase,
) async {
  final importChatRows = await importDatabase.database.rawQuery(
    'SELECT COUNT(*) AS chat_count FROM chats',
  );
  final workingChatRows = await workingDatabase.selectRows(
    'SELECT COUNT(*) AS chat_count FROM chats',
  );
  final importHandleRows = await importDatabase.database.rawQuery(
    'SELECT COUNT(*) AS handle_count FROM handles',
  );
  final workingHandleRows = await workingDatabase.selectRows(
    'SELECT COUNT(*) AS handle_count FROM handles',
  );
  final importEdgeRows = await importDatabase.database.rawQuery(
    'SELECT COUNT(*) AS edge_count FROM chat_to_message',
  );
  final workingEdgeRows = await workingDatabase.selectRows(
    'SELECT COUNT(*) AS edge_count FROM chat_to_message',
  );
  final duplicateEdgeRows = await workingDatabase.selectRows('''
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
  final workingChatToHandleRows = await workingDatabase.selectRows(
    'SELECT COUNT(*) AS edge_count FROM chat_to_handle',
  );
  final duplicateChatToHandleRows = await workingDatabase.selectRows('''
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
  final workingAttachmentRows = await workingDatabase.selectRows(
    'SELECT COUNT(*) AS attachment_count FROM attachments',
  );
  final importMessageToAttachmentRows = await importDatabase.database.rawQuery(
    'SELECT COUNT(*) AS edge_count FROM message_to_attachment',
  );
  final workingMessageToAttachmentRows = await workingDatabase.selectRows(
    'SELECT COUNT(*) AS edge_count FROM message_to_attachment',
  );
  final duplicateMessageToAttachmentRows = await workingDatabase.selectRows('''
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
    workingChatCount: _readInt(workingChatRows.single['chat_count']),
    importHandleCount: _readInt(importHandleRows.single['handle_count']),
    workingHandleCount: _readInt(workingHandleRows.single['handle_count']),
    importTopologyEdgeCount: _readInt(importEdgeRows.single['edge_count']),
    workingTopologyEdgeCount: _readInt(workingEdgeRows.single['edge_count']),
    duplicateWorkingTopologyEdgeCount: _readInt(
      duplicateEdgeRows.single['duplicate_edge_count'],
    ),
    importChatToHandleEdgeCount: _readInt(
      importChatToHandleRows.single['edge_count'],
    ),
    workingChatToHandleEdgeCount: _readInt(
      workingChatToHandleRows.single['edge_count'],
    ),
    duplicateWorkingChatToHandleEdgeCount: _readInt(
      duplicateChatToHandleRows.single['duplicate_edge_count'],
    ),
    importAttachmentCount: _readInt(
      importAttachmentRows.single['attachment_count'],
    ),
    workingAttachmentCount: _readInt(
      workingAttachmentRows.single['attachment_count'],
    ),
    importMessageToAttachmentEdgeCount: _readInt(
      importMessageToAttachmentRows.single['edge_count'],
    ),
    workingMessageToAttachmentEdgeCount: _readInt(
      workingMessageToAttachmentRows.single['edge_count'],
    ),
    duplicateWorkingMessageToAttachmentEdgeCount: _readInt(
      duplicateMessageToAttachmentRows.single['duplicate_edge_count'],
    ),
  );
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

class _WorkingMessageSnapshot {
  const _WorkingMessageSnapshot({
    required this.count,
    required this.associatedMessageEdgeCount,
  });

  final int count;
  final int associatedMessageEdgeCount;
}

class _GraphSnapshot {
  const _GraphSnapshot({
    required this.importChatCount,
    required this.workingChatCount,
    required this.importHandleCount,
    required this.workingHandleCount,
    required this.importTopologyEdgeCount,
    required this.workingTopologyEdgeCount,
    required this.duplicateWorkingTopologyEdgeCount,
    required this.importChatToHandleEdgeCount,
    required this.workingChatToHandleEdgeCount,
    required this.duplicateWorkingChatToHandleEdgeCount,
    required this.importAttachmentCount,
    required this.workingAttachmentCount,
    required this.importMessageToAttachmentEdgeCount,
    required this.workingMessageToAttachmentEdgeCount,
    required this.duplicateWorkingMessageToAttachmentEdgeCount,
  });

  final int importChatCount;
  final int workingChatCount;
  final int importHandleCount;
  final int workingHandleCount;
  final int importTopologyEdgeCount;
  final int workingTopologyEdgeCount;
  final int duplicateWorkingTopologyEdgeCount;
  final int importChatToHandleEdgeCount;
  final int workingChatToHandleEdgeCount;
  final int duplicateWorkingChatToHandleEdgeCount;
  final int importAttachmentCount;
  final int workingAttachmentCount;
  final int importMessageToAttachmentEdgeCount;
  final int workingMessageToAttachmentEdgeCount;
  final int duplicateWorkingMessageToAttachmentEdgeCount;
}
