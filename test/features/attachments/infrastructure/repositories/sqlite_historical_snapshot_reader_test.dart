import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:remember_this_text/features/attachments/infrastructure/repositories/sqlite_historical_snapshot_reader.dart';
import 'package:sqlite3/sqlite3.dart';

/// Helper to create a minimal historical chat.db with the standard schema.
Database _createHistoricalDb(String path) {
  final db = sqlite3.open(path);
  db.execute('''
    CREATE TABLE message (
      ROWID INTEGER PRIMARY KEY,
      guid TEXT
    )
  ''');
  db.execute('''
    CREATE TABLE attachment (
      ROWID INTEGER PRIMARY KEY,
      guid TEXT,
      filename TEXT,
      transfer_name TEXT,
      mime_type TEXT,
      uti TEXT,
      total_bytes INTEGER,
      is_outgoing INTEGER DEFAULT 0
    )
  ''');
  db.execute('''
    CREATE TABLE message_attachment_join (
      message_id INTEGER NOT NULL,
      attachment_id INTEGER NOT NULL
    )
  ''');
  return db;
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('snapshot_reader_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('SqliteHistoricalSnapshotReader validation', () {
    test('chat.db missing → validation error', () {
      final reader = SqliteHistoricalSnapshotReader(
        chatDbPath: p.join(tempDir.path, 'nonexistent.db'),
        attachmentsFolderPath: tempDir.path,
      );
      final result = reader.validate();

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('does not exist'));
    });

    test('Attachments folder missing → validation error', () {
      // Create a valid chat.db file.
      final dbPath = p.join(tempDir.path, 'chat.db');
      final db = _createHistoricalDb(dbPath);
      db.dispose();

      final reader = SqliteHistoricalSnapshotReader(
        chatDbPath: dbPath,
        attachmentsFolderPath: p.join(tempDir.path, 'NoSuchFolder'),
      );
      final result = reader.validate();

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('does not exist'));
    });

    test('valid chat.db + valid folder → validation succeeds', () {
      final dbPath = p.join(tempDir.path, 'chat.db');
      final db = _createHistoricalDb(dbPath);
      db.dispose();

      final attachDir = Directory(p.join(tempDir.path, 'Attachments'));
      attachDir.createSync();

      final reader = SqliteHistoricalSnapshotReader(
        chatDbPath: dbPath,
        attachmentsFolderPath: attachDir.path,
      );
      final result = reader.validate();

      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
    });

    test('WAL and SHM present → detected', () {
      final dbPath = p.join(tempDir.path, 'chat.db');
      final db = _createHistoricalDb(dbPath);
      db.dispose();

      // Create WAL and SHM files alongside.
      File('$dbPath-wal').writeAsStringSync('dummy');
      File('$dbPath-shm').writeAsStringSync('dummy');

      final attachDir = Directory(p.join(tempDir.path, 'Attachments'));
      attachDir.createSync();

      final reader = SqliteHistoricalSnapshotReader(
        chatDbPath: dbPath,
        attachmentsFolderPath: attachDir.path,
      );
      final result = reader.validate();

      expect(result.isValid, isTrue);
      expect(result.walDetected, isTrue);
      expect(result.shmDetected, isTrue);
    });

    test('WAL and SHM absent → not detected', () {
      final dbPath = p.join(tempDir.path, 'chat.db');
      final db = _createHistoricalDb(dbPath);
      db.dispose();

      final attachDir = Directory(p.join(tempDir.path, 'Attachments'));
      attachDir.createSync();

      final reader = SqliteHistoricalSnapshotReader(
        chatDbPath: dbPath,
        attachmentsFolderPath: attachDir.path,
      );
      final result = reader.validate();

      expect(result.walDetected, isFalse);
      expect(result.shmDetected, isFalse);
    });

    test('invalid SQLite file → validation error', () {
      final dbPath = p.join(tempDir.path, 'chat.db');
      File(dbPath).writeAsStringSync('not a database');

      final attachDir = Directory(p.join(tempDir.path, 'Attachments'));
      attachDir.createSync();

      final reader = SqliteHistoricalSnapshotReader(
        chatDbPath: dbPath,
        attachmentsFolderPath: attachDir.path,
      );
      final result = reader.validate();

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Invalid SQLite'));
    });
  });

  group('SqliteHistoricalSnapshotReader enumeration', () {
    test('returns all message↔attachment pairs with non-null GUID', () {
      final dbPath = p.join(tempDir.path, 'chat.db');
      final attachDir = Directory(p.join(tempDir.path, 'Attachments'));
      attachDir.createSync(recursive: true);

      final db = _createHistoricalDb(dbPath);
      db.execute("INSERT INTO message (ROWID, guid) VALUES (1, 'msg-guid-1')");
      db.execute("INSERT INTO message (ROWID, guid) VALUES (2, 'msg-guid-2')");
      db.execute('''
        INSERT INTO attachment (ROWID, guid, filename, transfer_name, mime_type)
        VALUES (10, 'att-guid-10', '/tmp/fake/path.jpg', 'photo.jpg', 'image/jpeg')
      ''');
      db.execute('''
        INSERT INTO attachment (ROWID, guid, filename, transfer_name, mime_type)
        VALUES (20, 'att-guid-20', '/tmp/fake/path2.png', 'photo2.png', 'image/png')
      ''');
      db.execute(
        'INSERT INTO message_attachment_join (message_id, attachment_id) '
        'VALUES (1, 10)',
      );
      db.execute(
        'INSERT INTO message_attachment_join (message_id, attachment_id) '
        'VALUES (2, 20)',
      );
      db.dispose();

      final reader = SqliteHistoricalSnapshotReader(
        chatDbPath: dbPath,
        attachmentsFolderPath: attachDir.path,
      );
      final result = reader.enumerate();

      expect(result, isNotNull);
      expect(result!.totalHistoricalPairs, equals(2));
      expect(result.records.length, equals(2));
      expect(result.records[0].histMessageGuid, equals('msg-guid-1'));
      expect(result.records[0].histAttachmentGuid, equals('att-guid-10'));
      expect(result.records[1].histMessageGuid, equals('msg-guid-2'));
    });

    test('records with NULL message GUID are excluded', () {
      final dbPath = p.join(tempDir.path, 'chat.db');
      final attachDir = Directory(p.join(tempDir.path, 'Attachments'));
      attachDir.createSync();

      final db = _createHistoricalDb(dbPath);
      db.execute("INSERT INTO message (ROWID, guid) VALUES (1, 'msg-guid-1')");
      db.execute('INSERT INTO message (ROWID, guid) VALUES (2, NULL)');
      db.execute('''
        INSERT INTO attachment (ROWID, guid, filename)
        VALUES (10, 'att-10', '/tmp/att.jpg')
      ''');
      db.execute('''
        INSERT INTO attachment (ROWID, guid, filename)
        VALUES (20, 'att-20', '/tmp/att2.jpg')
      ''');
      db.execute(
        'INSERT INTO message_attachment_join (message_id, attachment_id) '
        'VALUES (1, 10)',
      );
      db.execute(
        'INSERT INTO message_attachment_join (message_id, attachment_id) '
        'VALUES (2, 20)',
      );
      db.dispose();

      final reader = SqliteHistoricalSnapshotReader(
        chatDbPath: dbPath,
        attachmentsFolderPath: attachDir.path,
      );
      final result = reader.enumerate()!;

      expect(result.totalHistoricalPairs, equals(1));
      expect(result.records.first.histMessageGuid, equals('msg-guid-1'));
    });

    test('records with empty/whitespace GUID are excluded', () {
      final dbPath = p.join(tempDir.path, 'chat.db');
      final attachDir = Directory(p.join(tempDir.path, 'Attachments'));
      attachDir.createSync();

      final db = _createHistoricalDb(dbPath);
      db.execute("INSERT INTO message (ROWID, guid) VALUES (1, '')");
      db.execute("INSERT INTO message (ROWID, guid) VALUES (2, '   ')");
      db.execute("INSERT INTO message (ROWID, guid) VALUES (3, 'valid-guid')");
      db.execute('''
        INSERT INTO attachment (ROWID, guid, filename)
        VALUES (10, 'a10', '/tmp/a.jpg')
      ''');
      db.execute('''
        INSERT INTO attachment (ROWID, guid, filename)
        VALUES (20, 'a20', '/tmp/b.jpg')
      ''');
      db.execute('''
        INSERT INTO attachment (ROWID, guid, filename)
        VALUES (30, 'a30', '/tmp/c.jpg')
      ''');
      db.execute('INSERT INTO message_attachment_join VALUES (1, 10)');
      db.execute('INSERT INTO message_attachment_join VALUES (2, 20)');
      db.execute('INSERT INTO message_attachment_join VALUES (3, 30)');
      db.dispose();

      final reader = SqliteHistoricalSnapshotReader(
        chatDbPath: dbPath,
        attachmentsFolderPath: attachDir.path,
      );
      final result = reader.enumerate()!;

      expect(result.totalHistoricalPairs, equals(1));
      expect(result.records.first.histMessageGuid, equals('valid-guid'));
    });

    test('hist_attachment_guid includes NULL cases', () {
      final dbPath = p.join(tempDir.path, 'chat.db');
      final attachDir = Directory(p.join(tempDir.path, 'Attachments'));
      attachDir.createSync();

      final db = _createHistoricalDb(dbPath);
      db.execute("INSERT INTO message (ROWID, guid) VALUES (1, 'msg-1')");
      db.execute('''
        INSERT INTO attachment (ROWID, guid, filename)
        VALUES (10, NULL, '/tmp/a.jpg')
      ''');
      db.execute('INSERT INTO message_attachment_join VALUES (1, 10)');
      db.dispose();

      final reader = SqliteHistoricalSnapshotReader(
        chatDbPath: dbPath,
        attachmentsFolderPath: attachDir.path,
      );
      final result = reader.enumerate()!;

      expect(result.records.length, equals(1));
      expect(result.records.first.histAttachmentGuid, isNull);
    });

    test('deterministic path rewrite resolves file correctly', () {
      final attachDir = Directory(p.join(tempDir.path, 'Attachments'));
      // Create the subdirectory and file that would result from prefix strip.
      final subDir = Directory(p.join(attachDir.path, 'ab', 'cd'));
      subDir.createSync(recursive: true);
      final testFile = File(p.join(subDir.path, 'photo.jpg'));
      testFile.writeAsStringSync('fake image data');

      final dbPath = p.join(tempDir.path, 'chat.db');
      final db = _createHistoricalDb(dbPath);
      db.execute("INSERT INTO message (ROWID, guid) VALUES (1, 'msg-1')");
      // Use a path starting with the known prefix.
      final home = Platform.environment['HOME']!;
      db.execute('''
        INSERT INTO attachment (ROWID, guid, filename)
        VALUES (10, 'att-10', '$home/Library/Messages/Attachments/ab/cd/photo.jpg')
      ''');
      db.execute('INSERT INTO message_attachment_join VALUES (1, 10)');
      db.dispose();

      final reader = SqliteHistoricalSnapshotReader(
        chatDbPath: dbPath,
        attachmentsFolderPath: attachDir.path,
      );
      final result = reader.enumerate()!;

      expect(result.records.length, equals(1));
      expect(result.records.first.fileFound, isTrue);
      expect(result.records.first.resolvedFilePath, equals(testFile.path));
      expect(result.filesFound, equals(1));
      expect(result.filesMissing, equals(0));
    });

    test('file missing at resolved path → fileFound false', () {
      final attachDir = Directory(p.join(tempDir.path, 'Attachments'));
      attachDir.createSync();

      final dbPath = p.join(tempDir.path, 'chat.db');
      final db = _createHistoricalDb(dbPath);
      db.execute("INSERT INTO message (ROWID, guid) VALUES (1, 'msg-1')");
      final home = Platform.environment['HOME']!;
      db.execute('''
        INSERT INTO attachment (ROWID, guid, filename)
        VALUES (10, 'att-10', '$home/Library/Messages/Attachments/no/such/file.jpg')
      ''');
      db.execute('INSERT INTO message_attachment_join VALUES (1, 10)');
      db.dispose();

      final reader = SqliteHistoricalSnapshotReader(
        chatDbPath: dbPath,
        attachmentsFolderPath: attachDir.path,
      );
      final result = reader.enumerate()!;

      expect(result.records.first.fileFound, isFalse);
      expect(result.records.first.resolvedFilePath, isNull);
      expect(result.filesMissing, equals(1));
    });

    test('NULL local path → counted as nullPathRecords', () {
      final attachDir = Directory(p.join(tempDir.path, 'Attachments'));
      attachDir.createSync();

      final dbPath = p.join(tempDir.path, 'chat.db');
      final db = _createHistoricalDb(dbPath);
      db.execute("INSERT INTO message (ROWID, guid) VALUES (1, 'msg-1')");
      db.execute('''
        INSERT INTO attachment (ROWID, guid, filename)
        VALUES (10, 'att-10', NULL)
      ''');
      db.execute('INSERT INTO message_attachment_join VALUES (1, 10)');
      db.dispose();

      final reader = SqliteHistoricalSnapshotReader(
        chatDbPath: dbPath,
        attachmentsFolderPath: attachDir.path,
      );
      final result = reader.enumerate()!;

      expect(result.nullPathRecords, equals(1));
      expect(result.filesFound, equals(0));
      expect(result.filesMissing, equals(0));
    });

    test('summary counts: total, found, missing, null', () {
      final attachDir = Directory(p.join(tempDir.path, 'Attachments'));
      final subDir = Directory(p.join(attachDir.path, 'ab'));
      subDir.createSync(recursive: true);
      File(p.join(subDir.path, 'found.jpg')).writeAsStringSync('data');

      final dbPath = p.join(tempDir.path, 'chat.db');
      final db = _createHistoricalDb(dbPath);
      final home = Platform.environment['HOME']!;

      // Message 1: file exists
      db.execute("INSERT INTO message (ROWID, guid) VALUES (1, 'msg-1')");
      db.execute('''
        INSERT INTO attachment (ROWID, guid, filename)
        VALUES (10, 'a10', '$home/Library/Messages/Attachments/ab/found.jpg')
      ''');
      db.execute('INSERT INTO message_attachment_join VALUES (1, 10)');

      // Message 2: file missing
      db.execute("INSERT INTO message (ROWID, guid) VALUES (2, 'msg-2')");
      db.execute('''
        INSERT INTO attachment (ROWID, guid, filename)
        VALUES (20, 'a20', '$home/Library/Messages/Attachments/nofile.jpg')
      ''');
      db.execute('INSERT INTO message_attachment_join VALUES (2, 20)');

      // Message 3: NULL path
      db.execute("INSERT INTO message (ROWID, guid) VALUES (3, 'msg-3')");
      db.execute('''
        INSERT INTO attachment (ROWID, guid, filename)
        VALUES (30, 'a30', NULL)
      ''');
      db.execute('INSERT INTO message_attachment_join VALUES (3, 30)');

      db.dispose();

      final reader = SqliteHistoricalSnapshotReader(
        chatDbPath: dbPath,
        attachmentsFolderPath: attachDir.path,
      );
      final result = reader.enumerate()!;

      expect(result.totalHistoricalPairs, equals(3));
      expect(result.filesFound, equals(1));
      expect(result.filesMissing, equals(1));
      expect(result.nullPathRecords, equals(1));
    });

    test('cancellation returns null', () {
      final attachDir = Directory(p.join(tempDir.path, 'Attachments'));
      attachDir.createSync();

      final dbPath = p.join(tempDir.path, 'chat.db');
      final db = _createHistoricalDb(dbPath);
      db.execute("INSERT INTO message (ROWID, guid) VALUES (1, 'msg-1')");
      db.execute('''
        INSERT INTO attachment (ROWID, guid, filename)
        VALUES (10, 'a10', '/tmp/fake.jpg')
      ''');
      db.execute('INSERT INTO message_attachment_join VALUES (1, 10)');
      db.dispose();

      final reader = SqliteHistoricalSnapshotReader(
        chatDbPath: dbPath,
        attachmentsFolderPath: attachDir.path,
      );
      final result = reader.enumerate(isCancelled: () => true);

      expect(result, isNull);
    });

    test('DB opened read-only — writes rejected', () {
      final dbPath = p.join(tempDir.path, 'chat.db');
      final db = _createHistoricalDb(dbPath);
      db.dispose();

      // Verify the reader opens read-only by ensuring enumeration works
      // but the file is not modified.
      final beforeStat = File(dbPath).statSync();

      final attachDir = Directory(p.join(tempDir.path, 'Attachments'));
      attachDir.createSync();

      final reader = SqliteHistoricalSnapshotReader(
        chatDbPath: dbPath,
        attachmentsFolderPath: attachDir.path,
      );
      reader.enumerate();

      final afterStat = File(dbPath).statSync();
      expect(afterStat.size, equals(beforeStat.size));
    });

    test('path with tilde prefix gets resolved', () {
      final attachDir = Directory(p.join(tempDir.path, 'Attachments'));
      final subDir = Directory(p.join(attachDir.path, 'xy'));
      subDir.createSync(recursive: true);
      File(p.join(subDir.path, 'tilde.jpg')).writeAsStringSync('data');

      final dbPath = p.join(tempDir.path, 'chat.db');
      final db = _createHistoricalDb(dbPath);
      db.execute("INSERT INTO message (ROWID, guid) VALUES (1, 'msg-1')");
      // Use tilde-style path that Apple stores in chat.db.
      db.execute('''
        INSERT INTO attachment (ROWID, guid, filename)
        VALUES (10, 'a10', '~/Library/Messages/Attachments/xy/tilde.jpg')
      ''');
      db.execute('INSERT INTO message_attachment_join VALUES (1, 10)');
      db.dispose();

      final reader = SqliteHistoricalSnapshotReader(
        chatDbPath: dbPath,
        attachmentsFolderPath: attachDir.path,
      );
      final result = reader.enumerate()!;

      expect(result.records.first.fileFound, isTrue);
      expect(result.filesFound, equals(1));
    });

    test('path with no known prefix → resolvedFilePath is null', () {
      final attachDir = Directory(p.join(tempDir.path, 'Attachments'));
      attachDir.createSync();

      final dbPath = p.join(tempDir.path, 'chat.db');
      final db = _createHistoricalDb(dbPath);
      db.execute("INSERT INTO message (ROWID, guid) VALUES (1, 'msg-1')");
      db.execute('''
        INSERT INTO attachment (ROWID, guid, filename)
        VALUES (10, 'a10', '/some/random/unknown/path.jpg')
      ''');
      db.execute('INSERT INTO message_attachment_join VALUES (1, 10)');
      db.dispose();

      final reader = SqliteHistoricalSnapshotReader(
        chatDbPath: dbPath,
        attachmentsFolderPath: attachDir.path,
      );
      final result = reader.enumerate()!;

      expect(result.records.first.fileFound, isFalse);
      expect(result.records.first.resolvedFilePath, isNull);
      expect(result.filesMissing, equals(1));
    });
  });
}
