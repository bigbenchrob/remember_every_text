import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/repositories/sqlite_conversation_graph_readiness_checker.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('SqliteConversationGraphReadinessChecker', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'conversation_graph_readiness_',
      );
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('reports missing graph database', () {
      final readiness = const SqliteConversationGraphReadinessChecker()
          .checkPath('${tempDir.path}/$conversationGraphDatabaseFileName');

      expect(readiness.isReady, isFalse);
      expect(readiness.reason, '$conversationGraphDatabaseFileName is missing');
    });

    test('reports missing required graph tables', () {
      final dbPath = '${tempDir.path}/$conversationGraphDatabaseFileName';
      final db = sqlite3.open(dbPath);
      db
        ..execute('CREATE TABLE messages (ss_id INTEGER PRIMARY KEY)')
        ..dispose();

      final readiness = const SqliteConversationGraphReadinessChecker()
          .checkPath(dbPath);

      expect(readiness.isReady, isFalse);
      expect(readiness.reason, contains('missing graph tables'));
      expect(readiness.reason, contains('chat_to_message'));
    });

    test('reports empty graph core as not ready', () {
      final dbPath = '${tempDir.path}/$conversationGraphDatabaseFileName';
      _createRequiredGraphTables(dbPath);

      final readiness = const SqliteConversationGraphReadinessChecker()
          .checkPath(dbPath);

      expect(readiness.isReady, isFalse);
      expect(
        readiness.reason,
        '$conversationGraphDatabaseFileName has no messages',
      );
      expect(readiness.messageCount, 0);
    });

    test('reports graph with messages chats and topology as ready', () {
      final dbPath = '${tempDir.path}/$conversationGraphDatabaseFileName';
      final db = _createRequiredGraphTables(dbPath);
      db
        ..execute('INSERT INTO messages (ss_id) VALUES (1)')
        ..execute('INSERT INTO chats (ss_id) VALUES (10)')
        ..execute(
          'INSERT INTO chat_to_message (chat_ss_id, message_ss_id) '
          'VALUES (10, 1)',
        )
        ..dispose();

      final readiness = const SqliteConversationGraphReadinessChecker()
          .checkPath(dbPath);

      expect(readiness.isReady, isTrue);
      expect(readiness.messageCount, 1);
      expect(readiness.chatCount, 1);
      expect(readiness.chatToMessageEdgeCount, 1);
    });
  });
}

Database _createRequiredGraphTables(String dbPath) {
  final db = sqlite3.open(dbPath);
  db
    ..execute('CREATE TABLE messages (ss_id INTEGER PRIMARY KEY)')
    ..execute('CREATE TABLE chats (ss_id INTEGER PRIMARY KEY)')
    ..execute('CREATE TABLE handles (ss_id INTEGER PRIMARY KEY)')
    ..execute('''
      CREATE TABLE chat_to_message (
        chat_ss_id INTEGER NOT NULL,
        message_ss_id INTEGER NOT NULL
      )
    ''')
    ..execute('''
      CREATE TABLE chat_to_handle (
        chat_ss_id INTEGER NOT NULL,
        handle_ss_id INTEGER NOT NULL
      )
    ''')
    ..execute('CREATE TABLE attachments (ss_id INTEGER PRIMARY KEY)')
    ..execute('''
      CREATE TABLE message_to_attachment (
        message_ss_id INTEGER NOT NULL,
        attachment_ss_id INTEGER NOT NULL
      )
    ''');
  return db;
}
