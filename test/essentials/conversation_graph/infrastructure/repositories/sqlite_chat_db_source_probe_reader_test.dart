import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/sqlite_chat_db_source_probe_reader.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('SqliteChatDbSourceProbeReader', () {
    test('reads max row id and importable message count', () {
      final tempDirectory = Directory.systemTemp.createTempSync(
        'sqlite-chat-db-source-probe-',
      );
      addTearDown(() {
        if (tempDirectory.existsSync()) {
          tempDirectory.deleteSync(recursive: true);
        }
      });

      final chatDbPath = '${tempDirectory.path}/chat.db';
      final db = sqlite3.open(chatDbPath);
      try {
        db.execute('CREATE TABLE message (guid TEXT);');
        db.execute(
          "INSERT INTO message (ROWID, guid) VALUES (7, 'm1'), (8, NULL), (9, '  '), (10, 'm2');",
        );
      } finally {
        db.dispose();
      }

      const reader = SqliteChatDbSourceProbeReader();

      expect(reader.readMaxRowId(chatDbPath), 10);
      expect(reader.readImportableMessageCount(chatDbPath), 2);
    });

    test('throws typed state error when source database cannot be read', () {
      final tempDirectory = Directory.systemTemp.createTempSync(
        'sqlite-chat-db-source-probe-invalid-',
      );
      addTearDown(() {
        if (tempDirectory.existsSync()) {
          tempDirectory.deleteSync(recursive: true);
        }
      });

      final invalidChatDb = File('${tempDirectory.path}/chat.db')
        ..writeAsStringSync('not sqlite');

      expect(
        () => const SqliteChatDbSourceProbeReader().readMaxRowId(
          invalidChatDb.path,
        ),
        throwsA(isA<StateError>()),
      );
      expect(
        () => const SqliteChatDbSourceProbeReader().readImportableMessageCount(
          invalidChatDb.path,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
