import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/essentials/onboarding/application/database_existence_checker.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('DatabaseExistenceChecker', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'database_existence_checker_',
      );
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('requires import database and ready graph database', () {
      const checker = DatabaseExistenceChecker();
      File(
        path.join(tempDir.path, 'macos_import.db'),
      ).writeAsStringSync('not empty');
      _createReadyGraphDatabase(
        path.join(tempDir.path, conversationGraphDatabaseFileName),
      );

      expect(checker.hasPopulatedDatabases(tempDir.path), isTrue);
    });

    test('does not treat legacy working database as sufficient', () {
      const checker = DatabaseExistenceChecker();
      File(
        path.join(tempDir.path, 'macos_import.db'),
      ).writeAsStringSync('not empty');
      File(
        path.join(tempDir.path, 'working.db'),
      ).writeAsStringSync('legacy only');

      expect(checker.hasPopulatedDatabases(tempDir.path), isFalse);
    });
  });
}

void _createReadyGraphDatabase(String dbPath) {
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
    ''')
    ..execute('INSERT INTO messages (ss_id) VALUES (1)')
    ..execute('INSERT INTO chats (ss_id) VALUES (10)')
    ..execute(
      'INSERT INTO chat_to_message (chat_ss_id, message_ss_id) '
      'VALUES (10, 1)',
    )
    ..dispose();
}
