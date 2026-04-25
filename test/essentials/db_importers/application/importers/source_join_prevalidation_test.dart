import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/db_importers/application/importers/chat_to_handle_importer.dart';
import 'package:remember_this_text/essentials/db_importers/application/importers/chat_to_message_importer.dart';
import 'package:remember_this_text/essentials/db_importers/application/importers/message_attachments_importer.dart';
import 'package:remember_this_text/essentials/db_importers/application/importers/messages_importer.dart';
import 'package:remember_this_text/essentials/db_importers/domain/base_table_importer.dart';
import 'package:remember_this_text/essentials/db_importers/infrastructure/sqlite/import_context_sqlite.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('source join prevalidation', () {
    late Directory tempDir;
    late SqfliteImportDatabase ledgerDb;
    late Database messagesDb;
    late Database addressBookDb;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'source_join_prevalidation_test',
      );
      ledgerDb = SqfliteImportDatabase(
        databaseDirectory: tempDir.path,
        databaseName: 'import_test.db',
        debugSettings: const ImportDebugSettingsState(),
      );
      messagesDb = await openDatabase('${tempDir.path}/chat.db');
      addressBookDb = await openDatabase('${tempDir.path}/addressbook.db');
    });

    tearDown(() async {
      await messagesDb.close();
      await addressBookDb.close();
      await ledgerDb.deleteDatabaseFile();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('chat_to_handle importer fails early on broken source joins', () async {
      await messagesDb.execute(
        'CREATE TABLE handle (ROWID INTEGER PRIMARY KEY, id TEXT, service TEXT)',
      );
      await messagesDb.execute(
        'CREATE TABLE chat (ROWID INTEGER PRIMARY KEY, guid TEXT, service_name TEXT)',
      );
      await messagesDb.execute(
        'CREATE TABLE chat_handle_join (chat_id INTEGER NOT NULL, handle_id INTEGER NOT NULL)',
      );
      await messagesDb.insert('chat', <String, Object?>{
        'ROWID': 17,
        'guid': 'chat-17',
        'service_name': 'iMessage',
      });
      await messagesDb.insert('chat_handle_join', <String, Object?>{
        'chat_id': 17,
        'handle_id': 22,
      });

      final ctx = await _buildContext(
        ledgerDb: ledgerDb,
        messagesDb: messagesDb,
        addressBookDb: addressBookDb,
      );

      await expectLater(
        ChatToHandleImporter().validatePrereqs(ctx),
        throwsA(
          isA<ImportException>()
              .having((e) => e.code, 'code', 'chat-to-handle-source-fk-broken')
              .having(
                (e) => e.message,
                'message',
                contains('SELECT j.chat_id, j.handle_id'),
              ),
        ),
      );
    });

    test('chat_to_handle importer fails early on missing ledger parents', () async {
      await messagesDb.execute(
        'CREATE TABLE handle (ROWID INTEGER PRIMARY KEY, id TEXT, service TEXT)',
      );
      await messagesDb.execute(
        'CREATE TABLE chat (ROWID INTEGER PRIMARY KEY, guid TEXT, service_name TEXT)',
      );
      await messagesDb.execute(
        'CREATE TABLE chat_handle_join (chat_id INTEGER NOT NULL, handle_id INTEGER NOT NULL)',
      );
      await messagesDb.insert('handle', <String, Object?>{
        'ROWID': 22,
        'id': 'cathie.campbell@gmail.com',
        'service': 'iMessage',
      });
      await messagesDb.insert('chat', <String, Object?>{
        'ROWID': 17,
        'guid': 'chat-17',
        'service_name': 'iMessage',
      });
      await messagesDb.insert('chat_handle_join', <String, Object?>{
        'chat_id': 17,
        'handle_id': 22,
      });

      final ctx = await _buildContext(
        ledgerDb: ledgerDb,
        messagesDb: messagesDb,
        addressBookDb: addressBookDb,
      );
      await ledgerDb.insertChat(
        id: 17,
        sourceRowid: 17,
        guid: 'chat-17',
        service: 'iMessage',
        batchId: ctx.batchId,
      );

      await expectLater(
        ChatToHandleImporter().validatePrereqs(ctx),
        throwsA(
          isA<ImportException>()
              .having(
                (e) => e.code,
                'code',
                'chat-to-handle-ledger-parent-missing',
              )
              .having(
                (e) => e.message,
                'message',
                contains('Diagnostic SQL to run against macos_import.db'),
              ),
        ),
      );
    });

    test('chat_to_message importer fails early on broken source joins', () async {
      await messagesDb.execute(
        'CREATE TABLE chat (ROWID INTEGER PRIMARY KEY, guid TEXT, service_name TEXT)',
      );
      await messagesDb.execute(
        'CREATE TABLE message (ROWID INTEGER PRIMARY KEY, guid TEXT)',
      );
      await messagesDb.execute(
        'CREATE TABLE chat_message_join (chat_id INTEGER NOT NULL, message_id INTEGER NOT NULL)',
      );
      await messagesDb.insert('chat_message_join', <String, Object?>{
        'chat_id': 17,
        'message_id': 100,
      });

      final ctx = await _buildContext(
        ledgerDb: ledgerDb,
        messagesDb: messagesDb,
        addressBookDb: addressBookDb,
      );

      await expectLater(
        ChatToMessageImporter().validatePrereqs(ctx),
        throwsA(
          isA<ImportException>()
              .having((e) => e.code, 'code', 'chat-to-message-source-fk-broken')
              .having(
                (e) => e.message,
                'message',
                contains('SELECT j.chat_id, j.message_id'),
              ),
        ),
      );
    });

    test(
      'messages importer relinks recovered messages when joins become visible',
      () async {
        await messagesDb.execute(
          'CREATE TABLE chat (ROWID INTEGER PRIMARY KEY, guid TEXT, service_name TEXT)',
        );
        await messagesDb.execute(
          'CREATE TABLE message (ROWID INTEGER PRIMARY KEY, guid TEXT, text TEXT)',
        );
        await messagesDb.execute(
          'CREATE TABLE chat_message_join (chat_id INTEGER NOT NULL, message_id INTEGER NOT NULL)',
        );
        await messagesDb.insert('chat', <String, Object?>{
          'ROWID': 17,
          'guid': 'chat-17',
          'service_name': 'iMessage',
        });
        await messagesDb.insert('message', <String, Object?>{
          'ROWID': 100,
          'guid': 'message-100',
          'text': 'Recovered first, linked later',
        });
        await messagesDb.insert('chat_message_join', <String, Object?>{
          'chat_id': 17,
          'message_id': 100,
        });

        final ctx = await _buildContext(
          ledgerDb: ledgerDb,
          messagesDb: messagesDb,
          addressBookDb: addressBookDb,
          hasExistingLedgerData: true,
          previousMaxMessageRowId: 100,
        );
        await ledgerDb.insertChat(
          id: 17,
          sourceRowid: 17,
          guid: 'chat-17',
          service: 'iMessage',
          batchId: ctx.batchId,
        );
        await ledgerDb.insertRecoveredUnlinkedMessage(
          id: 100,
          sourceRowid: 100,
          guid: 'message-100',
          service: 'iMessage',
          isFromMe: false,
          text: 'Recovered first, linked later',
          hasAttributedBodySource: false,
          hasMessageSummaryInfo: false,
          hasPayloadDataSource: false,
          isSystemMessage: false,
          batchId: ctx.batchId,
        );

        await MessagesImporter().copy(ctx);

        final linkedRows = await ledgerDb.rawQuery(
          'SELECT id, chat_id FROM messages WHERE id = 100',
        );
        final recoveredRows = await ledgerDb.rawQuery(
          'SELECT id FROM recovered_unlinked_messages WHERE id = 100',
        );

        expect(linkedRows, hasLength(1));
        expect(linkedRows.single['chat_id'], 17);
        expect(recoveredRows, isEmpty);
        expect(ctx.readScratch<int>('messages.inserted'), 1);
        expect(
          ctx.readScratch<List<int>>('messages.insertedIds'),
          contains(100),
        );

        await expectLater(
          ChatToMessageImporter().validatePrereqs(ctx),
          completes,
        );
      },
    );

    test(
      'message_attachments importer fails early on broken source joins',
      () async {
        await messagesDb.execute(
          'CREATE TABLE message (ROWID INTEGER PRIMARY KEY, guid TEXT)',
        );
        await messagesDb.execute(
          'CREATE TABLE attachment (ROWID INTEGER PRIMARY KEY, guid TEXT)',
        );
        await messagesDb.execute(
          'CREATE TABLE message_attachment_join (message_id INTEGER NOT NULL, attachment_id INTEGER NOT NULL)',
        );
        await messagesDb.insert('message', <String, Object?>{
          'ROWID': 100,
          'guid': 'message-100',
        });
        await messagesDb.insert('message_attachment_join', <String, Object?>{
          'message_id': 100,
          'attachment_id': 300,
        });

        final ctx = await _buildContext(
          ledgerDb: ledgerDb,
          messagesDb: messagesDb,
          addressBookDb: addressBookDb,
        );

        await expectLater(
          MessageAttachmentsImporter().validatePrereqs(ctx),
          throwsA(
            isA<ImportException>()
                .having(
                  (e) => e.code,
                  'code',
                  'message-attachments-source-fk-broken',
                )
                .having(
                  (e) => e.message,
                  'message',
                  contains('SELECT j.message_id, j.attachment_id'),
                ),
          ),
        );
      },
    );

    test(
      'message_attachments importer fails early on missing ledger parents',
      () async {
        await messagesDb.execute(
          'CREATE TABLE message (ROWID INTEGER PRIMARY KEY, guid TEXT)',
        );
        await messagesDb.execute(
          'CREATE TABLE attachment (ROWID INTEGER PRIMARY KEY, guid TEXT)',
        );
        await messagesDb.execute(
          'CREATE TABLE message_attachment_join (message_id INTEGER NOT NULL, attachment_id INTEGER NOT NULL)',
        );
        await messagesDb.insert('message', <String, Object?>{
          'ROWID': 100,
          'guid': 'message-100',
        });
        await messagesDb.insert('attachment', <String, Object?>{
          'ROWID': 300,
          'guid': 'attachment-300',
        });
        await messagesDb.insert('message_attachment_join', <String, Object?>{
          'message_id': 100,
          'attachment_id': 300,
        });

        final ctx = await _buildContext(
          ledgerDb: ledgerDb,
          messagesDb: messagesDb,
          addressBookDb: addressBookDb,
        );
        await ledgerDb.insertAttachment(
          id: 300,
          sourceRowid: 300,
          guid: 'attachment-300',
          batchId: ctx.batchId,
        );

        await expectLater(
          MessageAttachmentsImporter().validatePrereqs(ctx),
          throwsA(
            isA<ImportException>()
                .having(
                  (e) => e.code,
                  'code',
                  'message-attachments-ledger-parent-missing',
                )
                .having(
                  (e) => e.message,
                  'message',
                  contains('Diagnostic SQL to run against macos_import.db'),
                ),
          ),
        );
      },
    );

    test(
      'message_attachments importer ignores join rows beyond batch snapshot ceilings',
      () async {
        await messagesDb.execute(
          'CREATE TABLE message (ROWID INTEGER PRIMARY KEY, guid TEXT)',
        );
        await messagesDb.execute(
          'CREATE TABLE attachment (ROWID INTEGER PRIMARY KEY, guid TEXT)',
        );
        await messagesDb.execute(
          'CREATE TABLE message_attachment_join (message_id INTEGER NOT NULL, attachment_id INTEGER NOT NULL)',
        );
        await messagesDb.insert('message', <String, Object?>{
          'ROWID': 100,
          'guid': 'message-100',
        });
        await messagesDb.insert('message', <String, Object?>{
          'ROWID': 101,
          'guid': 'message-101',
        });
        await messagesDb.insert('attachment', <String, Object?>{
          'ROWID': 300,
          'guid': 'attachment-300',
        });
        await messagesDb.insert('attachment', <String, Object?>{
          'ROWID': 301,
          'guid': 'attachment-301',
        });
        await messagesDb.insert('message_attachment_join', <String, Object?>{
          'message_id': 100,
          'attachment_id': 300,
        });
        await messagesDb.insert('message_attachment_join', <String, Object?>{
          'message_id': 101,
          'attachment_id': 301,
        });

        final ctx = await _buildContext(
          ledgerDb: ledgerDb,
          messagesDb: messagesDb,
          addressBookDb: addressBookDb,
          sourceMaxMessageRowIdAtBatchStart: 100,
          sourceMaxAttachmentRowIdAtBatchStart: 300,
        );
        await ledgerDb.insertChat(
          id: 17,
          sourceRowid: 17,
          guid: 'chat-17',
          service: 'iMessage',
          batchId: ctx.batchId,
        );
        await ledgerDb.insertMessage(
          id: 100,
          sourceRowid: 100,
          guid: 'message-100',
          chatId: 17,
          service: 'iMessage',
          isFromMe: false,
          hasAttributedBodySource: false,
          hasMessageSummaryInfo: false,
          hasPayloadDataSource: false,
          isSystemMessage: false,
          batchId: ctx.batchId,
        );
        await ledgerDb.insertAttachment(
          id: 300,
          sourceRowid: 300,
          guid: 'attachment-300',
          batchId: ctx.batchId,
        );

        await expectLater(
          MessageAttachmentsImporter().validatePrereqs(ctx),
          completes,
        );
      },
    );
  });
}

Future<ImportContextSqlite> _buildContext({
  required SqfliteImportDatabase ledgerDb,
  required Database messagesDb,
  required Database addressBookDb,
  bool hasExistingLedgerData = false,
  int? previousMaxMessageRowId,
  int? sourceMaxChatRowIdAtBatchStart,
  int? sourceMaxMessageRowIdAtBatchStart,
  int? sourceMaxAttachmentRowIdAtBatchStart,
}) async {
  final batchId = await ledgerDb.insertImportBatch(
    startedAtUtc: DateTime.now().toUtc().toIso8601String(),
  );

  return ImportContextSqlite(
    importDb: ledgerDb,
    messagesDb: messagesDb,
    messagesDbPath: messagesDb.path,
    addressBookDb: addressBookDb,
    batchId: batchId,
    hasExistingLedgerData: hasExistingLedgerData,
    previousMaxMessageRowId: previousMaxMessageRowId,
    sourceMaxChatRowIdAtBatchStart: sourceMaxChatRowIdAtBatchStart,
    sourceMaxMessageRowIdAtBatchStart: sourceMaxMessageRowIdAtBatchStart,
    sourceMaxAttachmentRowIdAtBatchStart: sourceMaxAttachmentRowIdAtBatchStart,
  );
}
