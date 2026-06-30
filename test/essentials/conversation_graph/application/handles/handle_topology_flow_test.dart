import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chat_handle_joins/chat_to_handle_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/handles/handle_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/chat_to_handle_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/handle_projection_repository.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/chat_handle_joins/chat_handle_join_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/handles/handle_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/source_database/sqflite_source_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../conversation_graph_test_database.dart';

void main() {
  late Directory tempDir;
  late String chatDbPath;
  late ImportDatabase importLedgerDatabase;
  late ConversationGraphDatabase graphDatabase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('ss_handle_test_');
    chatDbPath = '${tempDir.path}/chat.db';
    importLedgerDatabase = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
    graphDatabase = await openConversationGraphTestDatabase();
    await _createSourceTables(chatDbPath);
  });

  tearDown(() async {
    await graphDatabase.close();
    await importLedgerDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('imports and projects handles with stable ss_id', () async {
    await _insertSourceHandle(
      chatDbPath,
      rowId: 12,
      id: '+15550000012',
      service: 'iMessage',
    );

    final importResult = await HandleImporter(
      chatDbPath: chatDbPath,
      importLedger: importLedgerDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    ).importNewHandles();
    final projectionResult = await HandleProjector(
      repository: SqliteHandleProjectionRepository(
        importLedgerDatabase: importLedgerDatabase,
        graphDatabase: graphDatabase,
      ),
    ).projectHandles();

    final expectedSsId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 12,
    );
    final importRows = await importLedgerDatabase.database.query('handles');
    final workingRows = await graphDatabase.database.query('handles');

    expect(importResult.startedAfterSourceRowId, 0);
    expect(importResult.insertedHandleCount, 1);
    expect(projectionResult.insertedHandleCount, 1);
    expect(importRows.single['ss_id'], expectedSsId);
    expect(importRows.single['source_id'], liveChatDbSourceId);
    expect(importRows.single['source_rowid'], 12);
    expect(importRows.single['id'], '+15550000012');
    expect(workingRows.single['ss_id'], expectedSsId);
    expect(workingRows.single['id'], '+15550000012');
    expect(workingRows.single.keys, isNot(contains('source_id')));
    expect(workingRows.single.keys, isNot(contains('source_rowid')));
    expect(workingRows.single.keys, isNot(contains('batch_id')));

    final aliases = await graphDatabase.database.query('handle_aliases');
    final canonicalHandles = await graphDatabase.database.query(
      'canonical_handles',
    );
    expect(aliases.single['handle_ss_id'], expectedSsId);
    expect(aliases.single['canonical_handle_ss_id'], expectedSsId);
    expect(canonicalHandles.single['canonical_handle_ss_id'], expectedSsId);
  });

  test(
    'projects normalized handle aliases above source handle identity',
    () async {
      await _insertSourceHandle(
        chatDbPath,
        rowId: 12,
        id: '+16049995969',
        service: 'iMessage',
      );
      await _insertSourceHandle(
        chatDbPath,
        rowId: 13,
        id: '6049995969',
        service: 'SMS',
      );

      await HandleImporter(
        chatDbPath: chatDbPath,
        importLedger: importLedgerDatabase,
        sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
      ).importNewHandles();
      await HandleProjector(
        repository: SqliteHandleProjectionRepository(
          importLedgerDatabase: importLedgerDatabase,
          graphDatabase: graphDatabase,
        ),
      ).projectHandles();

      final firstSsId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 12,
      );
      final secondSsId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 13,
      );
      final handles = await graphDatabase.database.query('handles');
      final canonicalHandles = await graphDatabase.database.query(
        'canonical_handles',
      );
      final aliases = await graphDatabase.database.query(
        'handle_aliases',
        orderBy: 'handle_ss_id ASC',
      );

      expect(handles, hasLength(2));
      expect(canonicalHandles, hasLength(1));
      expect(canonicalHandles.single['canonical_handle_ss_id'], firstSsId);
      expect(canonicalHandles.single['alias_count'], 2);
      expect(aliases.map((row) => row['handle_ss_id']), [
        firstSsId,
        secondSsId,
      ]);
      expect(aliases.map((row) => row['canonical_handle_ss_id']).toSet(), {
        firstSsId,
      });
    },
  );

  test('handle import is idempotent and source-scoped', () async {
    await _insertLedgerHandle(
      importLedgerDatabase,
      sourceId: 3,
      sourceRowId: 999999,
    );
    await _insertSourceHandle(
      chatDbPath,
      rowId: 5,
      id: '+15550000005',
      service: 'SMS',
    );

    final importer = HandleImporter(
      chatDbPath: chatDbPath,
      importLedger: importLedgerDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    );
    final first = await importer.importNewHandles();
    final second = await importer.importNewHandles();

    expect(first.startedAfterSourceRowId, 0);
    expect(first.insertedHandleCount, 1);
    expect(second.startedAfterSourceRowId, 5);
    expect(second.insertedHandleCount, 0);
  });

  test('imports and projects chat-to-handle topology idempotently', () async {
    await _insertSourceChatHandle(chatDbPath, chatId: 7, handleId: 12);

    final importResult = await ChatHandleJoinImporter(
      chatDbPath: chatDbPath,
      importLedger: importLedgerDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    ).importJoins();
    final projector = ChatToHandleProjector(
      repository: SqliteChatToHandleProjectionRepository(
        importLedgerDatabase: importLedgerDatabase,
        graphDatabase: graphDatabase,
      ),
    );
    final firstProjection = await projector.projectEdges();
    final secondProjection = await projector.projectEdges();
    final importRows = await importLedgerDatabase.database.query(
      'chat_to_handle',
    );
    final workingRows = await graphDatabase.database.query('chat_to_handle');

    final chatSsId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 7,
    );
    final handleSsId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 12,
    );

    expect(importResult.insertedJoinCount, 1);
    expect(firstProjection.insertedEdgeCount, 1);
    expect(secondProjection.insertedEdgeCount, 0);
    expect(importRows.single['source_chat_rowid'], 7);
    expect(importRows.single['source_handle_rowid'], 12);
    expect(importRows.single['chat_ss_id'], chatSsId);
    expect(importRows.single['handle_ss_id'], handleSsId);
    expect(workingRows.single['chat_ss_id'], chatSsId);
    expect(workingRows.single['handle_ss_id'], handleSsId);
  });
}

Future<void> _createSourceTables(String chatDbPath) async {
  final db = await openDatabase(chatDbPath);
  await db.execute('''
    CREATE TABLE handle (
      ROWID INTEGER PRIMARY KEY,
      id TEXT NOT NULL,
      service TEXT
    )
  ''');
  await db.execute('''
    CREATE TABLE chat_handle_join (
      chat_id INTEGER NOT NULL,
      handle_id INTEGER NOT NULL
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

Future<void> _insertLedgerHandle(
  ImportDatabase importLedgerDatabase, {
  required int sourceId,
  required int sourceRowId,
}) async {
  await importLedgerDatabase.database
      .insert('source_registry', <String, Object?>{
        'source_id': sourceId,
        'source_key': 'source-$sourceId',
        'source_kind': 'archive_chat_db',
        'created_at_utc': DateTime.now().toUtc().toIso8601String(),
      });
  final batchId = await importLedgerDatabase.insertImportBatch(
    sourceId: sourceId,
    startedAtUtc: DateTime.now().toUtc().toIso8601String(),
  );
  await importLedgerDatabase.database.insert('handles', <String, Object?>{
    'ss_id': SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: sourceRowId,
    ),
    'source_id': sourceId,
    'source_rowid': sourceRowId,
    'id': 'archive-handle',
    'batch_id': batchId,
  });
}
