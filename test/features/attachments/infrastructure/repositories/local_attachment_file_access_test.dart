import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/features/attachments/infrastructure/repositories/local_attachment_file_access.dart';

void main() {
  late Directory tempDir;
  late LocalAttachmentFileAccess fileAccess;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'local_attachment_file_access_test_',
    );
    fileAccess = const LocalAttachmentFileAccess();
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('expandPath normalizes null and empty input to null', () {
    expect(fileAccess.expandPath(null), isNull);
    expect(fileAccess.expandPath(''), isNull);
  });

  test('expandPath preserves ordinary absolute paths', () {
    expect(fileAccess.expandPath('/tmp/photo.jpg'), '/tmp/photo.jpg');
  });

  test('expandPath expands home-relative paths when HOME is available', () {
    final home = Platform.environment['HOME'];

    final expanded = fileAccess.expandPath('~/Library/Messages/photo.jpg');

    if (home == null || home.isEmpty) {
      expect(expanded, '/Library/Messages/photo.jpg');
    } else {
      expect(expanded, '$home/Library/Messages/photo.jpg');
    }
  });

  test('existingExpandedPath returns only paths that exist on disk', () async {
    final existingFile = File(path.join(tempDir.path, 'photo.jpg'));
    await existingFile.writeAsString('image');

    expect(
      fileAccess.existingExpandedPath(existingFile.path),
      existingFile.path,
    );
    expect(
      fileAccess.existingExpandedPath(path.join(tempDir.path, 'missing.jpg')),
      isNull,
    );
    expect(fileAccess.existingExpandedPath(null), isNull);
  });
}
