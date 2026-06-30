import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/features/address_book_folders/infrastructure/data_sources/local/address_book_db_helper_multi_instance.dart';
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
    tempDir = await Directory.systemTemp.createTemp('address_book_db_test_');
    databasePath = '${tempDir.path}/AddressBook-v22.abcddb';
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('CREATE TABLE ZABCDRECORD (Z_PK INTEGER PRIMARY KEY)');
        await db.insert('ZABCDRECORD', <String, Object?>{'Z_PK': 1});
      },
    );
    await database.close();
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('readRows accepts only read queries', () async {
    final helper = AddressBookDbHelperMultiInstance(databasePath);
    addTearDown(helper.close);

    await helper.verifyReadable();
    expect(
      await helper.readRows('SELECT Z_PK FROM ZABCDRECORD'),
      <Map<String, Object?>>[
        <String, Object?>{'Z_PK': 1},
      ],
    );
    expect(await helper.readRows('PRAGMA table_info(ZABCDRECORD)'), isNotEmpty);
    expect(
      await helper.readRows(
        'WITH rows AS (SELECT Z_PK FROM ZABCDRECORD) SELECT Z_PK FROM rows',
      ),
      <Map<String, Object?>>[
        <String, Object?>{'Z_PK': 1},
      ],
    );

    await expectLater(
      helper.readRows('DELETE FROM ZABCDRECORD'),
      throwsA(isA<StateError>()),
    );
  });
}
