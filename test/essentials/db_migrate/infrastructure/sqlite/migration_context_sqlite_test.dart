import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/db_migrate/infrastructure/sqlite/migration_context_sqlite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('MigrationContextSqlite', () {
    late Directory tempDir;
    late SqfliteImportDatabase importDb;
    late WorkingDatabase workingDb;
    late MigrationContextSqlite context;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'migration_context_sqlite_test',
      );
      importDb = SqfliteImportDatabase(
        databaseDirectory: tempDir.path,
        databaseName: 'import_test.db',
        debugSettings: const ImportDebugSettingsState(),
      );
      workingDb = WorkingDatabase(NativeDatabase.memory());
      context = MigrationContextSqlite(
        importDb: importDb,
        workingDb: workingDb,
        log: (_) {},
      );
    });

    tearDown(() async {
      await workingDb.close();
      await importDb.deleteDatabaseFile();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'ensureImportReady detaches import_preflight after verification',
      () async {
        await context.ensureImportReady('preflight');
        await context.ensureImportClean('postflight');

        final databaseList = await workingDb
            .customSelect('PRAGMA database_list')
            .get();
        final attachmentNames = databaseList
            .map((row) => row.data['name'] as String?)
            .whereType<String>()
            .toList();
        expect(
          attachmentNames.where((name) => name.startsWith('import_')),
          isEmpty,
        );

        final probeTables = await workingDb
            .customSelect(
              "SELECT name FROM sqlite_temp_master WHERE type = 'table' AND name = 'import_preflight_probe'",
            )
            .get();
        expect(probeTables, isEmpty);
      },
    );
  });
}
