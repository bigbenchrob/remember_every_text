import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/core/util/paths_helper.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/db_importers/application/monitor/chat_db_change_monitor_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_gate_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_status.dart';
import 'package:remember_this_text/providers.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('chatDbChangeMonitorProvider', () {
    late Directory tempDir;
    late String chatDbPath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'chat_db_change_monitor_provider_test',
      );
      chatDbPath = '${tempDir.path}/chat.db';
      _createChatDb(chatDbPath);
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'does not read the import database provider while onboarding is blocking',
      () async {
        var importProviderReadCount = 0;
        final container = ProviderContainer(
          overrides: [
            onboardingGateProvider.overrideWith(_RecoveringGate.new),
            pathsHelperProvider.overrideWith(
              (ref) async => _FakePathsHelper(chatDbPath: chatDbPath),
            ),
            sqfliteImportDatabaseProvider.overrideWith((ref) async {
              importProviderReadCount += 1;
              throw StateError(
                'sqfliteImportDatabaseProvider should not be read while onboarding is blocking',
              );
            }),
          ],
        );
        addTearDown(container.dispose);

        container.read(chatDbChangeMonitorProvider);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(importProviderReadCount, 0);
      },
    );

    test(
      'reads the import database provider after onboarding completes',
      () async {
        var importProviderReadCount = 0;
        final container = ProviderContainer(
          overrides: [
            onboardingGateProvider.overrideWith(_ReadyGate.new),
            pathsHelperProvider.overrideWith(
              (ref) async => _FakePathsHelper(chatDbPath: chatDbPath),
            ),
            sqfliteImportDatabaseProvider.overrideWith((ref) async {
              importProviderReadCount += 1;
              return _FakeSqfliteImportDatabase(maxImportedMessageRowId: 42);
            }),
          ],
        );
        addTearDown(container.dispose);

        container.read(chatDbChangeMonitorProvider);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(importProviderReadCount, 1);
        expect(container.read(chatDbChangeMonitorProvider).lastMaxRowId, 42);
      },
    );
  });
}

class _RecoveringGate extends OnboardingGate {
  @override
  OnboardingStatus build() {
    return OnboardingStatus.recoveringFailedAttempt;
  }
}

class _ReadyGate extends OnboardingGate {
  @override
  OnboardingStatus build() {
    return OnboardingStatus.notNeeded;
  }
}

class _FakePathsHelper implements PathsHelper {
  _FakePathsHelper({required String chatDbPath}) : _chatDbPath = chatDbPath;

  final String _chatDbPath;

  @override
  String get applicationDocumentsPath => '/tmp';

  @override
  String get chatDBPath => _chatDbPath;

  @override
  String? get downloadsPath => '/tmp';

  @override
  String get libraryPath => '/tmp';

  @override
  String get temporaryPath => '/tmp';

  @override
  String getUserName() {
    return 'test-user';
  }

  @override
  String stripTilde(String path) {
    return path.startsWith('~') ? path.replaceFirst('~', '/Users/test') : path;
  }

  @override
  String userGraft(String graft) {
    return '/Users/test/$graft';
  }
}

class _FakeSqfliteImportDatabase extends SqfliteImportDatabase {
  _FakeSqfliteImportDatabase({required this.maxImportedMessageRowId})
    : super(
        databaseDirectory: '/tmp',
        databaseName: 'macos_import.db',
        debugSettings: const ImportDebugSettingsState(),
      );

  final int? maxImportedMessageRowId;

  @override
  Future<int?> getMaxImportedMessageRowId() async {
    return maxImportedMessageRowId;
  }
}

void _createChatDb(String path) {
  final db = sqlite3.open(path);
  try {
    db.execute('CREATE TABLE message (ROWID INTEGER PRIMARY KEY, value TEXT)');
    db.execute('INSERT INTO message (value) VALUES (?)', ['fixture']);
  } finally {
    db.dispose();
  }
}
