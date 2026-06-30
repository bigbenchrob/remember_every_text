import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/features/settings/infrastructure/repositories/archive_source_inspection_repository.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'archive_source_inspection_repository_test_',
    );
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('ArchiveSourceInspectionRepository', () {
    test('reads a real source folder with chat database', () async {
      _createMinimalChatDatabase(tempDir);
      await Directory(path.join(tempDir.path, 'Attachments')).create();
      const repository = ArchiveSourceInspectionRepository(graphDb: null);

      final inspection = await repository.inspectFolder(
        folderPath: tempDir.path,
      );

      expect(inspection.isReadable, isTrue);
      expect(inspection.chatDbStatusLabel, 'Found and readable');
      expect(inspection.attachmentsStatusLabel, 'Found');
      expect(inspection.totalMessages, 1);
      expect(inspection.totalChats, 1);
      expect(inspection.totalHandles, 1);
    });

    test('does not inspect a symlinked source folder', () async {
      final realSource = await Directory.systemTemp.createTemp(
        'archive_source_inspection_real_source_',
      );
      addTearDown(() async {
        if (realSource.existsSync()) {
          await realSource.delete(recursive: true);
        }
      });
      _createMinimalChatDatabase(realSource);
      final sourceLink = Link(path.join(tempDir.path, 'source_link'));
      await sourceLink.create(realSource.path);
      const repository = ArchiveSourceInspectionRepository(graphDb: null);

      final inspection = await repository.inspectFolder(
        folderPath: sourceLink.path,
      );

      expect(inspection.isReadable, isFalse);
      expect(inspection.chatDbStatusLabel, 'Missing');
      expect(inspection.detail, 'The selected folder no longer exists.');
    });

    test('does not inspect a symlinked chat database', () async {
      final realChatDb = File(path.join(tempDir.path, 'real-chat.db'));
      _createMinimalChatDatabaseAt(realChatDb.path);
      await Link(path.join(tempDir.path, 'chat.db')).create(realChatDb.path);
      await Directory(path.join(tempDir.path, 'Attachments')).create();
      const repository = ArchiveSourceInspectionRepository(graphDb: null);

      final inspection = await repository.inspectFolder(
        folderPath: tempDir.path,
      );

      expect(inspection.isReadable, isFalse);
      expect(inspection.chatDbStatusLabel, 'Missing');
      expect(inspection.attachmentsStatusLabel, 'Found');
    });

    test('does not report symlinked attachments folder as found', () async {
      _createMinimalChatDatabase(tempDir);
      final realAttachments = await Directory.systemTemp.createTemp(
        'archive_source_inspection_real_attachments_',
      );
      addTearDown(() async {
        if (realAttachments.existsSync()) {
          await realAttachments.delete(recursive: true);
        }
      });
      await Link(
        path.join(tempDir.path, 'Attachments'),
      ).create(realAttachments.path);
      const repository = ArchiveSourceInspectionRepository(graphDb: null);

      final inspection = await repository.inspectFolder(
        folderPath: tempDir.path,
      );

      expect(inspection.isReadable, isTrue);
      expect(inspection.chatDbStatusLabel, 'Found and readable');
      expect(inspection.attachmentsStatusLabel, 'Not found');
    });
  });
}

void _createMinimalChatDatabase(Directory sourceDirectory) {
  _createMinimalChatDatabaseAt(path.join(sourceDirectory.path, 'chat.db'));
}

void _createMinimalChatDatabaseAt(String databasePath) {
  final db = sqlite3.sqlite3.open(databasePath);
  try {
    db
      ..execute(
        'CREATE TABLE message (ROWID INTEGER PRIMARY KEY, guid TEXT, date INTEGER)',
      )
      ..execute('CREATE TABLE chat (ROWID INTEGER PRIMARY KEY)')
      ..execute('CREATE TABLE handle (ROWID INTEGER PRIMARY KEY)')
      ..execute(
        "INSERT INTO message (ROWID, guid, date) VALUES (1, 'message-1', 0)",
      )
      ..execute('INSERT INTO chat (ROWID) VALUES (1)')
      ..execute('INSERT INTO handle (ROWID) VALUES (1)');
  } finally {
    db.dispose();
  }
}
