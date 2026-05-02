import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/domain_driven_development/value_objects.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/db_importers/domain/entities/db_import_result.dart';
import 'package:remember_this_text/essentials/db_migrate/domain/entities/db_migration_result.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_environment_report_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';
import 'package:remember_this_text/essentials/onboarding/infrastructure/persistence/overlay_onboarding_failure_storage.dart';
import 'package:remember_this_text/features/address_book_folders/domain/entities/address_book_folder_aggregate.dart';
import 'package:remember_this_text/features/address_book_folders/domain/entities/address_book_folder_entity.dart';
import 'package:remember_this_text/features/address_book_folders/domain/value_objects/value_objects.dart';
import 'package:remember_this_text/features/address_book_folders/feature_level_providers.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('onboardingEnvironmentReportProvider', () {
    late Directory tempDir;
    late OverlayDatabase overlayDb;
    late ProviderContainer container;

    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'onboarding_environment_report_provider_test',
      );
      overlayDb = OverlayDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      container.dispose();
      await overlayDb.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'treats stale persisted import failures as ready to import when app databases are empty',
      () async {
        final messagesDbPath = _createMessagesDatabase(
          tempDir.path,
          messageCount: 11,
        );
        final addressBookPath = _createReadableFile(
          tempDir.path,
          'AddressBook-v22.abcddb',
        );
        final recordedAt = DateTime.utc(2026, 03, 24, 12, 45);

        final storage = OverlayOnboardingFailureStorage(
          overlayDb: Future<OverlayDatabase>.value(overlayDb),
        );
        await storage.saveImportResult(
          const DbImportResult(
            batchId: 99,
            success: false,
            error: 'Persisted import failure',
          ),
          recordedAt: recordedAt,
        );

        container = ProviderContainer(
          overrides: [
            overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
            _workingDbOverride(tempDir.path),
            onboardingFullDiskAccessProvider.overrideWith((ref) => true),
            onboardingMessagesDatabasePathProvider.overrideWith(
              (ref) => messagesDbPath,
            ),
            onboardingDatabaseDirectoryPathProvider.overrideWith(
              (ref) => tempDir.path,
            ),
            futureGetFolderAggregateProvider.overrideWith(
              (ref) async => right(_addressBookAggregate(addressBookPath)),
            ),
          ],
        );

        final report = await container.read(
          onboardingEnvironmentReportProvider.future,
        );

        expect(report.state, OnboardingEnvironmentState.readyToImport);
        expect(report.blockerKind, OnboardingBlockerKind.importDatabaseMissing);
        expect(report.importFailureMessage, 'Persisted import failure');
        expect(report.usingPersistedImportFailure, isTrue);
        expect(report.lastImportFailureRecordedAt, recordedAt);
      },
    );

    test(
      'simulated full disk access override forces permission blocked',
      () async {
        final messagesDbPath = _createMessagesDatabase(
          tempDir.path,
          messageCount: 11,
        );
        final addressBookPath = _createReadableFile(
          tempDir.path,
          'AddressBook-v22.abcddb',
        );

        container = ProviderContainer(
          overrides: [
            overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
            _workingDbOverride(tempDir.path),
            onboardingFullDiskAccessProvider.overrideWith((ref) => true),
            onboardingMessagesDatabasePathProvider.overrideWith(
              (ref) => messagesDbPath,
            ),
            onboardingDatabaseDirectoryPathProvider.overrideWith(
              (ref) => tempDir.path,
            ),
            futureGetFolderAggregateProvider.overrideWith(
              (ref) async => right(_addressBookAggregate(addressBookPath)),
            ),
          ],
        );

        container
            .read(onboardingDevOverridesProvider.notifier)
            .setFullDiskAccessBlocked(enabled: true);

        final report = await container.refresh(
          onboardingEnvironmentReportProvider.future,
        );

        expect(report.state, OnboardingEnvironmentState.permissionBlocked);
        expect(report.blockerKind, OnboardingBlockerKind.fullDiskAccessMissing);
        expect(report.hasFullDiskAccess, isFalse);
      },
    );

    test('simulated import failure overrides ready app state', () async {
      final messagesDbPath = _createMessagesDatabase(
        tempDir.path,
        messageCount: 11,
      );
      final addressBookPath = _createReadableFile(
        tempDir.path,
        'AddressBook-v22.abcddb',
      );
      _createProjectionDatabase(tempDir.path, 'macos_import.db');
      _createProjectionDatabase(tempDir.path, 'working.db');

      container = ProviderContainer(
        overrides: [
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
          _workingDbOverride(tempDir.path),
          onboardingFullDiskAccessProvider.overrideWith((ref) => true),
          onboardingMessagesDatabasePathProvider.overrideWith(
            (ref) => messagesDbPath,
          ),
          onboardingDatabaseDirectoryPathProvider.overrideWith(
            (ref) => tempDir.path,
          ),
          futureGetFolderAggregateProvider.overrideWith(
            (ref) async => right(_addressBookAggregate(addressBookPath)),
          ),
        ],
      );

      container
          .read(onboardingDevOverridesProvider.notifier)
          .setImportFailure(enabled: true);

      final report = await container.refresh(
        onboardingEnvironmentReportProvider.future,
      );

      expect(report.state, OnboardingEnvironmentState.importFailed);
      expect(report.blockerKind, OnboardingBlockerKind.importFailed);
      expect(
        report.importFailureMessage,
        'Simulated import failure from onboarding dev panel',
      );
      expect(report.usingPersistedImportFailure, isFalse);
    });

    test(
      'treats incomplete projection_state as migration failure even when working db still has rows',
      () async {
        final messagesDbPath = _createMessagesDatabase(
          tempDir.path,
          messageCount: 120,
        );
        final addressBookPath = _createReadableFile(
          tempDir.path,
          'AddressBook-v22.abcddb',
        );
        final importDb = SqfliteImportDatabase(
          databaseDirectory: tempDir.path,
          databaseName: 'macos_import.db',
          debugSettings: const ImportDebugSettingsState(),
        );
        addTearDown(() async {
          await importDb.close();
        });
        final batchId = await importDb.insertImportBatch(
          startedAtUtc: DateTime.utc(2026, 05, 02).toIso8601String(),
        );
        await importDb.insertChat(
          id: 1,
          guid: 'chat-1',
          service: 'iMessage',
          batchId: batchId,
        );
        for (var index = 0; index < 120; index++) {
          await importDb.insertMessage(
            id: index + 1,
            guid: 'message-$index',
            chatId: 1,
            service: 'iMessage',
            isFromMe: false,
            text: 'message-$index',
            hasAttributedBodySource: false,
            hasMessageSummaryInfo: false,
            hasPayloadDataSource: false,
            isSystemMessage: false,
            batchId: batchId,
          );
        }
        final workingDbPath = File('${tempDir.path}/working.db');
        final seededWorkingDb = WorkingDatabase(NativeDatabase(workingDbPath));
        await seededWorkingDb.customStatement(
          "INSERT INTO chats (id, guid, service) VALUES (1, 'working-chat-1', 'iMessage')",
        );
        for (var index = 0; index < 100; index++) {
          await seededWorkingDb.customStatement(
            'INSERT INTO messages (id, guid, chat_id, is_from_me) VALUES (?, ?, 1, 0)',
            <Object?>[index + 1, 'working-message-$index'],
          );
        }
        await seededWorkingDb.customStatement(
          "UPDATE projection_state SET completion_status = 'incomplete', "
          'last_completed_batch_id = 8, '
          "completed_at_utc = '2026-05-02T14:57:54.395398Z' "
          'WHERE id = 1',
        );

        container = ProviderContainer(
          overrides: [
            overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
            sqfliteImportDatabaseProvider.overrideWith((ref) async => importDb),
            driftWorkingDatabaseProvider.overrideWith((ref) async {
              ref.onDispose(() async {
                await seededWorkingDb.close();
              });
              return seededWorkingDb;
            }),
            onboardingFullDiskAccessProvider.overrideWith((ref) => true),
            onboardingMessagesDatabasePathProvider.overrideWith(
              (ref) => messagesDbPath,
            ),
            onboardingDatabaseDirectoryPathProvider.overrideWith(
              (ref) => tempDir.path,
            ),
            futureGetFolderAggregateProvider.overrideWith(
              (ref) async => right(_addressBookAggregate(addressBookPath)),
            ),
          ],
        );

        final report = await container.read(
          onboardingEnvironmentReportProvider.future,
        );

        expect(report.state, OnboardingEnvironmentState.migrationFailed);
        expect(report.blockerKind, OnboardingBlockerKind.migrationFailed);
        expect(report.workingDatabase.projectionStatus, 'incomplete');
        expect(report.workingDatabase.lastCompletedBatchId, 8);
        expect(report.shouldResetAppDatabasesBeforeImport, isTrue);
        expect(report.resetAppDatabasesReason, contains('projection_state'));
        expect(report.hasPopulatedAppDatabases, isFalse);
      },
    );

    test(
      'treats incomplete working projection plus missing import db as missing-ledger recovery',
      () async {
        final messagesDbPath = _createMessagesDatabase(
          tempDir.path,
          messageCount: 120,
        );
        final addressBookPath = _createReadableFile(
          tempDir.path,
          'AddressBook-v22.abcddb',
        );
        final workingDbPath = File('${tempDir.path}/working.db');
        final seededWorkingDb = WorkingDatabase(NativeDatabase(workingDbPath));
        await seededWorkingDb.customStatement(
          "INSERT INTO chats (id, guid, service) VALUES (1, 'working-chat-1', 'iMessage')",
        );
        await seededWorkingDb.customStatement(
          'INSERT INTO messages (id, guid, chat_id, is_from_me) VALUES (1, ?, 1, 0)',
          <Object?>['working-message-1'],
        );
        await seededWorkingDb.customStatement(
          "UPDATE projection_state SET completion_status = 'incomplete', "
          'last_completed_batch_id = 8, '
          "completed_at_utc = '2026-05-02T14:57:54.395398Z' "
          'WHERE id = 1',
        );

        container = ProviderContainer(
          overrides: [
            overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
            driftWorkingDatabaseProvider.overrideWith((ref) async {
              ref.onDispose(() async {
                await seededWorkingDb.close();
              });
              return seededWorkingDb;
            }),
            onboardingFullDiskAccessProvider.overrideWith((ref) => true),
            onboardingMessagesDatabasePathProvider.overrideWith(
              (ref) => messagesDbPath,
            ),
            onboardingDatabaseDirectoryPathProvider.overrideWith(
              (ref) => tempDir.path,
            ),
            futureGetFolderAggregateProvider.overrideWith(
              (ref) async => right(_addressBookAggregate(addressBookPath)),
            ),
          ],
        );

        final report = await container.read(
          onboardingEnvironmentReportProvider.future,
        );

        expect(report.importDatabaseExists, isFalse);
        expect(report.hasReadableImportDatabase, isFalse);
        expect(
          report.hasIncompleteWorkingProjectionWithMissingImportDatabase,
          isTrue,
        );
        expect(report.state, OnboardingEnvironmentState.migrationFailed);
        expect(report.blockerKind, OnboardingBlockerKind.importDatabaseMissing);
        expect(report.shouldResetAppDatabasesBeforeImport, isTrue);
        expect(report.resetAppDatabasesReason, contains('macos_import.db'));
      },
    );

    test(
      'uses recovery classification for an on-disk incomplete working db when the import ledger is missing',
      () async {
        final messagesDbPath = _createMessagesDatabase(
          tempDir.path,
          messageCount: 120,
        );
        final addressBookPath = _createReadableFile(
          tempDir.path,
          'AddressBook-v22.abcddb',
        );
        _createProjectionDatabase(
          tempDir.path,
          'working.db',
          rowCount: 1,
          projectionStatus: 'incomplete',
          lastCompletedBatchId: 8,
          completedAtUtc: '2026-05-02T14:57:54.395398Z',
        );

        container = ProviderContainer(
          overrides: [
            overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
            onboardingFullDiskAccessProvider.overrideWith((ref) => true),
            onboardingMessagesDatabasePathProvider.overrideWith(
              (ref) => messagesDbPath,
            ),
            onboardingDatabaseDirectoryPathProvider.overrideWith(
              (ref) => tempDir.path,
            ),
            futureGetFolderAggregateProvider.overrideWith(
              (ref) async => right(_addressBookAggregate(addressBookPath)),
            ),
          ],
        );

        final report = await container.read(
          onboardingEnvironmentReportProvider.future,
        );

        expect(report.workingDatabase.exists, isTrue);
        expect(report.state, OnboardingEnvironmentState.migrationFailed);
        expect(report.blockerKind, OnboardingBlockerKind.importDatabaseMissing);
        expect(report.hasExistingIncompleteWorkingDatabase, isTrue);
        expect(
          report.hasIncompleteWorkingProjectionWithMissingImportDatabase,
          isTrue,
        );
        expect(report.shouldResetAppDatabasesBeforeImport, isTrue);
      },
    );

    test(
      'treats a freshly seeded empty working db with missing import ledger as ready to import',
      () async {
        final messagesDbPath = _createMessagesDatabase(
          tempDir.path,
          messageCount: 120,
        );
        final addressBookPath = _createReadableFile(
          tempDir.path,
          'AddressBook-v22.abcddb',
        );

        container = ProviderContainer(
          overrides: [
            overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
            _workingDbOverride(tempDir.path),
            onboardingFullDiskAccessProvider.overrideWith((ref) => true),
            onboardingMessagesDatabasePathProvider.overrideWith(
              (ref) => messagesDbPath,
            ),
            onboardingDatabaseDirectoryPathProvider.overrideWith(
              (ref) => tempDir.path,
            ),
            futureGetFolderAggregateProvider.overrideWith(
              (ref) async => right(_addressBookAggregate(addressBookPath)),
            ),
          ],
        );

        await container.read(driftWorkingDatabaseProvider.future);
        final report = await container.refresh(
          onboardingEnvironmentReportProvider.future,
        );

        expect(report.workingDatabase.exists, isTrue);
        expect(report.workingDatabase.projectionStatus, 'incomplete');
        expect(report.workingDatabase.rowCount, 0);
        expect(report.hasExistingIncompleteWorkingDatabase, isFalse);
        expect(
          report.hasIncompleteWorkingProjectionWithMissingImportDatabase,
          isFalse,
        );
        expect(report.state, OnboardingEnvironmentState.readyToImport);
        expect(report.shouldResetAppDatabasesBeforeImport, isFalse);
      },
    );

    test(
      'flags a populated import ledger plus tiny working database for automatic reset',
      () async {
        final messagesDbPath = _createMessagesDatabase(
          tempDir.path,
          messageCount: 120,
        );
        final addressBookPath = _createReadableFile(
          tempDir.path,
          'AddressBook-v22.abcddb',
        );
        final importDb = SqfliteImportDatabase(
          databaseDirectory: tempDir.path,
          databaseName: 'macos_import.db',
          debugSettings: const ImportDebugSettingsState(),
        );
        addTearDown(() async {
          await importDb.close();
        });

        final storage = OverlayOnboardingFailureStorage(
          overlayDb: Future<OverlayDatabase>.value(overlayDb),
        );
        final batchId = await importDb.insertImportBatch(
          startedAtUtc: DateTime.utc(2026, 03, 24).toIso8601String(),
        );
        await importDb.insertChat(
          id: 1,
          guid: 'chat-1',
          service: 'iMessage',
          batchId: batchId,
        );
        for (var index = 0; index < 120; index++) {
          await importDb.insertMessage(
            id: index + 1,
            guid: 'message-$index',
            chatId: 1,
            service: 'iMessage',
            isFromMe: false,
            text: 'message-$index',
            hasAttributedBodySource: false,
            hasMessageSummaryInfo: false,
            hasPayloadDataSource: false,
            isSystemMessage: false,
            batchId: batchId,
          );
        }
        await storage.saveMigrationResult(
          const DbMigrationResult(
            batchId: 99,
            success: false,
            error: 'Persisted migration failure',
          ),
          recordedAt: DateTime.utc(2026, 03, 24, 12, 45),
        );

        container = ProviderContainer(
          overrides: [
            overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
            sqfliteImportDatabaseProvider.overrideWith((ref) async => importDb),
            _workingDbOverride(tempDir.path),
            onboardingFullDiskAccessProvider.overrideWith((ref) => true),
            onboardingMessagesDatabasePathProvider.overrideWith(
              (ref) => messagesDbPath,
            ),
            onboardingDatabaseDirectoryPathProvider.overrideWith(
              (ref) => tempDir.path,
            ),
            futureGetFolderAggregateProvider.overrideWith(
              (ref) async => right(_addressBookAggregate(addressBookPath)),
            ),
          ],
        );

        final report = await container.read(
          onboardingEnvironmentReportProvider.future,
        );

        expect(report.state, OnboardingEnvironmentState.migrationFailed);
        expect(report.blockerKind, OnboardingBlockerKind.migrationFailed);
        expect(report.shouldResetAppDatabasesBeforeImport, isTrue);
        expect(report.resetAppDatabasesReason, isNotNull);
      },
    );
  });
}

Override _workingDbOverride(String directoryPath) {
  return driftWorkingDatabaseProvider.overrideWith((ref) async {
    final db = WorkingDatabase(
      NativeDatabase.createInBackground(File('$directoryPath/working.db')),
    );

    await db.doWhenOpened((_) async {
      await db.customStatement('PRAGMA foreign_keys = ON');
    });

    ref.onDispose(() async {
      await db.close();
    });

    return db;
  });
}

String _createMessagesDatabase(
  String directoryPath, {
  required int messageCount,
}) {
  final filePath = '$directoryPath/messages.db';
  final db = sqlite3.open(filePath);
  try {
    db.execute('CREATE TABLE message (ROWID INTEGER PRIMARY KEY, value TEXT)');
    db.execute(
      'CREATE TABLE attachment (ROWID INTEGER PRIMARY KEY, value TEXT)',
    );
    for (var index = 0; index < messageCount; index++) {
      db.execute('INSERT INTO message (value) VALUES (?)', ['message-$index']);
    }
  } finally {
    db.dispose();
  }
  return filePath;
}

String _createProjectionDatabase(
  String directoryPath,
  String fileName, {
  int rowCount = 1,
  String? projectionStatus,
  int? lastCompletedBatchId,
  String? completedAtUtc,
}) {
  final filePath = '$directoryPath/$fileName';
  final db = sqlite3.open(filePath);
  try {
    db.execute('CREATE TABLE messages (ROWID INTEGER PRIMARY KEY, value TEXT)');
    for (var index = 0; index < rowCount; index++) {
      db.execute('INSERT INTO messages (value) VALUES (?)', ['fixture-$index']);
    }
    if (projectionStatus != null) {
      db.execute('''
        CREATE TABLE projection_state (
          id INTEGER PRIMARY KEY,
          completion_status TEXT,
          last_completed_batch_id INTEGER,
          completed_at_utc TEXT,
          note TEXT
        )
      ''');
      db.execute(
        'INSERT INTO projection_state '
        '(id, completion_status, last_completed_batch_id, completed_at_utc, note) '
        'VALUES (1, ?, ?, ?, NULL)',
        [projectionStatus, lastCompletedBatchId, completedAtUtc],
      );
    }
  } finally {
    db.dispose();
  }
  return filePath;
}

String _createReadableFile(String directoryPath, String fileName) {
  final file = File('$directoryPath/$fileName');
  file.writeAsStringSync('fixture');
  return file.path;
}

AddressBookFolderAggregate _addressBookAggregate(String addressBookPath) {
  return AddressBookFolderAggregate([
    AddressBookFolderEntity(
      path: FolderPathValueObject(addressBookPath),
      shortPath: AddressBookFolderShortPath('TEST-SOURCE'),
      lastCreationDate: FolderCreationDate(DateTime.utc(2026, 03, 24)),
      lastModificationDate: FolderModificationDate(DateTime.utc(2026, 03, 24)),
      recordCount: NonZeroInt(12),
    ),
  ]);
}
