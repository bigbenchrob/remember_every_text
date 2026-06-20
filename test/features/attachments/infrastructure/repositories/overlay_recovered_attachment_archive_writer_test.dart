import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/attachments/application/cross_snapshot_mapping.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/overlay_recovered_attachment_archive_writer.dart';

void main() {
  late Directory tempDir;
  late Directory archiveDir;
  late OverlayDatabase overlayDatabase;
  late OverlayRecoveredAttachmentArchiveWriter writer;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'overlay_recovered_attachment_archive_writer_test_',
    );
    archiveDir = Directory(path.join(tempDir.path, 'attachment_archive'));
    await archiveDir.create(recursive: true);
    overlayDatabase = OverlayDatabase(NativeDatabase.memory());
    writer = OverlayRecoveredAttachmentArchiveWriter(
      overlayDb: overlayDatabase,
      archiveDir: archiveDir.path,
    );
  });

  tearDown(() async {
    await overlayDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'archives mapped historical file into retained overlay archive',
    () async {
      final sourceFile = File(
        path.join(tempDir.path, 'historical', 'Photo.JPG'),
      );
      await sourceFile.parent.create(recursive: true);
      await sourceFile.writeAsString('historical image');
      final sourceBytes = await sourceFile.readAsBytes();
      final expectedHash = sha256.convert(sourceBytes).toString();

      final size = await writer.archive(
        _record(
          resolvedFilePath: sourceFile.path,
          histLocalPath: '~/Historical/Messages/Attachments/Photo.JPG',
        ),
      );

      expect(size, sourceBytes.length);

      final archivedRows = await overlayDatabase
          .select(overlayDatabase.archivedAttachments)
          .get();
      expect(archivedRows, hasLength(1));
      final archivedRow = archivedRows.single;
      expect(archivedRow.messageGuid, 'current-message-guid');
      expect(archivedRow.importAttachmentId, 200);
      expect(
        archivedRow.archiveRelativePath,
        '${expectedHash.substring(0, 2)}/$expectedHash.jpg',
      );
      expect(archivedRow.fileSizeBytes, sourceBytes.length);
      expect(archivedRow.contentHash, expectedHash);
      expect(archivedRow.provenance, 'imported_historical_snapshot');
      expect(
        archivedRow.originalLocalPath,
        '~/Historical/Messages/Attachments/Photo.JPG',
      );
      expect(
        File(
          path.join(archiveDir.path, archivedRow.archiveRelativePath),
        ).readAsBytesSync(),
        sourceBytes,
      );
    },
  );

  test(
    'returns null and does not rewrite when archive row already exists',
    () async {
      final sourceFile = File(
        path.join(tempDir.path, 'historical', 'photo.jpg'),
      );
      await sourceFile.parent.create(recursive: true);
      await sourceFile.writeAsString('historical image');
      await overlayDatabase.customStatement(
        '''
      INSERT INTO archived_attachments (
        message_guid,
        import_attachment_id,
        archive_relative_path,
        archived_at_utc,
        file_size_bytes,
        content_hash,
        provenance
      ) VALUES (?, ?, ?, ?, ?, ?, ?)
      ''',
        <Object?>[
          'current-message-guid',
          200,
          'aa/existing.jpg',
          '2026-06-19T10:00:00.000Z',
          5,
          'existing-hash',
          'archived',
        ],
      );

      final size = await writer.archive(
        _record(resolvedFilePath: sourceFile.path),
      );

      expect(size, isNull);
      final archivedRows = await overlayDatabase
          .select(overlayDatabase.archivedAttachments)
          .get();
      expect(archivedRows, hasLength(1));
      expect(archivedRows.single.archiveRelativePath, 'aa/existing.jpg');
    },
  );
}

MappedAttachmentRecord _record({
  required String resolvedFilePath,
  String? histLocalPath,
}) {
  return MappedAttachmentRecord(
    histMessageGuid: 'historical-message-guid',
    currentMessageGuid: 'current-message-guid',
    currentImportAttachmentId: 200,
    resolvedFilePath: resolvedFilePath,
    matchMethod: MatchMethod.guidMatch,
    histAttachmentGuid: 'historical-attachment-guid',
    histLocalPath: histLocalPath,
    currentMessageSsId: 100,
    currentAttachmentSsId: 200,
  );
}
