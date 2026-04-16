import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/essentials/db/shared/handle_identifier_utils.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/db_migrate/application/migrators/handles_migrator.dart';
import 'package:remember_this_text/essentials/db_migrate/infrastructure/sqlite/migration_context_sqlite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('HandlesMigrator', () {
    late Directory tempDir;
    late SqfliteImportDatabase importDb;
    late WorkingDatabase workingDb;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('handles_migrator_test');
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
      'merges text handles whose fallback identity collides after whitespace removal',
      () async {
        final batchId = await importDb.insertImportBatch(
          startedAtUtc: DateTime.now().toUtc().toIso8601String(),
        );

        await importDb.insertHandle(
          id: 258,
          sourceRowid: 258,
          service: 'SMS',
          rawIdentifier: 'citycenter',
          compoundIdentifier: buildCompoundIdentifier(
            rawIdentifier: 'citycenter',
            service: 'SMS',
          ),
          batchId: batchId,
        );
        await importDb.insertHandle(
          id: 259,
          sourceRowid: 259,
          service: 'SMS',
          rawIdentifier: 'city center',
          compoundIdentifier: buildCompoundIdentifier(
            rawIdentifier: 'city center',
            service: 'SMS',
          ),
          batchId: batchId,
        );

        final context = MigrationContextSqlite(
          importDb: importDb,
          workingDb: workingDb,
          incrementalMode: true,
          log: (_) {},
        );
        final migrator = HandlesMigrator();

        await migrator.validatePrereqs(context);
        await migrator.copy(context);
        await migrator.postValidate(context);

        final canonicalRows = await workingDb.customSelect('''
          SELECT id, raw_identifier, compound_identifier
          FROM handles_canonical
          ORDER BY id ASC
        ''').get();
        expect(canonicalRows, hasLength(1));
        expect(canonicalRows.single.data['id'], 258);
        expect(canonicalRows.single.data['raw_identifier'], 'citycenter');
        expect(
          canonicalRows.single.data['compound_identifier'],
          'citycenter-SMS',
        );

        final aliasRows = await workingDb.customSelect('''
          SELECT source_handle_id, canonical_handle_id, alias_kind, normalized_identifier
          FROM handles_canonical_to_alias
          ORDER BY source_handle_id ASC
        ''').get();
        expect(aliasRows, hasLength(2));
        expect(aliasRows[0].data['source_handle_id'], 258);
        expect(aliasRows[0].data['canonical_handle_id'], 258);
        expect(aliasRows[0].data['alias_kind'], 'canonical');
        expect(aliasRows[1].data['source_handle_id'], 259);
        expect(aliasRows[1].data['canonical_handle_id'], 258);
        expect(aliasRows[1].data['alias_kind'], 'format_variant');
        expect(aliasRows[1].data['normalized_identifier'], 'citycenter');
      },
    );
  });
}
