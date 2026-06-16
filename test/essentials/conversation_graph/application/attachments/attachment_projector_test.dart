import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/attachments/attachment_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/attachments/attachment_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/attachment_projection_repository.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../conversation_graph_test_database.dart';

void main() {
  late Directory tempDir;
  late ImportDatabase importLedgerDatabase;
  late ConversationGraphDatabase graphDatabase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('delegates attachment projection to repository', () async {
    final repository = _FakeAttachmentProjectionRepository(
      result: const AttachmentProjectionResult(
        examinedAttachmentCount: 6,
        insertedAttachmentCount: 3,
      ),
    );
    final result = await AttachmentProjector(
      repository: repository,
    ).projectAttachments();

    expect(repository.callCount, 1);
    expect(result.examinedAttachmentCount, 6);
    expect(result.insertedAttachmentCount, 3);
  });

  test('delegates bounded attachment projection to repository', () async {
    final repository = _FakeAttachmentProjectionRepository(
      result: const AttachmentProjectionResult(
        examinedAttachmentCount: 1,
        insertedAttachmentCount: 1,
      ),
    );
    final result = await AttachmentProjector(repository: repository)
        .projectAttachmentsAfterSourceRowId(
          sourceId: 7,
          startedAfterSourceRowId: 40,
        );

    expect(repository.boundedCallCount, 1);
    expect(repository.lastSourceId, 7);
    expect(repository.lastStartedAfterSourceRowId, 40);
    expect(result.examinedAttachmentCount, 1);
    expect(result.insertedAttachmentCount, 1);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'attachment_projector_test_',
    );
    importLedgerDatabase = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
    graphDatabase = await openConversationGraphTestDatabase();
  });

  tearDown(() async {
    await graphDatabase.close();
    await importLedgerDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('projects attachments and preserves ss_id', () async {
    final ssId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 10,
    );
    await _insertImportAttachment(
      importLedgerDatabase,
      sourceRowId: 10,
      guid: 'attachment-guid',
      filename: '/source/photo.jpg',
    );

    final result = await AttachmentProjector(
      repository: SqliteAttachmentProjectionRepository(
        importLedgerDatabase: importLedgerDatabase,
        graphDatabase: graphDatabase,
      ),
    ).projectAttachments();
    final rows = await graphDatabase.database.query('attachments');

    expect(result.examinedAttachmentCount, 1);
    expect(result.insertedAttachmentCount, 1);
    expect(rows.single['ss_id'], ssId);
    expect(rows.single['guid'], 'attachment-guid');
    expect(rows.single['filename'], '/source/photo.jpg');
    expect(rows.single, isNot(containsPair('source_id', liveChatDbSourceId)));
  });

  test('is idempotent and refreshes metadata', () async {
    await _insertImportAttachment(
      importLedgerDatabase,
      sourceRowId: 10,
      guid: 'attachment-guid',
      filename: '/source/photo.jpg',
    );
    final projector = AttachmentProjector(
      repository: SqliteAttachmentProjectionRepository(
        importLedgerDatabase: importLedgerDatabase,
        graphDatabase: graphDatabase,
      ),
    );

    final firstResult = await projector.projectAttachments();
    await importLedgerDatabase.database.update(
      'attachments',
      <String, Object?>{'filename': '/source/updated.jpg'},
      where: 'source_id = ? AND source_rowid = ?',
      whereArgs: <Object?>[liveChatDbSourceId, 10],
    );
    final secondResult = await projector.projectAttachments();
    final rows = await graphDatabase.database.query('attachments');

    expect(firstResult.insertedAttachmentCount, 1);
    expect(secondResult.insertedAttachmentCount, 0);
    expect(rows.single['filename'], '/source/updated.jpg');
  });

  test('projects attachments after source rowid', () async {
    await _insertImportAttachment(
      importLedgerDatabase,
      sourceRowId: 40,
      guid: 'old-attachment',
      filename: '/source/old.jpg',
    );
    await _insertImportAttachment(
      importLedgerDatabase,
      sourceRowId: 42,
      guid: 'new-attachment',
      filename: '/source/new.jpg',
    );

    final result =
        await AttachmentProjector(
          repository: SqliteAttachmentProjectionRepository(
            importLedgerDatabase: importLedgerDatabase,
            graphDatabase: graphDatabase,
          ),
        ).projectAttachmentsAfterSourceRowId(
          sourceId: liveChatDbSourceId,
          startedAfterSourceRowId: 40,
        );
    final rows = await graphDatabase.database.query('attachments');

    expect(result.examinedAttachmentCount, 1);
    expect(result.insertedAttachmentCount, 1);
    expect(rows, hasLength(1));
    expect(rows.single['guid'], 'new-attachment');
  });
}

class _FakeAttachmentProjectionRepository
    implements AttachmentProjectionRepository {
  _FakeAttachmentProjectionRepository({required this.result});

  final AttachmentProjectionResult result;
  int callCount = 0;
  int boundedCallCount = 0;
  int? lastSourceId;
  int? lastStartedAfterSourceRowId;

  @override
  Future<AttachmentProjectionResult> projectAttachments() async {
    callCount += 1;
    return result;
  }

  @override
  Future<AttachmentProjectionResult> projectAttachmentsAfterSourceRowId({
    required int sourceId,
    required int startedAfterSourceRowId,
  }) async {
    boundedCallCount += 1;
    lastSourceId = sourceId;
    lastStartedAfterSourceRowId = startedAfterSourceRowId;
    return result;
  }
}

Future<void> _insertImportAttachment(
  ImportDatabase importLedgerDatabase, {
  required int sourceRowId,
  required String guid,
  String? filename,
}) async {
  final batchId = await importLedgerDatabase.insertImportBatch(
    sourceId: liveChatDbSourceId,
    startedAtUtc: DateTime.now().toUtc().toIso8601String(),
  );
  await importLedgerDatabase.database.insert('attachments', <String, Object?>{
    'ss_id': SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: sourceRowId,
    ),
    'source_id': liveChatDbSourceId,
    'source_rowid': sourceRowId,
    'guid': guid,
    'filename': filename,
    'batch_id': batchId,
  });
}
