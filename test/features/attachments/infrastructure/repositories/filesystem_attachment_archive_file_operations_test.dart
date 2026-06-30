import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/features/attachments/infrastructure/repositories/filesystem_attachment_archive_file_operations.dart';

void main() {
  late Directory tempDir;
  late Directory archiveDir;
  late FilesystemAttachmentArchiveFileOperations operations;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'filesystem_attachment_archive_file_operations_test_',
    );
    archiveDir = Directory(path.join(tempDir.path, 'attachment_archive'));
    operations = const FilesystemAttachmentArchiveFileOperations();
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('reset creates archive directory when absent', () async {
    expect(archiveDir.existsSync(), isFalse);

    await operations.resetArchiveDirectory(archiveDir.path);

    expect(archiveDir.existsSync(), isTrue);
  });

  test(
    'reset removes existing archive contents and recreates directory',
    () async {
      final archiveFile = File(path.join(archiveDir.path, 'ab/photo.jpg'));
      await archiveFile.parent.create(recursive: true);
      await archiveFile.writeAsString('image');

      await operations.resetArchiveDirectory(archiveDir.path);

      expect(archiveDir.existsSync(), isTrue);
      expect(archiveFile.existsSync(), isFalse);
      expect(archiveDir.listSync(recursive: true), isEmpty);
    },
  );

  test('reset rejects symlinked archive directory', () async {
    final outsideDir = Directory(path.join(tempDir.path, 'outside_archive'));
    await outsideDir.create(recursive: true);
    final outsideFile = File(path.join(outsideDir.path, 'keep.jpg'));
    await outsideFile.writeAsString('image');
    final archiveLink = Link(archiveDir.path);
    await archiveLink.create(outsideDir.path);

    await expectLater(
      operations.resetArchiveDirectory(archiveDir.path),
      throwsStateError,
    );

    expect(outsideFile.existsSync(), isTrue);
  });

  test('export returns zero when archive directory is absent', () async {
    final count = await operations.exportArchiveDirectory(archiveDir.path);

    expect(count, 0);
  });

  test('export rejects symlinked archive directory', () async {
    final outsideDir = Directory(path.join(tempDir.path, 'outside_archive'));
    await outsideDir.create(recursive: true);
    final archiveLink = Link(archiveDir.path);
    await archiveLink.create(outsideDir.path);

    await expectLater(
      operations.exportArchiveDirectory(archiveDir.path),
      throwsStateError,
    );
  });
}
