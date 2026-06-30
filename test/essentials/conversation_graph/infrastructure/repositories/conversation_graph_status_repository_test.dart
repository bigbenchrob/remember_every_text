import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/conversation_graph_status_repository.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../conversation_graph_test_database.dart';

void main() {
  late Directory tempDir;
  late ImportDatabase importLedger;
  late ConversationGraphDatabase graphDatabase;
  late String sourcePath;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('graph_status_test_');
    sourcePath = '${tempDir.path}/chat.db';
    await _createSourceDatabase(sourcePath);
    importLedger = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
    graphDatabase = await openConversationGraphTestDatabase();
  });

  tearDown(() async {
    await graphDatabase.close();
    await importLedger.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'reads source status through guarded read-only source queries',
    () async {
      final status = await const ConversationGraphStatusRepository().readStatus(
        chatDbPath: sourcePath,
        importLedger: importLedger,
        graphDatabase: graphDatabase,
        importLedgerDatabaseLabel: 'import',
        graphDatabaseLabel: 'graph',
        sourceId: liveChatDbSourceId,
      );

      expect(status.sourceMessageCount, 2);
      expect(status.sourceMaxRowId, 7);
      expect(status.sourceChatCount, 1);
      expect(status.sourceHandleCount, 1);
      expect(status.sourceAttachmentCount, 1);
      expect(status.ledgerMessageCount, 0);
      expect(status.graphMessageCount, 0);
    },
  );
}

Future<void> _createSourceDatabase(String path) async {
  final database = await openDatabase(
    path,
    version: 1,
    onCreate: (db, _) async {
      await db.execute('CREATE TABLE message (ROWID INTEGER PRIMARY KEY)');
      await db.execute('CREATE TABLE chat (ROWID INTEGER PRIMARY KEY)');
      await db.execute('CREATE TABLE handle (ROWID INTEGER PRIMARY KEY)');
      await db.execute('CREATE TABLE attachment (ROWID INTEGER PRIMARY KEY)');
      await db.insert('message', <String, Object?>{'ROWID': 4});
      await db.insert('message', <String, Object?>{'ROWID': 7});
      await db.insert('chat', <String, Object?>{'ROWID': 1});
      await db.insert('handle', <String, Object?>{'ROWID': 2});
      await db.insert('attachment', <String, Object?>{'ROWID': 3});
    },
  );
  await database.close();
}
