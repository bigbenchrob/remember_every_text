import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/app_database_files.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_operation_snapshot.dart';
import 'package:remember_this_text/essentials/onboarding/infrastructure/persistence/sqlite_message_lens_installation_evidence_reader.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('reads completion evidence without mutating canonical stores', () async {
    final root = Directory.systemTemp.createTempSync(
      'messagelens-installation-evidence-',
    );
    addTearDown(() {
      root.deleteSync(recursive: true);
    });

    _createImportDatabase(
      appDatabasePath(
        AppDatabaseFile.sourceScopedImport,
        databaseDirectory: root.path,
      ),
    );
    _createGraphDatabase(
      appDatabasePath(
        AppDatabaseFile.conversationGraph,
        databaseDirectory: root.path,
      ),
    );
    _createOverlayDatabase(
      appDatabasePath(AppDatabaseFile.overlay, databaseDirectory: root.path),
    );
    _createPresenceDatabase(
      appDatabasePath(AppDatabaseFile.presence, databaseDirectory: root.path),
    );

    const reader = SqliteMessageLensInstallationEvidenceReader();
    final evidence = await reader.read(
      archiveRootPath: root.path,
      operationSnapshot: const OnboardingOperationSnapshot.idle(),
    );

    expect(evidence.sourceScopedImport.isUsable, isTrue);
    expect(evidence.sourceScopedImport.messageCount, 2);
    expect(evidence.sourceScopedImport.nonLiveSourceCount, 0);
    expect(evidence.conversationGraph.isUsable, isTrue);
    expect(evidence.conversationGraph.messageCount, 2);
    expect(evidence.conversationGraph.chatCount, 1);
    expect(evidence.conversationGraph.chatMessageEdgeCount, 2);
    expect(evidence.overlay.isUsable, isTrue);
    expect(evidence.presence.isUsable, isTrue);
  });

  test(
    'reports unsupported or malformed preservation store as unusable',
    () async {
      final root = Directory.systemTemp.createTempSync(
        'messagelens-installation-evidence-bad-',
      );
      addTearDown(() {
        root.deleteSync(recursive: true);
      });
      File(
        appDatabasePath(AppDatabaseFile.overlay, databaseDirectory: root.path),
      ).writeAsStringSync('not sqlite');

      final evidence = await const SqliteMessageLensInstallationEvidenceReader()
          .read(
            archiveRootPath: root.path,
            operationSnapshot: const OnboardingOperationSnapshot.idle(),
          );

      expect(evidence.overlay.exists, isTrue);
      expect(evidence.overlay.isUsable, isFalse);
      expect(evidence.overlay.failure, isNotNull);
    },
  );

  test(
    'keeps the caller event loop responsive during SQLite contention',
    () async {
      final root = Directory.systemTemp.createTempSync(
        'messagelens-installation-evidence-contention-',
      );
      addTearDown(() {
        root.deleteSync(recursive: true);
      });

      _createImportDatabase(
        appDatabasePath(
          AppDatabaseFile.sourceScopedImport,
          databaseDirectory: root.path,
        ),
      );
      final graphPath = appDatabasePath(
        AppDatabaseFile.conversationGraph,
        databaseDirectory: root.path,
      );
      _createGraphDatabase(graphPath);
      _createOverlayDatabase(
        appDatabasePath(AppDatabaseFile.overlay, databaseDirectory: root.path),
      );
      _createPresenceDatabase(
        appDatabasePath(AppDatabaseFile.presence, databaseDirectory: root.path),
      );

      final blocker = sqlite3.open(graphPath);
      addTearDown(blocker.dispose);
      blocker.execute('BEGIN EXCLUSIVE;');

      final lockReleased = Completer<void>();
      Timer(const Duration(milliseconds: 100), () {
        blocker.execute('ROLLBACK;');
        lockReleased.complete();
      });

      final evidenceFuture = const SqliteMessageLensInstallationEvidenceReader()
          .read(
            archiveRootPath: root.path,
            operationSnapshot: const OnboardingOperationSnapshot.idle(),
          );

      await lockReleased.future.timeout(const Duration(seconds: 1));
      final evidence = await evidenceFuture;

      expect(evidence.conversationGraph.isUsable, isTrue);
    },
  );
}

void _createImportDatabase(String path) {
  final database = sqlite3.open(path);
  try {
    database.execute('PRAGMA user_version = 10;');
    database.execute('CREATE TABLE messages (id INTEGER PRIMARY KEY);');
    database.execute(
      'CREATE TABLE source_registry (source_id INTEGER PRIMARY KEY);',
    );
    database.execute('INSERT INTO messages (id) VALUES (1), (2);');
    database.execute('INSERT INTO source_registry (source_id) VALUES (1);');
  } finally {
    database.dispose();
  }
}

void _createGraphDatabase(String path) {
  final database = sqlite3.open(path);
  try {
    database.execute('PRAGMA user_version = 2;');
    database.execute('CREATE TABLE messages (id INTEGER PRIMARY KEY);');
    database.execute('CREATE TABLE chats (id INTEGER PRIMARY KEY);');
    database.execute(
      'CREATE TABLE chat_to_message '
      '(chat_id INTEGER NOT NULL, message_id INTEGER NOT NULL);',
    );
    database.execute('INSERT INTO messages (id) VALUES (1), (2);');
    database.execute('INSERT INTO chats (id) VALUES (1);');
    database.execute(
      'INSERT INTO chat_to_message (chat_id, message_id) VALUES (1, 1), (1, 2);',
    );
  } finally {
    database.dispose();
  }
}

void _createOverlayDatabase(String path) {
  final database = sqlite3.open(path);
  try {
    database.execute('PRAGMA user_version = 8;');
    database.execute(
      'CREATE TABLE overlay_settings (key TEXT PRIMARY KEY, value TEXT);',
    );
  } finally {
    database.dispose();
  }
}

void _createPresenceDatabase(String path) {
  final database = sqlite3.open(path);
  try {
    database.execute('PRAGMA user_version = 9;');
    database.execute(
      'CREATE TABLE schedule_definitions (id INTEGER PRIMARY KEY);',
    );
    database.execute('CREATE TABLE schedule_runs (id INTEGER PRIMARY KEY);');
  } finally {
    database.dispose();
  }
}
