import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chat_handle_joins/chat_to_handle_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/handles/handle_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/chat_to_handle_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/handle_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/message_projection_repository.dart';
import 'package:remember_this_text/essentials/db/shared/handle_identifier_utils.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/chat_handle_joins/chat_handle_join_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/handles/handle_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/source_import_work_progress.dart';
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
    expect(importResult.normalizedHandleCount, 1);
    expect(importResult.preservedUnnormalizedHandleCount, 0);
    expect(projectionResult.normalizedHandleCount, 1);
    expect(projectionResult.preservedUnnormalizedHandleCount, 0);
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

  test('marks local account handles without reimporting messages', () async {
    await _insertSourceHandle(
      chatDbPath,
      rowId: 12,
      id: '+16046858506',
      service: 'iMessage',
    );
    await _insertSourceHandle(
      chatDbPath,
      rowId: 13,
      id: '+16045550123',
      service: 'iMessage',
    );
    final importer = HandleImporter(
      chatDbPath: chatDbPath,
      importLedger: importLedgerDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    );
    final projector = HandleProjector(
      repository: SqliteHandleProjectionRepository(
        importLedgerDatabase: importLedgerDatabase,
        graphDatabase: graphDatabase,
      ),
    );
    await importer.importNewHandles();
    await projector.projectHandles();
    await _insertSourceAccountEvidence(
      chatDbPath,
      accountLogin: 'E:',
      destinationCallerId: 'tel:+16046858506',
    );

    final reconciliationResult = await importer.reconcileLocalAccountIdentity();
    final projectionResult = await projector.projectLocalAccountIdentity();

    final importRows = await importLedgerDatabase.database.query(
      'handles',
      orderBy: 'source_rowid ASC',
    );
    final graphRows = await graphDatabase.database.query(
      'handles',
      orderBy: 'ss_id ASC',
    );

    expect(reconciliationResult.examinedHandleCount, 2);
    expect(reconciliationResult.localAccountHandleCount, 1);
    expect(reconciliationResult.updatedHandleCount, 1);
    expect(projectionResult.examinedHandleCount, 2);
    expect(projectionResult.updatedHandleCount, 1);
    expect(importRows.map((row) => row['is_me']), [1, 0]);
    expect(graphRows.map((row) => row['is_me']), [1, 0]);
  });

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

  test('handle import reports start and completed source row', () async {
    await _insertSourceHandle(
      chatDbPath,
      rowId: 5,
      id: '*city*',
      service: 'SMS',
    );
    final observations = <SourceImportWorkProgress>[];

    final result = await HandleImporter(
      chatDbPath: chatDbPath,
      importLedger: importLedgerDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    ).importNewHandles(onProgress: observations.add);

    expect(observations, hasLength(2));
    expect(observations.first.completedWorkCount, 0);
    expect(observations.first.totalWorkCount, 1);
    expect(observations.last.completedWorkCount, 1);
    expect(observations.last.lastCompletedSourceRowId, 5);
    expect(observations.last.preservedUnnormalizedCount, 1);
    expect(result.examinedHandleCount, 1);
    expect(result.normalizedHandleCount, 0);
    expect(result.preservedUnnormalizedHandleCount, 1);
  });

  test(
    'preserves identical unnormalized handles as distinct identities',
    () async {
      await _insertSourceHandle(
        chatDbPath,
        rowId: 12,
        id: '*city*',
        service: 'SMS',
      );
      await _insertSourceHandle(
        chatDbPath,
        rowId: 13,
        id: '*city*',
        service: 'SMS',
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

      final handles = await graphDatabase.database.query(
        'handles',
        orderBy: 'ss_id ASC',
      );
      final aliases = await graphDatabase.database.query('handle_aliases');
      final canonicalHandles = await graphDatabase.database.query(
        'canonical_handles',
      );

      expect(importResult.preservedUnnormalizedHandleCount, 2);
      expect(projectionResult.preservedUnnormalizedHandleCount, 2);
      expect(handles, hasLength(2));
      expect(handles.map((row) => row['ss_id']).toSet(), hasLength(2));
      expect(handles.map((row) => row['id']), everyElement('*city*'));
      expect(aliases, isEmpty);
      expect(canonicalHandles, isEmpty);
    },
  );

  test(
    'typed normalization rejection preserves usable source identity',
    () async {
      const rawIdentifier = 'private-service-token';
      await _insertSourceHandle(
        chatDbPath,
        rowId: 27,
        id: rawIdentifier,
        service: 'iMessage',
      );

      final result = await HandleImporter(
        chatDbPath: chatDbPath,
        importLedger: importLedgerDatabase,
        sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
        handleIdentifierInterpreter: (_) {
          throw const HandleIdentifierNormalizationException('unsupported');
        },
      ).importNewHandles();

      final rows = await importLedgerDatabase.database.query('handles');
      expect(result.preservedUnnormalizedHandleCount, 1);
      expect(
        rows.single['ss_id'],
        SourceScopedRowKey.pack(sourceId: 1, sourceRowId: 27),
      );
      expect(rows.single['id'], rawIdentifier);
      expect(result.toString(), isNot(contains(rawIdentifier)));
    },
  );

  test(
    'reprojection clears obsolete canonical semantics for opaque handle',
    () async {
      await _insertSourceHandle(
        chatDbPath,
        rowId: 12,
        id: '*city*',
        service: 'SMS',
      );
      await HandleImporter(
        chatDbPath: chatDbPath,
        importLedger: importLedgerDatabase,
        sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
      ).importNewHandles();
      final handleSsId = SourceScopedRowKey.pack(sourceId: 1, sourceRowId: 12);
      await graphDatabase.database.insert('handles', <String, Object?>{
        'ss_id': handleSsId,
        'id': '*city*',
        'service': 'SMS',
      });
      await graphDatabase.database
          .insert('canonical_handles', <String, Object?>{
            'canonical_handle_ss_id': handleSsId,
            'display_handle': '*city*',
            'normalized_identifier': '*city*',
            'service': 'SMS',
            'alias_count': 1,
          });
      await graphDatabase.database.insert('handle_aliases', <String, Object?>{
        'handle_ss_id': handleSsId,
        'canonical_handle_ss_id': handleSsId,
        'raw_identifier': '*city*',
        'normalized_identifier': '*city*',
        'alias_kind': 'canonical',
      });
      await graphDatabase.database.insert('messages', <String, Object?>{
        'ss_id': 101,
        'guid': 'stale-canonical-message',
        'sender_handle_ss_id': handleSsId,
        'sender_canonical_handle_ss_id': handleSsId,
        'is_from_me': 0,
      });
      await graphDatabase.database.insert('contacts', <String, Object?>{
        'contact_id': 202,
        'display_name': 'Stale Match',
      });
      await graphDatabase.database.insert(
        'contact_to_handle',
        <String, Object?>{
          'contact_id': 202,
          'handle_ss_id': handleSsId,
          'handle_value': '*city*',
        },
      );

      await HandleProjector(
        repository: SqliteHandleProjectionRepository(
          importLedgerDatabase: importLedgerDatabase,
          graphDatabase: graphDatabase,
        ),
      ).projectHandles();

      expect(await graphDatabase.database.query('handle_aliases'), isEmpty);
      expect(await graphDatabase.database.query('canonical_handles'), isEmpty);
      final messages = await graphDatabase.database.query('messages');
      expect(messages.single['sender_handle_ss_id'], handleSsId);
      expect(messages.single['sender_canonical_handle_ss_id'], isNull);
      expect(await graphDatabase.database.query('contact_to_handle'), isEmpty);
    },
  );

  test('opaque handle keeps chat and message relationships usable', () async {
    await _insertSourceHandle(
      chatDbPath,
      rowId: 12,
      id: '*city*',
      service: 'SMS',
    );
    await _insertSourceChatHandle(chatDbPath, chatId: 7, handleId: 12);
    await _insertSourceMessage(
      chatDbPath,
      rowId: 101,
      guid: 'opaque-handle-message',
      handleId: 12,
      text: 'Message evidence remains available.',
    );

    final handleImporter = HandleImporter(
      chatDbPath: chatDbPath,
      importLedger: importLedgerDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    );
    final handleImportResult = await handleImporter.importNewHandles();
    final messageImportResult = await MessageImporter(
      chatDbPath: chatDbPath,
      importLedger: importLedgerDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    ).importNewMessages();
    await ChatHandleJoinImporter(
      chatDbPath: chatDbPath,
      importLedger: importLedgerDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    ).importJoins();

    final handleSsId = SourceScopedRowKey.pack(sourceId: 1, sourceRowId: 12);
    final chatSsId = SourceScopedRowKey.pack(sourceId: 1, sourceRowId: 7);
    await graphDatabase.database.insert('chats', <String, Object?>{
      'ss_id': chatSsId,
      'guid': 'chat-7',
      'is_group': 0,
    });
    await HandleProjector(
      repository: SqliteHandleProjectionRepository(
        importLedgerDatabase: importLedgerDatabase,
        graphDatabase: graphDatabase,
      ),
    ).projectHandles();
    await ChatToHandleProjector(
      repository: SqliteChatToHandleProjectionRepository(
        importLedgerDatabase: importLedgerDatabase,
        graphDatabase: graphDatabase,
      ),
    ).projectEdges();
    await SqliteMessageProjectionRepository(
      importLedgerDatabase: importLedgerDatabase,
      graphDatabase: graphDatabase,
    ).projectMessages();

    final edges = await graphDatabase.database.query('chat_to_handle');
    final messages = await graphDatabase.database.query('messages');
    expect(handleImportResult.preservedUnnormalizedHandleCount, 1);
    expect(messageImportResult.insertedMessageCount, 1);
    expect(edges.single['chat_ss_id'], chatSsId);
    expect(edges.single['handle_ss_id'], handleSsId);
    expect(messages.single['sender_handle_ss_id'], handleSsId);
    expect(messages.single['sender_canonical_handle_ss_id'], isNull);
    expect(messages.single['text'], 'Message evidence remains available.');
  });

  test('malformed handle stops with bounded source row context', () async {
    await _insertSourceHandle(chatDbPath, rowId: 19, id: null, service: 'SMS');
    final observations = <SourceImportWorkProgress>[];

    await expectLater(
      HandleImporter(
        chatDbPath: chatDbPath,
        importLedger: importLedgerDatabase,
        sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
      ).importNewHandles(onProgress: observations.add),
      throwsA(
        isA<SourceImportRecordException>()
            .having((error) => error.unit, 'unit', SourceImportWorkUnit.handles)
            .having((error) => error.sourceRowId, 'source ROWID', 19),
      ),
    );

    expect(observations, hasLength(1));
    expect(observations.single.completedWorkCount, 0);
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
      id TEXT,
      service TEXT
    )
  ''');
  await db.execute('''
    CREATE TABLE chat_handle_join (
      chat_id INTEGER NOT NULL,
      handle_id INTEGER NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE chat (
      ROWID INTEGER PRIMARY KEY,
      account_login TEXT
    )
  ''');
  await db.execute('''
    CREATE TABLE message (
      ROWID INTEGER PRIMARY KEY,
      guid TEXT,
      handle_id INTEGER,
      is_from_me INTEGER NOT NULL,
      date INTEGER,
      text TEXT,
      destination_caller_id TEXT
    )
  ''');
  await db.close();
}

Future<void> _insertSourceMessage(
  String chatDbPath, {
  required int rowId,
  required String guid,
  required int handleId,
  required String text,
}) async {
  final db = await openDatabase(chatDbPath);
  await db.insert('message', <String, Object?>{
    'ROWID': rowId,
    'guid': guid,
    'handle_id': handleId,
    'is_from_me': 0,
    'date': 0,
    'text': text,
  });
  await db.close();
}

Future<void> _insertSourceAccountEvidence(
  String chatDbPath, {
  required String accountLogin,
  required String destinationCallerId,
}) async {
  final db = await openDatabase(chatDbPath);
  await db.insert('chat', <String, Object?>{
    'ROWID': 1,
    'account_login': accountLogin,
  });
  await db.insert('message', <String, Object?>{
    'ROWID': 1,
    'is_from_me': 0,
    'destination_caller_id': destinationCallerId,
  });
  await db.close();
}

Future<void> _insertSourceHandle(
  String chatDbPath, {
  required int rowId,
  required String? id,
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
