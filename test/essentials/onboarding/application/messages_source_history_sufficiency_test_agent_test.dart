import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/onboarding/application/messages_source_history_count_reader.dart';
import 'package:remember_this_text/essentials/onboarding/application/messages_source_history_sufficiency_test_agent.dart';
import 'package:remember_this_text/essentials/onboarding/infrastructure/persistence/probe_messages_source_history_count_reader.dart';
import 'package:remember_this_text/essentials/onboarding/infrastructure/persistence/sqlite_onboarding_database_probe_reader.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('MessagesSourceHistorySufficiencyTestAgent', () {
    for (final testCase in <({int count, bool expected})>[
      (count: 0, expected: false),
      (count: 1, expected: false),
      (count: 10, expected: false),
      (count: 11, expected: true),
      (count: 1000, expected: true),
    ]) {
      test('${testCase.count} rows evaluates ${testCase.expected}', () async {
        final agent = MessagesSourceHistorySufficiencyTestAgent(
          countReader: _MutableCountReader(testCase.count),
        );

        expect(await agent.evaluate(), testCase.expected);
      });
    }

    test(
      'preserves count-read failure instead of fabricating a bool',
      () async {
        const agent = MessagesSourceHistorySufficiencyTestAgent(
          countReader: _UnavailableCountReader(),
        );

        await expectLater(
          agent.evaluate(),
          throwsA(isA<MessagesSourceHistoryCountUnavailableException>()),
        );
      },
    );

    test('performs a fresh factual read for every evaluation', () async {
      final reader = _MutableCountReader(10);
      final agent = MessagesSourceHistorySufficiencyTestAgent(
        countReader: reader,
      );

      expect(await agent.evaluate(), isFalse);
      reader.count = 11;
      expect(await agent.evaluate(), isTrue);
      expect(reader.invocationCount, 2);
    });
  });

  group('production count contract', () {
    late Directory tempDirectory;
    late String databasePath;

    setUp(() {
      tempDirectory = Directory.systemTemp.createTempSync(
        'messages-source-history-sufficiency-',
      );
      databasePath = '${tempDirectory.path}/chat.db';
      final database = sqlite3.open(databasePath);
      try {
        database.execute('CREATE TABLE message (guid TEXT);');
      } finally {
        database.dispose();
      }
    });

    tearDown(() {
      if (tempDirectory.existsSync()) {
        tempDirectory.deleteSync(recursive: true);
      }
    });

    test('counts every message row and preserves the 10/11 boundary', () async {
      _insertRows(databasePath, 10);
      final agent = _sqliteAgent(databasePath);

      expect(await agent.evaluate(), isFalse);

      _insertRows(databasePath, 1);
      expect(await agent.evaluate(), isTrue);
    });

    test('COUNT(*) includes rows without an importable guid', () async {
      _insertRows(databasePath, 11);

      expect(await _sqliteAgent(databasePath).evaluate(), isTrue);
    });

    test('unavailable SQLite count becomes evaluation failure', () async {
      File(databasePath).writeAsStringSync('not a SQLite database');

      await expectLater(
        _sqliteAgent(databasePath).evaluate(),
        throwsA(isA<MessagesSourceHistoryCountUnavailableException>()),
      );
    });
  });
}

MessagesSourceHistorySufficiencyTestAgent _sqliteAgent(String databasePath) {
  return MessagesSourceHistorySufficiencyTestAgent(
    countReader: ProbeMessagesSourceHistoryCountReader(
      databaseProbeReader: const SqliteOnboardingDatabaseProbeReader(),
      messagesDatabasePath: databasePath,
    ),
  );
}

void _insertRows(String databasePath, int count) {
  final database = sqlite3.open(databasePath);
  try {
    for (var index = 0; index < count; index += 1) {
      database.execute('INSERT INTO message (guid) VALUES (NULL);');
    }
  } finally {
    database.dispose();
  }
}

final class _MutableCountReader implements MessagesSourceHistoryCountReader {
  _MutableCountReader(this.count);

  int count;
  int invocationCount = 0;

  @override
  int readCount() {
    invocationCount += 1;
    return count;
  }
}

final class _UnavailableCountReader
    implements MessagesSourceHistoryCountReader {
  const _UnavailableCountReader();

  @override
  int readCount() {
    throw const MessagesSourceHistoryCountUnavailableException();
  }
}
