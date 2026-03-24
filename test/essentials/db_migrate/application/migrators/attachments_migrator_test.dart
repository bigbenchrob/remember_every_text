import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/db_migrate/application/migrators/attachments_migrator.dart';
import 'package:remember_this_text/essentials/db_migrate/infrastructure/sqlite/migration_context_sqlite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('AttachmentsMigrator', () {
    late Directory tempDir;
    late SqfliteImportDatabase importDb;
    late WorkingDatabase workingDb;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'attachments_migrator_test',
      );
      importDb = SqfliteImportDatabase(
        databaseDirectory: tempDir.path,
        databaseName: 'import_test.db',
        debugSettings: const ImportDebugSettingsState(),
      );
      workingDb = WorkingDatabase(NativeDatabase.memory());
      await workingDb.customStatement('PRAGMA foreign_keys = ON');
    });

    tearDown(() async {
      await workingDb.close();
      await importDb.deleteDatabaseFile();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'incremental copy removes duplicate projected rows and inserts missing attachments once',
      () async {
        const importChatId = 8;
        const importMessageId = 101;
        const messageGuid = 'message-guid-attachments-1';
        const sentAtUtc = '2024-01-02T03:04:05Z';
        const firstAttachmentId = 201;
        const secondAttachmentId = 202;

        final batchId = await importDb.insertImportBatch(
          startedAtUtc: DateTime.now().toUtc().toIso8601String(),
        );

        await importDb.insertChat(
          id: importChatId,
          guid: 'import-chat-guid-attachments-1',
          service: 'iMessage',
          batchId: batchId,
        );

        await importDb.insertMessage(
          id: importMessageId,
          guid: messageGuid,
          chatId: importChatId,
          service: 'iMessage',
          isFromMe: false,
          dateUtc: sentAtUtc,
          text: 'Attachment migration test',
          hasAttributedBodySource: false,
          hasMessageSummaryInfo: false,
          hasPayloadDataSource: false,
          itemType: 'text',
          isSystemMessage: false,
          batchId: batchId,
        );

        await importDb.insertAttachment(
          id: firstAttachmentId,
          transferName: 'a.jpg',
          mimeType: 'image/jpeg',
          localPath: '/tmp/a.jpg',
          batchId: batchId,
        );
        await importDb.insertAttachment(
          id: secondAttachmentId,
          transferName: 'b.jpg',
          mimeType: 'image/jpeg',
          localPath: '/tmp/b.jpg',
          batchId: batchId,
        );
        await importDb.insertMessageAttachment(
          messageId: importMessageId,
          attachmentId: firstAttachmentId,
        );
        await importDb.insertMessageAttachment(
          messageId: importMessageId,
          attachmentId: secondAttachmentId,
        );

        await workingDb.customStatement('''
          INSERT INTO chats (id, guid, service)
          VALUES ($importChatId, 'working-chat-guid-attachments-1', 'iMessage')
        ''');

        await workingDb.customStatement('''
          INSERT INTO messages (
            id,
            guid,
            chat_id,
            is_from_me,
            sent_at_utc,
            text,
            status,
            has_attachments,
            is_system_message,
            is_sparse_artifact,
            has_attributed_body_source,
            has_message_summary_info,
            has_payload_data_source
          ) VALUES (
            $importMessageId,
            '$messageGuid',
            $importChatId,
            0,
            '$sentAtUtc',
            'Attachment migration test',
            'unknown',
            1,
            0,
            0,
            0,
            0,
            0
          )
        ''');

        await workingDb.customStatement('''
          INSERT INTO attachments (
            message_guid,
            import_attachment_id,
            local_path,
            mime_type,
            transfer_name,
            is_sticker,
            is_outgoing
          ) VALUES
            ('$messageGuid', $firstAttachmentId, '/tmp/a.jpg', 'image/jpeg', 'a.jpg', 0, 0),
            ('$messageGuid', $firstAttachmentId, '/tmp/a.jpg', 'image/jpeg', 'a.jpg', 0, 0)
        ''');

        final context = MigrationContextSqlite(
          importDb: importDb,
          workingDb: workingDb,
          incrementalMode: true,
          log: (_) {},
        );
        const migrator = AttachmentsMigrator();

        await migrator.validatePrereqs(context);
        await migrator.copy(context);
        await migrator.postValidate(context);

        final rows = await workingDb
            .customSelect(
              '''
          SELECT import_attachment_id, COUNT(*) AS c
          FROM attachments
          WHERE message_guid = ?
          GROUP BY import_attachment_id
          ORDER BY import_attachment_id
        ''',
              variables: [const drift.Variable<String>(messageGuid)],
            )
            .get();

        expect(rows, hasLength(2));
        expect(rows[0].data['import_attachment_id'], firstAttachmentId);
        expect(rows[0].data['c'], 1);
        expect(rows[1].data['import_attachment_id'], secondAttachmentId);
        expect(rows[1].data['c'], 1);
      },
    );
  });
}
