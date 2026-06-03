import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/core/util/date_converter.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chat_handle_joins/chat_to_handle_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chat_message_joins/chat_to_message_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chats/chat_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chats/chat_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/handles/handle_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/chat_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/chat_to_handle_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/chat_to_message_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/handle_projection_repository.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/chat_handle_joins/chat_handle_join_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/chat_message_joins/chat_message_join_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/chats/chat_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/handles/handle_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../conversation_graph_test_database.dart';

void main() {
  late Directory tempDir;
  late String chatDbPath;
  late ImportDatabase importDatabase;
  late ConversationGraphDatabase workingDatabase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('chat projector delegates projection to repository', () async {
    final repository = _FakeChatProjectionRepository(
      result: const ChatProjectionResult(
        examinedChatCount: 8,
        insertedChatCount: 4,
      ),
    );
    final result = await ChatProjector(repository: repository).projectChats();

    expect(repository.callCount, 1);
    expect(result.examinedChatCount, 8);
    expect(result.insertedChatCount, 4);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('ss_chat_topology_test_');
    chatDbPath = '${tempDir.path}/chat.db';
    importDatabase = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
    workingDatabase = await openConversationGraphTestDatabase();
    await _createSourceTables(chatDbPath);
  });

  tearDown(() async {
    await workingDatabase.close();
    await importDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('imports and projects chats with stable ss_id', () async {
    final appleDate = DateConverter.dateString2Apple('2026-05-20');
    await _insertSourceChat(
      chatDbPath,
      rowId: 7,
      guid: 'chat-guid',
      serviceName: 'iMessage',
      groupId: 'group-id',
      originalGroupId: 'original-group-id',
      lastReadMessageTimestamp: appleDate,
    );
    await _insertSourceChatHandle(chatDbPath, chatId: 7, handleId: 1);
    await _insertSourceChatHandle(chatDbPath, chatId: 7, handleId: 2);
    await _insertSourceHandle(
      chatDbPath,
      rowId: 1,
      id: '+15550000001',
      service: 'iMessage',
    );
    await _insertSourceHandle(
      chatDbPath,
      rowId: 2,
      id: '+15550000002',
      service: 'iMessage',
    );

    final importResult = await ChatImporter(
      chatDbPath: chatDbPath,
      importDatabase: importDatabase,
    ).importChats();
    await HandleImporter(
      chatDbPath: chatDbPath,
      importDatabase: importDatabase,
    ).importNewHandles();
    await ChatHandleJoinImporter(
      chatDbPath: chatDbPath,
      importDatabase: importDatabase,
    ).importJoins();
    await HandleProjector(
      repository: SqliteHandleProjectionRepository(
        importDatabase: importDatabase,
        workingDatabase: workingDatabase,
      ),
    ).projectHandles();
    await ChatToHandleProjector(
      repository: SqliteChatToHandleProjectionRepository(
        importDatabase: importDatabase,
        workingDatabase: workingDatabase,
      ),
    ).projectEdges();
    final projectionResult = await ChatProjector(
      repository: SqliteChatProjectionRepository(
        importDatabase: importDatabase,
        workingDatabase: workingDatabase,
      ),
    ).projectChats();

    final expectedSsId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 7,
    );
    final importRows = await importDatabase.database.query('chats');
    final workingRows = await workingDatabase.database.query('chats');

    expect(importResult.insertedChatCount, 1);
    expect(projectionResult.insertedChatCount, 1);
    expect(importRows.single['ss_id'], expectedSsId);
    expect(importRows.single['source_id'], liveChatDbSourceId);
    expect(importRows.single['source_rowid'], 7);
    expect(importRows.single['guid'], 'chat-guid');
    expect(importRows.single['service'], 'iMessage');
    expect(importRows.single['group_id'], 'group-id');
    expect(importRows.single['original_group_id'], 'original-group-id');
    expect(importRows.single.keys, isNot(contains('is_group')));
    expect(
      importRows.single['last_read_message_at_utc'],
      DateConverter.appleToIsoString(appleDate),
    );
    expect(importRows.single.keys, isNot(contains('display_name')));
    expect(workingRows.single['ss_id'], expectedSsId);
    expect(workingRows.single['guid'], 'chat-guid');
    expect(workingRows.single['service'], 'iMessage');
    expect(workingRows.single['is_group'], 1);
    expect(
      workingRows.single['last_read_message_at_utc'],
      DateConverter.appleToIsoString(appleDate),
    );
    expect(workingRows.single.keys, isNot(contains('source_id')));
    expect(workingRows.single.keys, isNot(contains('source_rowid')));
    expect(workingRows.single.keys, isNot(contains('batch_id')));
    expect(workingRows.single.keys, isNot(contains('group_id')));
    expect(workingRows.single.keys, isNot(contains('original_group_id')));
  });

  test('projects one-or-zero-handle chats as non-group chats', () async {
    await _insertSourceChat(
      chatDbPath,
      rowId: 7,
      guid: 'one-handle-chat',
      serviceName: 'iMessage',
      lastReadMessageTimestamp: null,
    );
    await _insertSourceChat(
      chatDbPath,
      rowId: 8,
      guid: 'zero-handle-chat',
      serviceName: 'SMS',
      lastReadMessageTimestamp: null,
    );
    await _insertSourceChatHandle(chatDbPath, chatId: 7, handleId: 1);
    await _insertSourceHandle(
      chatDbPath,
      rowId: 1,
      id: '+15550000001',
      service: 'iMessage',
    );

    await ChatImporter(
      chatDbPath: chatDbPath,
      importDatabase: importDatabase,
    ).importChats();
    await HandleImporter(
      chatDbPath: chatDbPath,
      importDatabase: importDatabase,
    ).importNewHandles();
    await ChatHandleJoinImporter(
      chatDbPath: chatDbPath,
      importDatabase: importDatabase,
    ).importJoins();
    await HandleProjector(
      repository: SqliteHandleProjectionRepository(
        importDatabase: importDatabase,
        workingDatabase: workingDatabase,
      ),
    ).projectHandles();
    await ChatToHandleProjector(
      repository: SqliteChatToHandleProjectionRepository(
        importDatabase: importDatabase,
        workingDatabase: workingDatabase,
      ),
    ).projectEdges();

    final projector = ChatProjector(
      repository: SqliteChatProjectionRepository(
        importDatabase: importDatabase,
        workingDatabase: workingDatabase,
      ),
    );
    final first = await projector.projectChats();
    final second = await projector.projectChats();
    final rows = await workingDatabase.database.query(
      'chats',
      orderBy: 'ss_id ASC',
    );

    expect(first.insertedChatCount, 2);
    expect(second.insertedChatCount, 0);
    expect(rows.map((row) => row['is_group']), everyElement(0));
  });

  test('imports topology with raw rowids and canonical endpoints', () async {
    await _insertSourceJoin(chatDbPath, rowId: 99, chatId: 7, messageId: 42);

    final result = await ChatMessageJoinImporter(
      chatDbPath: chatDbPath,
      importDatabase: importDatabase,
    ).importJoins();
    final rows = await importDatabase.database.query('chat_to_message');

    expect(result.insertedJoinCount, 1);
    expect(rows.single['source_chat_rowid'], 7);
    expect(rows.single['source_message_rowid'], 42);
    expect(
      rows.single['chat_ss_id'],
      SourceScopedRowKey.pack(sourceId: liveChatDbSourceId, sourceRowId: 7),
    );
    expect(
      rows.single['message_ss_id'],
      SourceScopedRowKey.pack(sourceId: liveChatDbSourceId, sourceRowId: 42),
    );
  });

  test('projects topology edges idempotently', () async {
    await importDatabase.database.insert('chat_to_message', <String, Object?>{
      'ss_id': SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 99,
      ),
      'source_id': liveChatDbSourceId,
      'source_rowid': 99,
      'source_chat_rowid': 7,
      'source_message_rowid': 42,
      'chat_ss_id': SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 7,
      ),
      'message_ss_id': SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 42,
      ),
    });

    final projector = ChatToMessageProjector(
      repository: SqliteChatToMessageProjectionRepository(
        importDatabase: importDatabase,
        workingDatabase: workingDatabase,
      ),
    );
    final first = await projector.projectEdges();
    final second = await projector.projectEdges();
    final rows = await workingDatabase.database.query('chat_to_message');

    expect(first.insertedEdgeCount, 1);
    expect(second.insertedEdgeCount, 0);
    expect(rows, hasLength(1));
  });

  test('projects topology edges after source message rowid', () async {
    await importDatabase.database.insert('chat_to_message', <String, Object?>{
      'ss_id': SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 98,
      ),
      'source_id': liveChatDbSourceId,
      'source_rowid': 98,
      'source_chat_rowid': 7,
      'source_message_rowid': 40,
      'chat_ss_id': SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 7,
      ),
      'message_ss_id': SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 40,
      ),
    });
    await importDatabase.database.insert('chat_to_message', <String, Object?>{
      'ss_id': SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 99,
      ),
      'source_id': liveChatDbSourceId,
      'source_rowid': 99,
      'source_chat_rowid': 7,
      'source_message_rowid': 42,
      'chat_ss_id': SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 7,
      ),
      'message_ss_id': SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 42,
      ),
    });

    final projector = ChatToMessageProjector(
      repository: SqliteChatToMessageProjectionRepository(
        importDatabase: importDatabase,
        workingDatabase: workingDatabase,
      ),
    );
    final result = await projector.projectEdgesAfterSourceMessageRowId(
      sourceId: liveChatDbSourceId,
      startedAfterSourceRowId: 40,
    );
    final rows = await workingDatabase.database.query('chat_to_message');

    expect(result.examinedEdgeCount, 1);
    expect(result.insertedEdgeCount, 1);
    expect(rows, hasLength(1));
    expect(
      rows.single['message_ss_id'],
      SourceScopedRowKey.pack(sourceId: liveChatDbSourceId, sourceRowId: 42),
    );
  });

  test('working topology primary key prevents duplicate edges', () async {
    final chatSsId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 7,
    );
    final messageSsId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 42,
    );

    await workingDatabase.database.insert('chat_to_message', <String, Object?>{
      'chat_ss_id': chatSsId,
      'message_ss_id': messageSsId,
    });

    await expectLater(
      workingDatabase.database.insert('chat_to_message', <String, Object?>{
        'chat_ss_id': chatSsId,
        'message_ss_id': messageSsId,
      }),
      throwsA(isA<Exception>()),
    );
  });
}

class _FakeChatProjectionRepository implements ChatProjectionRepository {
  _FakeChatProjectionRepository({required this.result});

  final ChatProjectionResult result;
  int callCount = 0;

  @override
  Future<ChatProjectionResult> projectChats() async {
    callCount += 1;
    return result;
  }
}

Future<void> _createSourceTables(String chatDbPath) async {
  final db = await openDatabase(chatDbPath);
  await db.execute('''
    CREATE TABLE chat (
      ROWID INTEGER PRIMARY KEY,
      guid TEXT,
      service_name TEXT,
      group_id TEXT,
      original_group_id TEXT,
      last_read_message_timestamp INTEGER
    )
  ''');
  await db.execute('''
    CREATE TABLE chat_handle_join (
      chat_id INTEGER NOT NULL,
      handle_id INTEGER NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE handle (
      ROWID INTEGER PRIMARY KEY,
      id TEXT NOT NULL,
      service TEXT
    )
  ''');
  await db.execute('''
    CREATE TABLE chat_message_join (
      ROWID INTEGER PRIMARY KEY,
      chat_id INTEGER NOT NULL,
      message_id INTEGER NOT NULL
    )
  ''');
  await db.close();
}

Future<void> _insertSourceHandle(
  String chatDbPath, {
  required int rowId,
  required String id,
  required String service,
}) async {
  final db = await openDatabase(chatDbPath);
  await db.insert('handle', <String, Object?>{
    'ROWID': rowId,
    'id': id,
    'service': service,
  });
  await db.close();
}

Future<void> _insertSourceChat(
  String chatDbPath, {
  required int rowId,
  required String guid,
  required String serviceName,
  String? groupId,
  String? originalGroupId,
  required int? lastReadMessageTimestamp,
}) async {
  final db = await openDatabase(chatDbPath);
  await db.insert('chat', <String, Object?>{
    'ROWID': rowId,
    'guid': guid,
    'service_name': serviceName,
    'group_id': groupId,
    'original_group_id': originalGroupId,
    'last_read_message_timestamp': lastReadMessageTimestamp,
  });
  await db.close();
}

Future<void> _insertSourceChatHandle(
  String chatDbPath, {
  required int chatId,
  required int handleId,
}) async {
  final db = await openDatabase(chatDbPath);
  await db.insert('chat_handle_join', <String, Object?>{
    'chat_id': chatId,
    'handle_id': handleId,
  });
  await db.close();
}

Future<void> _insertSourceJoin(
  String chatDbPath, {
  required int rowId,
  required int chatId,
  required int messageId,
}) async {
  final db = await openDatabase(chatDbPath);
  await db.insert('chat_message_join', <String, Object?>{
    'ROWID': rowId,
    'chat_id': chatId,
    'message_id': messageId,
  });
  await db.close();
}
