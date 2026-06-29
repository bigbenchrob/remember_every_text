import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/onboarding/infrastructure/persistence/filesystem_derived_message_data_file_store.dart';

void main() {
  group('FilesystemDerivedMessageDataFileStore', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'filesystem_derived_message_data_file_store_test',
      );
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('deletes only requested database base file companions', () async {
      final store = FilesystemDerivedMessageDataFileStore(
        databaseDirectory: tempDir.path,
      );
      final dbFile = File(path.join(tempDir.path, 'working_ss.db'));
      final walFile = File(path.join(tempDir.path, 'working_ss.db-wal'));
      final shmFile = File(path.join(tempDir.path, 'working_ss.db-shm'));
      final archiveDir = Directory(
        path.join(tempDir.path, 'attachment_archive'),
      );

      await dbFile.writeAsString('db');
      await walFile.writeAsString('wal');
      await shmFile.writeAsString('shm');
      await archiveDir.create();

      final deleted = await store.deleteDatabaseBaseFiles(['working_ss.db']);

      expect(deleted.toSet(), {dbFile.path, walFile.path, shmFile.path});
      expect(dbFile.existsSync(), isFalse);
      expect(walFile.existsSync(), isFalse);
      expect(shmFile.existsSync(), isFalse);
      expect(archiveDir.existsSync(), isTrue);
    });

    test('rejects path-like database base names', () async {
      final store = FilesystemDerivedMessageDataFileStore(
        databaseDirectory: tempDir.path,
      );

      expect(
        () => store.databaseBaseFileExists('../attachment_archive'),
        throwsArgumentError,
      );
      await expectLater(
        store.deleteDatabaseBaseFiles(['../attachment_archive']),
        throwsArgumentError,
      );
      await expectLater(
        store.deleteDatabaseBaseFiles(['/tmp/working_ss.db']),
        throwsArgumentError,
      );
      await expectLater(
        store.deleteDatabaseBaseFiles([r'..\working_ss.db']),
        throwsArgumentError,
      );
    });
  });
}
