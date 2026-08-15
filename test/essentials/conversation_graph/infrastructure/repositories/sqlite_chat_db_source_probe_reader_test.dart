import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/monitor/chat_db_source_probe_reader.dart';
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

    test('does not modify the source while proving readability', () {
      final tempDirectory = Directory.systemTemp.createTempSync(
        'sqlite-chat-db-source-probe-read-only-',
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
        db.execute("INSERT INTO message (ROWID, guid) VALUES (7, 'm1');");
      } finally {
        db.dispose();
      }
      final before = File(chatDbPath).readAsBytesSync();

      expect(const SqliteChatDbSourceProbeReader().readMaxRowId(chatDbPath), 7);

      expect(File(chatDbPath).readAsBytesSync(), before);
    });

    test('classifies a missing database before SQLite open', () {
      final tempDirectory = Directory.systemTemp.createTempSync(
        'sqlite-chat-db-source-probe-missing-',
      );
      addTearDown(() {
        if (tempDirectory.existsSync()) {
          tempDirectory.deleteSync(recursive: true);
        }
      });
      final missingPath = '${tempDirectory.path}/chat.db';

      expect(
        () => const SqliteChatDbSourceProbeReader().readMaxRowId(missingPath),
        throwsA(
          isA<ChatDbSourceProbeException>().having(
            (error) => error.kind,
            'kind',
            ChatDbSourceProbeFailureKind.databaseMissing,
          ),
        ),
      );
    });

    test(
      'classifies explicit filesystem permission denial as access denied',
      () {
        const chatDbPath = '/test/Library/Messages/chat.db';
        final reader = SqliteChatDbSourceProbeReader(
          sourceFileReadVerifier: (_) {
            throw const FileSystemException(
              'Operation not permitted',
              chatDbPath,
              OSError('Operation not permitted', 1),
            );
          },
        );

        expect(
          () => reader.readMaxRowId(chatDbPath),
          throwsA(
            isA<ChatDbSourceProbeException>().having(
              (error) => error.kind,
              'kind',
              ChatDbSourceProbeFailureKind.accessDenied,
            ),
          ),
        );
      },
    );

    test(
      'does not classify an ambiguous filesystem error as access denied',
      () {
        const chatDbPath = '/test/Library/Messages/chat.db';
        final reader = SqliteChatDbSourceProbeReader(
          sourceFileReadVerifier: (_) {
            throw const FileSystemException(
              'Input/output error',
              chatDbPath,
              OSError('Input/output error', 5),
            );
          },
        );

        expect(
          () => reader.readMaxRowId(chatDbPath),
          throwsA(
            isA<ChatDbSourceProbeException>().having(
              (error) => error.kind,
              'kind',
              ChatDbSourceProbeFailureKind.filesystemReadFailed,
            ),
          ),
        );
      },
    );

    test('classifies a plain readable file as a failed SQLite query', () {
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
        throwsA(
          isA<ChatDbSourceProbeException>().having(
            (error) => error.kind,
            'kind',
            ChatDbSourceProbeFailureKind.queryFailed,
          ),
        ),
      );
      expect(
        () => const SqliteChatDbSourceProbeReader().readImportableMessageCount(
          invalidChatDb.path,
        ),
        throwsA(
          isA<ChatDbSourceProbeException>().having(
            (error) => error.kind,
            'kind',
            ChatDbSourceProbeFailureKind.queryFailed,
          ),
        ),
      );
    });

    test('classifies a database without message as unavailable schema', () {
      final tempDirectory = Directory.systemTemp.createTempSync(
        'sqlite-chat-db-source-probe-schema-',
      );
      addTearDown(() {
        if (tempDirectory.existsSync()) {
          tempDirectory.deleteSync(recursive: true);
        }
      });

      final chatDbPath = '${tempDirectory.path}/chat.db';
      final db = sqlite3.open(chatDbPath);
      try {
        db.execute('CREATE TABLE other_source (id INTEGER);');
      } finally {
        db.dispose();
      }

      expect(
        () => const SqliteChatDbSourceProbeReader().readMaxRowId(chatDbPath),
        throwsA(
          isA<ChatDbSourceProbeException>().having(
            (error) => error.kind,
            'kind',
            ChatDbSourceProbeFailureKind.expectedSchemaUnavailable,
          ),
        ),
      );
    });
  });
}
