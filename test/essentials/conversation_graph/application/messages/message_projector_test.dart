import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/working_database_provider.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:sqflite/sqflite.dart';
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
    tempDir = await Directory.systemTemp.createTemp('message_projector_test_');
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

  test('projects messages and preserves ss_id exactly', () async {
    final ssId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 100,
    );
    await _insertImportMessage(
      importDatabase,
      sourceId: liveChatDbSourceId,
      sourceRowId: 100,
      guid: 'message-100',
      text: 'hello',
    );

    final result = await MessageProjector(
      importDatabase: importDatabase,
      workingDatabase: workingDatabase,
    ).projectMessages();

    final rows = await workingDatabase.database.query('messages');

    expect(result.examinedMessageCount, 1);
    expect(result.insertedMessageCount, 1);
    expect(rows, hasLength(1));
    expect(rows.single['ss_id'], ssId);
    expect(rows.single['guid'], 'message-100');
    expect(rows.single['text'], 'hello');
  });

  test('is idempotent', () async {
    await _insertImportMessage(
      importDatabase,
      sourceId: liveChatDbSourceId,
      sourceRowId: 101,
      guid: 'message-101',
    );

    final projector = MessageProjector(
      importDatabase: importDatabase,
      workingDatabase: workingDatabase,
    );
    final firstResult = await projector.projectMessages();
    final secondResult = await projector.projectMessages();
    final rows = await workingDatabase.database.query('messages');

    expect(firstResult.insertedMessageCount, 1);
    expect(secondResult.examinedMessageCount, 1);
    expect(secondResult.insertedMessageCount, 0);
    expect(rows, hasLength(1));
  });

  test(
    'refreshes existing working text after import ledger enrichment',
    () async {
      await _insertImportMessage(
        importDatabase,
        sourceId: liveChatDbSourceId,
        sourceRowId: 101,
        guid: 'message-101',
        text: null,
      );

      final projector = MessageProjector(
        importDatabase: importDatabase,
        workingDatabase: workingDatabase,
      );
      await projector.projectMessages();
      await importDatabase.database.update(
        'messages',
        <String, Object?>{'text': 'decoded text'},
        where: 'source_id = ? AND source_rowid = ?',
        whereArgs: <Object?>[liveChatDbSourceId, 101],
      );
      final secondResult = await projector.projectMessages();
      final rows = await workingDatabase.database.query('messages');

      expect(secondResult.insertedMessageCount, 0);
      expect(rows.single['text'], 'decoded text');
    },
  );

  test(
    'duplicate guid values do not block projection when ss_id differs',
    () async {
      await _insertSource(importDatabase, sourceId: 2);
      await _insertImportMessage(
        importDatabase,
        sourceId: liveChatDbSourceId,
        sourceRowId: 102,
        guid: 'same-guid',
      );
      await _insertImportMessage(
        importDatabase,
        sourceId: 2,
        sourceRowId: 102,
        guid: 'same-guid',
      );

      final result = await MessageProjector(
        importDatabase: importDatabase,
        workingDatabase: workingDatabase,
      ).projectMessages();
      final rows = await workingDatabase.database.query(
        'messages',
        where: 'guid = ?',
        whereArgs: <Object?>['same-guid'],
      );

      expect(result.insertedMessageCount, 2);
      expect(rows, hasLength(2));
    },
  );

  test(
    'projects associated message guid to associated message ss_id',
    () async {
      final associatedSsId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 200,
      );
      await _insertImportMessage(
        importDatabase,
        sourceId: liveChatDbSourceId,
        sourceRowId: 200,
        guid: 'target-guid',
      );
      await _insertImportMessage(
        importDatabase,
        sourceId: liveChatDbSourceId,
        sourceRowId: 201,
        guid: 'reaction-guid',
        associatedMessageGuid: 'target-guid',
      );

      await MessageProjector(
        importDatabase: importDatabase,
        workingDatabase: workingDatabase,
      ).projectMessages();
      final rows = await workingDatabase.database.query(
        'messages',
        where: 'guid = ?',
        whereArgs: <Object?>['reaction-guid'],
      );

      expect(rows.single['associated_message_ss_id'], associatedSsId);
    },
  );

  test('associated message lookup remains source scoped', () async {
    await _insertSource(importDatabase, sourceId: 2);
    final liveTargetSsId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 300,
    );
    final archiveTargetSsId = SourceScopedRowKey.pack(
      sourceId: 2,
      sourceRowId: 300,
    );
    await _insertImportMessage(
      importDatabase,
      sourceId: liveChatDbSourceId,
      sourceRowId: 300,
      guid: 'shared-target-guid',
    );
    await _insertImportMessage(
      importDatabase,
      sourceId: 2,
      sourceRowId: 300,
      guid: 'shared-target-guid',
    );
    await _insertImportMessage(
      importDatabase,
      sourceId: 2,
      sourceRowId: 301,
      guid: 'archive-reaction-guid',
      associatedMessageGuid: 'shared-target-guid',
    );

    await MessageProjector(
      importDatabase: importDatabase,
      workingDatabase: workingDatabase,
    ).projectMessages();
    final rows = await workingDatabase.database.query(
      'messages',
      where: 'guid = ?',
      whereArgs: <Object?>['archive-reaction-guid'],
    );

    expect(rows.single['associated_message_ss_id'], archiveTargetSsId);
    expect(rows.single['associated_message_ss_id'], isNot(liveTargetSsId));
  });

  test(
    'missing associated guid projects null associated message ss_id',
    () async {
      await _insertImportMessage(
        importDatabase,
        sourceId: liveChatDbSourceId,
        sourceRowId: 400,
        guid: 'missing-target-reaction',
        associatedMessageGuid: 'missing-target-guid',
      );

      await MessageProjector(
        importDatabase: importDatabase,
        workingDatabase: workingDatabase,
      ).projectMessages();
      final rows = await workingDatabase.database.query(
        'messages',
        where: 'guid = ?',
        whereArgs: <Object?>['missing-target-reaction'],
      );

      expect(rows.single['associated_message_ss_id'], isNull);
    },
  );
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

Future<void> _insertImportMessage(
  ImportDatabase importDatabase, {
  required int sourceId,
  required int sourceRowId,
  required String guid,
  String? text,
  String? associatedMessageGuid,
}) async {
  final batchId = await importDatabase.insertImportBatch(
    sourceId: sourceId,
    startedAtUtc: DateTime.now().toUtc().toIso8601String(),
  );

  await importDatabase.database.insert('messages', <String, Object?>{
    'ss_id': SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: sourceRowId,
    ),
    'source_id': sourceId,
    'source_rowid': sourceRowId,
    'guid': guid,
    'sender_handle_ss_id': SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: 50,
    ),
    'is_from_me': 0,
    'date_utc': '2026-05-19T00:00:00.000Z',
    'text': text,
    'associated_message_guid': associatedMessageGuid,
    'batch_id': batchId,
  });
}
