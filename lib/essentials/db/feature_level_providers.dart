///***************************************************************** */
///* The entry point for dependency injection for the database layer.
///***************************************************************** */

import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../logging/feature_level_providers.dart';
import '../onboarding/application/onboarding_environment_report_provider.dart';
import '../source_scoped_import/feature_level_providers.dart';

import 'application/database_health_audit/database_health_audit_service.dart';
import 'application/database_health_audit/database_health_query_layer.dart';
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

/// The directory where all application databases are stored.
///
/// Initialized once at app startup via [initDatabaseDirectoryPath].
/// Exposed for use by the onboarding existence checker.
/// All DB providers below also use this path.
/// FOR DEVELOPER'S REFERENCE ONLY: path is ~/Library/Application Support/com.bigbenchsoftware.MessageLens/ on macOS.
late final String databaseDirectoryPath;

/// Retired import filename kept only so reset/health diagnostics can identify
/// old files in an existing data folder. This is not a database provider.
const retiredMacosImportDatabaseFileName = 'macos_import.db';

/// Retired working filename kept only so reset/health diagnostics can identify
/// old files in an existing data folder. This is not a database provider.
const retiredWorkingDatabaseFileName = 'working.db';

/// Must be called once in `main()` after `WidgetsFlutterBinding.ensureInitialized()`.
Future<void> initDatabaseDirectoryPath() async {
  final appSupportDir = await getApplicationSupportDirectory();
  databaseDirectoryPath = appSupportDir.path;
}

Future<void> _ensureDatabaseDirectoryExists() async {
  final directory = Directory(databaseDirectoryPath);
  if (!directory.existsSync()) {
    await directory.create(recursive: true);
  }
}

/// Provides access to the source-scoped conversation graph projection database.
@Riverpod(keepAlive: true)
Future<ConversationGraphDatabase> driftConversationGraphDatabase(
  DriftConversationGraphDatabaseRef ref,
) async {
  if (ref.watch(dbMaintenanceLockProvider)) {
    throw StateError(
      '$conversationGraphDatabaseFileName is unavailable during database maintenance',
    );
  }

  await _ensureDatabaseDirectoryExists();
  final dbPath = path.join(
    databaseDirectoryPath,
    conversationGraphDatabaseFileName,
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
  final dbPath = path.join(databaseDirectoryPath, overlayDatabaseFileName);

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
      ReadOnlySqliteFileHealthQueryLayer(
        databaseKey: 'retired_macos_import',
        role: 'retired_macos_import_cleanup',
        databasePath: path.join(
          databaseDirectoryPath,
          retiredMacosImportDatabaseFileName,
        ),
      ),
      ReadOnlySqliteFileHealthQueryLayer(
        databaseKey: 'retired_working',
        role: 'retired_working_cleanup',
        databasePath: path.join(
          databaseDirectoryPath,
          retiredWorkingDatabaseFileName,
        ),
      ),
      SourceScopedImportDatabaseHealthQueryLayer(
        database: sourceScopedImportDb,
        databasePath: path.join(
          databaseDirectoryPath,
          sourceScopedImportDatabaseFileName,
        ),
      ),
      ConversationGraphDatabaseHealthQueryLayer(
        database: conversationGraphDb,
        databasePath: path.join(
          databaseDirectoryPath,
          conversationGraphDatabaseFileName,
        ),
      ),
      OverlayDatabaseHealthQueryLayer(
        database: overlayDb,
        databasePath: path.join(databaseDirectoryPath, overlayDatabaseFileName),
      ),
    ],
  );
}
