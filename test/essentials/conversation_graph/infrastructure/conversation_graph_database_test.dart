import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/app_database_files.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../conversation_graph_test_database.dart';

void main() {
  late Directory tempDir;
  late ConversationGraphDatabase graphDatabase;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'conversation_graph_db_test_',
    );
    graphDatabase = await openConversationGraphTestDatabase();
  });

  tearDown(() async {
    await graphDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('creates messages projection schema only', () async {
    final messageColumns = await graphDatabase.database.rawQuery(
      'PRAGMA table_info(messages)',
    );
    final columnNames = messageColumns.map((row) => row['name']).toSet();

    expect(
      columnNames,
      containsAll(<String>{
        'ss_id',
        'guid',
        'sender_handle_ss_id',
        'sender_canonical_handle_ss_id',
        'is_from_me',
        'date_utc',
        'text',
        'associated_message_ss_id',
        'semantic_kind',
        'item_kind',
        'is_system_message',
        'is_sparse_artifact',
        'has_attributed_body_source',
        'has_message_summary_info',
        'has_payload_data_source',
        'error_code',
      }),
    );
    expect(columnNames, isNot(contains('source_id')));
    expect(columnNames, isNot(contains('source_rowid')));
    expect(columnNames, isNot(contains('attributed_body_blob')));
    expect(columnNames, isNot(contains('associated_message_guid')));
    expect(columnNames, isNot(contains('thread_originator_guid')));
    expect(columnNames, isNot(contains('reply_to_guid')));
  });

  test('selectRows accepts only read queries', () async {
    expect(
      await graphDatabase.selectRows('SELECT 1 AS ok'),
      <Map<String, Object?>>[
        <String, Object?>{'ok': 1},
      ],
    );
    expect(
      await graphDatabase.selectRows(
        'WITH rows AS (SELECT 2 AS ok) SELECT ok FROM rows',
      ),
      <Map<String, Object?>>[
        <String, Object?>{'ok': 2},
      ],
    );
    expect(
      await graphDatabase.selectRows('PRAGMA table_info(messages)'),
      isNotEmpty,
    );

    await expectLater(
      graphDatabase.selectRows('DELETE FROM messages'),
      throwsA(isA<StateError>()),
    );
  });

  test('creates chats and chat_to_message projection schema', () async {
    final handleColumns = await graphDatabase.database.rawQuery(
      'PRAGMA table_info(handles)',
    );
    final canonicalHandleColumns = await graphDatabase.database.rawQuery(
      'PRAGMA table_info(canonical_handles)',
    );
    final handleAliasColumns = await graphDatabase.database.rawQuery(
      'PRAGMA table_info(handle_aliases)',
    );
    final chatColumns = await graphDatabase.database.rawQuery(
      'PRAGMA table_info(chats)',
    );
    final edgeColumns = await graphDatabase.database.rawQuery(
      'PRAGMA table_info(chat_to_message)',
    );
    final participantColumns = await graphDatabase.database.rawQuery(
      'PRAGMA table_info(chat_to_handle)',
    );
    final contactColumns = await graphDatabase.database.rawQuery(
      'PRAGMA table_info(contacts)',
    );
    final contactEdgeColumns = await graphDatabase.database.rawQuery(
      'PRAGMA table_info(contact_to_handle)',
    );
    final attachmentColumns = await graphDatabase.database.rawQuery(
      'PRAGMA table_info(attachments)',
    );
    final attachmentEdgeColumns = await graphDatabase.database.rawQuery(
      'PRAGMA table_info(message_to_attachment)',
    );

    expect(handleColumns.map((row) => row['name']).toSet(), <String>{
      'ss_id',
      'id',
      'service',
      'is_me',
    });
    expect(canonicalHandleColumns.map((row) => row['name']).toSet(), <String>{
      'canonical_handle_ss_id',
      'display_handle',
      'normalized_identifier',
      'service',
      'alias_count',
    });
    expect(handleAliasColumns.map((row) => row['name']).toSet(), <String>{
      'handle_ss_id',
      'canonical_handle_ss_id',
      'raw_identifier',
      'normalized_identifier',
      'alias_kind',
    });
    expect(chatColumns.map((row) => row['name']).toSet(), <String>{
      'ss_id',
      'guid',
      'service',
      'is_group',
      'last_read_message_at_utc',
    });
    expect(
      chatColumns.map((row) => row['name']).toSet(),
      isNot(contains('source_id')),
    );
    expect(
      chatColumns.map((row) => row['name']).toSet(),
      isNot(contains('source_rowid')),
    );
    expect(
      chatColumns.map((row) => row['name']).toSet(),
      isNot(contains('batch_id')),
    );
    expect(edgeColumns.map((row) => row['name']).toSet(), <String>{
      'chat_ss_id',
      'message_ss_id',
    });
    expect(participantColumns.map((row) => row['name']).toSet(), <String>{
      'chat_ss_id',
      'handle_ss_id',
    });
    expect(contactColumns.map((row) => row['name']).toSet(), <String>{
      'contact_id',
      'display_name',
      'given_name',
      'family_name',
      'organization',
    });
    expect(
      contactColumns.map((row) => row['name']).toSet(),
      isNot(contains('source_id')),
    );
    expect(
      contactColumns.map((row) => row['name']).toSet(),
      isNot(contains('source_rowid')),
    );
    expect(contactEdgeColumns.map((row) => row['name']).toSet(), <String>{
      'contact_id',
      'handle_ss_id',
      'handle_value',
    });
    expect(attachmentColumns.map((row) => row['name']).toSet(), <String>{
      'ss_id',
      'guid',
      'filename',
      'transfer_name',
      'uti',
      'mime_type',
      'total_bytes',
      'created_at_utc',
    });
    expect(
      attachmentColumns.map((row) => row['name']).toSet(),
      isNot(contains('source_id')),
    );
    expect(
      attachmentColumns.map((row) => row['name']).toSet(),
      isNot(contains('source_rowid')),
    );
    expect(attachmentEdgeColumns.map((row) => row['name']).toSet(), <String>{
      'message_ss_id',
      'attachment_ss_id',
    });
  });

  test(
    'opens existing pre-Drift graph database with upgrade strategy',
    () async {
      final dbPath = appDatabasePath(
        AppDatabaseFile.conversationGraph,
        databaseDirectory: tempDir.path,
      );
      final existingDatabase = await databaseFactoryFfi.openDatabase(dbPath);
      await existingDatabase.execute('''
      CREATE TABLE messages (
        ss_id INTEGER PRIMARY KEY,
        guid TEXT
      )
    ''');
      await existingDatabase.execute('PRAGMA user_version = 0');
      await existingDatabase.close();

      await graphDatabase.close();
      graphDatabase = ConversationGraphDatabase(NativeDatabase(File(dbPath)));

      final tables = await graphDatabase.selectRows('''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
      ORDER BY name
      ''');

      expect(tables.map((row) => row['name']), contains('messages'));
      expect(tables.map((row) => row['name']), contains('chat_to_handle'));
      expect(tables.map((row) => row['name']), contains('contact_to_handle'));
    },
  );

  test('upgrades version 1 handles with local account identity', () async {
    final dbPath = appDatabasePath(
      AppDatabaseFile.conversationGraph,
      databaseDirectory: tempDir.path,
    );
    final existingDatabase = await databaseFactoryFfi.openDatabase(dbPath);
    await existingDatabase.execute('''
      CREATE TABLE handles (
        ss_id INTEGER PRIMARY KEY,
        id TEXT NOT NULL,
        service TEXT
      )
    ''');
    await existingDatabase.insert('handles', <String, Object?>{
      'ss_id': 12,
      'id': '+16046858506',
      'service': 'iMessage',
    });
    await existingDatabase.execute('PRAGMA user_version = 1');
    await existingDatabase.close();

    await graphDatabase.close();
    graphDatabase = ConversationGraphDatabase(NativeDatabase(File(dbPath)));

    final columns = await graphDatabase.selectRows(
      'PRAGMA table_info(handles)',
    );
    final rows = await graphDatabase.selectRows('SELECT * FROM handles');

    expect(columns.map((row) => row['name']), contains('is_me'));
    expect(rows.single['is_me'], 0);
  });
}
