import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/source_database/sqflite_source_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late String databasePath;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('source_db_read_test_');
    databasePath = '${tempDir.path}/source.db';
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('CREATE TABLE message (ROWID INTEGER PRIMARY KEY)');
        await db.insert('message', <String, Object?>{'ROWID': 1});
      },
    );
    await database.close();
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('source rawQuery accepts only read queries', () async {
    final sourceDatabase = await const SqfliteSourceDatabaseOpener()
        .openReadOnly(databasePath);
    addTearDown(sourceDatabase.close);

    expect(
      await sourceDatabase.rawQuery('SELECT ROWID FROM message'),
      <Map<String, Object?>>[
        <String, Object?>{'ROWID': 1},
      ],
    );
    expect(
      await sourceDatabase.rawQuery('PRAGMA table_info(message)'),
      isNotEmpty,
    );
    expect(
      await sourceDatabase.rawQuery(
        'WITH rows AS (SELECT ROWID FROM message) SELECT ROWID FROM rows',
      ),
      <Map<String, Object?>>[
        <String, Object?>{'ROWID': 1},
      ],
    );

    await expectLater(
      sourceDatabase.rawQuery('DELETE FROM message'),
      throwsA(isA<StateError>()),
    );
  });
}
