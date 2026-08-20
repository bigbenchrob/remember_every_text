import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

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
        'contacts',
        'contact_channels',
        'attachments',
        'message_to_attachment',
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
        'raw_item_type',
        'raw_associated_message_type',
        'thread_originator_guid',
        'error_code',
        'is_system_message',
        'has_attributed_body_source',
        'has_message_summary_info',
        'has_payload_data_source',
        'batch_id',
      }),
    );

    final handleColumns = await importDatabase.database.rawQuery(
      'PRAGMA table_info(handles)',
    );
    expect(handleColumns.map((row) => row['name']), contains('is_me'));
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

  test('waits for a brief competing read lock before writing', () async {
    final databasePath = '${tempDir.path}/macos_import_ss_test.db';
    final competingReader = sqlite.sqlite3.open(databasePath);
    competingReader.execute('BEGIN');
    competingReader.select('SELECT COUNT(*) FROM messages');

    final releaseReader = Future<void>.delayed(
      const Duration(milliseconds: 100),
      () {
        competingReader.execute('COMMIT');
        competingReader.dispose();
      },
    );

    final batchId = await importDatabase.insertImportBatch(
      sourceId: liveChatDbSourceId,
      startedAtUtc: DateTime.utc(2026, 8, 20).toIso8601String(),
    );
    await releaseReader;

    expect(batchId, greaterThan(0));
  });

  test('upgrades existing handles with local account identity', () async {
    const databaseName = 'version_9_import.db';
    final legacyDatabase = await openDatabase(
      '${tempDir.path}/$databaseName',
      version: 9,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE source_registry (
            source_id INTEGER PRIMARY KEY,
            source_key TEXT NOT NULL UNIQUE,
            source_kind TEXT NOT NULL,
            source_label TEXT,
            created_at_utc TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE handles (
            ss_id INTEGER PRIMARY KEY,
            source_id INTEGER NOT NULL,
            source_rowid INTEGER NOT NULL,
            id TEXT NOT NULL,
            service TEXT,
            batch_id INTEGER NOT NULL,
            UNIQUE(source_id, source_rowid)
          )
        ''');
        await db.execute('''
          CREATE TABLE chat_to_message (
            source_id INTEGER NOT NULL,
            source_message_rowid INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE message_to_attachment (
            message_source_id INTEGER NOT NULL,
            source_message_rowid INTEGER NOT NULL
          )
        ''');
        await db.insert('handles', <String, Object?>{
          'ss_id': 12,
          'source_id': liveChatDbSourceId,
          'source_rowid': 12,
          'id': '+16046858506',
          'service': 'iMessage',
          'batch_id': 1,
        });
      },
    );
    await legacyDatabase.close();

    final upgradedDatabase = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: databaseName,
    );
    addTearDown(upgradedDatabase.close);

    final columns = await upgradedDatabase.database.rawQuery(
      'PRAGMA table_info(handles)',
    );
    final rows = await upgradedDatabase.database.query('handles');

    expect(columns.map((row) => row['name']), contains('is_me'));
    expect(rows.single['is_me'], 0);
  });

  test('registers live AddressBook source identity', () async {
    final rows = await importDatabase.database.query(
      'source_registry',
      where: 'source_id = ?',
      whereArgs: <Object?>[liveAddressBookSourceId],
    );

    expect(rows, hasLength(1));
    expect(rows.single['source_key'], liveAddressBookSourceKey);
    expect(rows.single['source_kind'], liveAddressBookSourceKind);
  });

  test('registers historical Messages archive source identity', () async {
    final sourceId = await importDatabase.getOrCreateSource(
      sourceKey: '${historicalMessagesArchiveSourceKeyPrefix}archive-a',
      sourceKind: historicalMessagesArchiveSourceKind,
      sourceLabel: 'Archive A',
    );

    expect(sourceId, greaterThan(liveAddressBookSourceId));

    final rows = await importDatabase.database.query(
      'source_registry',
      where: 'source_id = ?',
      whereArgs: <Object?>[sourceId],
    );

    expect(rows, hasLength(1));
    expect(
      rows.single['source_key'],
      '${historicalMessagesArchiveSourceKeyPrefix}archive-a',
    );
    expect(rows.single['source_kind'], historicalMessagesArchiveSourceKind);
    expect(rows.single['source_label'], 'Archive A');
  });

  test('reuses existing source id for the same source key', () async {
    final firstSourceId = await importDatabase.getOrCreateSource(
      sourceKey: '${historicalMessagesArchiveSourceKeyPrefix}archive-a',
      sourceKind: historicalMessagesArchiveSourceKind,
      sourceLabel: 'Archive A',
    );
    final secondSourceId = await importDatabase.getOrCreateSource(
      sourceKey: '${historicalMessagesArchiveSourceKeyPrefix}archive-a',
      sourceKind: historicalMessagesArchiveSourceKind,
      sourceLabel: 'Renamed Archive A',
    );

    expect(secondSourceId, firstSourceId);

    final rows = await importDatabase.database.query(
      'source_registry',
      where: 'source_key = ?',
      whereArgs: <Object?>[
        '${historicalMessagesArchiveSourceKeyPrefix}archive-a',
      ],
    );

    expect(rows, hasLength(1));
    expect(rows.single['source_label'], 'Archive A');
  });

  test('allocates distinct source ids for distinct archive sources', () async {
    final firstSourceId = await importDatabase.getOrCreateSource(
      sourceKey: '${historicalMessagesArchiveSourceKeyPrefix}archive-a',
      sourceKind: historicalMessagesArchiveSourceKind,
    );
    final secondSourceId = await importDatabase.getOrCreateSource(
      sourceKey: '${historicalMessagesArchiveSourceKeyPrefix}archive-b',
      sourceKind: historicalMessagesArchiveSourceKind,
    );

    expect(firstSourceId, greaterThan(liveAddressBookSourceId));
    expect(secondSourceId, firstSourceId + 1);
  });

  test('rejects blank source registration identity', () async {
    expect(
      () => importDatabase.getOrCreateSource(
        sourceKey: ' ',
        sourceKind: historicalMessagesArchiveSourceKind,
      ),
      throwsArgumentError,
    );
    expect(
      () => importDatabase.getOrCreateSource(
        sourceKey: '${historicalMessagesArchiveSourceKeyPrefix}archive-a',
        sourceKind: ' ',
      ),
      throwsArgumentError,
    );
  });

  test('allows duplicate GUIDs across different source ids', () async {
    final liveBatchId = await importDatabase.insertImportBatch(
      sourceId: liveChatDbSourceId,
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );
    await _insertSource(importDatabase, sourceId: 3);
    final archiveBatchId = await importDatabase.insertImportBatch(
      sourceId: 3,
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
      sourceId: 3,
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

  test('reports message cursor and count for one source only', () async {
    final liveBatchId = await importDatabase.insertImportBatch(
      sourceId: liveChatDbSourceId,
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );
    await _insertSource(importDatabase, sourceId: 3);
    final archiveBatchId = await importDatabase.insertImportBatch(
      sourceId: 3,
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );

    await _insertMessage(
      importDatabase,
      sourceId: liveChatDbSourceId,
      sourceRowId: 10,
      guid: 'live-10',
      batchId: liveBatchId,
    );
    await _insertMessage(
      importDatabase,
      sourceId: liveChatDbSourceId,
      sourceRowId: 20,
      guid: 'live-20',
      batchId: liveBatchId,
    );
    await _insertMessage(
      importDatabase,
      sourceId: 3,
      sourceRowId: 999,
      guid: 'archive-999',
      batchId: archiveBatchId,
    );

    expect(
      await importDatabase.maxMessageSourceRowIdForSource(liveChatDbSourceId),
      20,
    );
    expect(await importDatabase.messageCountForSource(liveChatDbSourceId), 2);
  });

  test('deletes source facts and topology rows for one source only', () async {
    await _insertSource(importDatabase, sourceId: 3);
    await _insertSource(importDatabase, sourceId: 4);
    final archiveBatchId = await importDatabase.insertImportBatch(
      sourceId: 3,
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );
    final otherBatchId = await importDatabase.insertImportBatch(
      sourceId: 4,
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );

    await _insertFullSourceSlice(
      importDatabase,
      sourceId: 3,
      batchId: archiveBatchId,
    );
    await _insertFullSourceSlice(
      importDatabase,
      sourceId: 4,
      batchId: otherBatchId,
    );

    expect(await importDatabase.sourceIdForKey('source-3'), 3);

    final deletionResult = await importDatabase.deleteRowsForSource(
      sourceId: 3,
    );

    expect(deletionResult.messages, 1);
    expect(deletionResult.chats, 1);
    expect(deletionResult.handles, 1);
    expect(deletionResult.contacts, 1);
    expect(deletionResult.contactChannels, 1);
    expect(deletionResult.attachments, 1);
    expect(deletionResult.chatMessageEdges, 1);
    expect(deletionResult.chatHandleEdges, 1);
    expect(deletionResult.messageAttachmentEdges, 1);
    expect(deletionResult.importBatches, 1);
    expect(deletionResult.deletedSourceFactCount, 6);
    expect(deletionResult.deletedTopologyEdgeCount, 3);

    for (final tableName in <String>[
      'messages',
      'chats',
      'handles',
      'contacts',
      'contact_channels',
      'attachments',
      'chat_to_message',
      'chat_to_handle',
      'message_to_attachment',
      'import_batches',
    ]) {
      expect(
        await _countRowsForSource(importDatabase, tableName, sourceId: 3),
        0,
        reason: '$tableName should be deleted for source 3',
      );
      expect(
        await _countRowsForSource(importDatabase, tableName, sourceId: 4),
        1,
        reason: '$tableName should remain for source 4',
      );
    }

    expect(await importDatabase.sourceIdForKey('source-3'), 3);
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
    final attachmentColumns = await importDatabase.database.rawQuery(
      'PRAGMA table_info(attachments)',
    );
    final attachmentEdgeColumns = await importDatabase.database.rawQuery(
      'PRAGMA table_info(message_to_attachment)',
    );

    expect(handleColumns.map((row) => row['name']).toSet(), <String>{
      'ss_id',
      'source_id',
      'source_rowid',
      'id',
      'service',
      'is_me',
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

    final contactColumns = await importDatabase.database.rawQuery(
      'PRAGMA table_info(contacts)',
    );
    final channelColumns = await importDatabase.database.rawQuery(
      'PRAGMA table_info(contact_channels)',
    );

    expect(contactColumns.map((row) => row['name']).toSet(), <String>{
      'ss_id',
      'source_id',
      'source_rowid',
      'display_name',
      'first_name',
      'last_name',
      'organization',
      'created_at_utc',
      'batch_id',
    });
    expect(channelColumns.map((row) => row['name']).toSet(), <String>{
      'source_id',
      'source_contact_rowid',
      'contact_ss_id',
      'kind',
      'value',
      'label',
      'batch_id',
    });
    expect(attachmentColumns.map((row) => row['name']).toSet(), <String>{
      'ss_id',
      'source_id',
      'source_rowid',
      'guid',
      'filename',
      'transfer_name',
      'uti',
      'mime_type',
      'total_bytes',
      'created_at_utc',
      'batch_id',
    });
    expect(attachmentEdgeColumns.map((row) => row['name']).toSet(), <String>{
      'message_source_id',
      'attachment_source_id',
      'source_message_rowid',
      'source_attachment_rowid',
      'message_ss_id',
      'attachment_ss_id',
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

  test('creates incremental topology projection cursor indexes', () async {
    final chatMessageIndexes = await importDatabase.database.rawQuery(
      'PRAGMA index_list(chat_to_message)',
    );
    final attachmentIndexes = await importDatabase.database.rawQuery(
      'PRAGMA index_list(message_to_attachment)',
    );

    expect(
      chatMessageIndexes.map((row) => row['name']),
      contains('idx_chat_to_message_source_message_cursor'),
    );
    expect(
      attachmentIndexes.map((row) => row['name']),
      contains('idx_message_to_attachment_source_message_cursor'),
    );
  });

  test('allows duplicate chat GUIDs across different source ids', () async {
    final liveBatchId = await importDatabase.insertImportBatch(
      sourceId: liveChatDbSourceId,
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );
    await _insertSource(importDatabase, sourceId: 3);
    final archiveBatchId = await importDatabase.insertImportBatch(
      sourceId: 3,
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
      sourceId: 3,
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

  test(
    'allows duplicate attachment GUIDs across different source ids',
    () async {
      final liveBatchId = await importDatabase.insertImportBatch(
        sourceId: liveChatDbSourceId,
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );
      await _insertSource(importDatabase, sourceId: 3);
      final archiveBatchId = await importDatabase.insertImportBatch(
        sourceId: 3,
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );

      await _insertAttachment(
        importDatabase,
        sourceId: liveChatDbSourceId,
        sourceRowId: 8,
        guid: 'same-attachment-guid',
        batchId: liveBatchId,
      );
      await _insertAttachment(
        importDatabase,
        sourceId: 3,
        sourceRowId: 8,
        guid: 'same-attachment-guid',
        batchId: archiveBatchId,
      );

      final rows = await importDatabase.database.query(
        'attachments',
        where: 'guid = ?',
        whereArgs: <Object?>['same-attachment-guid'],
      );

      expect(rows, hasLength(2));
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

Future<void> _insertAttachment(
  ImportDatabase importDatabase, {
  required int sourceId,
  required int sourceRowId,
  required String guid,
  required int batchId,
}) async {
  await importDatabase.database.insert('attachments', <String, Object?>{
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

Future<void> _insertFullSourceSlice(
  ImportDatabase importDatabase, {
  required int sourceId,
  required int batchId,
}) async {
  const sourceRowId = 10;
  const chatRowId = 20;
  const handleRowId = 30;
  const contactRowId = 40;
  const attachmentRowId = 50;
  final messageSsId = SourceScopedRowKey.pack(
    sourceId: sourceId,
    sourceRowId: sourceRowId,
  );
  final chatSsId = SourceScopedRowKey.pack(
    sourceId: sourceId,
    sourceRowId: chatRowId,
  );
  final handleSsId = SourceScopedRowKey.pack(
    sourceId: sourceId,
    sourceRowId: handleRowId,
  );
  final contactSsId = SourceScopedRowKey.pack(
    sourceId: sourceId,
    sourceRowId: contactRowId,
  );
  final attachmentSsId = SourceScopedRowKey.pack(
    sourceId: sourceId,
    sourceRowId: attachmentRowId,
  );

  await _insertMessage(
    importDatabase,
    sourceId: sourceId,
    sourceRowId: sourceRowId,
    guid: 'message-$sourceId',
    batchId: batchId,
  );
  await _insertChat(
    importDatabase,
    sourceId: sourceId,
    sourceRowId: chatRowId,
    guid: 'chat-$sourceId',
    batchId: batchId,
  );
  await importDatabase.database.insert('handles', <String, Object?>{
    'ss_id': handleSsId,
    'source_id': sourceId,
    'source_rowid': handleRowId,
    'id': 'handle-$sourceId',
    'batch_id': batchId,
  });
  await importDatabase.database.insert('contacts', <String, Object?>{
    'ss_id': contactSsId,
    'source_id': sourceId,
    'source_rowid': contactRowId,
    'display_name': 'Contact $sourceId',
    'batch_id': batchId,
  });
  await importDatabase.database.insert('contact_channels', <String, Object?>{
    'source_id': sourceId,
    'source_contact_rowid': contactRowId,
    'contact_ss_id': contactSsId,
    'kind': 'phone',
    'value': 'handle-$sourceId',
    'batch_id': batchId,
  });
  await _insertAttachment(
    importDatabase,
    sourceId: sourceId,
    sourceRowId: attachmentRowId,
    guid: 'attachment-$sourceId',
    batchId: batchId,
  );
  await importDatabase.database.insert('chat_to_message', <String, Object?>{
    'ss_id': SourceScopedRowKey.pack(sourceId: sourceId, sourceRowId: 60),
    'source_id': sourceId,
    'source_rowid': 60,
    'source_chat_rowid': chatRowId,
    'source_message_rowid': sourceRowId,
    'chat_ss_id': chatSsId,
    'message_ss_id': messageSsId,
  });
  await importDatabase.database.insert('chat_to_handle', <String, Object?>{
    'source_id': sourceId,
    'source_chat_rowid': chatRowId,
    'source_handle_rowid': handleRowId,
    'chat_ss_id': chatSsId,
    'handle_ss_id': handleSsId,
    'batch_id': batchId,
  });
  await importDatabase.database
      .insert('message_to_attachment', <String, Object?>{
        'message_source_id': sourceId,
        'attachment_source_id': sourceId,
        'source_message_rowid': sourceRowId,
        'source_attachment_rowid': attachmentRowId,
        'message_ss_id': messageSsId,
        'attachment_ss_id': attachmentSsId,
        'batch_id': batchId,
      });
}

Future<int> _countRowsForSource(
  ImportDatabase importDatabase,
  String tableName, {
  required int sourceId,
}) async {
  final whereColumn = switch (tableName) {
    'message_to_attachment' => 'message_source_id',
    _ => 'source_id',
  };
  final rows = await importDatabase.database.rawQuery(
    'SELECT COUNT(*) AS row_count FROM $tableName WHERE $whereColumn = ?',
    <Object?>[sourceId],
  );
  return rows.single['row_count'] as int? ?? 0;
}
