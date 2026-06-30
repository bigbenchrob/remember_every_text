import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/contacts/contact_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/source_database/sqflite_source_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late ImportDatabase importDatabase;
  late String addressBookDbPath;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('contact_importer_test_');
    importDatabase = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
    addressBookDbPath = '${tempDir.path}/AddressBook-v22.abcddb';
    final sourceDb = await openDatabase(
      addressBookDbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ZABCDRECORD (
            Z_PK INTEGER PRIMARY KEY,
            ZFIRSTNAME TEXT,
            ZMIDDLENAME TEXT,
            ZLASTNAME TEXT,
            ZORGANIZATION TEXT,
            ZNICKNAME TEXT,
            ZCREATIONDATE REAL
          )
        ''');
        await db.execute('''
          CREATE TABLE ZABCDEMAILADDRESS (
            ZOWNER INTEGER,
            ZADDRESS TEXT,
            ZADDRESSNORMALIZED TEXT,
            ZLABEL TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE ZABCDPHONENUMBER (
            ZOWNER INTEGER,
            ZFULLNUMBER TEXT,
            ZVALUE TEXT,
            ZLABEL TEXT
          )
        ''');
      },
    );
    await sourceDb.close();
  });

  tearDown(() async {
    await importDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('imports contacts and channels into the source-scoped ledger', () async {
    final sourceDb = await openDatabase(addressBookDbPath);
    await sourceDb.insert('ZABCDRECORD', <String, Object?>{
      'Z_PK': 24,
      'ZFIRSTNAME': 'Cathie',
      'ZLASTNAME': 'Campbell',
    });
    await sourceDb.insert('ZABCDPHONENUMBER', <String, Object?>{
      'ZOWNER': 24,
      'ZFULLNUMBER': '+1 (604) 999-5969',
    });
    await sourceDb.insert('ZABCDEMAILADDRESS', <String, Object?>{
      'ZOWNER': 24,
      'ZADDRESS': 'Cathie.Campbell@GMAIL.COM',
    });
    await sourceDb.close();

    final result = await ContactImporter(
      addressBookDbPath: addressBookDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    ).importContacts();

    expect(result.examinedContactCount, 1);
    expect(result.insertedContactCount, 1);
    expect(result.insertedChannelCount, 2);

    final contactSsId = SourceScopedRowKey.pack(
      sourceId: liveAddressBookSourceId,
      sourceRowId: 24,
    );
    final contacts = await importDatabase.database.query('contacts');
    expect(contacts.single['ss_id'], contactSsId);
    expect(contacts.single['source_id'], liveAddressBookSourceId);
    expect(contacts.single['source_rowid'], 24);
    expect(contacts.single['display_name'], 'Cathie Campbell');

    final channels = await importDatabase.database.query(
      'contact_channels',
      orderBy: 'kind ASC',
    );
    expect(channels, hasLength(2));
    expect(channels.map((row) => row['value']).toSet(), <String>{
      'cathie.campbell@gmail.com',
      '6049995969',
    });

    final secondResult = await ContactImporter(
      addressBookDbPath: addressBookDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    ).importContacts();
    expect(secondResult.insertedContactCount, 0);
    expect(secondResult.insertedChannelCount, 0);
  });
}
