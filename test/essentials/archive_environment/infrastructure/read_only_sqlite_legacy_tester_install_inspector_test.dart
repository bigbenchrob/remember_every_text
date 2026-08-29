import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/infrastructure/read_only_sqlite_legacy_tester_install_inspector.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Directory temporaryDirectory;

  setUp(() {
    temporaryDirectory = Directory.systemTemp.createTempSync(
      'legacy-tester-inspector-',
    );
  });

  tearDown(() {
    if (temporaryDirectory.existsSync()) {
      temporaryDirectory.deleteSync(recursive: true);
    }
  });

  test('exact 4/3/3 legacy trio is proven', () async {
    await _createExactLegacyTrio(temporaryDirectory);

    final result = await _inspect(temporaryDirectory);

    expect(result.kind, LegacyTesterInstallInspectionKind.legacyTesterInstall);
  });

  test('optional attachment archive does not invalidate proof', () async {
    await _createExactLegacyTrio(temporaryDirectory);
    await Directory(
      path.join(temporaryDirectory.path, 'attachment_archive'),
    ).create();

    final result = await _inspect(temporaryDirectory);

    expect(result.provesLegacyTesterInstall, isTrue);
  });

  test('optional derived media does not invalidate proof', () async {
    await _createExactLegacyTrio(temporaryDirectory);
    await Directory(
      path.join(temporaryDirectory.path, 'derived_media'),
    ).create();

    final result = await _inspect(temporaryDirectory);

    expect(result.provesLegacyTesterInstall, isTrue);
  });

  test('healthy current marked installation is not legacy', () async {
    await _createExactLegacyTrio(temporaryDirectory);
    await File(
      path.join(temporaryDirectory.path, '.messagelens-archive.json'),
    ).writeAsString('{}');
    await File(
      path.join(temporaryDirectory.path, 'macos_import_ss.db'),
    ).writeAsString('current');

    final result = await _inspect(temporaryDirectory);

    expect(result.kind, LegacyTesterInstallInspectionKind.notLegacy);
  });

  test('ordinary Start Fresh installation is not legacy', () async {
    await File(
      path.join(temporaryDirectory.path, '.messagelens-archive.json'),
    ).writeAsString('{}');
    await _createDatabase(
      path.join(temporaryDirectory.path, 'macos_import_ss.db'),
      version: 10,
      tables: const {'source_registry'},
    );
    await _createDatabase(
      path.join(temporaryDirectory.path, 'working_ss.db'),
      version: 2,
      tables: const {'projection_state'},
    );

    final result = await _inspect(temporaryDirectory);

    expect(result.kind, LegacyTesterInstallInspectionKind.notLegacy);
  });

  test('missing only attachment archive does not establish legacy', () async {
    await File(
      path.join(temporaryDirectory.path, '.messagelens-archive.json'),
    ).writeAsString('{}');
    await File(
      path.join(temporaryDirectory.path, 'macos_import_ss.db'),
    ).writeAsString('current');

    final result = await _inspect(temporaryDirectory);

    expect(result.kind, LegacyTesterInstallInspectionKind.notLegacy);
  });

  test('missing marker alone does not establish legacy', () async {
    await File(
      path.join(temporaryDirectory.path, 'macos_import_ss.db'),
    ).writeAsString('current');
    await File(
      path.join(temporaryDirectory.path, 'working_ss.db'),
    ).writeAsString('current');

    final result = await _inspect(temporaryDirectory);

    expect(result.kind, LegacyTesterInstallInspectionKind.notLegacy);
  });

  test('one or two old databases are not legacy', () async {
    await _createDatabase(
      path.join(temporaryDirectory.path, 'macos_import.db'),
      version: 4,
      tables: _legacyImportTables,
    );
    await _createDatabase(
      path.join(temporaryDirectory.path, 'working.db'),
      version: 3,
      tables: _legacyWorkingTables,
    );

    final result = await _inspect(temporaryDirectory);

    expect(result.kind, LegacyTesterInstallInspectionKind.notLegacy);
  });

  test('wrong legacy schema versions are not legacy', () async {
    await _createExactLegacyTrio(temporaryDirectory, importVersion: 3);

    final result = await _inspect(temporaryDirectory);

    expect(result.kind, LegacyTesterInstallInspectionKind.notLegacy);
  });

  test(
    'right filenames with wrong table fingerprints are not legacy',
    () async {
      await _createExactLegacyTrio(
        temporaryDirectory,
        importTables: const {'schema_migrations'},
      );

      final result = await _inspect(temporaryDirectory);

      expect(result.kind, LegacyTesterInstallInspectionKind.notLegacy);
    },
  );

  test(
    'unexpected application table is not the exact legacy fingerprint',
    () async {
      await _createExactLegacyTrio(temporaryDirectory);
      final database = sqlite3.open(
        path.join(temporaryDirectory.path, 'macos_import.db'),
      );
      try {
        database.execute('CREATE TABLE unexpected_table (id INTEGER);');
      } finally {
        database.dispose();
      }

      final result = await _inspect(temporaryDirectory);

      expect(result.kind, LegacyTesterInstallInspectionKind.notLegacy);
    },
  );

  for (final currentFile in const [
    'macos_import_ss.db',
    'working_ss.db',
    'presence.db',
  ]) {
    test('legacy trio plus $currentFile is not legacy', () async {
      await _createExactLegacyTrio(temporaryDirectory);
      await File(
        path.join(temporaryDirectory.path, currentFile),
      ).writeAsString('current');

      final result = await _inspect(temporaryDirectory);

      expect(result.kind, LegacyTesterInstallInspectionKind.notLegacy);
    });
  }

  test('legacy trio plus current marker is not legacy', () async {
    await _createExactLegacyTrio(temporaryDirectory);
    await File(
      path.join(temporaryDirectory.path, '.messagelens-archive.json'),
    ).writeAsString('{}');

    final result = await _inspect(temporaryDirectory);

    expect(result.kind, LegacyTesterInstallInspectionKind.notLegacy);
  });

  test('current installation with retired residue is not legacy', () async {
    await _createExactLegacyTrio(temporaryDirectory);
    await File(
      path.join(temporaryDirectory.path, '.messagelens-archive.json'),
    ).writeAsString('{}');
    await File(
      path.join(temporaryDirectory.path, 'presence.db'),
    ).writeAsString('current');

    final result = await _inspect(temporaryDirectory);

    expect(result.kind, LegacyTesterInstallInspectionKind.notLegacy);
  });

  test('inspection error fails closed', () async {
    await _createExactLegacyTrio(temporaryDirectory);
    await File(
      path.join(temporaryDirectory.path, 'working.db'),
    ).writeAsString('not sqlite');
    final before = await _snapshot(temporaryDirectory);

    final result = await _inspect(temporaryDirectory);
    final after = await _snapshot(temporaryDirectory);

    expect(result.kind, LegacyTesterInstallInspectionKind.inspectionFailed);
    expect(after, before);
  });

  test('inspection leaves every legacy file byte-identical', () async {
    await _createExactLegacyTrio(temporaryDirectory);
    await File(
      path.join(temporaryDirectory.path, 'unknown-legacy-file'),
    ).writeAsString('untouched');
    final before = await _snapshot(temporaryDirectory);

    final result = await _inspect(temporaryDirectory);
    final after = await _snapshot(temporaryDirectory);

    expect(result.provesLegacyTesterInstall, isTrue);
    expect(after, before);
    expect(
      File(
        path.join(temporaryDirectory.path, '.messagelens-archive.json'),
      ).existsSync(),
      isFalse,
    );
  });

  test('development claim cannot enter legacy tester classification', () async {
    await _createExactLegacyTrio(temporaryDirectory);
    const inspector = ReadOnlySqliteLegacyTesterInstallInspector();

    final result = await inspector.inspect(
      NativeArchiveClaim(
        environment: ArchiveEnvironment.development,
        buildIdentity: ArchiveBuildIdentity.developmentDebug,
        bundleIdentifier:
            ArchiveIdentityValidator.defaultDevelopmentBundleIdentifier,
        productName: ArchiveIdentityValidator.defaultDevelopmentProductName,
        canonicalRootPath: temporaryDirectory.path,
        productionSignatureIsValid: true,
      ),
    );

    expect(result.kind, LegacyTesterInstallInspectionKind.notLegacy);
  });
}

Future<LegacyTesterInstallInspection> _inspect(Directory root) {
  return const ReadOnlySqliteLegacyTesterInstallInspector().inspect(
    NativeArchiveClaim(
      environment: ArchiveEnvironment.production,
      buildIdentity: ArchiveBuildIdentity.productionRelease,
      bundleIdentifier:
          ArchiveIdentityValidator.defaultProductionBundleIdentifier,
      productName: ArchiveIdentityValidator.defaultProductionProductName,
      canonicalRootPath: root.path,
      productionSignatureIsValid: true,
    ),
  );
}

Future<void> _createExactLegacyTrio(
  Directory root, {
  int importVersion = 4,
  Set<String> importTables = _legacyImportTables,
}) async {
  await root.create(recursive: true);
  await _createDatabase(
    path.join(root.path, 'macos_import.db'),
    version: importVersion,
    tables: importTables,
  );
  await _createDatabase(
    path.join(root.path, 'working.db'),
    version: 3,
    tables: _legacyWorkingTables,
  );
  await _createDatabase(
    path.join(root.path, 'user_overlays.db'),
    version: 3,
    tables: _legacyOverlayTables,
  );
}

Future<void> _createDatabase(
  String databasePath, {
  required int version,
  required Set<String> tables,
}) async {
  final database = sqlite3.open(databasePath);
  try {
    database.execute('PRAGMA user_version = $version');
    for (final table in tables) {
      database.execute('CREATE TABLE "$table" (id INTEGER)');
    }
  } finally {
    database.dispose();
  }
}

Future<Map<String, List<int>>> _snapshot(Directory root) async {
  final result = <String, List<int>>{};
  await for (final entity in root.list(followLinks: false)) {
    if (entity is File) {
      result[path.basename(entity.path)] = await entity.readAsBytes();
    }
  }
  return result;
}

const Set<String> _legacyImportTables = {
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

const Set<String> _legacyWorkingTables = {
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

const Set<String> _legacyOverlayTables = {
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
