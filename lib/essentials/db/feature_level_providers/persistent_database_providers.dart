import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../logging/feature_level_providers.dart' show appLoggerProvider;
import '../../source_scoped_import/infrastructure/import_database_provider.dart';
import '../app_database_files.dart';
import '../database_directory.dart';
import '../infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'db_maintenance_lock_provider.dart';

part 'persistent_database_providers.g.dart';

Future<void> _ensureDatabaseDirectoryExists() async {
  final directory = Directory(databaseDirectoryPath);
  if (!directory.existsSync()) {
    await directory.create(recursive: true);
  }
}

/// Provides access to the source-scoped import ledger database.
@Riverpod(keepAlive: true)
Future<ImportDatabase> sourceScopedImportDatabase(
  SourceScopedImportDatabaseRef ref,
) async {
  await _ensureDatabaseDirectoryExists();

  final database = await ImportDatabase.open(
    databaseDirectory: databaseDirectoryPath,
    databaseName: appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
  );

  ref.onDispose(() async {
    await database.close();
  });

  return database;
}

/// Provides access to the source-scoped conversation graph projection database.
@Riverpod(keepAlive: true)
Future<ConversationGraphDatabase> driftConversationGraphDatabase(
  DriftConversationGraphDatabaseRef ref,
) async {
  if (ref.watch(dbMaintenanceLockProvider)) {
    throw StateError(
      '${appDatabaseFileName(AppDatabaseFile.conversationGraph)} is unavailable during database maintenance',
    );
  }

  await _ensureDatabaseDirectoryExists();
  final dbPath = appDatabasePath(
    AppDatabaseFile.conversationGraph,
    databaseDirectory: databaseDirectoryPath,
  );

  final database = ConversationGraphDatabase(
    NativeDatabase.createInBackground(File(dbPath)),
  );
  final logger = ref.read(appLoggerProvider.notifier);

  await database.doWhenOpened((_) async {
    await database.customStatement('PRAGMA foreign_keys = ON');
  });

  ref.onDispose(() async {
    logger.debug(
      'Disposing ConversationGraphDatabase for $dbPath',
      source: 'ConversationGraphDbProvider',
    );
    await database.close();
  });

  return database;
}

/// Provides access to the overlay database for user preferences and customizations.
@Riverpod(keepAlive: true)
Future<OverlayDatabase> overlayDatabase(OverlayDatabaseRef ref) async {
  await _ensureDatabaseDirectoryExists();
  final dbPath = appDatabasePath(
    AppDatabaseFile.overlay,
    databaseDirectory: databaseDirectoryPath,
  );

  final database = OverlayDatabase(
    NativeDatabase.createInBackground(File(dbPath)),
  );

  await database.doWhenOpened((_) async {
    await database.customStatement('PRAGMA foreign_keys = ON');
  });

  ref.onDispose(() async {
    await database.close();
  });

  return database;
}

/// Root path for the content-addressable attachment archive.
///
/// Lives alongside the databases under Application Support:
/// `~/Library/Application Support/com.bigbenchsoftware.MessageLens/attachment_archive/`
@Riverpod(keepAlive: true)
String attachmentArchiveDirectory(AttachmentArchiveDirectoryRef ref) {
  return path.join(databaseDirectoryPath, 'attachment_archive');
}
