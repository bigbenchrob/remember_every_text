import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SqfliteImportDatabase handles schema', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'sqflite_import_database_test',
      );
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'fresh database preserves multiple source rows with same imported raw identifier',
      () async {
        final ledgerDb = SqfliteImportDatabase(
          databaseDirectory: tempDir.path,
          databaseName: 'import_test.db',
          debugSettings: const ImportDebugSettingsState(),
        );

        final batchId = await ledgerDb.insertImportBatch(
          startedAtUtc: DateTime.now().toUtc().toIso8601String(),
        );

        await ledgerDb.insertHandle(
          id: 22,
          sourceRowid: 22,
          service: 'iMessage',
          rawIdentifier: 'cathie.campbell@gmail.com',
          normalizedIdentifier: 'cathie.campbell@gmail.com',
          compoundIdentifier: 'cathie.campbell@gmail.com-iMessage',
          batchId: batchId,
        );
        await ledgerDb.insertHandle(
          id: 203,
          sourceRowid: 203,
          service: 'iMessage',
          rawIdentifier: 'cathie.campbell@gmail.com',
          normalizedIdentifier: 'cathie.campbell@gmail.com',
          compoundIdentifier: 'cathie.campbell@gmail.com-iMessage',
          batchId: batchId,
        );

        final db = await ledgerDb.database;
        final rows = await db.query('handles', orderBy: 'id ASC');

        expect(rows, hasLength(2));
        expect(rows.map((row) => row['id']), orderedEquals(<Object?>[22, 203]));
        expect(
          rows.map((row) => row['source_rowid']),
          orderedEquals(<Object?>[22, 203]),
        );

        await ledgerDb.close();
      },
    );

    test('upgrades a v3 database to preserve multiple source rows', () async {
      final dbPath = '${tempDir.path}/import_test.db';
      final legacyDb = await openDatabase(dbPath);
      await legacyDb.execute(
        'CREATE TABLE schema_migrations (version INTEGER PRIMARY KEY, applied_at_utc TEXT NOT NULL)',
      );
      await legacyDb.execute(
        'CREATE TABLE import_batches (id INTEGER PRIMARY KEY, started_at_utc TEXT NOT NULL, finished_at_utc TEXT, source_chat_db TEXT, source_addressbook TEXT, host_info_json TEXT, notes TEXT)',
      );
      await legacyDb.execute(
        "CREATE TABLE handles (id INTEGER PRIMARY KEY, source_rowid INTEGER, service TEXT NOT NULL, raw_identifier TEXT NOT NULL, normalized_identifier TEXT, compound_identifier TEXT NOT NULL DEFAULT '', country TEXT, last_seen_utc TEXT, is_ignored INTEGER NOT NULL DEFAULT 0 CHECK(is_ignored IN (0,1)), batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT, UNIQUE(service, raw_identifier))",
      );
      await legacyDb.execute(
        'CREATE INDEX idx_handles_compound ON handles(compound_identifier)',
      );
      await legacyDb.execute(
        'CREATE INDEX idx_handles_norm ON handles(normalized_identifier)',
      );
      await legacyDb.execute(
        'CREATE INDEX idx_handles_ignore ON handles(is_ignored)',
      );
      await legacyDb.execute('PRAGMA user_version = 3');
      await legacyDb.close();

      final upgradedDb = SqfliteImportDatabase(
        databaseDirectory: tempDir.path,
        databaseName: 'import_test.db',
        debugSettings: const ImportDebugSettingsState(),
      );

      final batchId = await upgradedDb.insertImportBatch(
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );

      await upgradedDb.insertHandle(
        id: 22,
        sourceRowid: 22,
        service: 'iMessage',
        rawIdentifier: 'cathie.campbell@gmail.com',
        normalizedIdentifier: 'cathie.campbell@gmail.com',
        compoundIdentifier: 'cathie.campbell@gmail.com-iMessage',
        batchId: batchId,
      );
      await upgradedDb.insertHandle(
        id: 203,
        sourceRowid: 203,
        service: 'iMessage',
        rawIdentifier: 'cathie.campbell@gmail.com',
        normalizedIdentifier: 'cathie.campbell@gmail.com',
        compoundIdentifier: 'cathie.campbell@gmail.com-iMessage',
        batchId: batchId,
      );

      final db = await upgradedDb.database;
      final rows = await db.query('handles', orderBy: 'id ASC');

      expect(rows, hasLength(2));
      expect(rows.map((row) => row['id']), orderedEquals(<Object?>[22, 203]));

      await upgradedDb.close();
    });
  });
}
