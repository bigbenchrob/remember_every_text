import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

import '../../db/app_database_files.dart';
import '../../db/application/read_only_sql_guard.dart';
import '../application/legacy_tester_install_inspector.dart';
import '../domain/archive_environment.dart';
import '../domain/legacy_tester_install_inspection.dart';
import '../domain/native_archive_claim.dart';
import 'file_system_archive_marker_store.dart';

/// Read-only recognizer for the pre-source-scoped tester database generation.
///
/// Native claim validation must establish the canonical production root before
/// this inspector is called. This component never uses current database
/// providers and never creates, migrates, or repairs a store.
final class ReadOnlySqliteLegacyTesterInstallInspector
    implements LegacyTesterInstallInspector {
  const ReadOnlySqliteLegacyTesterInstallInspector();

  static const Set<String> _legacyImportTables = <String>{
    'schema_migrations',
    'import_batches',
    'source_files',
    'import_logs',
    'contacts',
    'contact_phone_email',
    'handles',
    'chats',
    'chat_to_handle',
    'messages',
    'recovered_unlinked_messages',
    'chat_to_message',
    'attachments',
    'message_attachments',
    'recovered_unlinked_message_attachments',
    'reactions',
    'message_links',
    'contact_to_chat_handle',
  };

  static const Set<String> _legacyWorkingTables = <String>{
    'schema_migrations',
    'projection_state',
    'app_settings',
    'handles_canonical',
    'participants',
    'handle_to_participant',
    'handles_canonical_to_alias',
    'chats',
    'chat_to_handle',
    'messages',
    'recovered_unlinked_messages',
    'global_message_index',
    'message_index',
    'contact_message_index',
    'attachments',
    'recovered_unlinked_attachments',
    'reactions',
    'reaction_counts',
    'read_state',
    'message_read_marks',
    'supabase_sync_state',
    'supabase_sync_logs',
  };

  static const Set<String> _legacyOverlayTables = <String>{
    'participant_overrides',
    'chat_overrides',
    'message_annotations',
    'message_user_flags',
    'message_user_tags',
    'handle_to_participant_overrides',
    'virtual_participants',
    'overlay_settings',
    'favorite_contacts',
    'dismissed_handles',
    'handle_visibility_overrides',
    'archived_attachments',
  };

  @override
  Future<LegacyTesterInstallInspection> inspect(
    NativeArchiveClaim claim,
  ) async {
    if (claim.environment != ArchiveEnvironment.production) {
      return const LegacyTesterInstallInspection.notLegacy(
        'Legacy tester recognition is restricted to the canonical production root.',
      );
    }

    final root = Directory(claim.canonicalRootPath);
    if (!root.existsSync() ||
        FileSystemEntity.typeSync(root.path, followLinks: false) !=
            FileSystemEntityType.directory) {
      return const LegacyTesterInstallInspection.notLegacy(
        'The claimed archive root is unavailable or is not a directory.',
      );
    }

    if (File(
      path.join(root.path, FileSystemArchiveMarkerStore.markerFileName),
    ).existsSync()) {
      return const LegacyTesterInstallInspection.notLegacy(
        'A current archive marker is present.',
      );
    }

    final currentOnlyFiles = <String>[
      appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
      appDatabaseFileName(AppDatabaseFile.conversationGraph),
      appDatabaseFileName(AppDatabaseFile.presence),
    ];
    if (currentOnlyFiles.any(
      (fileName) => File(path.join(root.path, fileName)).existsSync(),
    )) {
      return const LegacyTesterInstallInspection.notLegacy(
        'A current source-scoped or Presence database is present.',
      );
    }

    final databaseRequirements = <_LegacyDatabaseRequirement>[
      _LegacyDatabaseRequirement(
        fileName: appDatabaseFileName(AppDatabaseFile.retiredMacosImport),
        schemaVersion: 4,
        requiredTables: _legacyImportTables,
      ),
      _LegacyDatabaseRequirement(
        fileName: appDatabaseFileName(AppDatabaseFile.retiredWorking),
        schemaVersion: 3,
        requiredTables: _legacyWorkingTables,
      ),
      _LegacyDatabaseRequirement(
        fileName: appDatabaseFileName(AppDatabaseFile.overlay),
        schemaVersion: 3,
        requiredTables: _legacyOverlayTables,
      ),
    ];

    for (final requirement in databaseRequirements) {
      final databasePath = path.join(root.path, requirement.fileName);
      if (FileSystemEntity.typeSync(databasePath, followLinks: false) !=
          FileSystemEntityType.file) {
        return LegacyTesterInstallInspection.notLegacy(
          '${requirement.fileName} is absent or is not a regular file.',
        );
      }
    }

    try {
      for (final requirement in databaseRequirements) {
        final matches = _matchesRequirement(
          databasePath: path.join(root.path, requirement.fileName),
          requirement: requirement,
        );
        if (!matches) {
          return LegacyTesterInstallInspection.notLegacy(
            '${requirement.fileName} does not match the required legacy fingerprint.',
          );
        }
      }
    } catch (error) {
      return LegacyTesterInstallInspection.failed(
        'Legacy tester inspection could not prove the database generation: $error',
      );
    }

    return const LegacyTesterInstallInspection.legacyTesterInstall();
  }

  bool _matchesRequirement({
    required String databasePath,
    required _LegacyDatabaseRequirement requirement,
  }) {
    final database = sqlite3.open(databasePath, mode: OpenMode.readOnly);
    try {
      database.execute('PRAGMA query_only = ON;');
      database.execute('PRAGMA busy_timeout = 3000;');

      const versionSql = 'PRAGMA user_version';
      assertReadOnlySql(
        versionSql,
        boundary: 'Legacy tester schema-version inspection',
      );
      final versionRows = database.select(versionSql);
      if (versionRows.length != 1 ||
          versionRows.single.columnAt(0) != requirement.schemaVersion) {
        return false;
      }

      const tableSql = '''
SELECT name FROM sqlite_master
WHERE type = 'table' AND name NOT LIKE 'sqlite_%'
''';
      assertReadOnlySql(
        tableSql,
        boundary: 'Legacy tester table-fingerprint inspection',
      );
      final tableRows = database.select(tableSql);
      final tableNames = <String>{
        for (final row in tableRows) row['name'] as String,
      };
      return tableNames.length == requirement.requiredTables.length &&
          tableNames.containsAll(requirement.requiredTables);
    } finally {
      database.dispose();
    }
  }
}

final class _LegacyDatabaseRequirement {
  const _LegacyDatabaseRequirement({
    required this.fileName,
    required this.schemaVersion,
    required this.requiredTables,
  });

  final String fileName;
  final int schemaVersion;
  final Set<String> requiredTables;
}
