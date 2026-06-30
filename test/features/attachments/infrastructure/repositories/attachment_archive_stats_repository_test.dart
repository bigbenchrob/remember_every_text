import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/attachment_archive_stats_repository.dart';

void main() {
  late Directory tempDir;
  late OverlayDatabase overlayDb;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'attachment_archive_stats_',
    );
    overlayDb = OverlayDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await overlayDb.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('AttachmentArchiveStatsRepository', () {
    test('reads overlay record count and physical archive size', () async {
      await File('${tempDir.path}/a.bin').writeAsString('hello');
      await Directory('${tempDir.path}/nested').create();
      await File('${tempDir.path}/nested/b.bin').writeAsString('world!');

      await overlayDb
          .into(overlayDb.archivedAttachments)
          .insert(
            ArchivedAttachmentsCompanion.insert(
              messageGuid: 'message-1',
              importAttachmentId: 10,
              archiveRelativePath: 'a.bin',
              archivedAtUtc: '2026-06-02T12:00:00.000Z',
              fileSizeBytes: 5,
              contentHash: const Value('hash-a'),
            ),
          );
      await overlayDb
          .into(overlayDb.archivedAttachments)
          .insert(
            ArchivedAttachmentsCompanion.insert(
              messageGuid: 'message-2',
              importAttachmentId: 20,
              archiveRelativePath: 'nested/b.bin',
              archivedAtUtc: '2026-06-02T12:01:00.000Z',
              fileSizeBytes: 6,
              contentHash: const Value('hash-b'),
            ),
          );

      final stats = await AttachmentArchiveStatsRepository(
        archiveDirectoryPath: tempDir.path,
        overlayDatabase: overlayDb,
      ).readStats();

      expect(stats.recordCount, 2);
      expect(stats.sizeBytes, 11);
    });

    test('returns zero size for a missing archive directory', () async {
      final stats = await AttachmentArchiveStatsRepository(
        archiveDirectoryPath: '${tempDir.path}/missing',
        overlayDatabase: overlayDb,
      ).readStats();

      expect(stats.recordCount, 0);
      expect(stats.sizeBytes, 0);
    });

    test('does not count symlinked archive contents', () async {
      await File('${tempDir.path}/a.bin').writeAsString('hello');
      final externalFile = File('${tempDir.path}_outside.bin');
      await externalFile.writeAsString('outside bytes');
      addTearDown(() {
        if (externalFile.existsSync()) {
          externalFile.deleteSync();
        }
      });
      await Link('${tempDir.path}/linked.bin').create(externalFile.path);

      final stats = await AttachmentArchiveStatsRepository(
        archiveDirectoryPath: tempDir.path,
        overlayDatabase: overlayDb,
      ).readStats();

      expect(stats.recordCount, 0);
      expect(stats.sizeBytes, 5);
    });

    test('does not walk a symlinked archive root', () async {
      final realArchiveDir = await Directory.systemTemp.createTemp(
        'attachment_archive_stats_real_',
      );
      addTearDown(() async {
        if (realArchiveDir.existsSync()) {
          await realArchiveDir.delete(recursive: true);
        }
      });
      await File('${realArchiveDir.path}/a.bin').writeAsString('hello');
      final archiveLink = Link('${tempDir.path}/archive_link');
      await archiveLink.create(realArchiveDir.path);

      final stats = await AttachmentArchiveStatsRepository(
        archiveDirectoryPath: archiveLink.path,
        overlayDatabase: overlayDb,
      ).readStats();

      expect(stats.recordCount, 0);
      expect(stats.sizeBytes, 0);
    });
  });
}
