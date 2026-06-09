import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/source_scoped_import/application/archives/historical_messages_archive_source_registrar.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late Directory archiveFolder;
  late ImportDatabase importDatabase;
  late HistoricalMessagesArchiveSourceRegistrar registrar;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'historical_archive_source_registrar_test_',
    );
    archiveFolder = Directory(path.join(tempDir.path, 'Archive-2017'));
    await archiveFolder.create(recursive: true);
    await File(path.join(archiveFolder.path, 'chat.db')).writeAsString('');

    importDatabase = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
    registrar = HistoricalMessagesArchiveSourceRegistrar(
      importDatabase: importDatabase,
    );
  });

  tearDown(() async {
    await importDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('registers archive folder as source-scoped source', () async {
    final registration = await registrar.registerFolder(
      folderPath: archiveFolder.path,
      sourceLabel: 'January 2017 Archive',
    );

    expect(registration.sourceId, greaterThan(liveAddressBookSourceId));
    expect(
      registration.sourceKey,
      startsWith(historicalMessagesArchiveSourceKeyPrefix),
    );
    expect(registration.sourceKey, contains(registration.chatDbPath));
    expect(registration.sourceKind, historicalMessagesArchiveSourceKind);
    expect(registration.sourceLabel, 'January 2017 Archive');
    expect(registration.selectedFolderPath, archiveFolder.absolute.path);
    expect(
      registration.chatDbPath,
      path.join(archiveFolder.absolute.path, 'chat.db'),
    );

    final rows = await importDatabase.database.query(
      'source_registry',
      where: 'source_id = ?',
      whereArgs: <Object?>[registration.sourceId],
    );

    expect(rows, hasLength(1));
    expect(rows.single['source_key'], registration.sourceKey);
    expect(rows.single['source_kind'], historicalMessagesArchiveSourceKind);
    expect(rows.single['source_label'], 'January 2017 Archive');
  });

  test('uses folder basename as default source label', () async {
    final registration = await registrar.registerFolder(
      folderPath: archiveFolder.path,
    );

    expect(registration.sourceLabel, 'Archive-2017');
  });

  test('reuses source id for the same archive folder', () async {
    final firstRegistration = await registrar.registerFolder(
      folderPath: archiveFolder.path,
      sourceLabel: 'Archive A',
    );
    final secondRegistration = await registrar.registerFolder(
      folderPath: archiveFolder.path,
      sourceLabel: 'Renamed Archive A',
    );

    expect(secondRegistration.sourceId, firstRegistration.sourceId);
    expect(secondRegistration.sourceKey, firstRegistration.sourceKey);

    final rows = await importDatabase.database.query(
      'source_registry',
      where: 'source_key = ?',
      whereArgs: <Object?>[firstRegistration.sourceKey],
    );

    expect(rows, hasLength(1));
    expect(rows.single['source_label'], 'Archive A');
  });

  test('rejects archive folder without chat db', () async {
    final emptyFolder = Directory(path.join(tempDir.path, 'NoChatDb'));
    await emptyFolder.create();

    expect(
      () => registrar.registerFolder(folderPath: emptyFolder.path),
      throwsA(isA<FileSystemException>()),
    );
  });

  test('rejects blank folder path', () async {
    expect(
      () => registrar.registerFolder(folderPath: ' '),
      throwsArgumentError,
    );
  });
}
