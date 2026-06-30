import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/filesystem_attachment_archive_file_store.dart';

void main() {
  late Directory tempDir;
  late Directory archiveDir;
  late FilesystemAttachmentArchiveFileStore store;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'filesystem_attachment_archive_file_store_test_',
    );
    archiveDir = Directory(path.join(tempDir.path, 'attachment_archive'));
    store = const FilesystemAttachmentArchiveFileStore();
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('ensures archive directory exists', () async {
    expect(archiveDir.existsSync(), isFalse);

    await store.ensureArchiveDirectory(archiveDir.path);

    expect(archiveDir.existsSync(), isTrue);
  });

  test('rejects symlinked archive directory', () async {
    final outsideDir = Directory(path.join(tempDir.path, 'outside_archive'))
      ..createSync();
    final archiveLink = Link(archiveDir.path);
    await archiveLink.create(outsideDir.path);

    await expectLater(
      store.ensureArchiveDirectory(archiveDir.path),
      throwsStateError,
    );
  });

  test('returns null when source file is absent', () async {
    final write = await store.writeArchiveEntry(
      archiveDirectoryPath: archiveDir.path,
      sourcePath: path.join(tempDir.path, 'missing.jpg'),
      archiveKey: _archiveKey(),
      sha256Hex: null,
    );

    expect(write, isNull);
    expect(archiveDir.existsSync(), isFalse);
  });

  test('returns null when source file is a symlink', () async {
    final outsideFile = File(path.join(tempDir.path, 'outside.jpg'));
    await outsideFile.writeAsString('outside image');
    final sourceLink = Link(path.join(tempDir.path, 'linked.jpg'));
    await sourceLink.create(outsideFile.path);

    final write = await store.writeArchiveEntry(
      archiveDirectoryPath: archiveDir.path,
      sourcePath: sourceLink.path,
      archiveKey: _archiveKey(),
      sha256Hex: null,
    );

    expect(write, isNull);
    expect(archiveDir.existsSync(), isFalse);
  });

  test('writes archive entry using computed content hash path', () async {
    final sourceFile = File(path.join(tempDir.path, 'Photo.JPG'));
    await sourceFile.writeAsString('image bytes');
    final expectedHash = sha256
        .convert(await sourceFile.readAsBytes())
        .toString();

    final write = await store.writeArchiveEntry(
      archiveDirectoryPath: archiveDir.path,
      sourcePath: sourceFile.path,
      archiveKey: _archiveKey(),
      sha256Hex: null,
    );

    expect(write, isNotNull);
    expect(write!.sourcePath, sourceFile.path);
    expect(
      write.relativePath,
      '${expectedHash.substring(0, 2)}/$expectedHash.jpg',
    );
    expect(write.fileSizeBytes, await sourceFile.length());
    expect(write.contentHash, expectedHash);
    expect(
      File(path.join(archiveDir.path, write.relativePath)).existsSync(),
      isTrue,
    );
  });

  test('writes archive entry using supplied content hash', () async {
    final sourceFile = File(path.join(tempDir.path, 'photo.png'));
    await sourceFile.writeAsString('image bytes');
    const suppliedHash = 'abcdef123456';

    final write = await store.writeArchiveEntry(
      archiveDirectoryPath: archiveDir.path,
      sourcePath: sourceFile.path,
      archiveKey: _archiveKey(),
      sha256Hex: suppliedHash,
    );

    expect(write, isNotNull);
    expect(write!.relativePath, 'ab/$suppliedHash.png');
    expect(write.contentHash, suppliedHash);
    expect(
      File(path.join(archiveDir.path, 'ab/$suppliedHash.png')).existsSync(),
      isTrue,
    );
  });

  test('rejects symlinked archive destination target', () async {
    final sourceFile = File(path.join(tempDir.path, 'photo.png'));
    await sourceFile.writeAsString('image bytes');
    const suppliedHash = 'abcdef123456';
    final outsideFile = File(path.join(tempDir.path, 'outside.png'));
    await outsideFile.writeAsString('outside');
    final destinationParent = Directory(path.join(archiveDir.path, 'ab'));
    await destinationParent.create(recursive: true);
    final destinationLink = Link(
      path.join(destinationParent.path, '$suppliedHash.png'),
    );
    await destinationLink.create(outsideFile.path);

    await expectLater(
      store.writeArchiveEntry(
        archiveDirectoryPath: archiveDir.path,
        sourcePath: sourceFile.path,
        archiveKey: _archiveKey(),
        sha256Hex: suppliedHash,
      ),
      throwsStateError,
    );
    expect(outsideFile.readAsStringSync(), 'outside');
  });

  test('falls back to compatibility id path when hash is unusable', () async {
    final sourceFile = File(path.join(tempDir.path, 'photo.heic'));
    await sourceFile.writeAsString('image bytes');

    final write = await store.writeArchiveEntry(
      archiveDirectoryPath: archiveDir.path,
      sourcePath: sourceFile.path,
      archiveKey: _archiveKey(),
      sha256Hex: 'a',
    );

    expect(write, isNotNull);
    expect(write!.relativePath, '_by_id/200.heic');
    expect(write.contentHash, 'a');
    expect(
      File(path.join(archiveDir.path, '_by_id/200.heic')).existsSync(),
      isTrue,
    );
  });

  test('checks archive integrity using stored hash', () async {
    final archiveFile = File(path.join(archiveDir.path, 'ab/photo.jpg'));
    await archiveFile.parent.create(recursive: true);
    await archiveFile.writeAsString('image bytes');
    final expectedHash = sha256
        .convert(await archiveFile.readAsBytes())
        .toString();

    final matching = await store.checkIntegrity(
      archiveDirectoryPath: archiveDir.path,
      relativePath: 'ab/photo.jpg',
      storedHash: expectedHash,
    );
    final mismatching = await store.checkIntegrity(
      archiveDirectoryPath: archiveDir.path,
      relativePath: 'ab/photo.jpg',
      storedHash: 'not-the-hash',
    );
    final missing = await store.checkIntegrity(
      archiveDirectoryPath: archiveDir.path,
      relativePath: 'missing.jpg',
      storedHash: expectedHash,
    );
    final unchecked = await store.checkIntegrity(
      archiveDirectoryPath: archiveDir.path,
      relativePath: 'ab/photo.jpg',
      storedHash: null,
    );

    expect(matching.fileExists, isTrue);
    expect(matching.hashMatches, isTrue);
    expect(matching.actualHash, expectedHash);
    expect(mismatching.fileExists, isTrue);
    expect(mismatching.hashMatches, isFalse);
    expect(mismatching.actualHash, expectedHash);
    expect(missing.fileExists, isFalse);
    expect(missing.hashMatches, isNull);
    expect(missing.actualHash, isNull);
    expect(unchecked.fileExists, isTrue);
    expect(unchecked.hashMatches, isNull);
    expect(unchecked.actualHash, isNull);
  });

  test('integrity check does not read paths outside archive root', () async {
    final outsideFile = File(path.join(tempDir.path, 'outside.jpg'));
    await outsideFile.writeAsString('outside image');
    final outsideHash = sha256
        .convert(await outsideFile.readAsBytes())
        .toString();

    final result = await store.checkIntegrity(
      archiveDirectoryPath: archiveDir.path,
      relativePath: '../outside.jpg',
      storedHash: outsideHash,
    );

    expect(result.fileExists, isFalse);
    expect(result.hashMatches, isNull);
    expect(result.actualHash, isNull);
  });
}

ArchiveCompatibilityKey _archiveKey() {
  return const ArchiveCompatibilityKey(
    messageGuid: 'message-guid',
    importAttachmentId: 200,
  );
}
