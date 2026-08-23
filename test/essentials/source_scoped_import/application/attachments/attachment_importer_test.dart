import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/attachments/attachment_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/source_import_work_progress.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/source_database/sqflite_source_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late String chatDbPath;
  late ImportDatabase importDatabase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('attachment_import_test_');
    chatDbPath = '${tempDir.path}/chat.db';
    importDatabase = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
    await _createSourceAttachmentTable(chatDbPath);
  });

  tearDown(() async {
    await importDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('imports attachment source facts and provenance', () async {
    await _insertSourceAttachment(
      chatDbPath,
      rowId: 10,
      guid: 'attachment-guid',
      filename: '/Users/rob/Library/Messages/Attachments/photo.jpg',
      transferName: 'photo.jpg',
      uti: 'public.jpeg',
      mimeType: 'image/jpeg',
      totalBytes: 1234,
    );

    final result = await AttachmentImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    ).importAttachments();
    final rows = await importDatabase.database.query('attachments');

    expect(result.startedAfterSourceRowId, 0);
    expect(result.examinedAttachmentCount, 1);
    expect(result.insertedAttachmentCount, 1);
    expect(result.lastImportedSourceRowId, 10);
    expect(
      rows.single['ss_id'],
      SourceScopedRowKey.pack(sourceId: liveChatDbSourceId, sourceRowId: 10),
    );
    expect(rows.single['source_id'], liveChatDbSourceId);
    expect(rows.single['source_rowid'], 10);
    expect(rows.single['guid'], 'attachment-guid');
    expect(rows.single['filename'], contains('photo.jpg'));
    expect(rows.single['transfer_name'], 'photo.jpg');
    expect(rows.single['uti'], 'public.jpeg');
    expect(rows.single['mime_type'], 'image/jpeg');
    expect(rows.single['total_bytes'], 1234);
  });

  test('is idempotent and continues from source-scoped cursor', () async {
    await _insertSourceAttachment(chatDbPath, rowId: 1, guid: 'one');
    await _insertSourceAttachment(chatDbPath, rowId: 2, guid: 'two');

    final importer = AttachmentImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    );
    final firstResult = await importer.importAttachments();
    final secondResult = await importer.importAttachments();

    expect(firstResult.insertedAttachmentCount, 2);
    expect(secondResult.startedAfterSourceRowId, 2);
    expect(secondResult.insertedAttachmentCount, 0);
  });

  test('source-scoped continuation ignores another source', () async {
    final batchId = await importDatabase.insertImportBatch(
      sourceId: liveChatDbSourceId,
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );
    await _insertSource(importDatabase, sourceId: 3);
    await importDatabase.database.insert('attachments', <String, Object?>{
      'ss_id': SourceScopedRowKey.pack(sourceId: 3, sourceRowId: 9999),
      'source_id': 3,
      'source_rowid': 9999,
      'guid': 'archive-attachment',
      'batch_id': batchId,
    });
    await _insertSourceAttachment(chatDbPath, rowId: 5, guid: 'live-five');

    final result = await AttachmentImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    ).importAttachments();

    expect(result.startedAfterSourceRowId, 0);
    expect(result.insertedAttachmentCount, 1);
    expect(result.lastImportedSourceRowId, 5);
  });

  test('reports attachment start and exact completed count', () async {
    await _insertSourceAttachment(chatDbPath, rowId: 3, guid: 'three');
    await _insertSourceAttachment(chatDbPath, rowId: 8, guid: 'eight');
    final observations = <SourceImportWorkProgress>[];

    await AttachmentImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    ).importAttachments(onProgress: observations.add);

    expect(observations, hasLength(2));
    expect(observations.first.completedWorkCount, 0);
    expect(observations.first.totalWorkCount, 2);
    expect(observations.last.completedWorkCount, 2);
    expect(observations.last.lastCompletedSourceRowId, 8);
  });
}

Future<void> _createSourceAttachmentTable(String chatDbPath) async {
  final db = await openDatabase(chatDbPath);
  await db.execute('''
    CREATE TABLE attachment (
      ROWID INTEGER PRIMARY KEY,
      guid TEXT,
      filename TEXT,
      transfer_name TEXT,
      uti TEXT,
      mime_type TEXT,
      total_bytes INTEGER,
      created_date INTEGER
    )
  ''');
  await db.close();
}

Future<void> _insertSourceAttachment(
  String chatDbPath, {
  required int rowId,
  required String guid,
  String? filename,
  String? transferName,
  String? uti,
  String? mimeType,
  int? totalBytes,
}) async {
  final db = await openDatabase(chatDbPath);
  await db.insert('attachment', <String, Object?>{
    'ROWID': rowId,
    'guid': guid,
    'filename': filename,
    'transfer_name': transferName,
    'uti': uti,
    'mime_type': mimeType,
    'total_bytes': totalBytes,
  });
  await db.close();
}

Future<void> _insertSource(
  ImportDatabase importDatabase, {
  required int sourceId,
}) async {
  await importDatabase.database.insert('source_registry', <String, Object?>{
    'source_id': sourceId,
    'source_key': 'source-$sourceId',
    'source_kind': 'archive_chat_db',
    'created_at_utc': DateTime.now().toUtc().toIso8601String(),
  });
}
