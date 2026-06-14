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
import 'application/retained_archive_metadata_store.dart';
import 'application/retained_database_debug_settings_provider.dart';
import 'feature_level_providers/db_maintenance_lock_provider.dart';
import 'infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'infrastructure/data_sources/local/import/retained_archive_metadata_database.dart';
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

/// Retained storage file for Historical Archives metadata compatibility.
const retainedArchiveMetadataDatabaseFileName = 'macos_import.db';

/// Retained storage file for historical/reference data compatibility.
const retainedHistoricalReferenceDatabaseFileName = 'working.db';

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

/// Provides access to retained archive-source metadata in `macos_import.db`.
@Riverpod(keepAlive: true)
Future<RetainedArchiveMetadataStore> retainedArchiveMetadataStore(
  RetainedArchiveMetadataStoreRef ref,
) async {
  await _ensureDatabaseDirectoryExists();
  final database = RetainedArchiveMetadataDatabase(
    databaseDirectory: databaseDirectoryPath,
    databaseName: retainedArchiveMetadataDatabaseFileName,
    debugSettings: ref.watch(retainedDatabaseDebugSettingsProvider),
  );

  // Ensure the retained metadata file is created immediately so dependent
  // archive-source services can query schema metadata.
  await database.database;

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
        databaseKey: 'import',
        role: 'retained_archive_metadata',
        databasePath: path.join(
          databaseDirectoryPath,
          retainedArchiveMetadataDatabaseFileName,
        ),
      ),
      ReadOnlySqliteFileHealthQueryLayer(
        databaseKey: 'working',
        role: 'retained_historical_reference',
        databasePath: path.join(
          databaseDirectoryPath,
          retainedHistoricalReferenceDatabaseFileName,
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
