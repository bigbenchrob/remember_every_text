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

    test('deletes rebuildable database files while preserving archive payloads '
        'and durable stores', () async {
      final store = FilesystemDerivedMessageDataFileStore(
        databaseDirectory: tempDir.path,
      );

      const rebuildableBaseNames = <String>[
        'macos_import_ss.db',
        'working_ss.db',
        'macos_import.db',
        'working.db',
      ];
      final rebuildableFiles = <File>[
        for (final baseName in rebuildableBaseNames)
          for (final suffix in const <String>['', '-wal', '-shm'])
            File(path.join(tempDir.path, '$baseName$suffix')),
      ];
      for (final file in rebuildableFiles) {
        await file.writeAsString('rebuildable:${path.basename(file.path)}');
      }

      final archiveDir = Directory(
        path.join(tempDir.path, 'attachment_archive'),
      );
      final archivedPayload = File(
        path.join(archiveDir.path, 'a1', 'a1-preserved-payload.jpg'),
      );
      await archivedPayload.parent.create(recursive: true);
      const archivedPayloadContents = <int>[0, 1, 2, 127, 128, 254, 255];
      await archivedPayload.writeAsBytes(archivedPayloadContents, flush: true);

      final overlayFile = File(path.join(tempDir.path, 'user_overlays.db'));
      final presenceFile = File(path.join(tempDir.path, 'presence.db'));
      final preferencesFile = File(
        path.join(tempDir.path, 'preferences-preserved.json'),
      );
      await overlayFile.writeAsString('overlay-preserved');
      await presenceFile.writeAsString('presence-preserved');
      await preferencesFile.writeAsString('preferences-preserved');

      final deleted = await store.deleteDatabaseBaseFiles(rebuildableBaseNames);

      expect(deleted.toSet(), {for (final file in rebuildableFiles) file.path});
      for (final file in rebuildableFiles) {
        expect(file.existsSync(), isFalse, reason: file.path);
      }
      expect(archiveDir.existsSync(), isTrue);
      expect(archivedPayload.existsSync(), isTrue);
      expect(await archivedPayload.readAsBytes(), archivedPayloadContents);
      expect(await overlayFile.readAsString(), 'overlay-preserved');
      expect(await presenceFile.readAsString(), 'presence-preserved');
      expect(await preferencesFile.readAsString(), 'preferences-preserved');
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

    test(
      'ignores symlinked database base files during reset cleanup',
      () async {
        final store = FilesystemDerivedMessageDataFileStore(
          databaseDirectory: tempDir.path,
        );
        final outsideFile = File(path.join(tempDir.path, 'outside.db'));
        await outsideFile.writeAsString('do not delete');
        final dbLink = Link(path.join(tempDir.path, 'working_ss.db'));
        await dbLink.create(outsideFile.path);

        expect(store.databaseBaseFileExists('working_ss.db'), isFalse);

        final deleted = await store.deleteDatabaseBaseFiles(['working_ss.db']);

        expect(deleted, isEmpty);
        expect(dbLink.existsSync(), isTrue);
        expect(await outsideFile.readAsString(), 'do not delete');
      },
    );
  });
}
