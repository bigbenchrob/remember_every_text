///***************************************************************** */
///* The entry point for dependency injection for the database layer.
///***************************************************************** */

import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../logging/feature_level_providers.dart' show appLoggerProvider;
import '../onboarding/application/onboarding_environment_report_provider.dart';
import '../source_scoped_import/infrastructure/import_database_provider.dart';

import 'app_database_files.dart';
import 'application/database_health_audit/database_health_audit_service.dart';
import 'application/database_health_audit/database_health_database_keys.dart';
import 'application/database_health_audit/database_health_query_layer.dart';
import 'database_directory.dart';
import 'feature_level_providers/db_maintenance_lock_provider.dart';
import 'infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'infrastructure/repositories/database_health_audit_queries.dart';
import 'infrastructure/repositories/filesystem_database_health_audit_report_writer.dart';
import 'infrastructure/repositories/local_database_health_runtime_environment.dart';

export 'feature_level_providers/conversation_graph_readiness_provider.dart';
export 'feature_level_providers/db_maintenance_lock_provider.dart';
export 'feature_level_providers/message_data_version_provider.dart';

part 'feature_level_providers.g.dart';

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

// ─────────────────────────────────────────────────────────────────────────────
// Attachment Archive Directory
// ─────────────────────────────────────────────────────────────────────────────

/// Root path for the content-addressable attachment archive.
///
/// Lives alongside the databases under Application Support:
/// `~/Library/Application Support/com.bigbenchsoftware.MessageLens/attachment_archive/`
@Riverpod(keepAlive: true)
String attachmentArchiveDirectory(AttachmentArchiveDirectoryRef ref) {
  return path.join(databaseDirectoryPath, 'attachment_archive');
}

@Riverpod(keepAlive: true)
Future<DatabaseHealthAuditService> databaseHealthAuditService(
  DatabaseHealthAuditServiceRef ref,
) async {
  final sourceScopedImportDb = await ref.read(
    sourceScopedImportDatabaseProvider.future,
  );
  final conversationGraphDb = await ref.read(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDb = await ref.read(overlayDatabaseProvider.future);
  final hasFullDiskAccess = ref.read(onboardingFullDiskAccessProvider);

  return DatabaseHealthAuditService(
    hasFullDiskAccess: hasFullDiskAccess,
    runtimeEnvironment: const LocalDatabaseHealthRuntimeEnvironment(),
    reportWriter: const FilesystemDatabaseHealthAuditReportWriter(),
    queryLayers: <DatabaseHealthQueryLayer>[
      RetiredCleanupSqliteFileHealthQueryLayer(
        databaseKey: databaseHealthKeyRetiredMacosImport,
        role: databaseHealthRoleRetiredMacosImportCleanup,
        databasePath: appDatabasePath(
          AppDatabaseFile.retiredMacosImport,
          databaseDirectory: databaseDirectoryPath,
        ),
      ),
      RetiredCleanupSqliteFileHealthQueryLayer(
        databaseKey: databaseHealthKeyRetiredWorking,
        role: databaseHealthRoleRetiredWorkingCleanup,
        databasePath: appDatabasePath(
          AppDatabaseFile.retiredWorking,
          databaseDirectory: databaseDirectoryPath,
        ),
      ),
      SourceScopedImportDatabaseHealthQueryLayer(
        database: sourceScopedImportDb,
        databasePath: appDatabasePath(
          AppDatabaseFile.sourceScopedImport,
          databaseDirectory: databaseDirectoryPath,
        ),
      ),
      ConversationGraphDatabaseHealthQueryLayer(
        database: conversationGraphDb,
        databasePath: appDatabasePath(
          AppDatabaseFile.conversationGraph,
          databaseDirectory: databaseDirectoryPath,
        ),
      ),
      OverlayDatabaseHealthQueryLayer(
        database: overlayDb,
        databasePath: appDatabasePath(
          AppDatabaseFile.overlay,
          databaseDirectory: databaseDirectoryPath,
        ),
      ),
    ],
  );
}
