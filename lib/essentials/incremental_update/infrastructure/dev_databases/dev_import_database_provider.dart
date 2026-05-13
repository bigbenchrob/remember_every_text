import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../../db_importers/application/debug_settings_provider.dart';

part 'dev_import_database_provider.g.dart';

const String devImportDatabaseFileName = 'macos_import_shadow.db';

@Riverpod(keepAlive: true)
Future<SqfliteImportDatabase> devImportDatabase(
  DevImportDatabaseRef ref,
) async {
  final directory = Directory(databaseDirectoryPath);
  if (!directory.existsSync()) {
    await directory.create(recursive: true);
  }

  final database = SqfliteImportDatabase(
    databaseDirectory: databaseDirectoryPath,
    databaseName: devImportDatabaseFileName,
    debugSettings: ref.watch(importDebugSettingsProvider),
  );

  await database.database;

  ref.onDispose(() async {
    await database.close();
  });

  return database;
}
