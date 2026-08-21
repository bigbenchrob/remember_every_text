import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/source_database/sqflite_source_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/source_database_messages_lineage_anchor_repository.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    sqflite.databaseFactory = databaseFactoryFfi;
  });

  test('raw Messages evidence uses message ROWID directly', () async {
    final directory = Directory.systemTemp.createTempSync('raw-lineage-');
    final path = '${directory.path}/chat.db';
    final db = sqlite3.open(path);
    db.execute('CREATE TABLE message (guid TEXT)');
    db.execute("INSERT INTO message (ROWID, guid) VALUES (42, 'guid-42')");
    db.dispose();
    addTearDown(() => directory.deleteSync(recursive: true));

    const repository = SourceDatabaseMessagesLineageAnchorRepository(
      sourceDatabaseOpener: SqfliteSourceDatabaseOpener(),
    );
    final evidence = await repository.readMacMessagesDatabase(
      databasePath: path,
    );

    expect(evidence.anchors.single.originalMessagesRowId, 42);
    expect(evidence.anchors.single.messageGuid, 'guid-42');
  });

  test(
    'MessageLens evidence canonically unscopes the live source identity',
    () async {
      final directory = Directory.systemTemp.createTempSync('scoped-lineage-');
      final path = '${directory.path}/macos_import_ss.db';
      final db = sqlite3.open(path);
      db.execute(
        'CREATE TABLE source_registry (source_id INTEGER, source_kind TEXT)',
      );
      db.execute(
        'CREATE TABLE messages (ss_id INTEGER, source_id INTEGER, source_rowid INTEGER, guid TEXT)',
      );
      db.execute('INSERT INTO source_registry VALUES (?, ?)', [
        liveChatDbSourceId,
        liveChatDbSourceKind,
      ]);
      db.execute('INSERT INTO messages VALUES (?, ?, ?, ?)', [
        SourceScopedRowKey.pack(sourceId: liveChatDbSourceId, sourceRowId: 42),
        liveChatDbSourceId,
        42,
        'guid-42',
      ]);
      db.dispose();
      addTearDown(() => directory.deleteSync(recursive: true));

      const repository = SourceDatabaseMessagesLineageAnchorRepository(
        sourceDatabaseOpener: SqfliteSourceDatabaseOpener(),
      );
      final evidence = await repository.readMessageLensImportLedger(
        databasePath: path,
      );

      expect(evidence.sourceShapeIsCoherent, isTrue);
      expect(evidence.anchors.single.originalMessagesRowId, 42);
      expect(evidence.anchors.single.messageGuid, 'guid-42');
    },
  );
}
