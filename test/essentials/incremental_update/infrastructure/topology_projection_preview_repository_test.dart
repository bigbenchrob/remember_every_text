import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/source_identity.dart';
import 'package:remember_this_text/essentials/incremental_update/infrastructure/topology_projection_preview_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late SqfliteImportDatabase ledgerDb;
  late WorkingDatabase workingDb;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'topology_projection_preview_repository_test_',
    );
    ledgerDb = SqfliteImportDatabase(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_shadow.db',
      debugSettings: const ImportDebugSettingsState(),
    );
    workingDb = WorkingDatabase(NativeDatabase.memory());
    await workingDb.customStatement('PRAGMA foreign_keys = ON');
  });

  tearDown(() async {
    await workingDb.close();
    await ledgerDb.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'resolves source topology endpoints through ledger and working rows',
    () async {
      final batchId = await ledgerDb.insertImportBatch(
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );
      await _insertLedgerChat(
        ledgerDb,
        batchId: batchId,
        id: 2,
        guid: 'chat-guid',
      );
      await _insertLedgerMessage(
        ledgerDb,
        batchId: batchId,
        id: 3,
        sourceChatId: 2,
        guid: 'message-guid',
      );
      await _insertLedgerTopology(
        ledgerDb,
        batchId: batchId,
        sourceJoinRowId: 1,
        sourceChatRowId: 2,
        sourceMessageRowId: 3,
      );
      await _insertWorkingChat(workingDb, id: 200, guid: 'chat-guid');
      await _insertWorkingMessage(
        workingDb,
        id: 100,
        guid: 'message-guid',
        chatId: 200,
      );

      final repository = TopologyProjectionPreviewRepository(
        ledgerDb: ledgerDb,
        workingDb: workingDb,
      );

      final facts = await repository.readPreviewFacts();

      expect(facts, hasLength(1));
      expect(facts.single.sourceId, liveChatDbSourceIdentity.sourceId);
      expect(facts.single.sourceJoinRowId, 1);
      expect(facts.single.sourceChatRowId, 2);
      expect(facts.single.sourceMessageRowId, 3);
      expect(facts.single.ledgerMessageId, 3);
      expect(facts.single.ledgerMessageGuid, 'message-guid');
      expect(facts.single.ledgerChatId, 2);
      expect(facts.single.ledgerChatGuid, 'chat-guid');
      expect(facts.single.workingMessageIds, <int>[100]);
      expect(facts.single.workingChatIds, <int>[200]);
    },
  );

  test(
    'resolves working chat by guid when ledger display name is absent',
    () async {
      final batchId = await ledgerDb.insertImportBatch(
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );
      await _insertLedgerChat(
        ledgerDb,
        batchId: batchId,
        id: 2,
        guid: 'chat-guid-without-display-name',
        displayName: null,
      );
      await _insertLedgerMessage(
        ledgerDb,
        batchId: batchId,
        id: 3,
        sourceChatId: 2,
        guid: 'message-guid',
      );
      await _insertLedgerTopology(
        ledgerDb,
        batchId: batchId,
        sourceJoinRowId: 1,
        sourceChatRowId: 2,
        sourceMessageRowId: 3,
      );
      await _insertWorkingChat(
        workingDb,
        id: 200,
        guid: 'chat-guid-without-display-name',
      );
      await _insertWorkingMessage(
        workingDb,
        id: 100,
        guid: 'message-guid',
        chatId: 200,
      );

      final repository = TopologyProjectionPreviewRepository(
        ledgerDb: ledgerDb,
        workingDb: workingDb,
      );

      final facts = await repository.readPreviewFacts();

      expect(facts.single.ledgerChatGuid, 'chat-guid-without-display-name');
      expect(facts.single.workingChatIds, <int>[200]);
    },
  );

  test('reports missing ledger message without mutating working db', () async {
    final batchId = await ledgerDb.insertImportBatch(
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );
    await _insertLedgerChat(
      ledgerDb,
      batchId: batchId,
      id: 2,
      guid: 'chat-guid',
    );
    await _insertLedgerTopology(
      ledgerDb,
      batchId: batchId,
      sourceJoinRowId: 1,
      sourceChatRowId: 2,
      sourceMessageRowId: 3,
    );
    await _insertWorkingChat(workingDb, id: 200, guid: 'chat-guid');

    final before = await _workingRowCounts(workingDb);
    final repository = TopologyProjectionPreviewRepository(
      ledgerDb: ledgerDb,
      workingDb: workingDb,
    );

    final facts = await repository.readPreviewFacts();
    final after = await _workingRowCounts(workingDb);

    expect(facts.single.ledgerMessageId, isNull);
    expect(facts.single.ledgerChatId, 2);
    expect(after, before);
  });

  test('reports missing ledger chat', () async {
    final batchId = await ledgerDb.insertImportBatch(
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );
    await _insertPlaceholderLedgerChat(ledgerDb, batchId: batchId);
    await _insertLedgerMessage(
      ledgerDb,
      batchId: batchId,
      id: 3,
      sourceChatId: -1,
      guid: 'message-guid',
    );
    await _insertLedgerTopology(
      ledgerDb,
      batchId: batchId,
      sourceJoinRowId: 1,
      sourceChatRowId: 2,
      sourceMessageRowId: 3,
    );

    final repository = TopologyProjectionPreviewRepository(
      ledgerDb: ledgerDb,
      workingDb: workingDb,
    );

    final facts = await repository.readPreviewFacts();

    expect(facts.single.ledgerMessageId, 3);
    expect(facts.single.ledgerChatId, isNull);
  });

  test(
    'reports missing working message and missing working chat endpoints',
    () async {
      final batchId = await ledgerDb.insertImportBatch(
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );
      await _insertLedgerChat(
        ledgerDb,
        batchId: batchId,
        id: 2,
        guid: 'chat-guid',
      );
      await _insertLedgerMessage(
        ledgerDb,
        batchId: batchId,
        id: 3,
        sourceChatId: 2,
        guid: 'message-guid',
      );
      await _insertLedgerTopology(
        ledgerDb,
        batchId: batchId,
        sourceJoinRowId: 1,
        sourceChatRowId: 2,
        sourceMessageRowId: 3,
      );

      final repository = TopologyProjectionPreviewRepository(
        ledgerDb: ledgerDb,
        workingDb: workingDb,
      );

      final facts = await repository.readPreviewFacts();

      expect(facts.single.ledgerMessageGuid, 'message-guid');
      expect(facts.single.ledgerChatGuid, 'chat-guid');
      expect(facts.single.workingMessageIds, isEmpty);
      expect(facts.single.workingChatIds, isEmpty);
    },
  );

  test('ignores topology rows from a fake archive source', () async {
    final batchId = await ledgerDb.insertImportBatch(
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );
    await _insertLedgerChat(
      ledgerDb,
      batchId: batchId,
      id: 2,
      guid: 'chat-guid',
    );
    await _insertLedgerMessage(
      ledgerDb,
      batchId: batchId,
      id: 3,
      sourceChatId: 2,
      guid: 'message-guid',
    );
    await _insertLedgerTopology(
      ledgerDb,
      batchId: batchId,
      sourceJoinRowId: 1,
      sourceChatRowId: 2,
      sourceMessageRowId: 3,
    );
    await _insertLedgerTopology(
      ledgerDb,
      batchId: batchId,
      sourceJoinRowId: 999,
      sourceChatRowId: 99,
      sourceMessageRowId: 9999,
      sourceId: 'archive-test',
      sourceKind: 'archived_messages_folder',
    );

    final repository = TopologyProjectionPreviewRepository(
      ledgerDb: ledgerDb,
      workingDb: workingDb,
    );

    final facts = await repository.readPreviewFacts();

    expect(facts, hasLength(1));
    expect(facts.single.sourceId, liveChatDbSourceIdentity.sourceId);
    expect(facts.single.sourceJoinRowId, 1);
  });
}

Future<Map<String, int>> _workingRowCounts(WorkingDatabase db) async {
  final rows = await db.customSelect('''
        SELECT
          (SELECT COUNT(*) FROM chats) AS chat_count,
          (SELECT COUNT(*) FROM messages) AS message_count;
        ''').getSingle();
  return <String, int>{
    'chat_count': rows.data['chat_count']! as int,
    'message_count': rows.data['message_count']! as int,
  };
}

Future<void> _insertLedgerChat(
  SqfliteImportDatabase ledgerDb, {
  required int batchId,
  required int id,
  required String guid,
  Object? displayName = _defaultDisplayName,
}) async {
  final db = await ledgerDb.database;
  await db.insert('chats', <String, Object?>{
    'id': id,
    'source_rowid': id,
    'source_id': liveChatDbSourceIdentity.sourceId,
    'source_kind': liveChatDbSourceIdentity.sourceKind,
    'guid': guid,
    'service': 'iMessage',
    'display_name': displayName == _defaultDisplayName ? guid : displayName,
    'is_group': 0,
    'batch_id': batchId,
  });
}

const Object _defaultDisplayName = Object();

Future<void> _insertPlaceholderLedgerChat(
  SqfliteImportDatabase ledgerDb, {
  required int batchId,
}) async {
  final db = await ledgerDb.database;
  await db.insert('chats', <String, Object?>{
    'id': -1,
    'guid': '__placeholder__',
    'service': 'Unknown',
    'display_name': 'Placeholder',
    'is_group': 0,
    'batch_id': batchId,
  });
}

Future<void> _insertLedgerMessage(
  SqfliteImportDatabase ledgerDb, {
  required int batchId,
  required int id,
  required int sourceChatId,
  required String guid,
}) async {
  final db = await ledgerDb.database;
  await db.insert('messages', <String, Object?>{
    'id': id,
    'source_rowid': id,
    'source_id': liveChatDbSourceIdentity.sourceId,
    'source_kind': liveChatDbSourceIdentity.sourceKind,
    'source_chat_rowid': sourceChatId == -1 ? null : sourceChatId,
    'guid': guid,
    'chat_id': sourceChatId,
    'service': 'iMessage',
    'is_from_me': 0,
    'has_attributed_body_source': 0,
    'has_message_summary_info': 0,
    'has_payload_data_source': 0,
    'is_system_message': 0,
    'batch_id': batchId,
  });
}

Future<void> _insertLedgerTopology(
  SqfliteImportDatabase ledgerDb, {
  required int batchId,
  required int sourceJoinRowId,
  required int sourceChatRowId,
  required int sourceMessageRowId,
  String sourceId = 'live-chat-db',
  String sourceKind = 'live_chat_db',
}) async {
  final db = await ledgerDb.database;
  await db.insert('chat_message_joins', <String, Object?>{
    'source_rowid': sourceJoinRowId,
    'source_id': sourceId,
    'source_kind': sourceKind,
    'source_chat_rowid': sourceChatRowId,
    'source_message_rowid': sourceMessageRowId,
    'batch_id': batchId,
  });
}

Future<void> _insertWorkingChat(
  WorkingDatabase db, {
  required int id,
  required String guid,
}) async {
  await db.customStatement(
    '''
    INSERT INTO chats (id, guid, service, is_group, is_ignored)
    VALUES (?, ?, 'iMessage', 0, 0);
    ''',
    <Object?>[id, guid],
  );
}

Future<void> _insertWorkingMessage(
  WorkingDatabase db, {
  required int id,
  required String guid,
  required int chatId,
}) async {
  await db.customStatement(
    '''
    INSERT INTO messages (id, guid, chat_id, is_from_me, status, batch_id)
    VALUES (?, ?, ?, 0, 'unknown', 1);
    ''',
    <Object?>[id, guid, chatId],
  );
}
