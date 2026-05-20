import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update_ss/domain/known_sources.dart';
import 'package:remember_this_text/essentials/incremental_update_ss/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/incremental_update_ss/infrastructure/import_database_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late ImportDatabase importDatabase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('import_ss_db_test_');
    importDatabase = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
  });

  tearDown(() async {
    await importDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('creates source registry, import batch, and messages schema', () async {
    final tables = await importDatabase.database.query(
      'sqlite_master',
      columns: <String>['name'],
      where: 'type = ?',
      whereArgs: <Object?>['table'],
    );
    final tableNames = tables.map((row) => row['name']).toSet();

    expect(
      tableNames,
      containsAll(<String>{
        'source_registry',
        'import_batches',
        'messages',
        'handles',
        'chats',
        'chat_to_message',
        'chat_to_handle',
      }),
    );

    final messageColumns = await importDatabase.database.rawQuery(
      'PRAGMA table_info(messages)',
    );
    final columnNames = messageColumns.map((row) => row['name']).toSet();

    expect(
      columnNames,
      containsAll(<String>{
        'ss_id',
        'source_id',
        'source_rowid',
        'guid',
        'sender_handle_ss_id',
        'is_from_me',
        'date_utc',
        'date_read_utc',
        'date_delivered_utc',
        'text',
        'attributed_body_blob',
        'associated_message_guid',
        'batch_id',
      }),
    );
  });

  test('registers live chat.db source identity', () async {
    final rows = await importDatabase.database.query(
      'source_registry',
      where: 'source_id = ?',
      whereArgs: <Object?>[liveChatDbSourceId],
    );

    expect(rows, hasLength(1));
    expect(rows.single['source_key'], liveChatDbSourceKey);
    expect(rows.single['source_kind'], liveChatDbSourceKind);
  });

  test('allows duplicate GUIDs across different source ids', () async {
    final liveBatchId = await importDatabase.insertImportBatch(
      sourceId: liveChatDbSourceId,
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );
    await _insertSource(importDatabase, sourceId: 2);
    final archiveBatchId = await importDatabase.insertImportBatch(
      sourceId: 2,
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );

    await _insertMessage(
      importDatabase,
      sourceId: liveChatDbSourceId,
      sourceRowId: 10,
      guid: 'same-guid',
      batchId: liveBatchId,
    );
    await _insertMessage(
      importDatabase,
      sourceId: 2,
      sourceRowId: 10,
      guid: 'same-guid',
      batchId: archiveBatchId,
    );

    final rows = await importDatabase.database.query(
      'messages',
      where: 'guid = ?',
      whereArgs: <Object?>['same-guid'],
    );

    expect(rows, hasLength(2));
  });

  test('forbids duplicate source row identity within one source', () async {
    final batchId = await importDatabase.insertImportBatch(
      sourceId: liveChatDbSourceId,
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );

    await _insertMessage(
      importDatabase,
      sourceId: liveChatDbSourceId,
      sourceRowId: 10,
      guid: 'first-guid',
      batchId: batchId,
    );

    expect(
      () => _insertMessage(
        importDatabase,
        sourceId: liveChatDbSourceId,
        sourceRowId: 10,
        guid: 'second-guid',
        batchId: batchId,
      ),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('creates non-unique guid index', () async {
    final indexes = await importDatabase.database.rawQuery(
      'PRAGMA index_list(messages)',
    );
    final guidIndex = indexes.singleWhere(
      (row) => row['name'] == 'idx_messages_guid',
    );

    expect(guidIndex['unique'], 0);
  });

  test('creates chats and chat_to_message topology schema', () async {
    final handleColumns = await importDatabase.database.rawQuery(
      'PRAGMA table_info(handles)',
    );
    final chatColumns = await importDatabase.database.rawQuery(
      'PRAGMA table_info(chats)',
    );
    final edgeColumns = await importDatabase.database.rawQuery(
      'PRAGMA table_info(chat_to_message)',
    );
    final participantColumns = await importDatabase.database.rawQuery(
      'PRAGMA table_info(chat_to_handle)',
    );

    expect(handleColumns.map((row) => row['name']).toSet(), <String>{
      'ss_id',
      'source_id',
      'source_rowid',
      'id',
      'service',
      'batch_id',
    });
    expect(chatColumns.map((row) => row['name']).toSet(), <String>{
      'ss_id',
      'source_id',
      'source_rowid',
      'guid',
      'service',
      'group_id',
      'original_group_id',
      'last_read_message_at_utc',
      'batch_id',
    });
    expect(edgeColumns.map((row) => row['name']).toSet(), <String>{
      'ss_id',
      'source_id',
      'source_rowid',
      'source_chat_rowid',
      'source_message_rowid',
      'chat_ss_id',
      'message_ss_id',
    });
    expect(participantColumns.map((row) => row['name']).toSet(), <String>{
      'source_id',
      'source_chat_rowid',
      'source_handle_rowid',
      'chat_ss_id',
      'handle_ss_id',
      'batch_id',
    });
  });

  test('creates non-unique chat guid index', () async {
    final indexes = await importDatabase.database.rawQuery(
      'PRAGMA index_list(chats)',
    );
    final guidIndex = indexes.singleWhere(
      (row) => row['name'] == 'idx_chats_guid',
    );

    expect(guidIndex['unique'], 0);
  });

  test('allows duplicate chat GUIDs across different source ids', () async {
    final liveBatchId = await importDatabase.insertImportBatch(
      sourceId: liveChatDbSourceId,
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );
    await _insertSource(importDatabase, sourceId: 2);
    final archiveBatchId = await importDatabase.insertImportBatch(
      sourceId: 2,
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );

    await _insertChat(
      importDatabase,
      sourceId: liveChatDbSourceId,
      sourceRowId: 7,
      guid: 'same-chat-guid',
      batchId: liveBatchId,
    );
    await _insertChat(
      importDatabase,
      sourceId: 2,
      sourceRowId: 7,
      guid: 'same-chat-guid',
      batchId: archiveBatchId,
    );

    final rows = await importDatabase.database.query(
      'chats',
      where: 'guid = ?',
      whereArgs: <Object?>['same-chat-guid'],
    );

    expect(rows, hasLength(2));
  });

  test(
    'forbids duplicate chat source row identity within one source',
    () async {
      final batchId = await importDatabase.insertImportBatch(
        sourceId: liveChatDbSourceId,
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );

      await _insertChat(
        importDatabase,
        sourceId: liveChatDbSourceId,
        sourceRowId: 7,
        guid: 'first-chat-guid',
        batchId: batchId,
      );

      expect(
        () => _insertChat(
          importDatabase,
          sourceId: liveChatDbSourceId,
          sourceRowId: 7,
          guid: 'second-chat-guid',
          batchId: batchId,
        ),
        throwsA(isA<DatabaseException>()),
      );
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

Future<void> _insertMessage(
  ImportDatabase importDatabase, {
  required int sourceId,
  required int sourceRowId,
  required String guid,
  required int batchId,
}) async {
  await importDatabase.database.insert('messages', <String, Object?>{
    'ss_id': SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: sourceRowId,
    ),
    'source_id': sourceId,
    'source_rowid': sourceRowId,
    'guid': guid,
    'is_from_me': 0,
    'batch_id': batchId,
  });
}

Future<void> _insertChat(
  ImportDatabase importDatabase, {
  required int sourceId,
  required int sourceRowId,
  required String guid,
  required int batchId,
}) async {
  await importDatabase.database.insert('chats', <String, Object?>{
    'ss_id': SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: sourceRowId,
    ),
    'source_id': sourceId,
    'source_rowid': sourceRowId,
    'guid': guid,
    'batch_id': batchId,
  });
}
