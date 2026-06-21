import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/domain_driven_development/value_objects.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_environment_report_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';
import 'package:remember_this_text/essentials/onboarding/infrastructure/persistence/overlay_onboarding_failure_storage.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart'
    as source_scoped_import;
import 'package:remember_this_text/features/address_book_folders/domain/entities/address_book_folder_aggregate.dart';
import 'package:remember_this_text/features/address_book_folders/domain/entities/address_book_folder_entity.dart';
import 'package:remember_this_text/features/address_book_folders/domain/value_objects/value_objects.dart';
import 'package:remember_this_text/features/address_book_folders/feature_level_providers.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('onboardingEnvironmentReportProvider', () {
    late Directory tempDir;
    late OverlayDatabase overlayDb;
    late ProviderContainer container;

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
        await storage.saveImportFailure(
          batchId: 99,
          message: 'Persisted import failure',
          recordedAt: recordedAt,
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
      _createProjectionDatabase(
        tempDir.path,
        source_scoped_import.importDatabaseFileName,
      );
      _createGraphDatabase(tempDir.path);

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

    test('conversation graph without topology is not ready', () async {
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
        source_scoped_import.importDatabaseFileName,
      );
      _createGraphDatabase(tempDir.path, graphComplete: false);

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

      expect(report.state, OnboardingEnvironmentState.graphProjectionFailed);
      expect(report.blockerKind, OnboardingBlockerKind.graphProjectionFailed);
    });

    test(
      'complete projection state allows normal startup classification',
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
          source_scoped_import.importDatabaseFileName,
        );
        _createGraphDatabase(tempDir.path, graphComplete: true);

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

        expect(report.state, OnboardingEnvironmentState.ready);
        expect(report.blockerKind, OnboardingBlockerKind.none);
      },
    );

    test(
      'does not open graph database while maintenance lock is active',
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
          source_scoped_import.importDatabaseFileName,
        );
        _createGraphDatabase(tempDir.path, graphComplete: true);

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
        container.read(dbMaintenanceLockProvider.notifier).begin();
        addTearDown(
          () => container.read(dbMaintenanceLockProvider.notifier).end(),
        );

        final report = await container.read(
          onboardingEnvironmentReportProvider.future,
        );

        expect(report.conversationGraph.exists, isTrue);
        expect(report.conversationGraph.rowCount, isNull);
      },
    );

    test(
      'flags a populated import ledger plus tiny conversation graph for automatic reset',
      () async {
        final messagesDbPath = _createMessagesDatabase(
          tempDir.path,
          messageCount: 120,
        );
        final addressBookPath = _createReadableFile(
          tempDir.path,
          'AddressBook-v22.abcddb',
        );
        final storage = OverlayOnboardingFailureStorage(
          overlayDb: Future<OverlayDatabase>.value(overlayDb),
        );
        _createProjectionDatabase(
          tempDir.path,
          source_scoped_import.importDatabaseFileName,
          rowCount: 120,
        );
        _createGraphDatabase(tempDir.path, rowCount: 1, graphComplete: false);
        await storage.saveGraphProjectionFailure(
          batchId: 99,
          message: 'Persisted graph projection failure',
          recordedAt: DateTime.utc(2026, 03, 24, 12, 45),
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

        expect(report.state, OnboardingEnvironmentState.graphProjectionFailed);
        expect(report.blockerKind, OnboardingBlockerKind.graphProjectionFailed);
        expect(report.shouldResetAppDatabasesBeforeImport, isTrue);
        expect(report.resetAppDatabasesReason, isNotNull);
      },
    );
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
  bool projectionComplete = false,
}) {
  final filePath = '$directoryPath/$fileName';
  final db = sqlite3.open(filePath);
  try {
    db.execute('CREATE TABLE messages (ROWID INTEGER PRIMARY KEY, value TEXT)');
    db.execute('''
      CREATE TABLE projection_state (
        id INTEGER PRIMARY KEY CHECK(id=1),
        last_import_batch_id INTEGER,
        last_projected_at_utc TEXT,
        last_projected_message_id INTEGER,
        last_projected_attachment_id INTEGER
      )
    ''');
    db.execute(
      '''
      INSERT INTO projection_state (
        id,
        last_import_batch_id,
        last_projected_at_utc,
        last_projected_message_id,
        last_projected_attachment_id
      ) VALUES (1, ?, ?, ?, ?)
      ''',
      projectionComplete
          ? <Object?>[1, DateTime.utc(2026, 03, 24).toIso8601String(), 1, null]
          : const <Object?>[null, null, null, null],
    );
    for (var index = 0; index < rowCount; index++) {
      db.execute('INSERT INTO messages (value) VALUES (?)', ['fixture-$index']);
    }
  } finally {
    db.dispose();
  }
  return filePath;
}

String _createGraphDatabase(
  String directoryPath, {
  int rowCount = 1,
  bool graphComplete = true,
}) {
  final filePath = '$directoryPath/$conversationGraphDatabaseFileName';
  final db = sqlite3.open(filePath);
  try {
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
      ''');
    for (var index = 0; index < rowCount; index++) {
      db.execute('INSERT INTO messages (ss_id) VALUES (?)', [index + 1]);
    }
    if (graphComplete && rowCount > 0) {
      db
        ..execute('INSERT INTO chats (ss_id) VALUES (10)')
        ..execute(
          'INSERT INTO chat_to_message (chat_ss_id, message_ss_id) '
          'VALUES (10, 1)',
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
