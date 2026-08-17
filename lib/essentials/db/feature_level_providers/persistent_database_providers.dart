import 'dart:io';

import 'package:drift/native.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../archive_environment/domain.dart'
    show ArchiveMutationResourceAction;
import '../../archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider, archiveMutationCoordinatorProvider;
import '../../logging/feature_level_providers.dart' show appLoggerProvider;
import '../../presence/infrastructure/data_sources/local/presence_database.dart';
import '../../source_scoped_import/infrastructure/import_database_provider.dart';
import '../app_database_files.dart';
import '../infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'conversation_graph_connection_lifecycle_provider.dart';
import 'db_maintenance_lock_provider.dart';

part 'persistent_database_providers.g.dart';

Future<void> _ensureDatabaseDirectoryExists(String rootPath) async {
  final directory = Directory(rootPath);
  if (!directory.existsSync()) {
    await directory.create(recursive: true);
  }
}

/// Provides access to the source-scoped import ledger database.
@Riverpod(keepAlive: true)
Future<ImportDatabase> sourceScopedImportDatabase(
  SourceScopedImportDatabaseRef ref,
) async {
  final authority = ref.watch(archiveAccessAuthorityProvider);
  await _ensureDatabaseDirectoryExists(authority.rootPath);

  final database = await ImportDatabase.open(
    databaseDirectory: authority.rootPath,
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
  final resourceAdmission = ref
      .read(archiveMutationCoordinatorProvider.notifier)
      .resourceAdmissionForCurrentCaller(
        ArchiveMutationResourceAction.openConversationGraphConnection,
      );
  if (!resourceAdmission.isAllowed) {
    // A provider first requested while blocked observes the signal so it can
    // recover automatically after maintenance releases.
    ref.watch(dbMaintenanceLockProvider);
    throw StateError(
      '${appDatabaseFileName(AppDatabaseFile.conversationGraph)} is unavailable during database maintenance',
    );
  }

  final authority = ref.watch(archiveAccessAuthorityProvider);
  await _ensureDatabaseDirectoryExists(authority.rootPath);
  final dbPath = appDatabasePath(
    AppDatabaseFile.conversationGraph,
    databaseDirectory: authority.rootPath,
  );

  final database = ConversationGraphDatabase(
    NativeDatabase.createInBackground(File(dbPath)),
  );
  final logger = ref.read(appLoggerProvider.notifier);

  await database.doWhenOpened((_) async {
    await database.customStatement('PRAGMA foreign_keys = ON');
  });

  final connectionLifecycle = ref.read(
    conversationGraphConnectionLifecycleProvider,
  );
  connectionLifecycle.register(database);

  ref.onDispose(() async {
    logger.debug(
      'Disposing ConversationGraphDatabase for $dbPath',
      source: 'ConversationGraphDbProvider',
    );
    await connectionLifecycle.release(database);
  });

  return database;
}

/// Provides access to the overlay database for user preferences and customizations.
@Riverpod(keepAlive: true)
Future<OverlayDatabase> overlayDatabase(OverlayDatabaseRef ref) async {
  final authority = ref.watch(archiveAccessAuthorityProvider);
  await _ensureDatabaseDirectoryExists(authority.rootPath);
  final dbPath = appDatabasePath(
    AppDatabaseFile.overlay,
    databaseDirectory: authority.rootPath,
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

/// Provides the durable Schedule/Trip experiment database.
@Riverpod(keepAlive: true)
Future<PresenceDatabase> presenceDatabase(PresenceDatabaseRef ref) async {
  final authority = ref.watch(archiveAccessAuthorityProvider);
  await _ensureDatabaseDirectoryExists(authority.rootPath);
  final dbPath = appDatabasePath(
    AppDatabaseFile.presence,
    databaseDirectory: authority.rootPath,
  );

  final database = PresenceDatabase(
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
/// Lives inside the admitted archive root alongside its databases.
@Riverpod(keepAlive: true)
String attachmentArchiveDirectory(AttachmentArchiveDirectoryRef ref) {
  return ref
      .watch(archiveAccessAuthorityProvider)
      .resolvePath('attachment_archive');
}
