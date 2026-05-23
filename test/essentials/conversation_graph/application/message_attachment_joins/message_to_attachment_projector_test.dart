import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/message_attachment_joins/message_to_attachment_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/message_attachment_joins/message_to_attachment_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/message_to_attachment_projection_repository.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../conversation_graph_test_database.dart';

void main() {
  late Directory tempDir;
  late ImportDatabase importDatabase;
  late ConversationGraphDatabase workingDatabase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('delegates edge projection to repository', () async {
    final repository = _FakeMessageToAttachmentProjectionRepository(
      result: const MessageToAttachmentProjectionResult(
        examinedEdgeCount: 5,
        insertedEdgeCount: 2,
      ),
    );
    final result = await MessageToAttachmentProjector(
      repository: repository,
    ).projectEdges();

    expect(repository.callCount, 1);
    expect(result.examinedEdgeCount, 5);
    expect(result.insertedEdgeCount, 2);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'message_to_attachment_projector_test_',
    );
    importDatabase = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
    workingDatabase = await openConversationGraphTestDatabase();
  });

  tearDown(() async {
    await workingDatabase.close();
    await importDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('projects message-to-attachment canonical graph edges', () async {
    final messageSsId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 11,
    );
    final attachmentSsId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 22,
    );
    await _insertImportEdge(
      importDatabase,
      sourceMessageRowId: 11,
      sourceAttachmentRowId: 22,
    );

    final result = await MessageToAttachmentProjector(
      repository: SqliteMessageToAttachmentProjectionRepository(
        importDatabase: importDatabase,
        workingDatabase: workingDatabase,
      ),
    ).projectEdges();
    final rows = await workingDatabase.database.query('message_to_attachment');

    expect(result.examinedEdgeCount, 1);
    expect(result.insertedEdgeCount, 1);
    expect(rows.single['message_ss_id'], messageSsId);
    expect(rows.single['attachment_ss_id'], attachmentSsId);
  });

  test('is idempotent', () async {
    await _insertImportEdge(
      importDatabase,
      sourceMessageRowId: 11,
      sourceAttachmentRowId: 22,
    );

    final projector = MessageToAttachmentProjector(
      repository: SqliteMessageToAttachmentProjectionRepository(
        importDatabase: importDatabase,
        workingDatabase: workingDatabase,
      ),
    );
    final firstResult = await projector.projectEdges();
    final secondResult = await projector.projectEdges();
    final rows = await workingDatabase.database.query('message_to_attachment');

    expect(firstResult.insertedEdgeCount, 1);
    expect(secondResult.insertedEdgeCount, 0);
    expect(rows, hasLength(1));
  });
}

class _FakeMessageToAttachmentProjectionRepository
    implements MessageToAttachmentProjectionRepository {
  _FakeMessageToAttachmentProjectionRepository({required this.result});

  final MessageToAttachmentProjectionResult result;
  int callCount = 0;

  @override
  Future<MessageToAttachmentProjectionResult> projectEdges() async {
    callCount += 1;
    return result;
  }
}

Future<void> _insertImportEdge(
  ImportDatabase importDatabase, {
  required int sourceMessageRowId,
  required int sourceAttachmentRowId,
}) async {
  final batchId = await importDatabase.insertImportBatch(
    sourceId: liveChatDbSourceId,
    startedAtUtc: DateTime.now().toUtc().toIso8601String(),
  );
  await importDatabase.database
      .insert('message_to_attachment', <String, Object?>{
        'message_source_id': liveChatDbSourceId,
        'attachment_source_id': liveChatDbSourceId,
        'source_message_rowid': sourceMessageRowId,
        'source_attachment_rowid': sourceAttachmentRowId,
        'message_ss_id': SourceScopedRowKey.pack(
          sourceId: liveChatDbSourceId,
          sourceRowId: sourceMessageRowId,
        ),
        'attachment_ss_id': SourceScopedRowKey.pack(
          sourceId: liveChatDbSourceId,
          sourceRowId: sourceAttachmentRowId,
        ),
        'batch_id': batchId,
      });
}
