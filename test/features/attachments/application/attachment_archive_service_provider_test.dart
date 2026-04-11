import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/features/attachments/application/archive_settings_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_service_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_recovery_hint_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Future<void> ensureTestChatDb(String dbPath) async {
    final db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE attachment (filename TEXT)');
      },
    );
    await db.execute('CREATE TABLE IF NOT EXISTS attachment (filename TEXT)');
    await db.close();
  }

  Future<void> upsertTestChatAttachmentPath({
    required String dbPath,
    required int attachmentId,
    required String localPath,
  }) async {
    final db = await openDatabase(dbPath, version: 1);
    await db.execute('CREATE TABLE IF NOT EXISTS attachment (filename TEXT)');
    await db.delete(
      'attachment',
      where: 'ROWID = ?',
      whereArgs: [attachmentId],
    );
    await db.rawInsert(
      'INSERT INTO attachment(ROWID, filename) VALUES (?, ?)',
      [attachmentId, localPath],
    );
    await db.close();
  }

  group('AttachmentArchiveService.prioritizeRecovery', () {
    late OverlayDatabase overlayDb;
    late Directory tempDir;
    late ProviderContainer container;

    setUp(() async {
      overlayDb = OverlayDatabase(NativeDatabase.memory());
      tempDir = await Directory.systemTemp.createTemp(
        'attachment-priority-test-',
      );
      await overlayDb.writeOverlaySetting(
        settingKey: 'attachment_archive_enabled',
        settingValue: 'true',
      );

      container = ProviderContainer(
        overrides: [
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
          attachmentArchiveDirectoryProvider.overrideWith(
            (ref) => tempDir.path,
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await overlayDb.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'stores a recovery hint and archives immediately when source exists',
      () async {
        final sourceFile = File('${tempDir.path}/messages/recover-now.jpg');
        await sourceFile.parent.create(recursive: true);
        await sourceFile.writeAsString('recover-now');

        await container
            .read(attachmentArchiveServiceProvider.notifier)
            .prioritizeRecovery(
              messageGuid: 'm-recover-now',
              importAttachmentId: 99,
              resolvedLocalPath: sourceFile.path,
              mimeType: 'image/jpeg',
            );

        var archivedRow =
            await (overlayDb.select(overlayDb.archivedAttachments)..where(
                  (t) =>
                      t.messageGuid.equals('m-recover-now') &
                      t.importAttachmentId.equals(99),
                ))
                .getSingleOrNull();

        for (var attempt = 0; attempt < 20 && archivedRow == null; attempt++) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          archivedRow =
              await (overlayDb.select(overlayDb.archivedAttachments)..where(
                    (t) =>
                        t.messageGuid.equals('m-recover-now') &
                        t.importAttachmentId.equals(99),
                  ))
                  .getSingleOrNull();
        }

        expect(archivedRow, isNotNull);
        expect(
          await overlayDb.readOverlaySetting(
            attachmentRecoveryHintSettingKey(
              messageGuid: 'm-recover-now',
              importAttachmentId: 99,
            ),
          ),
          isNull,
        );
      },
    );
  });

  group('AttachmentArchiveService.archiveImportedBatch', () {
    late OverlayDatabase overlayDb;
    late SqfliteImportDatabase importDb;
    late Directory tempDir;
    late ProviderContainer container;

    setUp(() async {
      overlayDb = OverlayDatabase(NativeDatabase.memory());
      tempDir = await Directory.systemTemp.createTemp(
        'attachment-import-batch-test-',
      );
      importDb = SqfliteImportDatabase(
        databaseDirectory: tempDir.path,
        databaseName: 'macos_import_test.db',
        debugSettings: const ImportDebugSettingsState(),
      );
      await overlayDb.writeOverlaySetting(
        settingKey: 'attachment_archive_enabled',
        settingValue: 'true',
      );

      container = ProviderContainer(
        overrides: [
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
          sqfliteImportDatabaseProvider.overrideWith((ref) async => importDb),
          attachmentArchiveDirectoryProvider.overrideWith(
            (ref) => '${tempDir.path}/archive',
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await overlayDb.close();
      await importDb.deleteDatabaseFile();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('archives only attachments from the requested import batch', () async {
      final batchOne = await importDb.insertImportBatch(
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );
      final batchTwo = await importDb.insertImportBatch(
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );

      await importDb.insertChat(
        id: 1,
        sourceRowid: 1,
        guid: 'chat-1',
        service: 'iMessage',
        batchId: batchOne,
      );

      final batchOneSource = File('${tempDir.path}/batch-one.png');
      final batchTwoSource = File('${tempDir.path}/batch-two.png');
      await batchOneSource.writeAsString('batch-one');
      await batchTwoSource.writeAsString('batch-two');

      await importDb.insertMessage(
        id: 100,
        sourceRowid: 100,
        guid: 'message-batch-one',
        chatId: 1,
        service: 'iMessage',
        isFromMe: true,
        text: 'one',
        hasAttributedBodySource: false,
        hasMessageSummaryInfo: false,
        hasPayloadDataSource: false,
        isSystemMessage: false,
        batchId: batchOne,
      );
      await importDb.insertAttachment(
        id: 200,
        sourceRowid: 200,
        localPath: batchOneSource.path,
        mimeType: 'image/png',
        batchId: batchOne,
      );
      await importDb.insertMessageAttachment(messageId: 100, attachmentId: 200);

      await importDb.insertMessage(
        id: 101,
        sourceRowid: 101,
        guid: 'message-batch-two',
        chatId: 1,
        service: 'iMessage',
        isFromMe: true,
        text: 'two',
        hasAttributedBodySource: false,
        hasMessageSummaryInfo: false,
        hasPayloadDataSource: false,
        isSystemMessage: false,
        batchId: batchTwo,
      );
      await importDb.insertAttachment(
        id: 201,
        sourceRowid: 201,
        localPath: batchTwoSource.path,
        mimeType: 'image/png',
        batchId: batchTwo,
      );
      await importDb.insertMessageAttachment(messageId: 101, attachmentId: 201);

      final result = await container
          .read(attachmentArchiveServiceProvider.notifier)
          .archiveImportedBatch(batchId: batchTwo);

      expect(result.totalScanned, 1);
      expect(result.newlyArchived, 1);

      final batchTwoArchive =
          await (overlayDb.select(overlayDb.archivedAttachments)..where(
                (t) =>
                    t.messageGuid.equals('message-batch-two') &
                    t.importAttachmentId.equals(201),
              ))
              .getSingleOrNull();
      final batchOneArchive =
          await (overlayDb.select(overlayDb.archivedAttachments)..where(
                (t) =>
                    t.messageGuid.equals('message-batch-one') &
                    t.importAttachmentId.equals(200),
              ))
              .getSingleOrNull();

      expect(batchTwoArchive, isNotNull);
      expect(batchOneArchive, isNull);
      expect(
        File(
          '${tempDir.path}/archive/${batchTwoArchive!.archiveRelativePath}',
        ).existsSync(),
        isTrue,
      );
    });
  });

  group('AttachmentArchiveService.archiveNextWorkingSweepChunk', () {
    late OverlayDatabase overlayDb;
    late WorkingDatabase workingDb;
    late Directory tempDir;
    late String chatDbPath;
    late ProviderContainer container;

    setUp(() async {
      overlayDb = OverlayDatabase(NativeDatabase.memory());
      workingDb = WorkingDatabase(NativeDatabase.memory());
      tempDir = await Directory.systemTemp.createTemp(
        'attachment-working-sweep-test-',
      );
      chatDbPath = '${tempDir.path}/chat.db';
      await ensureTestChatDb(chatDbPath);
      await overlayDb.writeOverlaySetting(
        settingKey: 'attachment_archive_enabled',
        settingValue: 'true',
      );

      container = ProviderContainer(
        overrides: [
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
          driftWorkingDatabaseProvider.overrideWith((ref) async => workingDb),
          attachmentArchiveMessagesDatabasePathProvider.overrideWith(
            (ref) async => chatDbPath,
          ),
          attachmentArchiveDirectoryProvider.overrideWith(
            (ref) => '${tempDir.path}/archive',
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await overlayDb.close();
      await workingDb.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('sweeps forward in small chunks and persists its cursor', () async {
      final alreadyArchivedSource = File(
        '${tempDir.path}/already-archived.png',
      );
      final firstSweepSource = File('${tempDir.path}/first-sweep.png');
      final secondSweepSource = File('${tempDir.path}/second-sweep.png');
      final thirdSweepSource = File('${tempDir.path}/third-sweep.png');

      await alreadyArchivedSource.writeAsString('already-archived');
      await firstSweepSource.writeAsString('first-sweep');
      await secondSweepSource.writeAsString('second-sweep');
      await thirdSweepSource.writeAsString('third-sweep');

      await workingDb
          .into(workingDb.workingAttachments)
          .insert(
            WorkingAttachmentsCompanion.insert(
              messageGuid: 'message-already-archived',
              importAttachmentId: const Value(11),
              localPath: Value(alreadyArchivedSource.path),
              mimeType: const Value('image/png'),
            ),
          );
      await workingDb
          .into(workingDb.workingAttachments)
          .insert(
            WorkingAttachmentsCompanion.insert(
              messageGuid: 'message-ignored-pdf',
              importAttachmentId: const Value(12),
              localPath: Value('${tempDir.path}/ignored.pdf'),
              mimeType: const Value('application/pdf'),
            ),
          );
      await workingDb
          .into(workingDb.workingAttachments)
          .insert(
            WorkingAttachmentsCompanion.insert(
              messageGuid: 'message-first-sweep',
              importAttachmentId: const Value(13),
              localPath: Value(firstSweepSource.path),
              mimeType: const Value('image/png'),
            ),
          );
      await workingDb
          .into(workingDb.workingAttachments)
          .insert(
            WorkingAttachmentsCompanion.insert(
              messageGuid: 'message-second-sweep',
              importAttachmentId: const Value(14),
              localPath: Value(secondSweepSource.path),
              mimeType: const Value('image/png'),
            ),
          );
      await workingDb
          .into(workingDb.workingAttachments)
          .insert(
            WorkingAttachmentsCompanion.insert(
              messageGuid: 'message-third-sweep',
              importAttachmentId: const Value(15),
              localPath: Value(thirdSweepSource.path),
              mimeType: const Value('image/png'),
            ),
          );

      await overlayDb
          .into(overlayDb.archivedAttachments)
          .insert(
            ArchivedAttachmentsCompanion.insert(
              messageGuid: 'message-already-archived',
              importAttachmentId: 11,
              archiveRelativePath: 'existing/already-archived.png',
              archivedAtUtc: DateTime.now().toUtc().toIso8601String(),
              fileSizeBytes: 16,
            ),
          );

      final firstResult = await container
          .read(attachmentArchiveServiceProvider.notifier)
          .archiveNextWorkingSweepChunk(limit: 2);

      expect(firstResult.totalScanned, 2);
      expect(firstResult.newlyArchived, 2);
      expect(await overlayDb.readOverlaySetting(kArchiveSweepCursorKey), '4');
      expect(
        await overlayDb.readOverlaySetting(kArchiveSweepLastTotalScannedKey),
        '2',
      );
      expect(
        await overlayDb.readOverlaySetting(kArchiveSweepLastNewlyArchivedKey),
        '2',
      );
      expect(
        await overlayDb.readOverlaySetting(kArchiveSweepLastSkippedKey),
        '0',
      );
      expect(
        await overlayDb.readOverlaySetting(kArchiveSweepLastFailedKey),
        '0',
      );
      expect(
        await overlayDb.readOverlaySetting(kArchiveSweepLastStartedAtUtcKey),
        isNotNull,
      );
      expect(
        await overlayDb.readOverlaySetting(kArchiveSweepLastCompletedAtUtcKey),
        isNotNull,
      );

      final firstArchivedRow =
          await (overlayDb.select(overlayDb.archivedAttachments)..where(
                (t) =>
                    t.messageGuid.equals('message-first-sweep') &
                    t.importAttachmentId.equals(13),
              ))
              .getSingleOrNull();
      final secondArchivedRowAfterFirstSweep =
          await (overlayDb.select(overlayDb.archivedAttachments)..where(
                (t) =>
                    t.messageGuid.equals('message-second-sweep') &
                    t.importAttachmentId.equals(14),
              ))
              .getSingleOrNull();
      expect(firstArchivedRow, isNotNull);
      expect(secondArchivedRowAfterFirstSweep, isNotNull);

      final secondResult = await container
          .read(attachmentArchiveServiceProvider.notifier)
          .archiveNextWorkingSweepChunk(limit: 2);

      expect(secondResult.totalScanned, 1);
      expect(secondResult.newlyArchived, 1);
      expect(await overlayDb.readOverlaySetting(kArchiveSweepCursorKey), '0');

      final thirdArchivedRow =
          await (overlayDb.select(overlayDb.archivedAttachments)..where(
                (t) =>
                    t.messageGuid.equals('message-third-sweep') &
                    t.importAttachmentId.equals(15),
              ))
              .getSingleOrNull();
      expect(thirdArchivedRow, isNotNull);
    });

    test('refreshes a stale Messages attachment path from chat.db', () async {
      final liveSource = File('${tempDir.path}/messages/live-path.png');
      await liveSource.parent.create(recursive: true);
      await liveSource.writeAsString('live-path');
      await upsertTestChatAttachmentPath(
        dbPath: chatDbPath,
        attachmentId: 500,
        localPath: liveSource.path,
      );

      await workingDb
          .into(workingDb.workingAttachments)
          .insert(
            WorkingAttachmentsCompanion.insert(
              messageGuid: 'message-path-drift',
              importAttachmentId: const Value(500),
              localPath: Value('${tempDir.path}/messages/stale-path.png'),
              mimeType: const Value('image/png'),
            ),
          );

      final result = await container
          .read(attachmentArchiveServiceProvider.notifier)
          .archiveNextWorkingSweepChunk(limit: 1);

      expect(result.totalScanned, 1);
      expect(result.newlyArchived, 1);

      final archivedRow =
          await (overlayDb.select(overlayDb.archivedAttachments)..where(
                (t) =>
                    t.messageGuid.equals('message-path-drift') &
                    t.importAttachmentId.equals(500),
              ))
              .getSingleOrNull();
      expect(archivedRow, isNotNull);
      expect(archivedRow!.originalLocalPath, liveSource.path);
      expect(
        File(
          '${tempDir.path}/archive/${archivedRow.archiveRelativePath}',
        ).existsSync(),
        isTrue,
      );
    });

    test(
      'persists manual burst totals separately from chunk sweep status',
      () async {
        final maintenanceSource = File('${tempDir.path}/maintenance.png');
        final firstBurstSource = File('${tempDir.path}/burst-first.png');
        final secondBurstSource = File('${tempDir.path}/burst-second.png');
        final thirdBurstSource = File('${tempDir.path}/burst-third.png');

        await maintenanceSource.writeAsString('maintenance');
        await firstBurstSource.writeAsString('burst-first');
        await secondBurstSource.writeAsString('burst-second');
        await thirdBurstSource.writeAsString('burst-third');

        await workingDb
            .into(workingDb.workingAttachments)
            .insert(
              WorkingAttachmentsCompanion.insert(
                messageGuid: 'message-maintenance',
                importAttachmentId: const Value(20),
                localPath: Value(maintenanceSource.path),
                mimeType: const Value('image/png'),
              ),
            );
        await workingDb
            .into(workingDb.workingAttachments)
            .insert(
              WorkingAttachmentsCompanion.insert(
                messageGuid: 'message-burst-first',
                importAttachmentId: const Value(21),
                localPath: Value(firstBurstSource.path),
                mimeType: const Value('image/png'),
              ),
            );
        await workingDb
            .into(workingDb.workingAttachments)
            .insert(
              WorkingAttachmentsCompanion.insert(
                messageGuid: 'message-burst-second',
                importAttachmentId: const Value(22),
                localPath: Value(secondBurstSource.path),
                mimeType: const Value('image/png'),
              ),
            );
        await workingDb
            .into(workingDb.workingAttachments)
            .insert(
              WorkingAttachmentsCompanion.insert(
                messageGuid: 'message-burst-third',
                importAttachmentId: const Value(23),
                localPath: Value(thirdBurstSource.path),
                mimeType: const Value('image/png'),
              ),
            );

        final maintenanceResult = await container
            .read(attachmentArchiveServiceProvider.notifier)
            .archiveNextWorkingSweepChunk(limit: 1);

        expect(maintenanceResult.totalScanned, 1);
        expect(maintenanceResult.newlyArchived, 1);

        final result = await container
            .read(attachmentArchiveServiceProvider.notifier)
            .archiveWorkingSweepBurst(chunkLimit: 2, maxChunks: 2);

        expect(result.totalScanned, 3);
        expect(result.newlyArchived, 3);
        expect(await overlayDb.readOverlaySetting(kArchiveSweepCursorKey), '0');
        expect(
          await overlayDb.readOverlaySetting(
            kArchiveManualSweepLastTotalScannedKey,
          ),
          '3',
        );
        expect(
          await overlayDb.readOverlaySetting(
            kArchiveManualSweepLastNewlyArchivedKey,
          ),
          '3',
        );
        expect(
          await overlayDb.readOverlaySetting(kArchiveManualSweepLastSkippedKey),
          '0',
        );
        expect(
          await overlayDb.readOverlaySetting(kArchiveManualSweepLastFailedKey),
          '0',
        );
        expect(
          await overlayDb.readOverlaySetting(
            kArchiveManualSweepLastStartedAtUtcKey,
          ),
          isNotNull,
        );
        expect(
          await overlayDb.readOverlaySetting(
            kArchiveManualSweepLastCompletedAtUtcKey,
          ),
          isNotNull,
        );

        expect(
          await overlayDb.readOverlaySetting(kArchiveSweepLastTotalScannedKey),
          '1',
        );
        expect(
          await overlayDb.readOverlaySetting(kArchiveSweepLastNewlyArchivedKey),
          '1',
        );
        expect(
          await overlayDb.readOverlaySetting(kArchiveSweepLastSkippedKey),
          '0',
        );
      },
    );

    test(
      'manual burst stops after one cursor cycle for a short tail',
      () async {
        final firstTailSource = File('${tempDir.path}/tail-first.png');
        final secondTailSource = File('${tempDir.path}/tail-second.png');
        final thirdTailSource = File('${tempDir.path}/tail-third.png');

        await firstTailSource.writeAsString('tail-first');
        await secondTailSource.writeAsString('tail-second');
        await thirdTailSource.writeAsString('tail-third');

        await workingDb
            .into(workingDb.workingAttachments)
            .insert(
              WorkingAttachmentsCompanion.insert(
                messageGuid: 'message-tail-first',
                importAttachmentId: const Value(31),
                localPath: Value(firstTailSource.path),
                mimeType: const Value('image/png'),
              ),
            );
        await workingDb
            .into(workingDb.workingAttachments)
            .insert(
              WorkingAttachmentsCompanion.insert(
                messageGuid: 'message-tail-second',
                importAttachmentId: const Value(32),
                localPath: Value(secondTailSource.path),
                mimeType: const Value('image/png'),
              ),
            );
        await workingDb
            .into(workingDb.workingAttachments)
            .insert(
              WorkingAttachmentsCompanion.insert(
                messageGuid: 'message-tail-third',
                importAttachmentId: const Value(33),
                localPath: Value(thirdTailSource.path),
                mimeType: const Value('image/png'),
              ),
            );

        final result = await container
            .read(attachmentArchiveServiceProvider.notifier)
            .archiveWorkingSweepBurst(chunkLimit: 100, maxChunks: 25);

        expect(result.totalScanned, 3);
        expect(result.newlyArchived, 3);
        expect(await overlayDb.readOverlaySetting(kArchiveSweepCursorKey), '0');
        expect(
          await overlayDb.readOverlaySetting(
            kArchiveManualSweepLastTotalScannedKey,
          ),
          '3',
        );
      },
    );

    test('manual burst stores skipped sample details', () async {
      await workingDb
          .into(workingDb.workingAttachments)
          .insert(
            WorkingAttachmentsCompanion.insert(
              messageGuid: 'message-missing-first',
              importAttachmentId: const Value(41),
              localPath: Value('${tempDir.path}/missing-first.png'),
              mimeType: const Value('image/png'),
            ),
          );
      await workingDb
          .into(workingDb.workingAttachments)
          .insert(
            WorkingAttachmentsCompanion.insert(
              messageGuid: 'message-missing-second',
              importAttachmentId: const Value(42),
              localPath: Value('${tempDir.path}/missing-second.png'),
              mimeType: const Value('image/png'),
            ),
          );

      final result = await container
          .read(attachmentArchiveServiceProvider.notifier)
          .archiveWorkingSweepBurst(chunkLimit: 100, maxChunks: 25);

      expect(result.totalScanned, 2);
      expect(result.newlyArchived, 0);
      expect(result.skipped, 2);

      final skippedSamples = await overlayDb.readOverlaySetting(
        kArchiveManualSweepLastSkippedSamplesKey,
      );
      expect(skippedSamples, isNotNull);
      expect(skippedSamples, contains('41 | source missing |'));
      expect(skippedSamples, contains('missing-first.png'));
      expect(skippedSamples, contains('42 | source missing |'));
      expect(skippedSamples, contains('missing-second.png'));
    });
  });
}
