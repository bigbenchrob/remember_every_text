import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/conversation_graph/application/archives/source_scoped_archive_graph_import_service.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/archives/source_scoped_archive_graph_removal_service.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/attachments/attachment_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chat_handle_joins/chat_to_handle_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chat_message_joins/chat_to_message_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chats/chat_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/handles/handle_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/message_attachment_joins/message_to_attachment_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/attachment_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/chat_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/chat_to_handle_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/chat_to_message_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/contact_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/handle_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/message_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/message_to_attachment_projection_repository.dart';
import 'package:remember_this_text/essentials/db_importers/domain/ports/message_extractor_port.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/archives/historical_messages_archive_source_registrar.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/archives/source_scoped_archive_import_service.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../conversation_graph_test_database.dart';

void main() {
  late Directory tempDir;
  late Directory archiveFolder;
  late String chatDbPath;
  late ImportDatabase importDatabase;
  late ConversationGraphDatabase graphDatabase;
  late SourceScopedArchiveGraphImportService service;
  late SourceScopedArchiveGraphRemovalService removalService;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'source_scoped_archive_graph_import_service_test_',
    );
    archiveFolder = Directory(path.join(tempDir.path, 'Archive-2017'));
    await archiveFolder.create(recursive: true);
    chatDbPath = path.join(archiveFolder.path, 'chat.db');
    await _createArchiveChatDb(chatDbPath);
    await _insertArchiveRows(chatDbPath);

    importDatabase = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
    graphDatabase = await openConversationGraphTestDatabase();
    final importService = SourceScopedArchiveImportService(
      registrar: HistoricalMessagesArchiveSourceRegistrar(
        importDatabase: importDatabase,
      ),
      richTextExtractor: const _FakeExtractor(<int, String>{
        300: 'enriched archive message',
      }),
    );
    service = SourceScopedArchiveGraphImportService(
      importService: importService,
      handleProjector: HandleProjector(
        repository: SqliteHandleProjectionRepository(
          importDatabase: importDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      chatToHandleProjector: ChatToHandleProjector(
        repository: SqliteChatToHandleProjectionRepository(
          importDatabase: importDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      chatProjector: ChatProjector(
        repository: SqliteChatProjectionRepository(
          importDatabase: importDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      messageProjector: MessageProjector(
        repository: SqliteMessageProjectionRepository(
          importDatabase: importDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      attachmentProjector: AttachmentProjector(
        repository: SqliteAttachmentProjectionRepository(
          importDatabase: importDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      chatToMessageProjector: ChatToMessageProjector(
        repository: SqliteChatToMessageProjectionRepository(
          importDatabase: importDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      messageToAttachmentProjector: MessageToAttachmentProjector(
        repository: SqliteMessageToAttachmentProjectionRepository(
          importDatabase: importDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
    );
    removalService = SourceScopedArchiveGraphRemovalService(
      importDatabase: importDatabase,
      graphDatabase: graphDatabase,
      handleProjector: HandleProjector(
        repository: SqliteHandleProjectionRepository(
          importDatabase: importDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      contactProjector: ContactProjector(
        repository: SqliteContactProjectionRepository(
          importDatabase: importDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      chatToHandleProjector: ChatToHandleProjector(
        repository: SqliteChatToHandleProjectionRepository(
          importDatabase: importDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      chatProjector: ChatProjector(
        repository: SqliteChatProjectionRepository(
          importDatabase: importDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      messageProjector: MessageProjector(
        repository: SqliteMessageProjectionRepository(
          importDatabase: importDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      attachmentProjector: AttachmentProjector(
        repository: SqliteAttachmentProjectionRepository(
          importDatabase: importDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      chatToMessageProjector: ChatToMessageProjector(
        repository: SqliteChatToMessageProjectionRepository(
          importDatabase: importDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      messageToAttachmentProjector: MessageToAttachmentProjector(
        repository: SqliteMessageToAttachmentProjectionRepository(
          importDatabase: importDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
    );
  });

  tearDown(() async {
    await graphDatabase.close();
    await importDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('imports and projects archive facts into the graph', () async {
    final firstResult = await service.importAndProject(
      folderPath: archiveFolder.path,
      sourceLabel: 'Archive 2017',
    );
    final secondResult = await service.importAndProject(
      folderPath: archiveFolder.path,
      sourceLabel: 'Archive 2017',
    );
    final sourceId = firstResult.importResult.registration.sourceId;
    final messageSsId = SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: 300,
    );
    final chatSsId = SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: 100,
    );
    final handleSsId = SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: 200,
    );
    final attachmentSsId = SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: 400,
    );

    expect(firstResult.projectionResult.insertedGraphNodeCount, 4);
    expect(firstResult.projectionResult.insertedGraphEdgeCount, 3);
    expect(secondResult.projectionResult.insertedGraphNodeCount, 0);
    expect(secondResult.projectionResult.insertedGraphEdgeCount, 0);

    final messages = await graphDatabase.database.query('messages');
    final chats = await graphDatabase.database.query('chats');
    final handles = await graphDatabase.database.query('handles');
    final attachments = await graphDatabase.database.query('attachments');
    final chatMessageEdges = await graphDatabase.database.query(
      'chat_to_message',
    );
    final chatHandleEdges = await graphDatabase.database.query(
      'chat_to_handle',
    );
    final messageAttachmentEdges = await graphDatabase.database.query(
      'message_to_attachment',
    );

    expect(messages, hasLength(1));
    expect(messages.single['ss_id'], messageSsId);
    expect(messages.single['text'], 'enriched archive message');
    expect(messages.single['sender_handle_ss_id'], handleSsId);
    expect(messages.single['sender_canonical_handle_ss_id'], handleSsId);
    expect(chats.single['ss_id'], chatSsId);
    expect(handles.single['ss_id'], handleSsId);
    expect(attachments.single['ss_id'], attachmentSsId);
    expect(chatMessageEdges.single['chat_ss_id'], chatSsId);
    expect(chatMessageEdges.single['message_ss_id'], messageSsId);
    expect(chatHandleEdges.single['chat_ss_id'], chatSsId);
    expect(chatHandleEdges.single['handle_ss_id'], handleSsId);
    expect(messageAttachmentEdges.single['message_ss_id'], messageSsId);
    expect(messageAttachmentEdges.single['attachment_ss_id'], attachmentSsId);
  });

  test(
    'removes one archive source from import facts and graph projection',
    () async {
      final importResult = await service.importAndProject(
        folderPath: archiveFolder.path,
        sourceLabel: 'Archive 2017',
      );
      final sourceId = importResult.importResult.registration.sourceId;

      expect(await _countGraphRows(graphDatabase, 'messages'), 1);
      expect(await _countImportRows(importDatabase, 'messages'), 1);

      final removalResult = await removalService.removeArchiveSource(
        folderPath: archiveFolder.path,
      );

      expect(removalResult.sourceId, sourceId);
      expect(removalResult.sourceWasRegistered, isTrue);
      expect(removalResult.deletedSourceFactCount, 4);
      expect(removalResult.deletedTopologyEdgeCount, 3);
      expect(removalResult.graphReprojected, isTrue);

      for (final tableName in <String>[
        'messages',
        'chats',
        'handles',
        'attachments',
        'chat_to_message',
        'chat_to_handle',
        'message_to_attachment',
      ]) {
        expect(await _countGraphRows(graphDatabase, tableName), 0);
        expect(await _countImportRows(importDatabase, tableName), 0);
      }

      final registryRows = await importDatabase.database.query(
        'source_registry',
        where: 'source_id = ?',
        whereArgs: <Object?>[sourceId],
      );
      expect(registryRows, hasLength(1));

      final reimportResult = await service.importAndProject(
        folderPath: archiveFolder.path,
        sourceLabel: 'Archive 2017',
      );
      expect(reimportResult.importResult.registration.sourceId, sourceId);
      expect(await _countGraphRows(graphDatabase, 'messages'), 1);
    },
  );
}

Future<void> _createArchiveChatDb(String chatDbPath) async {
  final db = await openDatabase(chatDbPath);
  await db.execute('''
    CREATE TABLE chat (
      ROWID INTEGER PRIMARY KEY,
      guid TEXT NOT NULL,
      service_name TEXT,
      group_id TEXT,
      original_group_id TEXT,
      last_read_message_timestamp INTEGER
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
    CREATE TABLE message (
      ROWID INTEGER PRIMARY KEY,
      guid TEXT NOT NULL,
      handle_id INTEGER,
      is_from_me INTEGER NOT NULL,
      date INTEGER,
      date_read INTEGER,
      date_delivered INTEGER,
      text TEXT,
      attributedBody BLOB,
      associated_message_guid TEXT,
      item_type INTEGER,
      associated_message_type INTEGER,
      thread_originator_guid TEXT,
      error INTEGER,
      is_system_message INTEGER,
      message_summary_info BLOB,
      payload_data BLOB
    )
  ''');
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
  await db.execute('''
    CREATE TABLE chat_message_join (
      ROWID INTEGER PRIMARY KEY,
      chat_id INTEGER NOT NULL,
      message_id INTEGER NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE chat_handle_join (
      chat_id INTEGER NOT NULL,
      handle_id INTEGER NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE message_attachment_join (
      message_id INTEGER NOT NULL,
      attachment_id INTEGER NOT NULL
    )
  ''');
  await db.close();
}

Future<void> _insertArchiveRows(String chatDbPath) async {
  final db = await openDatabase(chatDbPath);
  await db.insert('chat', <String, Object?>{
    'ROWID': 100,
    'guid': 'archive-chat-guid',
    'service_name': 'iMessage',
    'group_id': 'archive-group',
  });
  await db.insert('handle', <String, Object?>{
    'ROWID': 200,
    'id': '+16045550100',
    'service': 'iMessage',
  });
  await db.insert('message', <String, Object?>{
    'ROWID': 300,
    'guid': 'archive-message-guid',
    'handle_id': 200,
    'is_from_me': 0,
    'text': null,
    'attributedBody': Uint8List.fromList(<int>[1, 2, 3]),
  });
  await db.insert('attachment', <String, Object?>{
    'ROWID': 400,
    'guid': 'archive-attachment-guid',
    'filename': 'Attachments/photo.jpg',
    'transfer_name': 'photo.jpg',
    'uti': 'public.jpeg',
    'mime_type': 'image/jpeg',
    'total_bytes': 1234,
  });
  await db.insert('chat_message_join', <String, Object?>{
    'ROWID': 500,
    'chat_id': 100,
    'message_id': 300,
  });
  await db.insert('chat_handle_join', <String, Object?>{
    'chat_id': 100,
    'handle_id': 200,
  });
  await db.insert('message_attachment_join', <String, Object?>{
    'message_id': 300,
    'attachment_id': 400,
  });
  await db.close();
}

class _FakeExtractor implements MessageExtractorPort {
  const _FakeExtractor(this.extracted);

  final Map<int, String> extracted;

  @override
  Future<Map<int, String>> extractAllMessageTexts({
    int? limit,
    String? dbPath,
  }) async {
    throw StateError('Archive import enrichment must decode import blobs');
  }

  @override
  Future<Map<int, String>> extractMessageTextsFromBlobs(
    Map<int, Uint8List> attributedBodyBlobsByRowId,
  ) async {
    return Map<int, String>.fromEntries(
      extracted.entries.where(
        (entry) => attributedBodyBlobsByRowId.containsKey(entry.key),
      ),
    );
  }

  @override
  Future<bool> isAvailable() async {
    return true;
  }

  @override
  Future<bool> isBlobExtractionAvailable() async {
    return true;
  }
}

Future<int> _countGraphRows(
  ConversationGraphDatabase graphDatabase,
  String tableName,
) async {
  final rows = await graphDatabase.database.rawQuery(
    'SELECT COUNT(*) AS row_count FROM $tableName',
  );
  return rows.single['row_count'] as int? ?? 0;
}

Future<int> _countImportRows(
  ImportDatabase importDatabase,
  String tableName,
) async {
  final rows = await importDatabase.database.rawQuery(
    'SELECT COUNT(*) AS row_count FROM $tableName',
  );
  return rows.single['row_count'] as int? ?? 0;
}
