import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/infrastructure.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../test_support/test_archive_fixture.dart';

void main() {
  late TestArchiveFixture fixture;
  late Directory workRoot;
  const service = FileSystemArchiveCheckpointService();

  setUp(() async {
    fixture = await TestArchiveFixture.create(prefix: 'checkpoint_source_');
    workRoot = await Directory.systemTemp.createTemp('checkpoint_work_');

    final databasePath = path.join(fixture.root.path, 'working_ss.db');
    final database = sqlite3.open(databasePath);
    try {
      database.execute(
        'CREATE TABLE evidence (id INTEGER PRIMARY KEY, body TEXT)',
      );
      database.execute("INSERT INTO evidence (body) VALUES ('remembered')");
    } finally {
      database.dispose();
    }
    await File(
      path.join(fixture.root.path, 'working_ss.db-wal'),
    ).writeAsBytes(const <int>[]);
    await File(
      path.join(fixture.root.path, 'attachments', 'photo.bin'),
    ).create(recursive: true);
    await File(
      path.join(fixture.root.path, 'attachments', 'photo.bin'),
    ).writeAsBytes(<int>[1, 2, 3, 4]);
    await File(
      path.join(fixture.root.path, 'logs', 'application.log'),
    ).create(recursive: true);
    await File(
      path.join(fixture.root.path, 'logs', 'application.log'),
    ).writeAsString('checkpoint evidence\n');
  });

  tearDown(() async {
    await fixture.dispose();
    if (workRoot.existsSync()) {
      await workRoot.delete(recursive: true);
    }
  });

  test(
    'creates, restores, and verifies a complete disposable archive',
    () async {
      final checkpointPath = path.join(workRoot.path, 'checkpoint');
      final restorePath = path.join(workRoot.path, 'restore');

      final manifest = await service.createOfflineCheckpoint(
        sourceRootPath: fixture.root.path,
        checkpointRootPath: checkpointPath,
      );
      final receipt = await service.restoreAndVerify(
        checkpointRootPath: checkpointPath,
        disposableRestoreRootPath: restorePath,
      );

      expect(
        manifest.sourceArchiveInstanceId,
        fixture.authority.identity.archiveInstanceId,
      );
      expect(
        manifest.files.map((file) => file.relativePath),
        containsAll(<String>[
          '.messagelens-archive.json',
          'working_ss.db',
          'working_ss.db-wal',
          path.join('attachments', 'photo.bin'),
          path.join('logs', 'application.log'),
        ]),
      );
      expect(receipt.matches(fixture.authority), isTrue);
      expect(await service.checkpointStillMatchesSource(receipt), isTrue);

      final restoredDatabase = sqlite3.open(
        path.join(restorePath, 'working_ss.db'),
        mode: OpenMode.readOnly,
      );
      try {
        expect(
          restoredDatabase.select('SELECT body FROM evidence').single['body'],
          'remembered',
        );
      } finally {
        restoredDatabase.dispose();
      }
    },
  );

  test(
    'refuses to checkpoint an archive with an active process claim',
    () async {
      await File(
        path.join(fixture.root.path, 'MessageLens.instance.lock'),
      ).writeAsString('active');

      await expectLater(
        service.createOfflineCheckpoint(
          sourceRootPath: fixture.root.path,
          checkpointRootPath: path.join(workRoot.path, 'checkpoint'),
        ),
        throwsA(isA<ArchiveCheckpointException>()),
      );
    },
  );

  test('receipt becomes invalid when source data changes', () async {
    final checkpointPath = path.join(workRoot.path, 'checkpoint');
    await service.createOfflineCheckpoint(
      sourceRootPath: fixture.root.path,
      checkpointRootPath: checkpointPath,
    );
    final receipt = await service.restoreAndVerify(
      checkpointRootPath: checkpointPath,
      disposableRestoreRootPath: path.join(workRoot.path, 'restore'),
    );

    await File(
      path.join(fixture.root.path, 'logs', 'application.log'),
    ).writeAsString('changed after checkpoint\n');

    expect(await service.checkpointStillMatchesSource(receipt), isFalse);
  });
}
