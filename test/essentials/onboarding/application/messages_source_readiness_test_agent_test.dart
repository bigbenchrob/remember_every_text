import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/sqlite_chat_db_source_probe_reader.dart';
import 'package:remember_this_text/essentials/onboarding/application/full_disk_access.dart';
import 'package:remember_this_text/essentials/onboarding/application/messages_source_readiness_test_agent.dart';
import 'package:remember_this_text/essentials/onboarding/infrastructure/system/macos_full_disk_access.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('delegates true and false to the truthful source capability', () async {
    final fullDiskAccess = _FakeFullDiskAccess(canRead: true);
    final agent = MessagesSourceReadinessTestAgent(
      fullDiskAccess: fullDiskAccess,
    );

    expect(await agent.evaluate(), isTrue);
    fullDiskAccess.canRead = false;
    expect(await agent.evaluate(), isFalse);
    expect(fullDiskAccess.readInvocationCount, 2);
  });

  test('preserves specialist failures', () async {
    final agent = MessagesSourceReadinessTestAgent(
      fullDiskAccess: _FakeFullDiskAccess(canRead: true, failRead: true),
    );

    await expectLater(agent.evaluate(), throwsA(isA<StateError>()));
  });

  test('truthful SQLite source success evaluates true', () async {
    final tempDirectory = Directory.systemTemp.createTempSync(
      'presence-readable-source-',
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
    final agent = MessagesSourceReadinessTestAgent(
      fullDiskAccess: MacosFullDiskAccess(
        messagesDatabaseReadProbe:
            const SqliteChatDbSourceProbeReader().readMaxRowId,
        messagesDatabasePath: databasePath,
      ),
    );

    expect(await agent.evaluate(), isTrue);
  });

  test('failed SQLite source query evaluates false', () async {
    final tempDirectory = Directory.systemTemp.createTempSync(
      'presence-unreadable-source-',
    );
    addTearDown(() {
      if (tempDirectory.existsSync()) {
        tempDirectory.deleteSync(recursive: true);
      }
    });
    final databasePath = '${tempDirectory.path}/chat.db';
    File(databasePath).writeAsStringSync('readable but not SQLite');
    final agent = MessagesSourceReadinessTestAgent(
      fullDiskAccess: MacosFullDiskAccess(
        messagesDatabaseReadProbe:
            const SqliteChatDbSourceProbeReader().readMaxRowId,
        messagesDatabasePath: databasePath,
      ),
    );

    expect(await agent.evaluate(), isFalse);
  });
}

final class _FakeFullDiskAccess implements FullDiskAccess {
  _FakeFullDiskAccess({required this.canRead, this.failRead = false});

  bool canRead;
  final bool failRead;
  int readInvocationCount = 0;

  @override
  String get messagesDatabasePath => '/test/Library/Messages/chat.db';

  @override
  bool canReadMessagesDatabase() {
    readInvocationCount += 1;
    if (failRead) {
      throw StateError('Messages source probe failed.');
    }
    return canRead;
  }

  @override
  Future<void> openSettings() async {}
}
