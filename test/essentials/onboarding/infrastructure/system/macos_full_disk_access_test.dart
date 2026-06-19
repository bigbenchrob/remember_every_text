import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/onboarding/infrastructure/system/macos_full_disk_access.dart';

void main() {
  group('MacosFullDiskAccess', () {
    test(
      'returns false without reporting when Messages database is missing',
      () {
        Object? reportedError;
        final access = MacosFullDiskAccess(
          messagesDatabasePath: '/tmp/message-lens-missing-chat-db-test',
          onReadFailure: (error, stackTrace) {
            reportedError = error;
          },
        );

        expect(access.canReadMessagesDatabase(), isFalse);
        expect(reportedError, isNull);
      },
    );

    test('reports read failures for an existing unreadable database path', () {
      final tempDirectory = Directory.systemTemp.createTempSync(
        'full-disk-access-unreadable-',
      );
      final unreadableFile = File('${tempDirectory.path}/chat.db')
        ..writeAsStringSync('not readable');
      Process.runSync('chmod', ['000', unreadableFile.path]);
      addTearDown(() {
        Process.runSync('chmod', ['600', unreadableFile.path]);
        if (tempDirectory.existsSync()) {
          tempDirectory.deleteSync(recursive: true);
        }
      });

      Object? reportedError;
      StackTrace? reportedStackTrace;
      final access = MacosFullDiskAccess(
        messagesDatabasePath: unreadableFile.path,
        onReadFailure: (error, stackTrace) {
          reportedError = error;
          reportedStackTrace = stackTrace;
        },
      );

      expect(access.canReadMessagesDatabase(), isFalse);
      expect(reportedError, isNotNull);
      expect(reportedStackTrace, isNotNull);
    });
  });
}
