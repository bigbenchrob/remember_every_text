import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_write_store.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_recovery_metadata.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/overlay_attachment_archive_read_store.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/overlay_attachment_archive_write_store.dart';

void main() {
  late Directory tempDir;
  late Directory archiveDir;
  late OverlayDatabase overlayDatabase;
  late OverlayAttachmentArchiveWriteStore writeStore;
  late OverlayAttachmentArchiveReadStore readStore;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'overlay_attachment_archive_store_test_',
    );
    archiveDir = Directory(path.join(tempDir.path, 'attachment_archive'));
    await archiveDir.create(recursive: true);
    overlayDatabase = OverlayDatabase(NativeDatabase.memory());
    writeStore = OverlayAttachmentArchiveWriteStore(
      overlayDatabase: overlayDatabase,
    );
    readStore = OverlayAttachmentArchiveReadStore(
      overlayDb: overlayDatabase,
      archiveDirectory: archiveDir.path,
    );
  });

  tearDown(() async {
    await overlayDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'writes and reads existing archive records by compatibility key',
    () async {
      final archiveKey = _archiveKey();
      final archivedFile = File(path.join(archiveDir.path, 'ab/cd/photo.jpg'));
      await archivedFile.parent.create(recursive: true);
      await archivedFile.writeAsString('image');

      expect(await writeStore.hasArchiveRecord(archiveKey), isFalse);

      await writeStore.writeArchiveRecord(
        ArchivedAttachmentWrite(
          archiveKey: archiveKey,
          archiveRelativePath: 'ab/cd/photo.jpg',
          archivedAtUtc: '2026-06-19T10:00:00.000Z',
          fileSizeBytes: 5,
          contentHash: 'content-hash',
          originalLocalPath: '~/Library/Messages/Attachments/photo.jpg',
        ),
      );

      expect(await writeStore.hasArchiveRecord(archiveKey), isTrue);
      expect(
        await writeStore.hasArchiveRecord(
          const ArchiveCompatibilityKey(
            messageGuid: 'other-message-guid',
            importAttachmentId: 200,
          ),
        ),
        isFalse,
      );

      final record = await readStore.readArchiveRecord(archiveKey);
      expect(record, isNotNull);
      expect(record!.archiveRelativePath, 'ab/cd/photo.jpg');
      expect(record.archiveAbsolutePath, archivedFile.path);
      expect(record.archiveFileExists, isTrue);
      expect(record.provenance, 'archived');

      final integrityEntries = await writeStore.readIntegrityEntries();
      expect(integrityEntries, hasLength(1));
      expect(integrityEntries.single.relativePath, 'ab/cd/photo.jpg');
      expect(integrityEntries.single.contentHash, 'content-hash');
    },
  );

  test(
    'reports missing archive files without hiding archive records',
    () async {
      final archiveKey = _archiveKey();
      await writeStore.writeArchiveRecord(
        ArchivedAttachmentWrite(
          archiveKey: archiveKey,
          archiveRelativePath: 'missing/file.jpg',
          archivedAtUtc: '2026-06-19T10:00:00.000Z',
          fileSizeBytes: 5,
          contentHash: null,
          originalLocalPath: null,
        ),
      );

      final record = await readStore.readArchiveRecord(archiveKey);

      expect(record, isNotNull);
      expect(record!.archiveRelativePath, 'missing/file.jpg');
      expect(record.archiveFileExists, isFalse);
    },
  );

  test(
    'does not resolve archive records that escape the archive root',
    () async {
      final archiveKey = _archiveKey();
      await overlayDatabase.customStatement(
        '''
      INSERT INTO archived_attachments (
        message_guid,
        import_attachment_id,
        archive_relative_path,
        archived_at_utc,
        file_size_bytes
      ) VALUES (?, ?, ?, ?, ?)
      ''',
        <Object?>[
          archiveKey.messageGuid,
          archiveKey.importAttachmentId,
          '../outside.jpg',
          '2026-06-19T10:00:00.000Z',
          5,
        ],
      );

      final record = await readStore.readArchiveRecord(archiveKey);

      expect(record, isNull);
    },
  );

  test('rejects archive records that would escape the archive root', () async {
    await expectLater(
      writeStore.writeArchiveRecord(
        ArchivedAttachmentWrite(
          archiveKey: _archiveKey(),
          archiveRelativePath: '../outside.jpg',
          archivedAtUtc: '2026-06-19T10:00:00.000Z',
          fileSizeBytes: 5,
          contentHash: null,
          originalLocalPath: null,
        ),
      ),
      throwsStateError,
    );
  });

  test(
    'writes, reads, and clears recovery hints by compatibility key',
    () async {
      final archiveKey = _archiveKey();
      final metadata = AttachmentRecoveryMetadata(
        lastRecoveryAttemptAt: DateTime.utc(2026, 6, 19, 10),
        nextRecoveryAttemptAt: DateTime.utc(2026, 6, 20, 10),
        recoveryAttemptCount: 3,
        recoveryPriority: 8,
        userInterestRaisedAt: DateTime.utc(2026, 6, 18, 10),
        lastRecoveryErrorSummary: 'not found',
        isNonRecoverable: true,
      );

      expect(await writeStore.readRecoveryHint(archiveKey), isNull);

      await writeStore.writeRecoveryHint(
        archiveKey: archiveKey,
        metadata: metadata,
      );

      expect(await writeStore.readRecoveryHint(archiveKey), metadata);
      expect(await readStore.readRecoveryHint(archiveKey), metadata);

      await writeStore.clearRecoveryHint(archiveKey);

      expect(await writeStore.readRecoveryHint(archiveKey), isNull);
      expect(await readStore.readRecoveryHint(archiveKey), isNull);
    },
  );
}

ArchiveCompatibilityKey _archiveKey() {
  return const ArchiveCompatibilityKey(
    messageGuid: 'message-guid-1',
    importAttachmentId: 200,
  );
}
