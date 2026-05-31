import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqlite3/sqlite3.dart';

import '../feature_level_providers.dart' show databaseDirectoryPath;
import '../infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'message_data_version_provider.dart';

part 'conversation_graph_readiness_provider.g.dart';

class ConversationGraphReadiness {
  const ConversationGraphReadiness({
    required this.isReady,
    required this.reason,
    required this.messageCount,
    required this.chatCount,
    required this.chatToMessageEdgeCount,
  });

  final bool isReady;
  final String reason;
  final int messageCount;
  final int chatCount;
  final int chatToMessageEdgeCount;
}

class ConversationGraphReadinessChecker {
  const ConversationGraphReadinessChecker();

  ConversationGraphReadiness checkPath(String dbPath) {
    final file = File(dbPath);
    if (!file.existsSync()) {
      return const ConversationGraphReadiness(
        isReady: false,
        reason: 'working_ss.db is missing',
        messageCount: 0,
        chatCount: 0,
        chatToMessageEdgeCount: 0,
      );
    }

    if (file.lengthSync() == 0) {
      return const ConversationGraphReadiness(
        isReady: false,
        reason: 'working_ss.db is empty',
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
                'working_ss.db is missing graph tables: '
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
            reason: 'working_ss.db has no messages',
            messageCount: messageCount,
            chatCount: chatCount,
            chatToMessageEdgeCount: chatToMessageEdgeCount,
          );
        }
        if (chatCount == 0) {
          return ConversationGraphReadiness(
            isReady: false,
            reason: 'working_ss.db has no chats',
            messageCount: messageCount,
            chatCount: chatCount,
            chatToMessageEdgeCount: chatToMessageEdgeCount,
          );
        }
        if (chatToMessageEdgeCount == 0) {
          return ConversationGraphReadiness(
            isReady: false,
            reason: 'working_ss.db has no chat/message topology',
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
    final rows = db.select('''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
        AND name IN (${List.filled(requiredTables.length, '?').join(', ')})
      ''', requiredTables);
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
    final rows = db.select('SELECT COUNT(*) AS count FROM $tableName');
    final value = rows.single['count'];
    if (value is int) {
      return value;
    }
    return 0;
  }
}

@Riverpod(keepAlive: true)
Future<ConversationGraphReadiness> conversationGraphReadiness(
  ConversationGraphReadinessRef ref,
) async {
  ref.watch(messageDataVersionProvider);
  final dbPath = path.join(
    databaseDirectoryPath,
    conversationGraphDatabaseFileName,
  );
  return const ConversationGraphReadinessChecker().checkPath(dbPath);
}

@Riverpod(keepAlive: true)
class ConversationGraphPopulated extends _$ConversationGraphPopulated {
  @override
  bool build() {
    ref.watch(messageDataVersionProvider);
    final readiness = ref.watch(conversationGraphReadinessProvider);

    return readiness.valueOrNull?.isReady ?? false;
  }
}
