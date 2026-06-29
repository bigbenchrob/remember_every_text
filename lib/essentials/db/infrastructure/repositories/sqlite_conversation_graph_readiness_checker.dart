import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import '../../app_database_files.dart';
import '../../application/conversation_graph_readiness.dart';
import '../../application/read_only_sql_guard.dart';

final class SqliteConversationGraphReadinessChecker
    implements ConversationGraphReadinessChecker {
  const SqliteConversationGraphReadinessChecker();

  @override
  ConversationGraphReadiness checkPath(String dbPath) {
    final databaseName = appDatabaseFileName(AppDatabaseFile.conversationGraph);
    final file = File(dbPath);
    if (!file.existsSync()) {
      return ConversationGraphReadiness(
        isReady: false,
        reason: '$databaseName is missing',
        messageCount: 0,
        chatCount: 0,
        chatToMessageEdgeCount: 0,
      );
    }

    if (file.lengthSync() == 0) {
      return ConversationGraphReadiness(
        isReady: false,
        reason: '$databaseName is empty',
        messageCount: 0,
        chatCount: 0,
        chatToMessageEdgeCount: 0,
      );
    }

    try {
      final db = sqlite3.open(dbPath, mode: OpenMode.readOnly);
      try {
        db.execute('PRAGMA query_only = ON;');
        db.execute('PRAGMA busy_timeout = 3000;');

        final missingTables = _missingRequiredTables(db);
        if (missingTables.isNotEmpty) {
          return ConversationGraphReadiness(
            isReady: false,
            reason:
                '$databaseName is missing graph tables: '
                '${missingTables.join(', ')}',
            messageCount: 0,
            chatCount: 0,
            chatToMessageEdgeCount: 0,
          );
        }

        final messageCount = _count(db, 'messages');
        final chatCount = _count(db, 'chats');
        final chatToMessageEdgeCount = _count(db, 'chat_to_message');

        if (messageCount == 0) {
          return ConversationGraphReadiness(
            isReady: false,
            reason: '$databaseName has no messages',
            messageCount: messageCount,
            chatCount: chatCount,
            chatToMessageEdgeCount: chatToMessageEdgeCount,
          );
        }
        if (chatCount == 0) {
          return ConversationGraphReadiness(
            isReady: false,
            reason: '$databaseName has no chats',
            messageCount: messageCount,
            chatCount: chatCount,
            chatToMessageEdgeCount: chatToMessageEdgeCount,
          );
        }
        if (chatToMessageEdgeCount == 0) {
          return ConversationGraphReadiness(
            isReady: false,
            reason: '$databaseName has no chat/message topology',
            messageCount: messageCount,
            chatCount: chatCount,
            chatToMessageEdgeCount: chatToMessageEdgeCount,
          );
        }

        return ConversationGraphReadiness(
          isReady: true,
          reason: 'conversation graph has messages, chats, and topology',
          messageCount: messageCount,
          chatCount: chatCount,
          chatToMessageEdgeCount: chatToMessageEdgeCount,
        );
      } finally {
        db.dispose();
      }
    } catch (error) {
      return ConversationGraphReadiness(
        isReady: false,
        reason: 'conversation graph readiness check failed: $error',
        messageCount: 0,
        chatCount: 0,
        chatToMessageEdgeCount: 0,
      );
    }
  }

  static List<String> _missingRequiredTables(Database db) {
    const requiredTables = <String>[
      'messages',
      'chats',
      'handles',
      'chat_to_message',
      'chat_to_handle',
      'attachments',
      'message_to_attachment',
    ];
    final sql =
        '''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
        AND name IN (${List.filled(requiredTables.length, '?').join(', ')})
      ''';
    assertReadOnlySql(
      sql,
      boundary: 'Conversation graph readiness tables query',
    );
    final rows = db.select(sql, requiredTables);
    final existing = {
      for (final row in rows)
        if (row['name'] is String) row['name'] as String,
    };
    return [
      for (final tableName in requiredTables)
        if (!existing.contains(tableName)) tableName,
    ];
  }

  static int _count(Database db, String tableName) {
    final sql = 'SELECT COUNT(*) AS count FROM $tableName';
    assertReadOnlySql(
      sql,
      boundary: 'Conversation graph readiness count query',
    );
    final rows = db.select(sql);
    final value = rows.single['count'];
    if (value is int) {
      return value;
    }
    return 0;
  }
}
