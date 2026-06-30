import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/message_attachment_joins/message_attachment_join_importer.dart';
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
    tempDir = await Directory.systemTemp.createTemp(
      'message_attachment_join_import_test_',
    );
    chatDbPath = '${tempDir.path}/chat.db';
    importDatabase = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
    await _createSourceJoinTable(chatDbPath);
  });

  tearDown(() async {
    await importDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'imports message-to-attachment edges with canonical endpoints',
    () async {
      await _insertSourceJoin(chatDbPath, messageId: 11, attachmentId: 22);

      final result = await MessageAttachmentJoinImporter(
        chatDbPath: chatDbPath,
        importLedger: importDatabase,
        sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
      ).importJoins();
      final rows = await importDatabase.database.query('message_to_attachment');

      expect(result.examinedJoinCount, 1);
      expect(result.insertedJoinCount, 1);
      expect(rows.single['message_source_id'], liveChatDbSourceId);
      expect(rows.single['attachment_source_id'], liveChatDbSourceId);
      expect(rows.single['source_message_rowid'], 11);
      expect(rows.single['source_attachment_rowid'], 22);
      expect(
        rows.single['message_ss_id'],
        SourceScopedRowKey.pack(sourceId: liveChatDbSourceId, sourceRowId: 11),
      );
      expect(
        rows.single['attachment_ss_id'],
        SourceScopedRowKey.pack(sourceId: liveChatDbSourceId, sourceRowId: 22),
      );
    },
  );

  test('is idempotent', () async {
    await _insertSourceJoin(chatDbPath, messageId: 11, attachmentId: 22);

    final importer = MessageAttachmentJoinImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    );
    final firstResult = await importer.importJoins();
    final secondResult = await importer.importJoins();
    final rows = await importDatabase.database.query('message_to_attachment');

    expect(firstResult.insertedJoinCount, 1);
    expect(secondResult.insertedJoinCount, 0);
    expect(rows, hasLength(1));
  });

  test('imports joins after source message rowid', () async {
    await _insertSourceJoin(chatDbPath, messageId: 40, attachmentId: 21);
    await _insertSourceJoin(chatDbPath, messageId: 42, attachmentId: 22);

    final result = await MessageAttachmentJoinImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    ).importJoinsAfterSourceMessageRowId(startedAfterSourceRowId: 40);
    final rows = await importDatabase.database.query('message_to_attachment');

    expect(result.examinedJoinCount, 1);
    expect(result.insertedJoinCount, 1);
    expect(rows.single['source_message_rowid'], 42);
    expect(rows.single['source_attachment_rowid'], 22);
  });
}

Future<void> _createSourceJoinTable(String chatDbPath) async {
  final db = await openDatabase(chatDbPath);
  await db.execute('''
    CREATE TABLE message_attachment_join (
      message_id INTEGER NOT NULL,
      attachment_id INTEGER NOT NULL
    )
  ''');
  await db.close();
}

Future<void> _insertSourceJoin(
  String chatDbPath, {
  required int messageId,
  required int attachmentId,
}) async {
  final db = await openDatabase(chatDbPath);
  await db.insert('message_attachment_join', <String, Object?>{
    'message_id': messageId,
    'attachment_id': attachmentId,
  });
  await db.close();
}
