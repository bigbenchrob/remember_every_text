import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/monitor/chat_db_source_probe_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/sqlite_chat_db_source_probe_reader.dart';
import 'package:remember_this_text/essentials/onboarding/infrastructure/system/macos_full_disk_access.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('MacosFullDiskAccess', () {
    test(
      'plain file readability is insufficient without a SQLite source query',
      () {
        final tempDirectory = Directory.systemTemp.createTempSync(
          'full-disk-access-plain-file-',
        );
        addTearDown(() {
          if (tempDirectory.existsSync()) {
            tempDirectory.deleteSync(recursive: true);
          }
        });
        final plainFile = File('${tempDirectory.path}/chat.db')
          ..writeAsStringSync('readable but not SQLite');
        Object? reportedError;
        final access = MacosFullDiskAccess(
          messagesDatabaseReadProbe:
              const SqliteChatDbSourceProbeReader().readMaxRowId,
          messagesDatabasePath: plainFile.path,
          onReadFailure: (error, stackTrace) {
            reportedError = error;
          },
        );

        expect(access.canReadMessagesDatabase(), isFalse);
        expect(
          reportedError,
          isA<ChatDbSourceProbeException>().having(
            (error) => error.kind,
            'kind',
            ChatDbSourceProbeFailureKind.queryFailed,
          ),
        );
      },
    );

    test(
      'returns true only after reading the expected SQLite source table',
      () {
        final tempDirectory = Directory.systemTemp.createTempSync(
          'full-disk-access-sqlite-source-',
        );
        addTearDown(() {
          if (tempDirectory.existsSync()) {
            tempDirectory.deleteSync(recursive: true);
          }
        });
        final databasePath = '${tempDirectory.path}/chat.db';
        final database = sqlite3.open(databasePath);
        try {
          database.execute('CREATE TABLE message (guid TEXT);');
        } finally {
          database.dispose();
        }

        Object? reportedError;
        final access = MacosFullDiskAccess(
          messagesDatabaseReadProbe:
              const SqliteChatDbSourceProbeReader().readMaxRowId,
          messagesDatabasePath: databasePath,
          onReadFailure: (error, stackTrace) {
            reportedError = error;
          },
        );

        expect(access.canReadMessagesDatabase(), isTrue);
        expect(reportedError, isNull);
      },
    );

    test('preserves specialist failure information while exposing false', () {
      Object? reportedError;
      final access = MacosFullDiskAccess(
        messagesDatabaseReadProbe: (databasePath) {
          throw ChatDbSourceProbeException(
            kind: ChatDbSourceProbeFailureKind.sqliteOpenFailed,
            databasePath: databasePath,
            operation: 'read-only SQLite open',
          );
        },
        messagesDatabasePath: '/protected/Library/Messages/chat.db',
        onReadFailure: (error, stackTrace) {
          reportedError = error;
        },
      );

      expect(access.canReadMessagesDatabase(), isFalse);
      expect(
        reportedError,
        isA<ChatDbSourceProbeException>().having(
          (error) => error.kind,
          'kind',
          ChatDbSourceProbeFailureKind.sqliteOpenFailed,
        ),
      );
    });
  });
}
