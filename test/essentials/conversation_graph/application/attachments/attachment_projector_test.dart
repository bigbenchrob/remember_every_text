import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/attachments/attachment_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/working_database_provider.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late ImportDatabase importDatabase;
  late WorkingDatabase workingDatabase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'attachment_projector_test_',
    );
    importDatabase = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
    workingDatabase = await WorkingDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'working_ss_test.db',
    );
  });

  tearDown(() async {
    await workingDatabase.close();
    await importDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('projects attachments and preserves ss_id', () async {
    final ssId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 10,
    );
    await _insertImportAttachment(
      importDatabase,
      sourceRowId: 10,
      guid: 'attachment-guid',
      filename: '/source/photo.jpg',
    );

    final result = await AttachmentProjector(
      importDatabase: importDatabase,
      workingDatabase: workingDatabase,
    ).projectAttachments();
    final rows = await workingDatabase.database.query('attachments');

    expect(result.examinedAttachmentCount, 1);
    expect(result.insertedAttachmentCount, 1);
    expect(rows.single['ss_id'], ssId);
    expect(rows.single['guid'], 'attachment-guid');
    expect(rows.single['filename'], '/source/photo.jpg');
    expect(rows.single, isNot(containsPair('source_id', liveChatDbSourceId)));
  });

  test('is idempotent and refreshes metadata', () async {
    await _insertImportAttachment(
      importDatabase,
      sourceRowId: 10,
      guid: 'attachment-guid',
      filename: '/source/photo.jpg',
    );
    final projector = AttachmentProjector(
      importDatabase: importDatabase,
      workingDatabase: workingDatabase,
    );

    final firstResult = await projector.projectAttachments();
    await importDatabase.database.update(
      'attachments',
      <String, Object?>{'filename': '/source/updated.jpg'},
      where: 'source_id = ? AND source_rowid = ?',
      whereArgs: <Object?>[liveChatDbSourceId, 10],
    );
    final secondResult = await projector.projectAttachments();
    final rows = await workingDatabase.database.query('attachments');

    expect(firstResult.insertedAttachmentCount, 1);
    expect(secondResult.insertedAttachmentCount, 0);
    expect(rows.single['filename'], '/source/updated.jpg');
  });
}

Future<void> _insertImportAttachment(
  ImportDatabase importDatabase, {
  required int sourceRowId,
  required String guid,
  String? filename,
}) async {
  final batchId = await importDatabase.insertImportBatch(
    sourceId: liveChatDbSourceId,
    startedAtUtc: DateTime.now().toUtc().toIso8601String(),
  );
  await importDatabase.database.insert('attachments', <String, Object?>{
    'ss_id': SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: sourceRowId,
    ),
    'source_id': liveChatDbSourceId,
    'source_rowid': sourceRowId,
    'guid': guid,
    'filename': filename,
    'batch_id': batchId,
  });
}
