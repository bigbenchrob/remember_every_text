import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../../db/infrastructure/data_sources/local/working/working_database.dart';
import '../../../logging/application/app_logger.dart';

part 'dev_working_database_provider.g.dart';

const String devWorkingDatabaseFileName = 'working_shadow.db';

@Riverpod(keepAlive: true)
Future<WorkingDatabase> devWorkingDatabase(DevWorkingDatabaseRef ref) async {
  final directory = Directory(databaseDirectoryPath);
  if (!directory.existsSync()) {
    await directory.create(recursive: true);
  }

  final dbPath = path.join(databaseDirectoryPath, devWorkingDatabaseFileName);
  final database = _ShadowWorkingDatabase(
    NativeDatabase.createInBackground(File(dbPath)),
  );
  final logger = ref.read(appLoggerProvider.notifier);

  await database.doWhenOpened((_) async {
    await database.customStatement('PRAGMA foreign_keys = ON');
  });

  ref.onDispose(() async {
    logger.debug(
      'Disposing dev WorkingDatabase for $dbPath',
      source: 'DevWorkingDbProvider',
    );
    await database.close();
  });

  return database;
}

class _ShadowWorkingDatabase extends WorkingDatabase {
  _ShadowWorkingDatabase(super.executor);
}
