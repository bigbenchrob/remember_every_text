import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/sqlite_message_lens_attachment_donor_evidence_reader.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Directory donorRoot;
  late String importPath;
  late String overlayPath;

  setUp(() async {
    donorRoot = await Directory.systemTemp.createTemp(
      'message_lens_donor_evidence_reader_test_',
    );
    importPath = path.join(donorRoot.path, 'macos_import_ss.db');
    overlayPath = path.join(donorRoot.path, 'user_overlays.db');
    _createSupportedImportDatabase(importPath);
    _createSupportedOverlayDatabase(overlayPath);
  });

  tearDown(() async {
    if (donorRoot.existsSync()) {
      await donorRoot.delete(recursive: true);
    }
  });

  test(
    'reads relationship and archive evidence without modifying donor',
    () async {
      final importModifiedAt = File(importPath).lastModifiedSync();
      final overlayModifiedAt = File(overlayPath).lastModifiedSync();
      final reader = SqliteMessageLensAttachmentDonorEvidenceReader(
        donorArchiveRoot: donorRoot.path,
        donorSourceScopedImportDatabasePath: importPath,
        donorOverlayDatabasePath: overlayPath,
      );

      final relationships = await reader.readRelationships(
        sourceId: 1,
        originalMessageRowId: 11,
        originalAttachmentRowId: 22,
      );
      final payload = await reader.readArchivedPayload(
        const ArchiveCompatibilityKey(
          messageGuid: 'message-guid',
          importAttachmentId: 22,
        ),
      );

      expect(relationships, hasLength(1));
      expect(relationships.single.messageGuid, 'message-guid');
      expect(relationships.single.attachmentGuid, 'attachment-guid');
      expect(relationships.single.originalMessageRowId, 11);
      expect(relationships.single.originalAttachmentRowId, 22);
      expect(relationships.single.sourceScopedIdentityIsCoherent, isTrue);
      expect(payload, isNotNull);
      expect(payload!.archiveRelativePath, 'ab/payload.bin');
      expect(payload.recordedSizeBytes, 7);
      expect(File(importPath).lastModifiedSync(), importModifiedAt);
      expect(File(overlayPath).lastModifiedSync(), overlayModifiedAt);
      expect(File('$importPath-wal').existsSync(), isFalse);
      expect(File('$importPath-shm').existsSync(), isFalse);
      expect(File('$overlayPath-wal').existsSync(), isFalse);
      expect(File('$overlayPath-shm').existsSync(), isFalse);
    },
  );

  test('fails closed when donor schema lacks required columns', () async {
    File(importPath).deleteSync();
    final database = sqlite3.open(importPath);
    database.execute('CREATE TABLE messages (ss_id INTEGER PRIMARY KEY)');
    database.dispose();
    final reader = SqliteMessageLensAttachmentDonorEvidenceReader(
      donorArchiveRoot: donorRoot.path,
      donorSourceScopedImportDatabasePath: importPath,
      donorOverlayDatabasePath: overlayPath,
    );

    await expectLater(
      reader.readRelationships(
        sourceId: 1,
        originalMessageRowId: 11,
        originalAttachmentRowId: 22,
      ),
      throwsA(isA<StateError>()),
    );
  });
}

void _createSupportedImportDatabase(String databasePath) {
  final database = sqlite3.open(databasePath);
  database.execute('''
    CREATE TABLE messages (
      ss_id INTEGER PRIMARY KEY,
      source_id INTEGER NOT NULL,
      source_rowid INTEGER NOT NULL,
      guid TEXT NOT NULL
    )
  ''');
  database.execute('''
    CREATE TABLE attachments (
      ss_id INTEGER PRIMARY KEY,
      source_id INTEGER NOT NULL,
      source_rowid INTEGER NOT NULL,
      guid TEXT,
      filename TEXT,
      transfer_name TEXT,
      mime_type TEXT,
      uti TEXT,
      total_bytes INTEGER
    )
  ''');
  database.execute('''
    CREATE TABLE message_to_attachment (
      message_source_id INTEGER NOT NULL,
      attachment_source_id INTEGER NOT NULL,
      source_message_rowid INTEGER NOT NULL,
      source_attachment_rowid INTEGER NOT NULL,
      message_ss_id INTEGER NOT NULL,
      attachment_ss_id INTEGER NOT NULL
    )
  ''');
  final messageSsId = SourceScopedRowKey.pack(sourceId: 1, sourceRowId: 11);
  final attachmentSsId = SourceScopedRowKey.pack(sourceId: 1, sourceRowId: 22);
  database.execute('INSERT INTO messages VALUES (?, 1, 11, ?)', <Object?>[
    messageSsId,
    'message-guid',
  ]);
  database.execute(
    'INSERT INTO attachments VALUES (?, 1, 22, ?, ?, ?, ?, ?, ?)',
    <Object?>[
      attachmentSsId,
      'attachment-guid',
      '~/Library/Messages/Attachments/payload.bin',
      'payload.bin',
      'application/octet-stream',
      'public.data',
      7,
    ],
  );
  database.execute(
    'INSERT INTO message_to_attachment VALUES (1, 1, 11, 22, ?, ?)',
    <Object?>[messageSsId, attachmentSsId],
  );
  database.dispose();
}

void _createSupportedOverlayDatabase(String databasePath) {
  final database = sqlite3.open(databasePath);
  database.execute('''
    CREATE TABLE archived_attachments (
      message_guid TEXT NOT NULL,
      import_attachment_id INTEGER NOT NULL,
      archive_relative_path TEXT NOT NULL,
      file_size_bytes INTEGER NOT NULL,
      content_hash TEXT
    )
  ''');
  database.execute(
    'INSERT INTO archived_attachments VALUES (?, ?, ?, ?, ?)',
    <Object?>['message-guid', 22, 'ab/payload.bin', 7, 'hash'],
  );
  database.dispose();
}
